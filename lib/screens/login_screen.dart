import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isRegisterMode) {
        final response = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        if (response.session == null) {
          _showMessage('註冊完成，請到信箱點擊驗證連結後再登入。');
          setState(() => _isRegisterMode = false);
        }
      } else {
        await auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(_friendlyAuthError(error.message));
    } catch (_) {
      if (mounted) _showMessage('目前無法連線，請稍後再試。');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) return 'Email 或密碼不正確。';
    if (lower.contains('email not confirmed')) return '請先到信箱完成驗證。';
    if (lower.contains('user already registered')) return '這個 Email 已經註冊過了。';
    if (lower.contains('password should be at least')) return '密碼至少需要 6 個字元。';
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final loginCard = _LoginCard(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      isRegisterMode: _isRegisterMode,
      isLoading: _isLoading,
      obscurePassword: _obscurePassword,
      onSubmit: _submit,
      onTogglePassword: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      onToggleMode: () => setState(() => _isRegisterMode = !_isRegisterMode),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: _WelcomePanel()),
                        const SizedBox(width: 72),
                        Expanded(child: loginCard),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _BrandMark(compact: true),
                        const SizedBox(height: 28),
                        loginCard,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandMark(),
        const SizedBox(height: 36),
        Text('把想法留在\n一個安靜的地方。', style: theme.textTheme.displaySmall),
        const SizedBox(height: 18),
        Text(
          'Notely 是你的日常筆記桌。\n記下靈感、整理計畫，隨時在雲端找到它們。',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.mutedInk),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            _Feature(icon: Icons.cloud_done_outlined, label: '安全同步'),
            const SizedBox(width: 20),
            _Feature(icon: Icons.search_rounded, label: '快速找到'),
          ],
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.indigo),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge
        ?.copyWith(fontSize: compact ? 22 : 24, letterSpacing: -0.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 42 : 48,
          height: compact ? 42 : 48,
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text('Notely', style: textStyle),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isRegisterMode,
    required this.isLoading,
    required this.obscurePassword,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onToggleMode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isRegisterMode;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRegisterMode ? '建立你的帳號' : '歡迎回來',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                isRegisterMode ? '註冊後，你的筆記會自動安全同步。' : '登入後繼續整理你的思緒。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '請輸入 Email';
                  if (!value.contains('@')) return '請輸入有效的 Email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: '密碼',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '請輸入密碼';
                  if (value.length < 6) return '密碼至少需要 6 個字元';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isRegisterMode ? '註冊並開始' : '登入 Notely'),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : onToggleMode,
                  child: Text(isRegisterMode ? '已經有帳號？登入' : '還沒有帳號？立即註冊'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
