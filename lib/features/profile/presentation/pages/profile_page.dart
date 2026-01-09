import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;
import '../../../auth/presentation/providers/auth_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('No user data available'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Text(
                                    user.displayName?.isNotEmpty == true
                                        ? user.displayName![0].toUpperCase()
                                        : user.email[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.displayName ?? 'No Name',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (user.email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Professional Summary
                  if (user.summary != null && user.summary!.isNotEmpty) ...[
                    Text(
                      'Professional Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          user.summary!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Contact Information
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        if (user.phone != null && user.phone!.isNotEmpty)
                          _ProfileInfoTile(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: user.phone!,
                          ),
                        if (user.location != null && user.location!.isNotEmpty)
                          _ProfileInfoTile(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: user.location!,
                          ),
                        if (user.linkedInUrl != null && user.linkedInUrl!.isNotEmpty)
                          _ProfileInfoTile(
                            icon: Icons.business,
                            label: 'LinkedIn',
                            value: user.linkedInUrl!,
                            isUrl: true,
                          ),
                        if (user.portfolioUrl != null && user.portfolioUrl!.isNotEmpty)
                          _ProfileInfoTile(
                            icon: Icons.public,
                            label: 'Portfolio',
                            value: user.portfolioUrl!,
                            isUrl: true,
                          ),
                        if (user.githubUrl != null && user.githubUrl!.isNotEmpty)
                          _ProfileInfoTile(
                            icon: Icons.code,
                            label: 'GitHub',
                            value: user.githubUrl!,
                            isUrl: true,
                          ),
                        if ((user.phone == null || user.phone!.isEmpty) &&
                            (user.location == null || user.location!.isEmpty) &&
                            (user.linkedInUrl == null || user.linkedInUrl!.isEmpty) &&
                            (user.portfolioUrl == null || user.portfolioUrl!.isEmpty) &&
                            (user.githubUrl == null || user.githubUrl!.isEmpty))
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No contact information added yet. Tap the edit button to add your details.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Education
                  if (user.education.isNotEmpty) ...[
                    Text(
                      'Education',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...user.education.map((edu) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                            title: Text(edu.degree),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(edu.institution),
                                if (edu.fieldOfStudy != null) Text(edu.fieldOfStudy!),
                                if (edu.startDate != null || edu.endDate != null)
                                  Text(
                                    '${edu.startDate != null ? AppDateUtils.DateUtils.formatDate(edu.startDate!, format: 'MMM yyyy') : ''} - ${edu.endDate != null ? AppDateUtils.DateUtils.formatDate(edu.endDate!, format: 'MMM yyyy') : 'Present'}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Experience
                  if (user.experience.isNotEmpty) ...[
                    Text(
                      'Experience',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...user.experience.map((exp) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.work, color: AppTheme.primaryColor),
                            title: Text(exp.position),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.company),
                                if (exp.location != null) Text(exp.location!),
                                if (exp.startDate != null || exp.endDate != null)
                                  Text(
                                    '${exp.startDate != null ? AppDateUtils.DateUtils.formatDate(exp.startDate!, format: 'MMM yyyy') : ''} - ${exp.isCurrentRole == true ? 'Present' : (exp.endDate != null ? AppDateUtils.DateUtils.formatDate(exp.endDate!, format: 'MMM yyyy') : '')}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                if (exp.responsibilities.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: exp.responsibilities.take(3).map((r) => Text(
                                        '• $r',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      )).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Skills
                  if (user.skills.isNotEmpty) ...[
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.skills.map((skill) => Chip(
                                label: Text(skill),
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Projects
                  if (user.projects.isNotEmpty) ...[
                    Text(
                      'Projects',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...user.projects.map((project) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.code, color: AppTheme.primaryColor),
                            title: Text(project.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (project.description != null)
                                  Text(project.description!),
                                if (project.technologies != null)
                                  Text(
                                    'Technologies: ${project.technologies}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            trailing: project.url != null
                                ? IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () {
                                      // TODO: Open URL
                                    },
                                  )
                                : null,
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Certifications
                  if (user.certifications.isNotEmpty) ...[
                    Text(
                      'Certifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...user.certifications.map((cert) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.verified, color: AppTheme.primaryColor),
                            title: Text(cert.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cert.issuer != null) Text(cert.issuer!),
                                if (cert.issueDate != null)
                                  Text(
                                    'Issued: ${AppDateUtils.DateUtils.formatDate(cert.issueDate!, format: 'MMM yyyy')}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Account Information
                  Text(
                    'Account Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        _ProfileInfoTile(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.createdAt != null)
                          _ProfileInfoTile(
                            icon: Icons.calendar_today,
                            label: 'Member Since',
                            value: _formatDate(user.createdAt!),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isUrl = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      subtitle: Text(value),
      trailing: isUrl
          ? IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () {
                // TODO: Open URL in browser
              },
            )
          : null,
    );
  }
}
