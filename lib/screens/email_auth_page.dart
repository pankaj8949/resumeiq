import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class EmailAuthPage extends ConsumerStatefulWidget {
  const EmailAuthPage({super.key});

  @override
  ConsumerState<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends ConsumerState<EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    if (!_isSignUp) return null;
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (_isSignUp) return Validators.password(value);
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final notifier = ref.read(authNotifierProvider.notifier);
    final ok = _isSignUp
        ? await notifier.signUpWithEmailAndPassword(email: email, password: password)
        : await notifier.signInWithEmailAndPassword(email: email, password: password);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? (_isSignUp ? 'Sign up failed' : 'Sign in failed')),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create account' : 'Sign in'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _isSignUp ? Icons.person_add_alt_1 : Icons.lock_outline,
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _isSignUp ? 'Sign up with email' : 'Sign in with email',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Create your account to start building your resume'
                      : 'Welcome back — sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                  validator: _passwordValidator,
                  enabled: !authState.isLoading,
                  onFieldSubmitted: (_) => _isSignUp ? null : _submit(),
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                }),
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: _confirmPasswordValidator,
                    enabled: !authState.isLoading,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isSignUp ? 'Create account' : 'Sign in'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => setState(() {
                            _isSignUp = !_isSignUp;
                          }),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'Don’t have an account? Create one',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Password must be at least 8 characters and include uppercase, lowercase, and a number.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

