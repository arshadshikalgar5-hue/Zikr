import 'package:flutter/material.dart';

import '../../data/names_repository.dart';

/// Searches across every name's transliteration, meaning, and explanation.
/// Selecting a result closes the search and returns it, so the caller can
/// navigate to the detail screen.
class NameSearchDelegate extends SearchDelegate<NameEntry?> {
  NameSearchDelegate(this._allNames);

  final List<NameEntry> _allNames;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return const Center(
        child: Text('Search by transliteration or meaning.'),
      );
    }

    final results = _allNames.where((name) {
      return name.transliteration.toLowerCase().contains(needle) ||
          name.meaning.toLowerCase().contains(needle) ||
          name.explanation.toLowerCase().contains(needle);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No names found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final name = results[index];
        return ListTile(
          title: Text(name.transliteration),
          subtitle: Text(name.meaning),
          onTap: () => close(context, name),
        );
      },
    );
  }
}
