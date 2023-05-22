import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/linkify/linkifiers/linkifiers.dart';
import 'package:hooks/src/utils/utils.dart';

extension WidgetExtensions on Widget {
  Widget contextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState, {
    required Item item,
  }) {
    final start = editableTextState.textEditingValue.selection.base.offset;
    final end = editableTextState.textEditingValue.selection.end;

    final items = <ContextMenuButtonItem>[
      ...editableTextState.contextMenuButtonItems,
    ];

    if (start != -1 && end != -1) {
      var selectedText = item.text.substring(start, end);

      if (item is Buildable) {
        final emphasisElements =
            (item as Buildable).elements.whereType<EmphasisElement>();

        var count = 1;
        while (selectedText.contains(' ') && count <= emphasisElements.length) {
          final s = (start + count * 2).clamp(0, item.text.length);
          final e = (end + count * 2).clamp(0, item.text.length);
          selectedText = item.text.substring(s, e);
          count++;
        }

        count = 1;
        while (selectedText.contains(' ') && count <= emphasisElements.length) {
          final s = (start - count * 2).clamp(0, item.text.length);
          final e = (end - count * 2).clamp(0, item.text.length);
          selectedText = item.text.substring(s, e);
          count++;
        }
      }

      items.addAll(<ContextMenuButtonItem>[
        ContextMenuButtonItem(
          onPressed: () => LinkUtils.launch(
            '''${Constants.wikipediaLink}$selectedText''',
          ),
          label: 'Wikipedia',
        ),
        ContextMenuButtonItem(
          onPressed: () => LinkUtils.launch(
            '''${Constants.wiktionaryLink}$selectedText''',
          ),
          label: 'Wiktionary',
        ),
      ]);
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }
}
