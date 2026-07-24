import 'package:flutter/material.dart';

import '../../data/cities_repository.dart';

/// Searches bundled cities by name or country, for the manual location
/// fallback shared by Prayer Times and Qibla. Selecting a result closes the
/// search and returns it.
class CitySearchDelegate extends SearchDelegate<CityEntry?> {
  CitySearchDelegate(this._allCities);

  final List<CityEntry> _allCities;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
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
      return const Center(child: Text('Search for a city or country.'));
    }

    final results = _allCities.where((city) {
      return city.name.toLowerCase().contains(needle) ||
          city.country.toLowerCase().contains(needle);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No matching city found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final city = results[index];
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(city.name),
          subtitle: Text(city.country),
          onTap: () => close(context, city),
        );
      },
    );
  }
}
