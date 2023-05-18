import 'package:flutter/material.dart';
import 'package:hooks/src/features/settings/presentation/widgets/settings_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: AppSettingsCard(),
      ),
    );
  }
}
