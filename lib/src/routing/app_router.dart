import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/home/presentation/home_page.dart';
import 'package:hooks/src/features/item/item_page.dart';
import 'package:hooks/src/features/settings/presentation/settings_page.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/stories_page.dart';
import 'package:hooks/src/routing/mobile_scaffold.dart';

enum AppRoute {
  onboarding,
  home,
  items,
  item,
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
            path: '/items',
            name: AppRoute.items.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StoriesPage(),
            ),
            routes: [
              GoRoute(
                path: 'item/:id',
                name: AppRoute.item.name,
                pageBuilder: (context, state) {
                  // TODO(morpheus): Extract item args
                  return MaterialPage(
                    key: state.pageKey,
                    child: ItemPage(
                      item: Item.empty(),
                      parentComments: const <Comment>[],
                    ),
                  );
                },
              ),
            ],
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
