import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resume_builder/presentation/providers/resume_provider.dart';
import '../../../resume_builder/presentation/pages/resume_builder_page.dart';
import '../../../resume_builder/presentation/pages/resume_preview_page.dart';

class ResumeHistoryPage extends ConsumerStatefulWidget {
  const ResumeHistoryPage({super.key});

  @override
  ConsumerState<ResumeHistoryPage> createState() => _ResumeHistoryPageState();
}

class _ResumeHistoryPageState extends ConsumerState<ResumeHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(resumeNotifierProvider.notifier).loadUserResumes(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    if (resumeState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resume History')),
        body: const LoadingWidget(),
      );
    }

    if (resumeState.resumes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resume History')),
        body: EmptyStateWidget(
          icon: Icons.description,
          title: 'No Resumes Yet',
          message: 'Create your first resume to get started',
          action: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ResumeBuilderPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Resume'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ResumeBuilderPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(resumeNotifierProvider.notifier).loadUserResumes(user.id);
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: resumeState.resumes.length,
          itemBuilder: (context, index) {
            final resume = resumeState.resumes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getScoreColor(resume.score ?? 0),
                  child: Text(
                    '${resume.score ?? '?'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(resume.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.updatedAt != null)
                      Text(
                        'Updated ${AppDateUtils.DateUtils.getRelativeTime(resume.updatedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (resume.personalInfo != null)
                      Text(
                        resume.personalInfo!.fullName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResumeBuilderPage(resumeId: resume.id),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(resume.id, resume.title);
                    }
                  },
                ),
                onTap: () {
                  // Open resume in preview mode by default
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResumePreviewPage(resumeId: resume.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(String resumeId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop(); // Close confirmation dialog
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              final success = await ref.read(resumeNotifierProvider.notifier).deleteResume(resumeId);
              
              // Get current state before using context
              final currentError = ref.read(resumeNotifierProvider).error;
              
              if (!mounted) return;
              
              // Close loading indicator
              navigator.pop();
              
              if (!mounted) return;
              
              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('"$title" deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(currentError ?? 'Failed to delete resume'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

