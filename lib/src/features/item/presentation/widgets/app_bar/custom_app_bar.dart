import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/buttons/link_icon_button.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    required Item item,
    required Color super.backgroundColor,
    super.key,
  }) : super(
    elevation: 0,
    scrolledUnderElevation: 0,
    actions: [
      LinkIconButton(storyId: item.id),
    ],
  );
}
