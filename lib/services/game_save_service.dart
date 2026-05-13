import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/game_state_model.dart';
import '../data/models/policy_model.dart';
import '../data/datasources/countries_data.dart';
import '../data/datasources/policies_data.dart';

class GameSaveService {
  GameSaveService._();

  static const _key = 'wps_save_v1';

  static Future<void> save(GameStateModel state) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'countryId': state.country.id,
      'currentYear': state.currentYear,
      'termStartYear': state.termStartYear,
      'termDurationYears': state.termDurationYears,
      'approvalRating': state.approvalRating,
      'happiness': state.happiness,
      'corruption': state.corruption,
      'stability': state.stability,
      'gdpBillion': state.gdpBillion,
      'gdpGrowthRate': state.gdpGrowthRate,
      'inflation': state.inflation,
      'unemploymentRate': state.unemploymentRate,
      'taxRate': state.taxRate,
      'nationalDebt': state.nationalDebt,
      'militaryStrength': state.militaryStrength,
      'militaryBudget': state.militaryBudget,
      'atWar': state.atWar,
      'troopCount': state.troopCount,
      'militaryReadiness': state.militaryReadiness,
      'foodSecurity': state.foodSecurity,
      'agriculturalOutput': state.agriculturalOutput,
      'naturalResourceIndex': state.naturalResourceIndex,
      'oilReserves': state.oilReserves,
      'educationIndex': state.educationIndex,
      'healthcareIndex': state.healthcareIndex,
      'literacyRate': state.literacyRate,
      'diplomaticReputation': state.diplomaticReputation,
      'alliedCountries': state.alliedCountries,
      'sanctionedCountries': state.sanctionedCountries,
      'treasury': state.treasury,
      'activePolicyIds': state.activePolicies.map((p) => p.id).toList(),
      'buildingLevels': state.buildingLevels,
      'politicalCapital': state.politicalCapital,
      'approvalHistory': state.approvalHistory,
      'gdpHistory': state.gdpHistory,
    };
    await prefs.setString(_key, jsonEncode(map));
  }

  static Future<GameStateModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final country = CountriesData.byId(map['countryId'] as String);
      if (country == null) return null;

      final activePolicyIds = List<String>.from(map['activePolicyIds'] ?? []);
      final activePolicies = activePolicyIds
          .map((id) => PoliciesData.all.where((p) => p.id == id).firstOrNull)
          .whereType<PolicyModel>()
          .toList();

      return GameStateModel(
        country: country,
        currentYear: map['currentYear'] as int,
        termStartYear: map['termStartYear'] as int,
        termDurationYears: map['termDurationYears'] as int? ?? 5,
        approvalRating: (map['approvalRating'] as num).toDouble(),
        happiness: (map['happiness'] as num).toDouble(),
        corruption: (map['corruption'] as num).toDouble(),
        stability: (map['stability'] as num).toDouble(),
        gdpBillion: (map['gdpBillion'] as num).toDouble(),
        gdpGrowthRate: (map['gdpGrowthRate'] as num).toDouble(),
        inflation: (map['inflation'] as num).toDouble(),
        unemploymentRate: (map['unemploymentRate'] as num).toDouble(),
        taxRate: (map['taxRate'] as num).toDouble(),
        nationalDebt: (map['nationalDebt'] as num).toDouble(),
        militaryStrength: (map['militaryStrength'] as num).toDouble(),
        militaryBudget: (map['militaryBudget'] as num).toDouble(),
        atWar: map['atWar'] as bool? ?? false,
        troopCount: (map['troopCount'] as num?)?.toDouble() ?? 100.0,
        militaryReadiness: (map['militaryReadiness'] as num?)?.toDouble() ?? 50.0,
        foodSecurity: (map['foodSecurity'] as num?)?.toDouble() ?? 50.0,
        agriculturalOutput: (map['agriculturalOutput'] as num?)?.toDouble() ?? 0.0,
        naturalResourceIndex: (map['naturalResourceIndex'] as num?)?.toDouble() ?? 50.0,
        oilReserves: (map['oilReserves'] as num?)?.toDouble() ?? 40.0,
        educationIndex: (map['educationIndex'] as num).toDouble(),
        healthcareIndex: (map['healthcareIndex'] as num).toDouble(),
        literacyRate: (map['literacyRate'] as num).toDouble(),
        diplomaticReputation: (map['diplomaticReputation'] as num).toDouble(),
        alliedCountries: List<String>.from(map['alliedCountries'] ?? []),
        sanctionedCountries: List<String>.from(map['sanctionedCountries'] ?? []),
        treasury: (map['treasury'] as num?)?.toDouble() ?? 0.0,
        activePolicies: activePolicies,
        buildingLevels: (map['buildingLevels'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {},
        politicalCapital: map['politicalCapital'] as int? ?? 20,
        approvalHistory: List<double>.from(
            (map['approvalHistory'] as List).map((e) => (e as num).toDouble())),
        gdpHistory: List<double>.from(
            (map['gdpHistory'] as List).map((e) => (e as num).toDouble())),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  static Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
