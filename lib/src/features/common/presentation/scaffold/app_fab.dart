import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/extensions/scroll_controller_extensions.dart';

typedef OnClick = void Function();

class AppFab extends StatelessWidget {
  const AppFab({
    required this.scrollController,
    required this.hideFabAnimController,
    super.key,
    this.icon = const Icon(Icons.arrow_upward, color: Colors.white),
    this.mini = true,
    this.onPressed,
  });

  final ScrollController scrollController;
  final AnimationController hideFabAnimController;
  final Widget icon;
  final bool mini;
  final OnClick? onPressed;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: hideFabAnimController,
      child: ScaleTransition(
        scale: hideFabAnimController,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          mini: mini,
          onPressed: () => onPressed != null ? onPressed!() : scrollController.goToTheTop(),
          heroTag: null,
          child: icon,
        ),
      ),
    );
  }
}
