import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  info,
  succeed,
  warning,
  error,
}

class ToastUtils {
  static Duration toastDuration = const Duration(seconds: 2);

  static FToast of(BuildContext context) {
    final fToast = FToast().init(context);
    return fToast;
  }

  static void showSucceedToast(
    FToast toast,
    String msg, {
    VoidCallback? action,
  }) => _showToast(toast, msg, Colors.white, ToastType.succeed, action: action);

  static void showInfoToast(
    FToast toast,
    String msg, {
    VoidCallback? action,
  }) => _showToast(toast, msg, Colors.white, ToastType.info, action: action);

  static void showWarningToast(
    FToast toast,
    String msg, {
    VoidCallback? action,
  }) => _showToast(toast, msg, Colors.white, ToastType.warning, action: action);

  static void showErrorToast(
    FToast toast,
    String msg, {
    VoidCallback? action,
  }) => _showToast(toast, msg, Colors.white, ToastType.error, action: action);

  static void _showToast(
    FToast toast,
    String msg,
    Color textColor,
    ToastType type, {
    VoidCallback? action,
  }) {
    Color bgColor;
    Icon icon;
    switch (type) {
      case ToastType.info:
        bgColor = Colors.blue;
        icon = const Icon(Icons.info, color: Colors.white);
      case ToastType.succeed:
        bgColor = Colors.green;
        icon = const Icon(Icons.check, color: Colors.white);
      case ToastType.warning:
        bgColor = Colors.orange;
        icon = const Icon(Icons.warning, color: Colors.white);
      case ToastType.error:
        bgColor = Colors.red;
        icon = const Icon(Icons.dangerous, color: Colors.white);
    }

    final widget = buildToast(msg, textColor, bgColor, icon, toast.context, action: action);
    toast.showToast(
      child: widget,
      gravity: ToastGravity.BOTTOM,
      toastDuration: toastDuration,
    );
  }

  static Widget buildToast(
    String msg,
    Color textColor,
    Color bgColor,
    Icon icon,
    BuildContext? context, {
    VoidCallback? action,
  }) {
    return InkWell(
      onTap: action != null ? () => action.call() : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                msg,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
