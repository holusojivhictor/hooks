import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/animated_navigation_bar.dart';
import 'package:hooks/src/features/common/presentation/navigation_bar/navigation_bar_item.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/utils.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({required this.child, super.key});

  final Widget child;

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  bool _didChangeDependencies = false;
  int _selectedIndex = 0;
  DateTime? backButtonPressTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeDependencies) return;
    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: AnimatedNavigationBar(
          elevation: 0,
          iconSize: 22,
          selectedItemColor: AppColors.variantBlack,
          unselectedItemColor: AppColors.variantGrey8,
          currentIndex: _selectedIndex,
          items: const [
            NavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories),
              title: 'Stories',
            ),
            NavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              title: 'Settings',
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
      context.goNamed(AppRoute.items.name);
    } else if (index == 1) {
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
      ToastUtils.showInfoToast(fToast, 'Press once again to exit');
      return false;
    }

    return true;
  }
}
