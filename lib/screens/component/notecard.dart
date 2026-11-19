import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
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