import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_helper.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';
import '../theme/app_theme.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NotesRepository _repository;
  final _searchController = TextEditingController();
  List<Note> _notes = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = NotesRepository(Supabase.instance.client);
    _searchController.addListener(() => setState(() {}));
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final notes = await _repository.fetchNotes();
      if (mounted) setState(() => _notes = notes);
    } on PostgrestException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyDatabaseError(error.message));
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = '目前無法載入筆記，請稍後再試。');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Note> get _filteredNotes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _notes;
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query) ||
              note.tag.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _openEditor([Note? note]) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (result == null || !mounted) return;
    await _loadNotes();
    _showMessage(note == null ? '筆記已建立' : '筆記已更新');
  }

  Future<void> _deleteNote(Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('刪除這篇筆記？'),
        content: Text('「${note.title}」刪除後就不能復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await _repository.deleteNote(note.id);
      if (!mounted) return;
      setState(
        () => _notes = _notes.where((item) => item.id != note.id).toList(),
      );
      _showMessage('筆記已刪除');
    } on PostgrestException catch (error) {
      if (mounted) _showMessage(_friendlyDatabaseError(error.message));
    }
  }

  /*Future<void> _checkIn() async {
    await Supabase.instance.client.auth.signOut();
  }*/

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  String _friendlyDatabaseError(String message) {
    if (message.toLowerCase().contains('relation') &&
        message.toLowerCase().contains('does not exist')) {
      return '找不到 notes 資料表，請先執行 supabase/schema.sql。';
    }
    if (message.toLowerCase().contains('permission')) {
      return '沒有存取筆記的權限，請檢查 RLS 設定。';
    }
    return message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final filteredNotes = _filteredNotes;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 860;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: isWide ? 32 : 20,
        title: const _AppBrand(),
        actions: [
          if (isWide) ...[
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 18),
          ],
          IconButton(
            tooltip: '打卡',
            onPressed: () async {
              try {
                Position position = await LocationHelper.determinePosition();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('緯度: ${position.latitude}, 經度: ${position.longitude}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('發生錯誤: $e'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          IconButton(
            tooltip: '登出',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          SizedBox(width: isWide ? 28 : 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('新增筆記'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isWide ? 32 : 20,
            12,
            isWide ? 32 : 20,
            120,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: _HomeContent(
                  userEmail: user?.email,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  notes: filteredNotes,
                  totalNotes: _notes.length,
                  searchController: _searchController,
                  onRetry: _loadNotes,
                  onOpenEditor: _openEditor,
                  onDelete: _deleteNote,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.userEmail,
    required this.isLoading,
    required this.errorMessage,
    required this.notes,
    required this.totalNotes,
    required this.searchController,
    required this.onRetry,
    required this.onOpenEditor,
    required this.onDelete,
  });

  final String? userEmail;
  final bool isLoading;
  final String? errorMessage;
  final List<Note> notes;
  final int totalNotes;
  final TextEditingController searchController;
  final VoidCallback onRetry;
  final Future<void> Function([Note?]) onOpenEditor;
  final Future<void> Function(Note) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greetingName = userEmail?.split('@').first ?? '朋友';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('早安，$greetingName', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          totalNotes == 0 ? '今天想記下什麼？' : '把腦中的想法，整理成下一步。',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.mutedInk),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: '搜尋你的筆記…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: '清除搜尋',
                    onPressed: searchController.clear,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Text('你的筆記', style: theme.textTheme.titleLarge),
            const SizedBox(width: 10),
            if (totalNotes > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalNotes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.indigoDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorMessage != null)
          _ErrorState(message: errorMessage!, onRetry: onRetry)
        else if (notes.isEmpty)
          _EmptyState(
            hasSearch: searchController.text.isNotEmpty,
            onCreate: onOpenEditor,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: notes
                    .map(
                      (note) => SizedBox(
                        width: cardWidth,
                        child: _NoteCard(
                          note: note,
                          onTap: () => onOpenEditor(note),
                          onDelete: () => onDelete(note),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Text('Notely', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.noteColor(note.color);
    final theme = Theme.of(context);
    final preview = note.content.replaceAll('\n', ' ').trim();
    final date = '${note.updatedAt.month}/${note.updatedAt.day}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 7, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          if (note.isPinned)
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 17,
                              color: AppColors.indigo,
                            ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 19,
                            tooltip: '更多選項',
                            onSelected: (value) {
                              if (value == 'delete') onDelete();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('刪除筆記'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        preview.isEmpty ? '還沒有內容' : preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              note.tag,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            date,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onCreate});

  final bool hasSearch;
  final Future<void> Function([Note?]) onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 58, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.edit_note_rounded,
            size: 48,
            color: AppColors.indigo.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? '沒有找到相符的筆記' : '這裡還是空的',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            hasSearch ? '換個關鍵字試試看。' : '把腦中的第一個想法寫下來吧。',
            style: theme.textTheme.bodyMedium,
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('寫下第一篇'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3C8BD)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 38, color: AppColors.coral),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('重新載入')),
        ],
      ),
    );
  }
}
