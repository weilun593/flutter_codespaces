import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, required this.onRetry});

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
