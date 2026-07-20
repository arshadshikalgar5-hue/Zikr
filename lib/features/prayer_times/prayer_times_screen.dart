import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Prayer Times',
      icon: Icons.access_time_outlined,
    );
  }
}
