import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/common/presentation/splash/animated_splash.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/item_page.dart';
import 'package:hooks/src/features/settings/presentation/settings_page.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/features/stories/presentation/stories_page.dart';
import 'package:hooks/src/routing/mobile_scaffold.dart';

enum AppRoute {
  splash,
  items,
  item,
  settings,
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        name: AppRoute.splash.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const AnimatedSplash(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MobileScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: AppRoute.items.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StoriesPage(),
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
      GoRoute(
        path: '/item',
        name: AppRoute.item.name,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra! as ItemPageArgs;

          return RepositoryProvider<CollapseCache>(
            create: (_) => CollapseCache(),
            lazy: false,
            child: BlocProvider<CommentsCubit>(
              create: (ctx) {
                final storiesService = getIt<StoriesService>();
                final dataService = getIt<DataService>();
                final loggingService = getIt<LoggingService>();
                final commentCache = getIt<CommentCache>();
                return CommentsCubit(
                  storiesService,
                  dataService,
                  loggingService,
                  commentCache,
                  filterCubit: ctx.read<FilterCubit>(),
                  collapseCache: ctx.read<CollapseCache>(),
                  item: args.item,
                  defaultFetchMode: ctx.read<SettingsBloc>().fetchMode,
                  defaultCommentsOrder: ctx.read<SettingsBloc>().order,
                )..init(
                  onlyShowTargetComment: args.onlyShowTargetComment,
                  targetAncestors: args.targetComments,
                  useCommentCache: args.useCommentCache,
                );
              },
              child: ItemPage(
                item: args.item,
                parentComments: args.targetComments ?? <Comment>[],
              ),
            ),
          );
        },
      ),
    ],
  );

  static GoRouter get router => _router;
}
