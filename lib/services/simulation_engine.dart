import '../data/models/country_model.dart';
import '../data/models/game_state_model.dart';
import '../data/models/policy_model.dart';
import '../data/models/event_model.dart';
import '../data/datasources/buildings_data.dart';

class SimulationEngine {
  SimulationEngine._();

  static GameStateModel initFromCountry(CountryModel country) {
    final startApproval = 50.0 + (country.humanDevelopmentIndex * 20) - 10;
    return GameStateModel(
      country: country,
      currentYear: 2024,
      termStartYear: 2024,
      termDurationYears: 5,
      approvalRating: startApproval,
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
      treasury: country.gdpBillion * (country.humanDevelopmentIndex * 0.06 + 0.02),
      foodSecurity: (40.0 + country.humanDevelopmentIndex * 45).clamp(20.0, 95.0),
      agriculturalOutput: (country.gdpBillion * (0.20 - country.humanDevelopmentIndex * 0.15)).clamp(country.gdpBillion * 0.02, country.gdpBillion * 0.25),
      troopCount: (country.militaryBudgetBillion * 5).clamp(5.0, 5000.0),
      militaryReadiness: (30.0 + country.humanDevelopmentIndex * 40.0 + (country.militaryBudgetBillion / 10).clamp(0.0, 20.0)).clamp(10.0, 90.0),
      naturalResourceIndex: 50.0,
      oilReserves: 40.0,
      politicalCapital: 20 + (startApproval / 5).round(),
      approvalHistory: [startApproval],
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
    double foodSec = state.foodSecurity;
    double agriOut = state.agriculturalOutput;
    double milReadiness = state.militaryReadiness;
    double natResources = state.naturalResourceIndex;
    double oilRes = state.oilReserves;
    double troops = state.troopCount;

    // Natural trends
    gdpGrowth += (happiness > 60 ? 0.5 : -0.3);
    gdpGrowth -= (inflation > 5 ? 0.5 : 0);
    gdpGrowth -= (unemployment > 10 ? 0.4 : 0);
    gdpGrowth += (state.alliedCountries.length * 0.1).clamp(0, 1.5);

    // Alliance & sanction ongoing effects
    diplo += (state.alliedCountries.length * 0.4).clamp(0, 6);
    diplo -= (state.sanctionedCountries.length * 0.3).clamp(0, 4);
    gdpGrowth -= (state.sanctionedCountries.length * 0.05).clamp(0, 0.5);
    stability += (state.alliedCountries.length * 0.1).clamp(0, 1.5);

    happiness += (healthcare - 50) * 0.05;
    happiness += (education - 50) * 0.04;
    happiness -= (unemployment > 8 ? 0.5 : 0);
    happiness -= (inflation > 6 ? 0.3 : 0);

    unemployment += (gdpGrowth < 0 ? 0.5 : -0.2);
    inflation += (debt > 80 ? 0.3 : -0.1);

    stability -= (corruption > 60 ? 0.5 : 0);
    stability += (military > 50 ? 0.2 : 0);

    corruption += (education < 40 ? 0.5 : -0.2);

    // Food security
    foodSec += (healthcare - 50) * 0.03;
    foodSec -= (unemployment > 15 ? 0.4 : 0);
    foodSec -= (corruption > 60 ? 0.3 : 0);
    foodSec += (gdpGrowth > 2 ? 0.2 : gdpGrowth < 0 ? -0.3 : 0);
    agriOut *= (1 + gdpGrowth / 200);
    happiness += (foodSec < 30 ? -1.0 : foodSec > 80 ? 0.3 : 0);

    // Military resources
    milReadiness += (military > 60 ? 0.2 : -0.1);
    troops += (military > 60 ? 2.0 : -1.0);

    // Natural resources (slow depletion unless policies invest)
    natResources -= 0.15;
    oilRes -= 0.08;

    // Resources boost economy
    gdpGrowth += (natResources > 70 ? 0.3 : 0);
    gdpGrowth += (oilRes > 70 ? 0.2 : 0);

    // Tax rate effects — baseline 25%, each 5% above reduces growth & happiness
    final taxDelta = (state.taxRate - 25.0) / 5.0; // units of 5% deviation
    gdpGrowth -= taxDelta * 0.25;       // +5% tax → -0.25% GDP growth
    happiness -= taxDelta * 0.4;        // +5% tax → -0.4 happiness
    unemployment += taxDelta * 0.05;    // +5% tax → slight unemployment rise
    // Low tax bonus: below 15% boosts growth but hurts public services
    if (state.taxRate < 15) {
      gdpGrowth += 0.5;
      happiness -= 0.5; // less public spending
    }

    // Building bonuses (yearly, per level owned)
    final bl = state.buildingLevels;
    int blv(String id) => bl[id] ?? 0;
    // Energy buildings
    gdpGrowth += blv('coal_plant') * 0.3;
    happiness += blv('solar_farm') * 0.8;
    // Military buildings
    military += blv('military_base') * 0.5;
    troops += blv('military_base') * 8.0;
    milReadiness += blv('training_academy') * 0.8;
    education += blv('training_academy') * 0.3;
    military += blv('weapons_factory') * 0.8;
    gdpGrowth += blv('weapons_factory') * 0.05;
    // Food buildings
    foodSec += blv('farm_complex') * 0.8;
    gdpGrowth += blv('farm_complex') * 0.1;
    foodSec += blv('granary') * 0.5;
    stability += blv('granary') * 0.3;
    foodSec += blv('irrigation') * 1.0;
    happiness += blv('irrigation') * 0.3;
    // Resource buildings
    oilRes += blv('oil_refinery') * 0.8;
    gdpGrowth += blv('oil_refinery') * 0.2;
    natResources += blv('mine_complex') * 0.9;
    gdpGrowth += blv('mine_complex') * 0.15;
    natResources += blv('research_center') * 0.5;
    education += blv('research_center') * 0.4;
    gdpGrowth += blv('research_center') * 0.1;

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

    // ── Treasury: annual budget cycle ─────────────────────────
    final taxIncome = state.gdpBillion * state.taxRate / 100;
    final baseGovSpending = state.gdpBillion * 0.20;
    final policySpending = state.activePolicies.fold(0.0, (sum, p) => sum + p.cost);
    double buildingMaintenance = 0;
    for (final b in BuildingsData.all) {
      final lvl = state.buildingLevels[b.id] ?? 0;
      if (lvl > 0) buildingMaintenance += lvl * b.moneyCostPerLevel * 0.02;
    }
    final netBudget = taxIncome - baseGovSpending - state.militaryBudget - policySpending - buildingMaintenance;
    double treasury = state.treasury + netBudget;

    // Deficit penalties
    if (treasury < 0) {
      gdpGrowth -= 0.3;
      happiness -= 1.0;
      debt = (debt + 2.0).clamp(0, 200);
    }
    if (treasury < -(state.gdpBillion * 0.1)) {
      stability -= 0.5;
      gdpGrowth -= 0.5;
    }

    // ── Political Capital earned this year ────────────────────
    final capitalBase = (approval / 10).floor();                    // 0–10
    final capitalBonus = (approval >= 80 ? 3 : approval >= 60 ? 1 : 0)  // loyalty bonus
        + (stability > 70 ? 2 : 0)                                 // stable nation
        + (state.atWar ? 0 : 1);                                   // peace dividend
    final newCapital = (state.politicalCapital + capitalBase + capitalBonus).clamp(0, 999);

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
      treasury: treasury,
      foodSecurity: foodSec.clamp(0.0, 100.0),
      agriculturalOutput: agriOut.clamp(0.0, state.gdpBillion * 0.5),
      troopCount: troops.clamp(0.0, 10000.0),
      militaryReadiness: milReadiness.clamp(0.0, 100.0),
      naturalResourceIndex: natResources.clamp(0.0, 100.0),
      oilReserves: oilRes.clamp(0.0, 100.0),
      politicalCapital: newCapital,
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

  static GameStateModel buildOrUpgrade(GameStateModel state, String buildingId) {
    final building = BuildingsData.byId(buildingId);
    if (building == null) return state;
    final currentLevel = state.buildingLevels[buildingId] ?? 0;
    if (currentLevel >= building.maxLevel) return state;
    final newLevels = Map<String, int>.from(state.buildingLevels)
      ..[buildingId] = currentLevel + 1;
    final newCapital = (state.politicalCapital - building.capitalCostPerLevel).clamp(0, 999);
    final newTreasury = state.treasury - building.moneyCostPerLevel;
    return state.copyWith(buildingLevels: newLevels, politicalCapital: newCapital, treasury: newTreasury);
  }

  static bool canAffordPolicy(GameStateModel state, PolicyModel policy) =>
      state.politicalCapital >= policy.capitalCost;

  static GameStateModel applyPolicy(GameStateModel state, PolicyModel policy) {
    var s = state;
    for (final effect in policy.effects) {
      s = _applyStat(s, effect.statName, effect.delta);
    }
    final active = [...state.activePolicies, policy];
    final newCapital = (state.politicalCapital - policy.capitalCost).clamp(0, 999);
    return s.copyWith(activePolicies: active, politicalCapital: newCapital);
  }

  static GameStateModel applyEventChoice(GameStateModel state, EventChoice choice) {
    var s = state;
    for (final effect in choice.effects) {
      s = _applyStat(s, effect.statName, effect.delta);
    }
    // Crisis resolution earns +2 political capital
    return s.copyWith(politicalCapital: (s.politicalCapital + 2).clamp(0, 999));
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
      case 'Food Security':
        return s.copyWith(foodSecurity: (s.foodSecurity + delta).clamp(0, 100));
      case 'Natural Resources':
        return s.copyWith(naturalResourceIndex: (s.naturalResourceIndex + delta).clamp(0, 100));
      case 'Oil Reserves':
        return s.copyWith(oilReserves: (s.oilReserves + delta).clamp(0, 100));
      case 'Troops':
        return s.copyWith(troopCount: (s.troopCount + delta).clamp(0, 10000));
      case 'Military Readiness':
        return s.copyWith(militaryReadiness: (s.militaryReadiness + delta).clamp(0, 100));
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

  // ── Diplomacy actions ─────────────────────────────────────────────────────

  static const int allianceCost    = 8;  // 💎 to propose
  static const int breakCost       = 4;  // 💎 to break
  static const int sanctionCost    = 5;  // 💎 to impose
  static const int liftCost        = 3;  // 💎 to lift

  static GameStateModel proposeAlliance(GameStateModel state, String countryName) {
    final allied = [...state.alliedCountries, countryName];
    return state.copyWith(
      alliedCountries: allied,
      politicalCapital: (state.politicalCapital - allianceCost).clamp(0, 999),
      diplomaticReputation: (state.diplomaticReputation + 6).clamp(0, 100),
      gdpGrowthRate: (state.gdpGrowthRate + 0.4).clamp(-15, 15),
      happiness: (state.happiness + 2).clamp(0, 100),
      stability: (state.stability + 1.5).clamp(0, 100),
    );
  }

  static GameStateModel breakAlliance(GameStateModel state, String countryName) {
    final allied = state.alliedCountries.where((c) => c != countryName).toList();
    return state.copyWith(
      alliedCountries: allied,
      politicalCapital: (state.politicalCapital - breakCost).clamp(0, 999),
      diplomaticReputation: (state.diplomaticReputation - 8).clamp(0, 100),
      gdpGrowthRate: (state.gdpGrowthRate - 0.3).clamp(-15, 15),
    );
  }

  static GameStateModel imposeSanction(GameStateModel state, String countryName) {
    final sanctioned = [...state.sanctionedCountries, countryName];
    return state.copyWith(
      sanctionedCountries: sanctioned,
      politicalCapital: (state.politicalCapital - sanctionCost).clamp(0, 999),
      diplomaticReputation: (state.diplomaticReputation - 4).clamp(0, 100),
    );
  }

  static GameStateModel liftSanction(GameStateModel state, String countryName) {
    final sanctioned = state.sanctionedCountries.where((c) => c != countryName).toList();
    return state.copyWith(
      sanctionedCountries: sanctioned,
      politicalCapital: (state.politicalCapital - liftCost).clamp(0, 999),
      diplomaticReputation: (state.diplomaticReputation + 3).clamp(0, 100),
    );
  }
}
