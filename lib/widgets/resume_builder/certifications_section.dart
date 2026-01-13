import 'package:flutter/material.dart';
import 'package:resumeiq/models/resume_model.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;

/// Reusable certifications section component
class CertificationsSection extends StatelessWidget {
  const CertificationsSection({
    super.key,
    required this.certifications,
    this.itemSpacing = 12.0,
    this.showDate = true,
    this.showIssuer = true,
  });

  final List<Certification> certifications;
  final double itemSpacing;
  final bool showDate;
  final bool showIssuer;

  @override
  Widget build(BuildContext context) {
    if (certifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: certifications
          .map((cert) => _CertificationItem(
                certification: cert,
                itemSpacing: itemSpacing,
                showDate: showDate,
                showIssuer: showIssuer,
              ))
          .toList(),
    );
  }
}

class _CertificationItem extends StatelessWidget {
  const _CertificationItem({
    required this.certification,
    required this.itemSpacing,
    required this.showDate,
    required this.showIssuer,
  });

  final Certification certification;
  final double itemSpacing;
  final bool showDate;
  final bool showIssuer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: itemSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (showIssuer && certification.issuer != null && certification.issuer!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    certification.issuer!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
                if (certification.credentialId != null && certification.credentialId!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Credential ID: ${certification.credentialId!}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (showDate && certification.issueDate != null)
            Text(
              AppDateUtils.DateUtils.formatDate(certification.issueDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }
}
