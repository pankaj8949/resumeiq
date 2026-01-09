import 'package:flutter/material.dart';

/// Reusable section title component for resume templates
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.color,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.underline = false,
    this.padding = const EdgeInsets.only(bottom: 8.0, top: 16.0),
  });

  final String title;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool underline;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).colorScheme.onSurface;

    Widget titleWidget = Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: defaultColor,
        letterSpacing: 1.2,
      ),
    );

    if (underline) {
      titleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: defaultColor,
          ),
        ],
      );
    }

    return Padding(
      padding: padding,
      child: titleWidget,
    );
  }
}
