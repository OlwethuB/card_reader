import 'package:card_reader/utils/country_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bannedCountriesProvider = StateProvider<List<String>>((ref) {
  return bannedCountries;
});