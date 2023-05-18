import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required this.title,
    required this.trailing,
    super.key,
    this.leadingIcon,
    this.onTap,
  });

  final String title;
  final Widget trailing;
  final Widget? leadingIcon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: leadingIcon,
        visualDensity: const VisualDensity(vertical: 2),
        contentPadding: const EdgeInsets.only(left: 12),
        onTap: onTap != null ? () => onTap!() : null,
        trailing: trailing,
      ),
    );
  }
}
