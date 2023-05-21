import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    required this.itemScrollController,
    required this.itemPositionsListener,
    super.key,
  });

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
