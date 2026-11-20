import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/note.dart';
import '../repositories/notes_repository.dart';
import '../theme/app_theme.dart';
import '../utils/location_helper.dart';
import '../utils/note_content.dart';
import '../utils/note_image_helper.dart';
import 'component/note_image_gallery.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final NotesRepository _repository;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  late final List<String> _imageUrls;
  late final List<String> _originalImageUrls;
  final List<String> _uploadedImageUrls = [];
  late String _selectedColor;
  late bool _isPinned;
  bool _isSaving = false;
  bool _isCheckingIn = false;
  bool _isUploadingImage = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _repository = NotesRepository(Supabase.instance.client);
    _imageUrls = NoteContent.imageUrls(widget.note?.content ?? '');
    _originalImageUrls = List.unmodifiable(_imageUrls);
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: NoteContent.text(widget.note?.content ?? ''),
    );
    _tagController = TextEditingController(text: widget.note?.tag ?? '靈感');
    _selectedColor = widget.note?.color ?? 'indigo';
    _isPinned = widget.note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('請先為筆記寫個標題。');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final note = Note(
        id: widget.note?.id ?? '',
        userId:
            widget.note?.userId ??
            Supabase.instance.client.auth.currentUser!.id,
        title: title,
        content: NoteContent.withImages(_contentController.text, _imageUrls),
        tag: _tagController.text.trim().isEmpty
            ? '未分類'
            : _tagController.text.trim(),
        color: _selectedColor,
        isPinned: _isPinned,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await _repository.updateNote(note);
      } else {
        await _repository.createNote(
          ownerId: Supabase.instance.client.auth.currentUser!.id,
          draft: note,
        );
      }
      final retainedUrls = _imageUrls.toSet();
      final removedUrls = {
        ..._originalImageUrls,
        ..._uploadedImageUrls,
      }.difference(retainedUrls).toList();
      if (removedUrls.isNotEmpty) {
        try {
          await _repository.deleteNoteImages(removedUrls);
        } catch (_) {
          // A failed cleanup leaves an unused file but does not undo the note save.
        }
      }
      if (mounted) Navigator.of(context).pop(note);
    } on PostgrestException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('儲存失敗，請檢查網路後再試。');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _insertCheckIn() async {
    setState(() => _isCheckingIn = true);
    try {
      final position = await LocationHelper.determinePosition();
      if (!mounted) return;
      final selection = _contentController.selection;
      final start = selection.isValid
          ? selection.start
          : _contentController.text.length;
      final end = selection.isValid ? selection.end : start;
      final text = _contentController.text;
      final prefix = start > 0 && text[start - 1] != '\n' ? '\n\n' : '';
      final suffix = end < text.length && text[end] != '\n' ? '\n' : '';
      final coordinates = '打卡座標\n'
          '緯度: ${position.latitude.toStringAsFixed(6)}\n'
          '經度: ${position.longitude.toStringAsFixed(6)}';
      final insertion = '$prefix$coordinates$suffix';
      _contentController.value = TextEditingValue(
        text: text.replaceRange(start, end, insertion),
        selection: TextSelection.collapsed(offset: start + insertion.length),
      );
    } catch (error) {
      if (mounted) _showMessage('無法取得打卡位置：$error');
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ownerId = Supabase.instance.client.auth.currentUser!.id;
      setState(() => _isUploadingImage = true);
      final url = await NoteImageHelper.pickAndUpload(
        repository: _repository,
        ownerId: ownerId,
      );
      if (url == null || !mounted) return;
      setState(() {
        _imageUrls.add(url);
        _uploadedImageUrls.add(url);
      });
    } catch (error) {
      if (mounted) _showMessage('圖片上傳失敗：$error');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
            onPressed: _isSaving || _isCheckingIn || _isUploadingImage
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(_isEditing ? '編輯筆記' : '新增筆記'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
                onPressed: _isSaving || _isCheckingIn || _isUploadingImage
                  ? null
                  : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 19),
              label: const Text('儲存'),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(isWide ? 36 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      autofocus: !_isEditing,
                      textInputAction: TextInputAction.next,
                      style: theme.textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: '筆記標題',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const Divider(height: 30),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSaving || _isCheckingIn
                              ? null
                              : _insertCheckIn,
                          icon: _isCheckingIn
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.location_on_outlined),
                          label: const Text('插入打卡座標'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSaving || _isUploadingImage
                              ? null
                              : _pickImage,
                          icon: _isUploadingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(_isUploadingImage ? '圖片上傳中' : '上傳圖片'),
                        ),
                      ],
                    ),
                    if (_imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      NoteImageGallery(
                        imageUrls: _imageUrls,
                        onRemove: (url) => setState(() => _imageUrls.remove(url)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _contentController,
                      minLines: 10,
                      maxLines: 18,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: '開始寫下你的想法…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: isWide ? 240 : 200,
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: '分類標籤',
                              prefixIcon: Icon(Icons.sell_outlined),
                              isDense: true,
                            ),
                          ),
                        ),
                        _ColorPicker(
                          selectedColor: _selectedColor,
                          onChanged: (color) =>
                              setState(() => _selectedColor = color),
                        ),
                        FilterChip(
                          selected: _isPinned,
                          onSelected: (value) =>
                              setState(() => _isPinned = value),
                          avatar: Icon(
                            _isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            size: 18,
                          ),
                          label: const Text('置頂'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selectedColor, required this.onChanged});

  final String selectedColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppColors.noteColors.entries.map((entry) {
        final selected = entry.key == selectedColor;
        return Tooltip(
          message: '筆記顏色',
          child: GestureDetector(
            onTap: () => onChanged(entry.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 3,
                      )
                    : Border.all(color: Colors.transparent, width: 3),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
