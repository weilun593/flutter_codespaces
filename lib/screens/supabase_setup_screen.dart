import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SupabaseSetupScreen extends StatelessWidget {
  const SupabaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.indigo,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Notely 還差最後一步', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text(
                      '目前尚未設定 Supabase，所以登入與雲端筆記功能還不能啟用。',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text('請在專案根目錄執行：', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _CodeLine('flutter run -d chrome \\'),
                    _CodeLine(
                      '  --dart-define=SUPABASE_URL=https://你的專案.supabase.co \\',
                    ),
                    _CodeLine(
                      '  --dart-define=SUPABASE_PUBLISHABLE_KEY=你的_publishable_key',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '第一次啟動前，也請把 supabase/schema.sql 貼到 Supabase SQL Editor 執行。',
                      style: theme.textTheme.bodyMedium,
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

class _CodeLine extends StatelessWidget {
  const _CodeLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFFF1F0EB),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
