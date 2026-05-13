import 'package:flutter/material.dart';
import 'policy_model.dart';

enum BuildingCategory { energy, military, food, resources }

class BuildingModel {
  final String id;
  final String name;
  final String description;
  final BuildingCategory category;
  final IconData icon;
  final int capitalCostPerLevel;
  final double moneyCostPerLevel; // billion USD (display only)
  final double energyConsumption; // MW required when any level is built
  final double energyProductionPerLevel; // MW generated per level (power plants)
  final int maxLevel;
  final List<StatEffect> effectsPerLevel; // yearly stat bonus per level owned

  const BuildingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.capitalCostPerLevel,
    required this.moneyCostPerLevel,
    this.energyConsumption = 0,
    this.energyProductionPerLevel = 0,
    this.maxLevel = 5,
    this.effectsPerLevel = const [],
  });

  bool get isPowerPlant => energyProductionPerLevel > 0;

  Color get categoryColor {
    switch (category) {
      case BuildingCategory.energy:
        return const Color(0xFFFFD700);
      case BuildingCategory.military:
        return const Color(0xFFFF5722);
      case BuildingCategory.food:
        return const Color(0xFF76C442);
      case BuildingCategory.resources:
        return const Color(0xFFFF6D00);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case BuildingCategory.energy:
        return Icons.bolt_rounded;
      case BuildingCategory.military:
        return Icons.shield_rounded;
      case BuildingCategory.food:
        return Icons.restaurant_rounded;
      case BuildingCategory.resources:
        return Icons.terrain_rounded;
    }
  }

  String get categoryLabel {
    switch (category) {
      case BuildingCategory.energy:
        return 'Energy';
      case BuildingCategory.military:
        return 'Military';
      case BuildingCategory.food:
        return 'Food';
      case BuildingCategory.resources:
        return 'Resources';
    }
  }
}
