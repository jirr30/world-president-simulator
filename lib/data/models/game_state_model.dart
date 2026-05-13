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
  final double troopCount; // thousands of active personnel
  final double militaryReadiness; // 0–100 equipment & training readiness

  // Food & Agriculture
  final double foodSecurity; // 0–100
  final double agriculturalOutput; // billion USD

  // Natural Resources
  final double naturalResourceIndex; // 0–100 overall resource wealth
  final double oilReserves; // 0–100 strategic oil/energy reserves

  // Social Stats
  final double educationIndex; // 0–100
  final double healthcareIndex; // 0–100
  final double literacyRate;

  // Diplomatic
  final double diplomaticReputation; // 0–100
  final List<String> alliedCountries;
  final List<String> sanctionedCountries;

  // Treasury — government's spendable cash balance (billion USD)
  final double treasury;

  // Applied Policies
  final List<PolicyModel> activePolicies;

  // Infrastructure buildings (buildingId → level, 0 = not built)
  final Map<String, int> buildingLevels;

  // Political Capital (earned from approval, spent on policies)
  final int politicalCapital;

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
    this.troopCount = 100,
    this.militaryReadiness = 50,
    this.foodSecurity = 50,
    this.agriculturalOutput = 0,
    this.naturalResourceIndex = 50,
    this.oilReserves = 40,
    required this.educationIndex,
    required this.healthcareIndex,
    required this.literacyRate,
    required this.diplomaticReputation,
    this.alliedCountries = const [],
    this.sanctionedCountries = const [],
    this.treasury = 0,
    this.activePolicies = const [],
    this.buildingLevels = const {},
    this.politicalCapital = 20,
    this.approvalHistory = const [],
    this.gdpHistory = const [],
  });

  String get troopCountFormatted {
    if (troopCount >= 1000) return '${(troopCount / 1000).toStringAsFixed(1)}M';
    return '${troopCount.toStringAsFixed(0)}K';
  }

  String get treasuryFormatted {
    final abs = treasury.abs();
    final sign = treasury < 0 ? '-' : '';
    if (abs >= 1000) return '$sign\$${(abs / 1000).toStringAsFixed(1)}T';
    return '$sign\$${abs.toStringAsFixed(0)}B';
  }

  bool get treasuryIsNegative => treasury < 0;

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
    double? troopCount,
    double? militaryReadiness,
    double? foodSecurity,
    double? agriculturalOutput,
    double? naturalResourceIndex,
    double? oilReserves,
    double? educationIndex,
    double? healthcareIndex,
    double? literacyRate,
    double? diplomaticReputation,
    List<String>? alliedCountries,
    List<String>? sanctionedCountries,
    double? treasury,
    List<PolicyModel>? activePolicies,
    Map<String, int>? buildingLevels,
    int? politicalCapital,
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
      troopCount: troopCount ?? this.troopCount,
      militaryReadiness: militaryReadiness ?? this.militaryReadiness,
      foodSecurity: foodSecurity ?? this.foodSecurity,
      agriculturalOutput: agriculturalOutput ?? this.agriculturalOutput,
      naturalResourceIndex: naturalResourceIndex ?? this.naturalResourceIndex,
      oilReserves: oilReserves ?? this.oilReserves,
      educationIndex: educationIndex ?? this.educationIndex,
      healthcareIndex: healthcareIndex ?? this.healthcareIndex,
      literacyRate: literacyRate ?? this.literacyRate,
      diplomaticReputation: diplomaticReputation ?? this.diplomaticReputation,
      alliedCountries: alliedCountries ?? this.alliedCountries,
      sanctionedCountries: sanctionedCountries ?? this.sanctionedCountries,
      treasury: treasury ?? this.treasury,
      activePolicies: activePolicies ?? this.activePolicies,
      buildingLevels: buildingLevels ?? this.buildingLevels,
      politicalCapital: politicalCapital ?? this.politicalCapital,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      gdpHistory: gdpHistory ?? this.gdpHistory,
    );
  }
}
