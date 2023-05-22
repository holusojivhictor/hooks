import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/routing/app_router.dart';

extension StateExtensions on State {
  Future<void>? goToItemScreen({
    required ItemPageArgs args,
    required BuildContext context,
  }) {
    return context.pushNamed(
      AppRoute.item.name,
      extra: args,
    );
  }

  // TODO(morpheus): Implement onMoreTapped
  void onMoreTapped(Item item, Rect? rect) {}

  // TODO(morpheus): Add login dialog
  void onLoginTapped() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Placeholder();
      },
    );
  }
}
