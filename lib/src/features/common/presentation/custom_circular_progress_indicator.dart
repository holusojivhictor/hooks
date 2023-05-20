import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    super.key,
    this.strokeWidth = 4,
  });

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
    );
  }
}
