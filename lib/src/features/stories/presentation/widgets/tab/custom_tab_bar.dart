import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/stories/presentation/widgets/tab/circle_tab_indicator.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({required this.tabController, super.key});

  final TabController tabController;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    widget.tabController.addListener(() {
      setState(() {
        currentIndex = widget.tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TabBar(
      isScrollable: true,
      controller: widget.tabController,
      indicator: CircleTabIndicator(
        color: colorScheme.primary,
        radius: 2,
      ),
      indicatorPadding: const EdgeInsets.only(bottom: 8),
      splashFactory: NoSplash.splashFactory,
      onTap: (_) {
        HapticFeedback.selectionClick();
      },
      tabs: <Widget>[
        for (var i = 0; i < StoryType.values.length; i++)
          Tab(
            key: ValueKey<StoryType>(StoryType.values.elementAt(i)),
            child: AnimatedDefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontSize: currentIndex == i ? 16 : 12,
                color: currentIndex == i ? colorScheme.primary : AppColors.grey6,
              ),
              duration: Constants.kAnimationDuration,
              child: Text(
                StoryType.values.elementAt(i).label,
                key: ValueKey<String>(
                  '${StoryType.values.elementAt(i).label}-${currentIndex == i}',
                ),
              ),
            ),
          )
      ],
    );
  }
}
