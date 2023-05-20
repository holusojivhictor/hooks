import 'package:flutter/widgets.dart';

class NavigationBarItem {
  const NavigationBarItem({
    required this.icon,
    required this.title,
    Widget? activeIcon,
    this.tooltip,
  }) : activeIcon = activeIcon ?? icon;

  final Widget icon;
  final Widget activeIcon;
  final String title;
  final String? tooltip;
}
