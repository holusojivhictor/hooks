import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';

class CenteredText extends StatelessWidget {
  const CenteredText({
    required this.text,
    super.key,
    this.color = AppColors.grey4,
  });

  const CenteredText.hidden({Key? key})
      : this(
          key: key,
          text: 'hidden',
        );

  const CenteredText.deleted({Key? key})
      : this(
          key: key,
          text: 'deleted',
        );

  const CenteredText.dead({Key? key})
      : this(
          key: key,
          text: 'dead',
        );

  const CenteredText.blocked({Key? key})
      : this(
          key: key,
          text: 'blocked',
        );

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      ),
    );
  }
}
