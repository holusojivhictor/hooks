import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/navigation_bar_item.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/navigation_tile.dart';

class AnimatedNavigationBar extends StatefulWidget {

  const AnimatedNavigationBar({
    required this.items, super.key,
    this.onItemSelected,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme,
    this.unselectedIconTheme,
    this.currentIndex = 0,
    this.elevation,
    this.backgroundColor,
    this.useLegacyColorScheme = true,
  })  : assert(items.length >= 2, 'Item length has to be greater than two'),
        assert(0 <= currentIndex && currentIndex < items.length, 'Invalid index');

  final List<NavigationBarItem> items;
  final ValueChanged<int>? onItemSelected;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final IconThemeData? selectedIconTheme;
  final IconThemeData? unselectedIconTheme;
  final int currentIndex;
  final double? elevation;
  final Color? backgroundColor;
  final bool useLegacyColorScheme;

  @override
  State<AnimatedNavigationBar> createState() => _AnimatedNavigationBarState();
}

class _AnimatedNavigationBarState extends State<AnimatedNavigationBar> with TickerProviderStateMixin {
  List<AnimationController> _controllers = <AnimationController>[];
  late List<CurvedAnimation> _animations;

  void _resetState() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    _controllers = List<AnimationController>.generate(widget.items.length, (int index) {
      return AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      )..addListener(_rebuild);
    });
    _animations = List<CurvedAnimation>.generate(widget.items.length, (int index) {
      return CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped,
      );
    });
    _controllers[widget.currentIndex].value = 1.0;
  }

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // No animated segue if the length of the items list changes.
    if (widget.items.length != oldWidget.items.length) {
      _resetState();
      return;
    }

    if (widget.currentIndex != oldWidget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  static IconThemeData _effectiveIconTheme(IconThemeData? iconTheme, Color? itemColor) {
    // Prefer the iconTheme over itemColor if present.
    return iconTheme ?? IconThemeData(color: itemColor);
  }

  List<Widget> _createTiles() {
    final themeData = Theme.of(context);
    final bottomTheme = BottomNavigationBarTheme.of(context);

    final Color themeColor;
    switch (themeData.brightness) {
      case Brightness.light:
        themeColor = themeData.colorScheme.primary;
      case Brightness.dark:
        themeColor = themeData.colorScheme.secondary;
    }

    final effectiveSelectedIconTheme =
    _effectiveIconTheme(
        widget.selectedIconTheme
            ?? bottomTheme.selectedIconTheme,
        widget.selectedItemColor
            ?? bottomTheme.selectedItemColor
            ?? themeColor,
    );

    final effectiveUnselectedIconTheme =
    _effectiveIconTheme(
        widget.unselectedIconTheme
            ?? bottomTheme.unselectedIconTheme,
        widget.unselectedItemColor
            ?? bottomTheme.unselectedItemColor
            ?? themeData.unselectedWidgetColor,
    );

    final colorTween = ColorTween(
      begin: widget.unselectedItemColor
          ?? bottomTheme.unselectedItemColor
          ?? themeData.unselectedWidgetColor,
      end: widget.selectedItemColor
          ?? bottomTheme.selectedItemColor
          ?? themeColor,
    );

    final iconColorTween = ColorTween(
      begin: effectiveSelectedIconTheme.color
          ?? widget.unselectedItemColor
          ?? bottomTheme.unselectedItemColor
          ?? themeData.unselectedWidgetColor,
      end: effectiveUnselectedIconTheme.color
          ?? widget.selectedItemColor
          ?? bottomTheme.selectedItemColor
          ?? themeColor,
    );

    final tiles = <Widget>[];

    for (var i = 0; i < widget.items.length; i++) {
      tiles.add(NavigationTile(
        widget.items[i],
        _animations[i],
        widget.iconSize,
        onTap: () {
          widget.onItemSelected?.call(i);
        },
        selected: i == widget.currentIndex,
        selectedIconTheme: widget.useLegacyColorScheme ? widget.selectedIconTheme ?? bottomTheme.selectedIconTheme : effectiveSelectedIconTheme,
        unselectedIconTheme: widget.useLegacyColorScheme ? widget.unselectedIconTheme ?? bottomTheme.unselectedIconTheme : effectiveUnselectedIconTheme,
        iconColorTween: widget.useLegacyColorScheme ? colorTween : iconColorTween,
      ),);
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final bottomTheme = BottomNavigationBarTheme.of(context);
    final additionalBottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Semantics(
      explicitChildNodes: true,
      child: _Bar(
        elevation: widget.elevation ?? bottomTheme.elevation ?? 8.0,
        color: widget.backgroundColor ?? bottomTheme.backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: kBottomNavigationBarHeight + additionalBottomPadding),
          child: Padding(
            padding: EdgeInsets.only(bottom: additionalBottomPadding),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _createTiles(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.child,
    required this.elevation,
    required this.color,
  });

  final Widget child;
  final double elevation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          elevation: elevation,
          color: color,
          child: child,
        ),
      ),
    );
  }
}
