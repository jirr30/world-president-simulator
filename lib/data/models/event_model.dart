import 'package:flutter/material.dart';
import 'policy_model.dart';

class EventChoice {
  final String label;
  final String description;
  final List<StatEffect> effects;

  const EventChoice({
    required this.label,
    required this.description,
    required this.effects,
  });
}

enum EventSeverity { low, medium, high, critical }

class EventModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final EventSeverity severity;
  final List<EventChoice> choices;
  final List<String> applicableContinent; // empty = global

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.severity,
    required this.choices,
    this.applicableContinent = const [],
  });

  Color get severityColor {
    switch (severity) {
      case EventSeverity.low:
        return const Color(0xFF4CAF50);
      case EventSeverity.medium:
        return const Color(0xFFFF9800);
      case EventSeverity.high:
        return const Color(0xFFF44336);
      case EventSeverity.critical:
        return const Color(0xFF9C27B0);
    }
  }

  String get severityLabel {
    switch (severity) {
      case EventSeverity.low:
        return 'Minor';
      case EventSeverity.medium:
        return 'Moderate';
      case EventSeverity.high:
        return 'Serious';
      case EventSeverity.critical:
        return 'Critical';
    }
  }
}
