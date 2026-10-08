import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';

class ThemeAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const ThemeAwareText(
    this.text, {
    super.key,
    this.style,
    this.align,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.themeMode == ThemeMode.dark;

    Color getTextColor(TextStyle? baseStyle) {
      if (baseStyle?.color != null) return baseStyle!.color!;
      return isDark ? Colors.white70 : Colors.black87;
    }

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: getTextColor(style),
      ),
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
