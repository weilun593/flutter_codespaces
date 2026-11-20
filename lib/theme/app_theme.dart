import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppColors {
  AppColors._();

  static const ink = Color(0xFF202331);
  static const mutedInk = Color(0xFF6E7180);
  static const paper = Color(0xFFF8F7F3);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE8E6DF);
  static const indigo = Color(0xFF5367D9);
  static const indigoDark = Color(0xFF3546A4);
  static const coral = Color(0xFFF08E79);
  static const mint = Color(0xFF74B7A5);
  static const mustard = Color(0xFFE7B655);
  static const lavender = Color(0xFF9A83C9);
  static const darkInk = Color(0xFFF2F1ED);
  static const darkMutedInk = Color(0xFFB2B3BD);
  static const darkPaper = Color(0xFF171922);
  static const darkSurface = Color(0xFF222530);
  static const darkLine = Color(0xFF383B48);

  static const noteColors = <String, Color>{
    'indigo': indigo,
    'coral': coral,
    'mint': mint,
    'mustard': mustard,
    'lavender': lavender,
  };

  static Color noteColor(String key) => noteColors[key] ?? indigo;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return _buildTheme(isDark: false);
  }

  static ThemeData dark() {
    return _buildTheme(isDark: true);
  }

  static ThemeData _buildTheme({required bool isDark}) {
    final background = isDark ? AppColors.darkPaper : AppColors.paper;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final foreground = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedForeground =
        isDark ? AppColors.darkMutedInk : AppColors.mutedInk;
    final outline = isDark ? AppColors.darkLine : AppColors.line;
    final primary = isDark ? const Color(0xFF9AA8FF) : AppColors.indigo;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        onPrimary: isDark ? AppColors.darkPaper : Colors.white,
        surface: background,
        onSurface: foreground,
        onSurfaceVariant: mutedForeground,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Arial',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: TextStyle(
          color: mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: foreground,
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        headlineSmall: TextStyle(
          color: foreground,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: foreground,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: foreground, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(
          color: mutedForeground,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}

class ThemeModeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggle() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeModeController>();
    return IconButton(
      tooltip: controller.isDark ? '切換淺色模式' : '切換深色模式',
      onPressed: controller.toggle,
      icon: Icon(controller.isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
