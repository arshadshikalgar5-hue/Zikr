import 'package:flutter/material.dart';

import '../../data/duas_repository.dart';

/// Searches across every bundled dua's category, transliteration, and
/// translation. Selecting a result closes the search and returns it, so the
/// caller can navigate to the detail screen.
class DuaSearchDelegate extends SearchDelegate<DuaEntry?> {
  DuaSearchDelegate(this._allDuas);

  final List<DuaEntry> _allDuas;

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
        child: Text('Search by category, transliteration, or meaning.'),
      );
    }

    final results = _allDuas.where((dua) {
      return dua.category.toLowerCase().contains(needle) ||
          dua.transliteration.toLowerCase().contains(needle) ||
          dua.translation.toLowerCase().contains(needle);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No duas found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final dua = results[index];
        return ListTile(
          title: Text(dua.transliteration),
          subtitle: Text(
            '${dua.category} · ${dua.translation}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => close(context, dua),
        );
      },
    );
  }
}
