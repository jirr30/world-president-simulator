import 'package:flutter/material.dart';
import '../models/building_model.dart';
import '../models/policy_model.dart';

class BuildingsData {
  BuildingsData._();

  static const List<BuildingModel> all = [
    // ══════════════════ ENERGY ══════════════════
    BuildingModel(
      id: 'coal_plant',
      name: 'Coal Power Plant',
      description: 'Burns coal to generate reliable base-load electricity. Affordable to build and upgrade.',
      category: BuildingCategory.energy,
      icon: Icons.factory_rounded,
      capitalCostPerLevel: 4,
      moneyCostPerLevel: 4,
      energyProductionPerLevel: 25,
      effectsPerLevel: [StatEffect('GDP Growth', 0.3)],
    ),
    BuildingModel(
      id: 'solar_farm',
      name: 'Solar Energy Farm',
      description: 'Large photovoltaic fields producing clean renewable electricity. Boosts public happiness.',
      category: BuildingCategory.energy,
      icon: Icons.wb_sunny_rounded,
      capitalCostPerLevel: 5,
      moneyCostPerLevel: 6,
      energyProductionPerLevel: 18,
      effectsPerLevel: [StatEffect('Happiness', 0.8)],
    ),
    BuildingModel(
      id: 'nuclear_plant',
      name: 'Nuclear Power Station',
      description: 'High-output nuclear reactors for industrial-scale power. Expensive but extremely efficient.',
      category: BuildingCategory.energy,
      icon: Icons.settings_suggest_rounded,
      capitalCostPerLevel: 10,
      moneyCostPerLevel: 18,
      energyProductionPerLevel: 80,
      maxLevel: 3,
      effectsPerLevel: [],
    ),

    // ══════════════════ MILITARY ══════════════════
    BuildingModel(
      id: 'military_base',
      name: 'Military Base',
      description: 'Houses and trains active-duty soldiers. Increases troop count and military strength each year.',
      category: BuildingCategory.military,
      icon: Icons.flag_rounded,
      capitalCostPerLevel: 6,
      moneyCostPerLevel: 8,
      energyConsumption: 18,
      effectsPerLevel: [StatEffect('Military Strength', 0.5), StatEffect('Troops', 8.0)],
    ),
    BuildingModel(
      id: 'training_academy',
      name: 'Training Academy',
      description: 'Advanced soldier training programs that improve combat readiness and technical education.',
      category: BuildingCategory.military,
      icon: Icons.fitness_center_rounded,
      capitalCostPerLevel: 5,
      moneyCostPerLevel: 6,
      energyConsumption: 10,
      effectsPerLevel: [StatEffect('Military Readiness', 0.8), StatEffect('Education', 0.3)],
    ),
    BuildingModel(
      id: 'weapons_factory',
      name: 'Defense Industry',
      description: 'Domestic arms manufacturing for military self-sufficiency. Boosts strength and economy.',
      category: BuildingCategory.military,
      icon: Icons.precision_manufacturing_rounded,
      capitalCostPerLevel: 8,
      moneyCostPerLevel: 12,
      energyConsumption: 28,
      effectsPerLevel: [StatEffect('Military Strength', 0.8), StatEffect('GDP Growth', 0.05)],
    ),

    // ══════════════════ FOOD ══════════════════
    BuildingModel(
      id: 'farm_complex',
      name: 'Agricultural Complex',
      description: 'Large-scale modern farming facilities to maximize crop yields and food production.',
      category: BuildingCategory.food,
      icon: Icons.grass_rounded,
      capitalCostPerLevel: 5,
      moneyCostPerLevel: 5,
      energyConsumption: 10,
      effectsPerLevel: [StatEffect('Food Security', 0.8), StatEffect('GDP Growth', 0.1)],
    ),
    BuildingModel(
      id: 'granary',
      name: 'National Granary',
      description: 'Strategic food reserves to buffer against shortages, droughts, and economic crises.',
      category: BuildingCategory.food,
      icon: Icons.inventory_rounded,
      capitalCostPerLevel: 3,
      moneyCostPerLevel: 3,
      energyConsumption: 6,
      effectsPerLevel: [StatEffect('Food Security', 0.5), StatEffect('Stability', 0.3)],
    ),
    BuildingModel(
      id: 'irrigation',
      name: 'Irrigation Network',
      description: 'Canals, pumps, and water management systems to extend farmland and improve crop output.',
      category: BuildingCategory.food,
      icon: Icons.water_drop_rounded,
      capitalCostPerLevel: 6,
      moneyCostPerLevel: 7,
      energyConsumption: 12,
      effectsPerLevel: [StatEffect('Food Security', 1.0), StatEffect('Happiness', 0.3)],
    ),

    // ══════════════════ RESOURCES ══════════════════
    BuildingModel(
      id: 'oil_refinery',
      name: 'Oil Refinery',
      description: 'Processes crude oil into fuel and industrial products. Replenishes strategic oil reserves.',
      category: BuildingCategory.resources,
      icon: Icons.local_gas_station_rounded,
      capitalCostPerLevel: 7,
      moneyCostPerLevel: 10,
      energyConsumption: 25,
      effectsPerLevel: [StatEffect('Oil Reserves', 0.8), StatEffect('GDP Growth', 0.2)],
    ),
    BuildingModel(
      id: 'mine_complex',
      name: 'Mining Complex',
      description: 'Industrial-scale extraction of minerals, metals, and strategic raw materials.',
      category: BuildingCategory.resources,
      icon: Icons.landscape_rounded,
      capitalCostPerLevel: 6,
      moneyCostPerLevel: 8,
      energyConsumption: 20,
      effectsPerLevel: [StatEffect('Natural Resources', 0.9), StatEffect('GDP Growth', 0.15)],
    ),
    BuildingModel(
      id: 'research_center',
      name: 'Resource Research Institute',
      description: 'Develops advanced extraction techniques and resource management to maximize yields.',
      category: BuildingCategory.resources,
      icon: Icons.science_rounded,
      capitalCostPerLevel: 6,
      moneyCostPerLevel: 9,
      energyConsumption: 14,
      effectsPerLevel: [
        StatEffect('Natural Resources', 0.5),
        StatEffect('Education', 0.4),
        StatEffect('GDP Growth', 0.1),
      ],
    ),
  ];

  static BuildingModel? byId(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<BuildingModel> byCategory(BuildingCategory cat) =>
      all.where((b) => b.category == cat).toList();

  /// Total MW generated from all power plants at current levels.
  static double calcEnergyCapacity(Map<String, int> levels) {
    double cap = 0;
    for (final b in all) {
      if (b.isPowerPlant) cap += b.energyProductionPerLevel * (levels[b.id] ?? 0);
    }
    return cap;
  }

  /// Total MW consumed by all non-power buildings that are built (level ≥ 1).
  static double calcEnergyConsumption(Map<String, int> levels) {
    double cons = 0;
    for (final b in all) {
      if (!b.isPowerPlant && (levels[b.id] ?? 0) > 0) cons += b.energyConsumption;
    }
    return cons;
  }
}
