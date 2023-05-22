import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/utils/utils.dart';

typedef PopupMenuItemText<T> = String Function(T value, int index);

class ItemPopupMenuFilter<TEnum> extends StatelessWidget {
  const ItemPopupMenuFilter({
    required this.toolTipText,
    required this.selectedValue,
    required this.values,
    required this.itemText,
    super.key,
    this.onSelected,
    this.exclude = const [],
    this.icon = const Icon(
      Icons.keyboard_arrow_right,
      color: Color(0xFF8B8C8C),
      size: 20,
    ),
  });

  final String toolTipText;
  final TEnum selectedValue;
  final void Function(TEnum)? onSelected;
  final List<TEnum> values;
  final List<TEnum> exclude;
  final Icon icon;
  final PopupMenuItemText<TEnum> itemText;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TEnum>(
      padding: EdgeInsets.zero,
      surfaceTintColor: AppColors.tertiary,
      initialValue: selectedValue,
      icon: icon,
      onSelected: handleItemSelected,
      itemBuilder: (context) {
        final translatedValues = getTranslatedValues(context);
        return getValuesToUse(context, translatedValues);
      },
      tooltip: toolTipText,
    );
  }

  List<TranslatedEnum<TEnum>> getTranslatedValues(BuildContext context) {
    return EnumUtils.getTranslatedAndSortedEnum<TEnum>(
      values,
      itemText,
      exclude: exclude,
    );
  }

  List<CheckedPopupMenuItem<TEnum>> getValuesToUse(
    BuildContext context,
    List<TranslatedEnum<TEnum>> translatedValues,
  ) {
    return translatedValues.map((e) => CheckedPopupMenuItem<TEnum>(
      checked: selectedValue == e.enumValue,
      value: e.enumValue,
      child: Text(
        e.translation,
      ),
    ),).toList();
  }

  void handleItemSelected(TEnum value) {
    onSelected?.call(value);
  }
}

class ItemPopupMenuFilterWithAllValue extends ItemPopupMenuFilter<int> {
  ItemPopupMenuFilterWithAllValue({
    required super.toolTipText,
    required List<int> values,
    required super.itemText,
    super.key,
    int? selectedValue,
    this.onAllOrValueSelected,
    super.exclude = const [],
    super.icon,
  }) : super(selectedValue: selectedValue ?? allValue, values: values..add(allValue));

  static int allValue = -1;

  final void Function(int?)? onAllOrValueSelected;

  @override
  List<TranslatedEnum<int>> getTranslatedValues(BuildContext context) {
    return EnumUtils.getTranslatedAndSortedEnumWithAllValue(
      allValue,
      'All',
      values,
      itemText,
      exclude: exclude,
    );
  }

  @override
  void handleItemSelected(int value) {
    if (onAllOrValueSelected == null) {
      return;
    }

    final valueToUse = value == allValue ? null : value;
    onAllOrValueSelected!(valueToUse);
  }
}
