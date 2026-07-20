import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class NamazTrackerScreen extends StatelessWidget {
  const NamazTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Namaz Tracker',
      icon: Icons.checklist_outlined,
    );
  }
}
