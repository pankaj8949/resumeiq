import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/resume_provider.dart';
import '../providers/ads_provider.dart';
import '../ads/interstitial_ad_service.dart';
import '../widgets/admob_banner.dart';
import 'resume_builder_page.dart';
import 'resume_scoring_page.dart';
import 'mock_interview_page.dart';
import 'profile_page.dart';

/// Provider for managing navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation page with bottom navigation bar
class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  @override
  void initState() {
    super.initState();

    // Preload interstitial so it can show quickly on Score/Interview tab.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final enabled = ref.read(adsEnabledProvider);
      if (!enabled) return;
      final unitId = ref.read(interstitialAdUnitIdProvider);
      // ignore: unawaited_futures
      InterstitialAdService.load(adUnitId: unitId);
    });
  }

  void _maybeShowTabInterstitial(int nextIndex) {
    final enabled = ref.read(adsEnabledProvider);
    if (!enabled) return;

    // Only show interstitial when entering Score or Interview tabs.
    if (nextIndex != 2 && nextIndex != 3) return;

    final unitId = ref.read(interstitialAdUnitIdProvider);
    InterstitialAdService.showIfAvailable(
      adUnitId: unitId,
      minInterval: const Duration(seconds: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    // If Firestore changes the interstitial unit id, preload the new one.
    // (Riverpod requires `ref.listen` to be called during build.)
    ref.listen<String>(interstitialAdUnitIdProvider, (prev, next) {
      final enabled = ref.read(adsEnabledProvider);
      if (!enabled) return;
      // ignore: unawaited_futures
      InterstitialAdService.load(adUnitId: next);
    });

    final pages = [
      const DashboardContentPage(),
      const ResumeBuilderPage(),
      const ResumeScoringPage(),
      const MockInterviewPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner on the Home tab (change this condition to show on other tabs too)
            if (currentIndex == 0) const AdMobBanner(),
            NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                _maybeShowTabInterstitial(index);
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
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard content without AppBar (since it's in MainNavigationPage)
class DashboardContentPage extends ConsumerStatefulWidget {
  const DashboardContentPage({super.key});

  @override
  ConsumerState<DashboardContentPage> createState() =>
      _DashboardContentPageState();
}

class _DashboardContentPageState extends ConsumerState<DashboardContentPage> {
  @override
  void initState() {
    super.initState();
    // Load resumes when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(resumeNotifierProvider.notifier).loadUserResumes(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final resumeState = ref.watch(resumeNotifierProvider);

    // Calculate resume counts
    final totalResumes = resumeState.resumes.length;
    final scoredResumes = resumeState.resumes
        .where((r) => r.score != null)
        .length;

    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (now scrollable with page)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.surfaceColor,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              user?.displayName?.isNotEmpty == true
                                  ? user!.displayName![0].toUpperCase()
                                  : (user?.email != null
                                        ? user!.email[0].toUpperCase()
                                        : 'U'),
                              style: TextStyle(
                                fontSize: 20,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hello, ${user?.displayName?.isNotEmpty == true ? user!.displayName!.split(' ').first : (user?.email != null ? user!.email.split('@').first : 'User')}!',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.textTertiary,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        // Handle notification tap
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Stats Section
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.description,
                          value: '$totalResumes',
                          label: 'Resumes',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth > 400 ? 16 : 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.assessment,
                          value: '$scoredResumes',
                          label: 'Scored',
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid: 2 columns on mobile, 3 on tablet, 4 on desktop
                  final crossAxisCount = constraints.maxWidth > 600
                      ? (constraints.maxWidth > 900 ? 4 : 3)
                      : 2;
                  final aspectRatio = constraints.maxWidth > 600 ? 1.0 : 1.15;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                    children: [
                      _FeatureCard(
                        icon: Icons.edit_document,
                        title: 'Build Resume',
                        description: 'Create an ATS-optimized resume',
                        color: AppTheme.primaryColor,
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state = 1;
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.assessment,
                        title: 'Score Resume',
                        description: 'Get AI-powered resume analysis',
                        color: AppTheme.successColor,
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state = 2;
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.chat_bubble,
                        title: 'Mock Interview',
                        description: 'Practice with AI interviews',
                        color: AppTheme.warningColor,
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state = 3;
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.person,
                        title: 'Profile',
                        description: 'View and edit your profile',
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state = 4;
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Tip',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Complete your profile to build better resumes. Add your education, experience, and skills for personalized resume suggestions.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    if (user?.displayName == null ||
                        user!.displayName!.isEmpty) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(navigationIndexProvider.notifier).state = 4;
                        },
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Complete Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 150;
        final padding = isSmall ? 12.0 : 16.0;
        final iconSize = isSmall ? 20.0 : 24.0;
        final iconPadding = isSmall ? 6.0 : 8.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 200;
        final iconSize = isSmall ? 28.0 : 32.0;
        final iconPadding = isSmall ? 10.0 : 12.0;
        final cardPadding = isSmall ? 12.0 : 16.0;
        final titleFontSize = isSmall ? 14.0 : 16.0;
        final descriptionFontSize = isSmall ? 11.0 : 12.0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: iconSize, color: color),
                    ),
                  ),
                  SizedBox(height: isSmall ? 12 : 16),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isSmall ? 6 : 8),
                  Flexible(
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: descriptionFontSize,
                      ),
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
      },
    );
  }
}
