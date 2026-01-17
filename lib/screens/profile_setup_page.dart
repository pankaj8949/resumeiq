import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile_completion/presentation/profile_completion_flow_page.dart';

/// Step-based profile completion flow shown after login.
///
/// The actual flow implementation lives under `lib/features/profile_completion/`.
class ProfileSetupPage extends ConsumerWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProfileCompletionFlowPage();
  }
}
