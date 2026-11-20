import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationCoordinatesDialog extends StatelessWidget {
  const LocationCoordinatesDialog({required this.position, super.key});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: const Icon(Icons.location_on_rounded),
      title: const Text('打卡位置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('緯度', style: theme.textTheme.labelLarge),
          SelectableText(position.latitude.toStringAsFixed(6)),
          const SizedBox(height: 12),
          Text('經度', style: theme.textTheme.labelLarge),
          SelectableText(position.longitude.toStringAsFixed(6)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('關閉'),
        ),
      ],
    );
  }
}