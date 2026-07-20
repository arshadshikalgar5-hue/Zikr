import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Favorites',
      icon: Icons.favorite_border,
    );
  }
}
