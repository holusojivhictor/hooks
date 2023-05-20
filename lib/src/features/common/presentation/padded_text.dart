import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/styles.dart';

class PaddedText extends StatelessWidget {
  const PaddedText(
    this.text, {
    super.key,
    this.padding,
    this.textAlign,
    this.style,
  });

  final EdgeInsetsGeometry? padding;
  final String? text;
  final TextAlign? textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? Styles.edgeInsetHorizontal16,
      child: Text(
        text ?? '',
        textAlign: textAlign,
        style: style ?? theme.textTheme.headlineSmall,
      ),
    );
  }
}
