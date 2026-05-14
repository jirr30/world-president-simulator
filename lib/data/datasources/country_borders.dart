import 'dart:convert';
import 'package:flutter/services.dart';

/// Polygon-based country hit-testing loaded from assets/data/country_borders.json.
///
/// Each entry is a list of rings (exterior only, [lat, lng] pairs).
/// Loaded once and cached for the app lifetime.
class CountryBorders {
  CountryBorders._();

  static Map<String, List<List<List<double>>>>? _data;

  static Future<void> load() async {
    if (_data != null) return;
    final raw = await rootBundle.loadString('assets/data/country_borders.json');
    final list = jsonDecode(raw) as List;
    _data = {
      for (final entry in list)
        (entry['id'] as String): [
          for (final poly in (entry['p'] as List))
            [for (final pt in (poly as List)) [(pt as List)[0] as double, pt[1] as double]],
        ],
    };
  }

  /// Returns the country ID whose polygon contains [lat]/[lng], or null.
  /// Falls back gracefully if data not loaded yet.
  static String? hitTest(double lat, double lng) {
    final data = _data;
    if (data == null) return null;
    for (final entry in data.entries) {
      for (final ring in entry.value) {
        if (_pointInPolygon(lat, lng, ring)) return entry.key;
      }
    }
    return null;
  }

  // Ray-casting algorithm — casts a horizontal ray east and counts crossings.
  static bool _pointInPolygon(double lat, double lng, List<List<double>> ring) {
    bool inside = false;
    int j = ring.length - 1;
    for (int i = 0; i < ring.length; i++) {
      final yi = ring[i][0], xi = ring[i][1];
      final yj = ring[j][0], xj = ring[j][1];
      if ((yi > lat) != (yj > lat) &&
          lng < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}
