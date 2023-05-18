import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/home/presentation/home_page.dart';
import 'package:hooks/src/features/settings/presentation/settings_page.dart';
import 'package:hooks/src/routing/mobile_scaffold.dart';

enum AppRoute {
  onboarding,
  home,
  stories,
  settings,
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const Placeholder(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MobileScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: AppRoute.home.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/stories',
            name: AppRoute.stories.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const Scaffold(backgroundColor: Colors.red),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: AppRoute.settings.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
