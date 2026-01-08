import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resume_builder/presentation/pages/resume_builder_page.dart';
import '../../../resume_scoring/presentation/pages/resume_scoring_page.dart';
import '../../../mock_interview/presentation/pages/mock_interview_page.dart';
import 'resume_history_page.dart';

/// Provider for managing navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation page with bottom navigation bar
class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final pages = [
      const DashboardContentPage(),
      const ResumeBuilderPage(),
      const ResumeScoringPage(),
      const MockInterviewPage(),
      const ResumeHistoryPage(),
    ];

    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(
              title: const Text('ResumeIQ'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await ref.read(authNotifierProvider.notifier).signOut();
                    }
                  },
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Build',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Score',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Interview',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// Dashboard content without AppBar (since it's in MainNavigationPage)
class DashboardContentPage extends ConsumerWidget {
  const DashboardContentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? user?.email ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _FeatureCard(
                  icon: Icons.edit_document,
                  title: 'Build Resume',
                  description: 'Create an ATS-optimized resume',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // Navigate to Build Resume tab
                    ref.read(navigationIndexProvider.notifier).state = 1;
                  },
                ),
                _FeatureCard(
                  icon: Icons.assessment,
                  title: 'Score Resume',
                  description: 'Get AI-powered resume analysis',
                  color: AppTheme.successColor,
                  onTap: () {
                    // Navigate to Score Resume tab
                    ref.read(navigationIndexProvider.notifier).state = 2;
                  },
                ),
                _FeatureCard(
                  icon: Icons.chat_bubble,
                  title: 'Mock Interview',
                  description: 'Practice with AI interviews',
                  color: AppTheme.warningColor,
                  onTap: () {
                    // Navigate to Mock Interview tab
                    ref.read(navigationIndexProvider.notifier).state = 3;
                  },
                ),
                _FeatureCard(
                  icon: Icons.history,
                  title: 'Resume History',
                  description: 'View all your saved resumes',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    // Navigate to History tab
                    ref.read(navigationIndexProvider.notifier).state = 4;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

