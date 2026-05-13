import '../data/models/country_model.dart';
import '../data/models/game_state_model.dart';
import '../data/models/policy_model.dart';
import '../data/models/event_model.dart';

class SimulationEngine {
  SimulationEngine._();

  static GameStateModel initFromCountry(CountryModel country) {
    return GameStateModel(
      country: country,
      currentYear: 2024,
      termStartYear: 2024,
      termDurationYears: 5,
      approvalRating: 50.0 + (country.humanDevelopmentIndex * 20) - 10,
      happiness: 40.0 + (country.humanDevelopmentIndex * 30),
      corruption: 100.0 - country.corruptionIndex.toDouble(),
      stability: 50.0 + (country.humanDevelopmentIndex * 25),
      gdpBillion: country.gdpBillion,
      gdpGrowthRate: 2.5,
      inflation: 3.5,
      unemploymentRate: country.unemploymentRate,
      taxRate: 25.0,
      nationalDebt: 50.0,
      militaryStrength: _calcMilitary(country),
      militaryBudget: country.militaryBudgetBillion,
      educationIndex: country.literacyRate,
      healthcareIndex: 40.0 + (country.humanDevelopmentIndex * 40),
      literacyRate: country.literacyRate,
      diplomaticReputation: 50.0 + (country.corruptionIndex * 0.2),
      alliedCountries: country.allies,
      sanctionedCountries: country.rivals,
      approvalHistory: [50.0 + (country.humanDevelopmentIndex * 20) - 10],
      gdpHistory: [country.gdpBillion],
    );
  }

  static double _calcMilitary(CountryModel c) {
    final base = (c.militaryBudgetBillion / 10).clamp(0.0, 50.0);
    final hdi = c.humanDevelopmentIndex * 20;
    return (base + hdi).clamp(5.0, 95.0);
  }

  static GameStateModel advanceYear(GameStateModel state) {
    double gdpGrowth = state.gdpGrowthRate;
    double happiness = state.happiness;
    double approval = state.approvalRating;
    double corruption = state.corruption;
    double unemployment = state.unemploymentRate;
    double inflation = state.inflation;
    double stability = state.stability;
    double military = state.militaryStrength;
    double education = state.educationIndex;
    double healthcare = state.healthcareIndex;
    double diplo = state.diplomaticReputation;
    double debt = state.nationalDebt;

    // Natural trends
    gdpGrowth += (happiness > 60 ? 0.5 : -0.3);
    gdpGrowth -= (inflation > 5 ? 0.5 : 0);
    gdpGrowth -= (unemployment > 10 ? 0.4 : 0);
    gdpGrowth += (state.alliedCountries.length * 0.1).clamp(0, 1.5);

    happiness += (healthcare - 50) * 0.05;
    happiness += (education - 50) * 0.04;
    happiness -= (unemployment > 8 ? 0.5 : 0);
    happiness -= (inflation > 6 ? 0.3 : 0);

    unemployment += (gdpGrowth < 0 ? 0.5 : -0.2);
    inflation += (debt > 80 ? 0.3 : -0.1);

    stability -= (corruption > 60 ? 0.5 : 0);
    stability += (military > 50 ? 0.2 : 0);

    corruption += (education < 40 ? 0.5 : -0.2);

    approval = _calcApproval(
      happiness: happiness,
      gdpGrowth: gdpGrowth,
      unemployment: unemployment,
      corruption: corruption,
      stability: stability,
      currentApproval: approval,
    );

    final newGdp = state.gdpBillion * (1 + gdpGrowth / 100);
    debt = (debt - gdpGrowth * 0.5).clamp(0.0, 200.0);

    final newApprovalHistory = [...state.approvalHistory, approval].take(10).toList();
    final newGdpHistory = [...state.gdpHistory, newGdp].take(10).toList();

    return state.copyWith(
      currentYear: state.currentYear + 1,
      approvalRating: approval.clamp(0.0, 100.0),
      happiness: happiness.clamp(0.0, 100.0),
      corruption: corruption.clamp(0.0, 100.0),
      stability: stability.clamp(0.0, 100.0),
      gdpBillion: newGdp,
      gdpGrowthRate: gdpGrowth.clamp(-15.0, 15.0),
      inflation: inflation.clamp(0.0, 50.0),
      unemploymentRate: unemployment.clamp(0.0, 60.0),
      nationalDebt: debt,
      militaryStrength: military.clamp(0.0, 100.0),
      educationIndex: education.clamp(0.0, 100.0),
      healthcareIndex: healthcare.clamp(0.0, 100.0),
      diplomaticReputation: diplo.clamp(0.0, 100.0),
      approvalHistory: newApprovalHistory,
      gdpHistory: newGdpHistory,
    );
  }

  static double _calcApproval({
    required double happiness,
    required double gdpGrowth,
    required double unemployment,
    required double corruption,
    required double stability,
    required double currentApproval,
  }) {
    double delta = 0;
    delta += (happiness - 50) * 0.1;
    delta += gdpGrowth * 0.5;
    delta -= (unemployment > 8 ? (unemployment - 8) * 0.3 : 0);
    delta -= (corruption > 50 ? (corruption - 50) * 0.1 : 0);
    delta += (stability - 50) * 0.05;
    // Regression to mean — prevents lock at extremes
    delta += (50 - currentApproval) * 0.02;
    return (currentApproval + delta).clamp(0.0, 100.0);
  }

  static GameStateModel applyPolicy(GameStateModel state, PolicyModel policy) {
    var s = state;
    for (final effect in policy.effects) {
      s = _applyStat(s, effect.statName, effect.delta);
    }
    final active = [...state.activePolicies, policy];
    return s.copyWith(activePolicies: active);
  }

  static GameStateModel applyEventChoice(GameStateModel state, EventChoice choice) {
    var s = state;
    for (final effect in choice.effects) {
      s = _applyStat(s, effect.statName, effect.delta);
    }
    return s;
  }

  static GameStateModel _applyStat(GameStateModel s, String stat, double delta) {
    switch (stat) {
      case 'GDP Growth':
        return s.copyWith(gdpGrowthRate: (s.gdpGrowthRate + delta).clamp(-15, 15));
      case 'Happiness':
        return s.copyWith(happiness: (s.happiness + delta).clamp(0, 100));
      case 'Approval':
        return s.copyWith(approvalRating: (s.approvalRating + delta).clamp(0, 100));
      case 'National Debt':
        return s.copyWith(nationalDebt: (s.nationalDebt - delta).clamp(0, 200));
      case 'Employment':
        return s.copyWith(unemploymentRate: (s.unemploymentRate - delta).clamp(0, 60));
      case 'Inflation':
        return s.copyWith(inflation: (s.inflation - delta).clamp(0, 50));
      case 'Military Strength':
        return s.copyWith(militaryStrength: (s.militaryStrength + delta).clamp(0, 100));
      case 'Diplomatic Rep':
        return s.copyWith(diplomaticReputation: (s.diplomaticReputation + delta).clamp(0, 100));
      case 'Education':
        return s.copyWith(educationIndex: (s.educationIndex + delta).clamp(0, 100));
      case 'Healthcare':
        return s.copyWith(healthcareIndex: (s.healthcareIndex + delta).clamp(0, 100));
      case 'Stability':
        return s.copyWith(stability: (s.stability + delta).clamp(0, 100));
      case 'Corruption':
        return s.copyWith(corruption: (s.corruption - delta).clamp(0, 100));
      default:
        return s;
    }
  }

  static String getApprovalLabel(double approval) {
    if (approval >= 80) return 'Beloved Leader';
    if (approval >= 65) return 'Popular';
    if (approval >= 50) return 'Acceptable';
    if (approval >= 35) return 'Unpopular';
    if (approval >= 20) return 'Disliked';
    return 'Despised';
  }

  static String getLegacyRating(GameStateModel state) {
    final avg = (state.approvalHistory.isNotEmpty)
        ? state.approvalHistory.reduce((a, b) => a + b) / state.approvalHistory.length
        : state.approvalRating;
    if (avg >= 80) return 'Greatest Leader in History';
    if (avg >= 65) return 'Outstanding Statesperson';
    if (avg >= 50) return 'Adequate Leader';
    if (avg >= 35) return 'Controversial Figure';
    if (avg >= 20) return 'Remembered Poorly';
    return 'Worst Leader in History';
  }
}
