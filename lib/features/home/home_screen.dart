import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Zikr', icon: Icons.home_outlined);
  }
}
