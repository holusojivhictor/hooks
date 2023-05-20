import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';

class SettingsSwitchListTile extends StatelessWidget {
  const SettingsSwitchListTile({
    required this.title,
    required this.value,
    super.key,
    this.leadingIcon,
    this.onChanged,
  });

  final bool value;
  final String title;
  final Widget? leadingIcon;
  final ValueChanged<bool>? onChanged;

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
        trailing: Switch.adaptive(
          activeColor: AppColors.primary,
          value: value,
          onChanged: onChanged != null ? (value) => onChanged!(value) : null,
        ),
      ),
    );
  }
}
