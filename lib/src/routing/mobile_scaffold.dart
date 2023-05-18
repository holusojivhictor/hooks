import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/extensions/string_extensions.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/animated_navigation_bar.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/navigation_bar_item.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/toast_utils.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({required this.child, super.key});

  final Widget child;

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  int _selectedIndex = 0;
  DateTime? backButtonPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop,
      child: Scaffold(
        body: widget.child,
        extendBody: true,
        bottomNavigationBar: AnimatedNavigationBar(
          elevation: 0,
          iconSize: 22,
          selectedItemColor: AppColors.variantBlack,
          unselectedItemColor: AppColors.variantGrey8,
          currentIndex: _selectedIndex,
          items: [
            // products
            NavigationBarItem(
              icon: const Icon(Icons.work_outline),
              activeIcon: const Icon(Icons.work),
              title: 'Home'.hardcoded,
            ),
            NavigationBarItem(
              icon: const Icon(Icons.auto_stories_outlined),
              activeIcon: const Icon(Icons.auto_stories),
              title: 'Stories'.hardcoded,
            ),
            NavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              title: 'Settings'.hardcoded,
            ),
          ],
          onItemSelected: (index) => _goToTab(context, index),
        ),
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 0) {
      context.goNamed(AppRoute.home.name);
    } else if (index == 1) {
      context.goNamed(AppRoute.stories.name);
    } else if (index == 2) {
      context.goNamed(AppRoute.settings.name);
    }
  }

  Future<bool> handleWillPop() async {
    if (_selectedIndex != 0) {
      _goToTab(context, 0);
      return false;
    }

    final settings = context.read<SettingsBloc>();
    if (!settings.doubleBackToClose) {
      return true;
    }

    final now = DateTime.now();
    final mustWait = backButtonPressTime == null || now.difference(backButtonPressTime!) > ToastUtils.toastDuration;

    if (mustWait) {
      backButtonPressTime = now;
      final fToast = ToastUtils.of(context);
      ToastUtils.showInfoToast(fToast, 'Press once again to exit'.hardcoded);
      return false;
    }

    return true;
  }
}
