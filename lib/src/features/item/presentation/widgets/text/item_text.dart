import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/linkify/linkify.dart';
import 'package:hooks/src/features/item/presentation/extensions/widget_extensions.dart';
import 'package:hooks/src/utils/utils.dart';

class ItemText extends StatelessWidget {
  const ItemText({
    required this.item,
    super.key,
    this.onTap,
  });

  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final style = textTheme.bodyLarge!;
    final linkStyle = style.copyWith(
      decoration: TextDecoration.underline,
      color: AppColors.primary,
    );

    if (item is Buildable) {
      return SelectableText.rich(
        buildTextSpan(
          (item as Buildable).elements,
          style: style,
          linkStyle: linkStyle,
          onOpen: (LinkableElement link) => LinkUtils.launch(link.url),
        ),
        onTap: onTap,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        contextMenuBuilder: (
          BuildContext context,
          EditableTextState editableTextState,
        ) => contextMenuBuilder(
          context,
          editableTextState,
          item: item,
        ),
        semanticsLabel: item.text,
      );
    } else {
      return SelectableLinkify(
        text: item.text,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        style: style,
        linkStyle: linkStyle,
        onOpen: (LinkableElement link) => LinkUtils.launch(link.url),
        onTap: onTap,
        contextMenuBuilder: (
          BuildContext context,
          EditableTextState editableTextState,
        ) => contextMenuBuilder(
          context,
          editableTextState,
          item: item,
        ),
        semanticsLabel: item.text,
      );
    }
  }
}
