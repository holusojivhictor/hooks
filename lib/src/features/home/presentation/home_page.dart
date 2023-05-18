import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/scaffold/sliver_scaffold_with_fab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverScaffoldWithFab(
      physics: ClampingScrollPhysics(),
      slivers: [],
    );
  }
}
