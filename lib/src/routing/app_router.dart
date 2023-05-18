import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/news/presentation/news_screen/news_screen.dart';

enum AppRoute {
  onboarding,
  news,
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: '/news',
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
      GoRoute(
        path: '/news',
        name: AppRoute.news.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const NewsScreen(),
        ),
      ),
    ],
  );

  static GoRouter get router => _router;
}
