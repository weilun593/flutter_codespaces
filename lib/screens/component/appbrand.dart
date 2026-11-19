import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppBrand extends StatelessWidget {
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