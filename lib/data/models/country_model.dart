import 'package:flutter/material.dart';

class CountryModel {
  final String id;
  final String name;
  final String capital;
  final String continent;
  final String governmentType;
  final String flag; // emoji flag
  final int population;
  final double gdpBillion;
  final double gdpPerCapita;
  final double militaryBudgetBillion;
  final double humanDevelopmentIndex;
  final double literacyRate;
  final double unemploymentRate;
  final double corruptionIndex;
  final List<String> allies;
  final List<String> rivals;

  const CountryModel({
    required this.id,
    required this.name,
    required this.capital,
    required this.continent,
    required this.governmentType,
    required this.flag,
    required this.population,
    required this.gdpBillion,
    required this.gdpPerCapita,
    required this.militaryBudgetBillion,
    required this.humanDevelopmentIndex,
    required this.literacyRate,
    required this.unemploymentRate,
    required this.corruptionIndex,
    this.allies = const [],
    this.rivals = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        capital: json['capital'] as String,
        continent: json['continent'] as String,
        governmentType: json['governmentType'] as String,
        flag: json['flag'] as String,
        population: json['population'] as int,
        gdpBillion: (json['gdpBillion'] as num).toDouble(),
        gdpPerCapita: (json['gdpPerCapita'] as num).toDouble(),
        militaryBudgetBillion: (json['militaryBudgetBillion'] as num).toDouble(),
        humanDevelopmentIndex: (json['humanDevelopmentIndex'] as num).toDouble(),
        literacyRate: (json['literacyRate'] as num).toDouble(),
        unemploymentRate: (json['unemploymentRate'] as num).toDouble(),
        corruptionIndex: (json['corruptionIndex'] as num).toDouble(),
        allies: List<String>.from(json['allies'] ?? []),
        rivals: List<String>.from(json['rivals'] ?? []),
      );

  Color get continentColor {
    const colors = {
      'Asia': Color(0xFF00BCD4),
      'Europe': Color(0xFF3F51B5),
      'Africa': Color(0xFFFF9800),
      'North America': Color(0xFF4CAF50),
      'South America': Color(0xFF9C27B0),
      'Oceania': Color(0xFFE91E63),
    };
    return colors[continent] ?? const Color(0xFF607D8B);
  }

  String get populationFormatted {
    if (population >= 1000000000) return '${(population / 1000000000).toStringAsFixed(1)}B';
    if (population >= 1000000) return '${(population / 1000000).toStringAsFixed(1)}M';
    if (population >= 1000) return '${(population / 1000).toStringAsFixed(0)}K';
    return population.toString();
  }

  String get gdpFormatted {
    if (gdpBillion >= 1000) return '\$${(gdpBillion / 1000).toStringAsFixed(1)}T';
    return '\$${gdpBillion.toStringAsFixed(0)}B';
  }

  String get governmentLabel {
    const labels = {
      'republic': 'Republic',
      'federal_republic': 'Federal Republic',
      'constitutional_monarchy': 'Constitutional Monarchy',
      'absolute_monarchy': 'Absolute Monarchy',
      'communist': 'Communist State',
      'parliamentary': 'Parliamentary Democracy',
      'theocracy': 'Theocracy',
      'military_junta': 'Military Junta',
    };
    return labels[governmentType] ?? governmentType;
  }

  int get militaryPower => (militaryBudgetBillion * 10).clamp(0, 1000).toInt();
}
