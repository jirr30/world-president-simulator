import 'package:flutter/material.dart';

enum PolicyCategory { economic, military, social, diplomatic }

class StatEffect {
  final String statName;
  final double delta;

  const StatEffect(this.statName, this.delta);

  String get label {
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(0)} $statName';
  }

  Color get color => delta > 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
}

class PolicyModel {
  final String id;
  final String name;
  final String description;
  final PolicyCategory category;
  final List<StatEffect> effects;
  final double cost; // billion USD per year
  final int durationYears; // 0 = permanent
  final bool requiresApproval; // needs parliament approval
  final int minApprovalToApply; // minimum approval rating needed

  const PolicyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.effects,
    required this.cost,
    this.durationYears = 0,
    this.requiresApproval = false,
    this.minApprovalToApply = 0,
  });

  Color get categoryColor {
    switch (category) {
      case PolicyCategory.economic:
        return const Color(0xFF00C853);
      case PolicyCategory.military:
        return const Color(0xFFFF5722);
      case PolicyCategory.social:
        return const Color(0xFF9C27B0);
      case PolicyCategory.diplomatic:
        return const Color(0xFF2196F3);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case PolicyCategory.economic:
        return Icons.trending_up_rounded;
      case PolicyCategory.military:
        return Icons.shield_rounded;
      case PolicyCategory.social:
        return Icons.people_rounded;
      case PolicyCategory.diplomatic:
        return Icons.public_rounded;
    }
  }

  String get categoryLabel {
    switch (category) {
      case PolicyCategory.economic:
        return 'Economic';
      case PolicyCategory.military:
        return 'Military';
      case PolicyCategory.social:
        return 'Social';
      case PolicyCategory.diplomatic:
        return 'Diplomatic';
    }
  }
}
