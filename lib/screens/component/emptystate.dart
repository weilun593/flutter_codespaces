import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/note.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.hasSearch, required this.onCreate});

  final bool hasSearch;
  final Future<void> Function([Note?]) onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 58, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
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
            hasSearch ? '沒有找到相符的紀錄' : '這裡還是空的',
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