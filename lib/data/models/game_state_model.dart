import 'country_model.dart';
import 'policy_model.dart';

class GameStateModel {
  final CountryModel country;
  final int currentYear;
  final int termStartYear;
  final int termDurationYears;

  // Core Stats (0–100)
  final double approvalRating;
  final double happiness;
  final double corruption;
  final double stability;

  // Economic Stats
  final double gdpBillion;
  final double gdpGrowthRate; // percentage
  final double inflation;
  final double unemploymentRate;
  final double taxRate;
  final double nationalDebt; // % of GDP

  // Military Stats
  final double militaryStrength; // 0–100
  final double militaryBudget; // billion USD
  final bool atWar;

  // Social Stats
  final double educationIndex; // 0–100
  final double healthcareIndex; // 0–100
  final double literacyRate;

  // Diplomatic
  final double diplomaticReputation; // 0–100
  final List<String> alliedCountries;
  final List<String> sanctionedCountries;

  // Applied Policies
  final List<PolicyModel> activePolicies;

  // History
  final List<double> approvalHistory;
  final List<double> gdpHistory;

  const GameStateModel({
    required this.country,
    required this.currentYear,
    required this.termStartYear,
    this.termDurationYears = 5,
    required this.approvalRating,
    required this.happiness,
    required this.corruption,
    required this.stability,
    required this.gdpBillion,
    required this.gdpGrowthRate,
    required this.inflation,
    required this.unemploymentRate,
    required this.taxRate,
    required this.nationalDebt,
    required this.militaryStrength,
    required this.militaryBudget,
    this.atWar = false,
    required this.educationIndex,
    required this.healthcareIndex,
    required this.literacyRate,
    required this.diplomaticReputation,
    this.alliedCountries = const [],
    this.sanctionedCountries = const [],
    this.activePolicies = const [],
    this.approvalHistory = const [],
    this.gdpHistory = const [],
  });

  int get yearsInOffice => currentYear - termStartYear;
  int get yearsRemaining => termDurationYears - yearsInOffice;
  bool get isTermOver => yearsInOffice >= termDurationYears;
  double get gdpPerCapita => gdpBillion * 1e9 / country.population;

  String get leaderTitle {
    switch (country.governmentType) {
      case 'constitutional_monarchy':
      case 'absolute_monarchy':
        return 'Prime Minister';
      case 'communist':
        return 'General Secretary';
      case 'theocracy':
        return 'Supreme Leader';
      default:
        return 'President';
    }
  }

  GameStateModel copyWith({
    CountryModel? country,
    int? currentYear,
    int? termStartYear,
    int? termDurationYears,
    double? approvalRating,
    double? happiness,
    double? corruption,
    double? stability,
    double? gdpBillion,
    double? gdpGrowthRate,
    double? inflation,
    double? unemploymentRate,
    double? taxRate,
    double? nationalDebt,
    double? militaryStrength,
    double? militaryBudget,
    bool? atWar,
    double? educationIndex,
    double? healthcareIndex,
    double? literacyRate,
    double? diplomaticReputation,
    List<String>? alliedCountries,
    List<String>? sanctionedCountries,
    List<PolicyModel>? activePolicies,
    List<double>? approvalHistory,
    List<double>? gdpHistory,
  }) {
    return GameStateModel(
      country: country ?? this.country,
      currentYear: currentYear ?? this.currentYear,
      termStartYear: termStartYear ?? this.termStartYear,
      termDurationYears: termDurationYears ?? this.termDurationYears,
      approvalRating: approvalRating ?? this.approvalRating,
      happiness: happiness ?? this.happiness,
      corruption: corruption ?? this.corruption,
      stability: stability ?? this.stability,
      gdpBillion: gdpBillion ?? this.gdpBillion,
      gdpGrowthRate: gdpGrowthRate ?? this.gdpGrowthRate,
      inflation: inflation ?? this.inflation,
      unemploymentRate: unemploymentRate ?? this.unemploymentRate,
      taxRate: taxRate ?? this.taxRate,
      nationalDebt: nationalDebt ?? this.nationalDebt,
      militaryStrength: militaryStrength ?? this.militaryStrength,
      militaryBudget: militaryBudget ?? this.militaryBudget,
      atWar: atWar ?? this.atWar,
      educationIndex: educationIndex ?? this.educationIndex,
      healthcareIndex: healthcareIndex ?? this.healthcareIndex,
      literacyRate: literacyRate ?? this.literacyRate,
      diplomaticReputation: diplomaticReputation ?? this.diplomaticReputation,
      alliedCountries: alliedCountries ?? this.alliedCountries,
      sanctionedCountries: sanctionedCountries ?? this.sanctionedCountries,
      activePolicies: activePolicies ?? this.activePolicies,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      gdpHistory: gdpHistory ?? this.gdpHistory,
    );
  }
}
