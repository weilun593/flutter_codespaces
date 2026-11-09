import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './core/app_config.dart';
import 'screens/auth_gate.dart';
import 'screens/supabase_setup_screen.dart';
import 'theme/app_theme.dart';
//test
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  runApp(const NotelyApp());
}

class NotelyApp extends StatelessWidget {
  const NotelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppConfig.isConfigured
          ? const AuthGate()
          : const SupabaseSetupScreen(),
    );
  }
}
