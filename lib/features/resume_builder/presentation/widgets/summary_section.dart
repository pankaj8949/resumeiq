import 'package:flutter/material.dart';

/// Reusable summary/objective section component
class SummarySection extends StatelessWidget {
  const SummarySection({
    super.key,
    required this.summary,
    this.padding = const EdgeInsets.only(bottom: 8.0),
    this.style,
  });

  final String? summary;
  final EdgeInsets padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (summary == null || summary!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Text(
        summary!,
        style: style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
