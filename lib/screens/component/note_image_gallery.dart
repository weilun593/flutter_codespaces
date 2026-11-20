import 'package:flutter/material.dart';

import 'note_image_preview_dialog.dart';

class NoteImageGallery extends StatelessWidget {
  const NoteImageGallery({
    required this.imageUrls,
    this.onRemove,
    this.maxHeight = 180,
    super.key,
  });

  final List<String> imageUrls;
  final ValueChanged<String>? onRemove;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: imageUrls.map((url) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => NoteImagePreviewDialog(imageUrl: url),
                  ),
                  child: Image.network(
                    url,
                    width: 220,
                    height: maxHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 220,
                      height: maxHeight,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filledTonal(
                  tooltip: '移除圖片',
                  onPressed: () => onRemove!(url),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}