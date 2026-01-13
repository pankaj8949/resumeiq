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
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  bool _isProfileComplete(UserModel user) {
    return user.displayName != null &&
        user.displayName!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.location != null &&
        user.location!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return const SplashPage();
    }

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
