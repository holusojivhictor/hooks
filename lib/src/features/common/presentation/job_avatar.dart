import 'package:flutter/material.dart';

class JobAvatar extends StatelessWidget {
  const JobAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const icon = Icons.av_timer;
    final avatar = Container(
      margin: const EdgeInsets.only(top: 5, left: 5),
      child: CircleAvatar(
        radius: 10,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(icon, color: Colors.white, size: 16),
      ),
    );
    return Tooltip(
      message: 'Job',
      child: avatar,
    );
  }
}
