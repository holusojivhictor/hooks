import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';

class Styles {
  static const edgeInsetAll16 = EdgeInsets.all(16);
  static const edgeInsetAll10 = EdgeInsets.all(10);
  static const edgeInsetAll7 = EdgeInsets.all(7);
  static const edgeInsetAll5 = EdgeInsets.all(5);
  static const edgeInsetAll3 = EdgeInsets.all(3);
  static const edgeInsetAll0 = EdgeInsets.zero;
  static const edgeInsetHorizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const edgeInsetVertical5 = EdgeInsets.symmetric(vertical: 5);
  static const edgeInsetHorizontal5 = EdgeInsets.symmetric(horizontal: 5);
  static const edgeInsetVertical16 = EdgeInsets.symmetric(vertical: 16);
  static const edgeInsetVertical10 = EdgeInsets.symmetric(vertical: 10);
  static const edgeInsetHorizontal10 = EdgeInsets.symmetric(horizontal: 10);
  static const edgeInsetSymmetric8 = EdgeInsets.symmetric(horizontal: 8, vertical: 8);

  static const inactiveButtonPadding = EdgeInsets.symmetric(vertical: 14);

  static const defaultShapeRadius = BorderRadius.all(Radius.circular(10));
  static const mainCardShape = RoundedRectangleBorder(borderRadius: defaultShapeRadius);
  static const defaultShapeBorder = RoundedRectangleBorder(borderRadius: defaultShapeRadius);

  static const formFieldMargin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  static UnderlineInputBorder outlineInputBorder({required Color color}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color),
    );
  }

  static const authButtonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 30);

  static const formFieldPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 18);

  static const formFieldBorder = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.grey5, width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );

  static const focusedFormFieldBorder = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );

  static const chipCircularRadius = Radius.circular(8);

  static const defaultCircularRadius = Radius.circular(24);

  static const choiceButtonBorderRadius = BorderRadius.all(defaultCircularRadius);

  static const chipBorderRadius = BorderRadius.all(chipCircularRadius);

  static const defaultCardBorderRadius = BorderRadius.all(Radius.circular(15));

  static const cardDefaultShape = RoundedRectangleBorder(
    borderRadius: defaultCardBorderRadius,
  );

  static const alertButtonBorderSide = BorderSide(color: AppColors.error);

  static const alertDialogBorderRadius = BorderRadius.all(Radius.circular(10));

  static const alertDialogShape = RoundedRectangleBorder(borderRadius: alertDialogBorderRadius);

  static const chipShape = RoundedRectangleBorder(borderRadius: chipBorderRadius);

  static const modalBottomSheetContainerMargin = EdgeInsets.only(left: 10, right: 10, bottom: 10);
  static const modalBottomSheetContainerPadding = EdgeInsets.only(left: 10, right: 10, top: 10);

  static BoxShadow boxDropShadow = BoxShadow(
    color: const Color(0xFFF2F7F2).withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  static BoxShadow boxAltDropShadow = BoxShadow(
    color: const Color(0xFFF2F7F2).withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, -4),
  );

  static BoxShadow homeCardDropShadow = BoxShadow(
    color: const Color(0xFF000000).withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(2, 2),
  );
}
