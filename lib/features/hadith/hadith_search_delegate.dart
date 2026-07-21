import 'package:flutter/material.dart';

import '../../data/hadith_repository.dart';

/// Searches across every bundled hadith's category, translation, and book
/// name. Selecting a result closes the search and returns it, so the
/// caller can navigate to the detail screen.
class HadithSearchDelegate extends SearchDelegate<HadithEntry?> {
  HadithSearchDelegate(this._allHadith);

  final List<HadithEntry> _allHadith;

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
        child: Text('Search by category, translation, or book.'),
      );
    }

    final results = _allHadith.where((entry) {
      return entry.category.toLowerCase().contains(needle) ||
          entry.translation.toLowerCase().contains(needle) ||
          entry.book.toLowerCase().contains(needle);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No hadith found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          title: Text(
            entry.translation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${entry.category} · ${entry.book}'),
          onTap: () => close(context, entry),
        );
      },
    );
  }
}
