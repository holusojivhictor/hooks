import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/navigation_bar_item.dart';

class NavigationTile extends StatelessWidget {
  const NavigationTile(
    this.item,
    this.animation,
    this.iconSize, {
    required this.selected,
    required this.selectedIconTheme,
    required this.unselectedIconTheme,
    super.key,
    this.iconColorTween,
    this.onTap,
  });

  final NavigationBarItem item;
  final Animation<double> animation;
  final double iconSize;
  final IconThemeData? selectedIconTheme;
  final IconThemeData? unselectedIconTheme;
  final ColorTween? iconColorTween;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: item.tooltip,
      selected: selected,
      container: true,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TileIcon(
                colorTween: iconColorTween!,
                animation: animation,
                iconSize: iconSize,
                selected: selected,
                item: item,
                selectedIconTheme: selectedIconTheme,
                unselectedIconTheme: unselectedIconTheme,
              ),
              _AnimatedBar(isActive: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.colorTween,
    required this.animation,
    required this.iconSize,
    required this.selected,
    required this.item,
    required this.selectedIconTheme,
    required this.unselectedIconTheme,
  });

  final ColorTween colorTween;
  final Animation<double> animation;
  final double iconSize;
  final bool selected;
  final NavigationBarItem item;
  final IconThemeData? selectedIconTheme;
  final IconThemeData? unselectedIconTheme;

  @override
  Widget build(BuildContext context) {
    final iconColor = colorTween.evaluate(animation);
    final defaultIconTheme = IconThemeData(
      color: iconColor,
      size: iconSize,
    );
    final iconThemeData = IconThemeData.lerp(
      defaultIconTheme.merge(unselectedIconTheme),
      defaultIconTheme.merge(selectedIconTheme),
      animation.value,
    );

    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: IconTheme(
        data: iconThemeData,
        child: selected ? item.activeIcon : item.icon,
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.isActive,
  });
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 2),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
