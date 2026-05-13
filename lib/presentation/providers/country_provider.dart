import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/country_model.dart';
import '../../data/datasources/countries_data.dart';

final selectedContinentProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCountriesProvider = Provider<List<CountryModel>>((ref) {
  final continent = ref.watch(selectedContinentProvider);
  final query = ref.watch(searchQueryProvider);

  var countries = CountriesData.all.toList();

  if (query.isNotEmpty) {
    countries = CountriesData.search(query);
  } else if (continent != null) {
    countries = CountriesData.byContinent(continent);
  }

  countries.sort((a, b) => a.name.compareTo(b.name));
  return countries;
});

final continentsProvider = Provider<List<String>>((ref) {
  return CountriesData.continents;
});
