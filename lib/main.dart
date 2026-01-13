import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/user_model.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_page.dart';
import 'screens/profile_setup_page.dart';
import 'screens/main_navigation_page.dart';
import 'screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  runApp(const ProviderScope(child: ResumeIQApp()));
}

class ResumeIQApp extends StatelessWidget {
  const ResumeIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResumeIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper to handle authentication state
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasCompletedInitialAuthCheck = false;

  bool _isProfileComplete(UserModel user) {
    return user.displayName != null &&
        user.displayName!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.location != null &&
        user.location!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Mark when initial auth check completes (loading becomes false for first time)
    if (!authState.isLoading && !_hasCompletedInitialAuthCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasCompletedInitialAuthCheck = true;
          });
        }
      });
    }

    // Show splash screen ONLY during initial auth check (before we know if user exists)
    // After initial check, show login page even if loading during sign-in
    if (authState.isLoading && !_hasCompletedInitialAuthCheck) {
      return const SplashPage();
    }

    // Show login page if no user (including during sign-in loading)
    if (authState.user == null) {
      return const LoginPage();
    }

    // Check if profile is complete
    if (!_isProfileComplete(authState.user!)) {
      return const ProfileSetupPage();
    }

    return const MainNavigationPage();
  }
}
