import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/common/domain/assets.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/routing/app_router.dart';

class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> {
  @override
  void initState() {
    super.initState();
    context.read<StoriesBloc>().add(const StoriesEvent.init());
    Future.delayed(const Duration(milliseconds: 3000), () {
      context.goNamed(AppRoute.items.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'ⓒ 2023 Morpheus',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
              ],
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: Constants.splashLogoDimension,
                    height: Constants.splashLogoDimension,
                    child: Image.asset(Assets.loading),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hooks',
                    style: theme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 34,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
