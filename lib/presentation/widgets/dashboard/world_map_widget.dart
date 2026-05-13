import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/datasources/country_coordinates.dart';

class WorldMapWidget extends StatelessWidget {
  final GameStateModel game;

  const WorldMapWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CustomPaint(
              painter: _WorldMapPainter(game: game),
              child: const SizedBox.expand(),
            ),
            // Header overlay
            Positioned(
              top: 10,
              left: 12,
              child: Row(
                children: [
                  const Icon(Icons.public_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    'World Map  •  ${game.country.flag} ${game.country.name}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Legend
            Positioned(
              bottom: 10,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppColors.accent, label: 'You'),
                  const SizedBox(width: 8),
                  _LegendDot(color: const Color(0xFF4CAF50), label: 'Ally'),
                  const SizedBox(width: 8),
                  _LegendDot(color: const Color(0xFFF44336), label: 'Rival'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

// ─── Simplified continent outline polygons ─────────────────────────────────
// Each point is Offset(latitude, longitude)
const List<List<Offset>> _continents = [
  // Eurasia (Europe + Asia as one landmass)
  [
    Offset(71, -10),  Offset(71, 180),  Offset(65, 180),
    Offset(60, 163),  Offset(50, 145),  Offset(42, 132),
    Offset(33, 130),  Offset(22, 121),  Offset(9, 110),
    Offset(1, 104),   Offset(1, 95),    Offset(5, 77),
    Offset(24, 60),   Offset(22, 57),   Offset(12, 44),
    Offset(30, 32),   Offset(36, 36),   Offset(42, 41),
    Offset(47, 38),   Offset(36, -9),   Offset(43, -9),
    Offset(48, -5),   Offset(55, -7),   Offset(58, -6),
    Offset(71, -10),
  ],
  // Africa
  [
    Offset(37, -5),   Offset(37, 12),   Offset(33, 12),
    Offset(30, 32),   Offset(22, 37),   Offset(12, 51),
    Offset(0, 42),    Offset(-5, 40),   Offset(-12, 40),
    Offset(-26, 35),  Offset(-35, 27),  Offset(-35, 18),
    Offset(-22, 14),  Offset(-7, 12),   Offset(5, 8),
    Offset(5, 2),     Offset(4, -7),    Offset(5, -16),
    Offset(14, -17),  Offset(22, -17),  Offset(32, -9),
    Offset(37, -5),
  ],
  // North America (incl. Central America to Panama)
  [
    Offset(72, -142), Offset(72, -95),  Offset(72, -65),
    Offset(62, -64),  Offset(50, -55),  Offset(47, -53),
    Offset(44, -64),  Offset(25, -80),  Offset(16, -86),
    Offset(9, -80),   Offset(8, -77),   Offset(20, -105),
    Offset(22, -109), Offset(30, -117), Offset(45, -124),
    Offset(60, -140), Offset(72, -142),
  ],
  // South America
  [
    Offset(12, -72),  Offset(10, -62),  Offset(8, -59),
    Offset(5, -51),   Offset(-3, -35),  Offset(-12, -37),
    Offset(-23, -43), Offset(-33, -52), Offset(-35, -57),
    Offset(-55, -65), Offset(-55, -68), Offset(-45, -74),
    Offset(-35, -73), Offset(-20, -70), Offset(-5, -81),
    Offset(2, -78),   Offset(10, -72),  Offset(12, -72),
  ],
  // Australia
  [
    Offset(-12, 114), Offset(-12, 136), Offset(-12, 142),
    Offset(-17, 147), Offset(-24, 154), Offset(-38, 147),
    Offset(-38, 140), Offset(-35, 136), Offset(-38, 129),
    Offset(-35, 117), Offset(-22, 114), Offset(-12, 114),
  ],
  // Greenland
  [
    Offset(83, -30),  Offset(76, -18),  Offset(70, -22),
    Offset(60, -45),  Offset(65, -52),  Offset(72, -57),
    Offset(83, -30),
  ],
  // Japan (simplified)
  [
    Offset(45, 141), Offset(42, 141), Offset(38, 141),
    Offset(34, 137), Offset(32, 131), Offset(34, 130),
    Offset(39, 141), Offset(43, 145), Offset(45, 141),
  ],
  // UK (simplified)
  [
    Offset(58, -5),  Offset(56, -5),  Offset(51, -5),
    Offset(51, 2),   Offset(53, 1),   Offset(57, -2),
    Offset(58, -5),
  ],
  // New Zealand (simplified)
  [
    Offset(-35, 174), Offset(-41, 175), Offset(-46, 170),
    Offset(-46, 168), Offset(-41, 172), Offset(-35, 174),
  ],
  // Madagascar
  [
    Offset(-12, 49),  Offset(-16, 50),  Offset(-25, 47),
    Offset(-25, 44),  Offset(-18, 43),  Offset(-12, 49),
  ],
  // Philippines (simplified blob)
  [
    Offset(18, 122), Offset(16, 120), Offset(10, 122),
    Offset(8, 124),  Offset(10, 125), Offset(14, 124),
    Offset(18, 122),
  ],
  // Indonesia main (Sumatra + Java + Kalimantan blob)
  [
    Offset(5, 95),   Offset(3, 106),  Offset(-7, 107),
    Offset(-9, 114), Offset(-5, 115), Offset(1, 117),
    Offset(4, 118),  Offset(1, 108),  Offset(5, 95),
  ],
];

class _WorldMapPainter extends CustomPainter {
  final GameStateModel game;

  const _WorldMapPainter({required this.game});

  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360 * size.width;
    final latC = lat.clamp(-85.0, 85.0) * pi / 180;
    final mercN = log(tan(pi / 4 + latC / 2));
    final y = size.height * (1 - (mercN + pi) / (2 * pi));
    return Offset(x.clamp(0.0, size.width), y.clamp(0.0, size.height));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── Ocean background ──────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0A1628),
    );

    // ── Grid lines ────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF16253A)
      ..strokeWidth = 0.7;
    for (var lng = -180; lng <= 180; lng += 30) {
      final x = (lng + 180) / 360 * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var lat = -60; lat <= 60; lat += 30) {
      final y = _project(lat.toDouble(), 0, size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Equator highlight
    final eqY = _project(0, 0, size).dy;
    canvas.drawLine(
      Offset(0, eqY),
      Offset(size.width, eqY),
      Paint()..color = const Color(0xFF1E3A55)..strokeWidth = 1.0,
    );

    // ── Continents ────────────────────────────────────────────
    final landFill = Paint()..color = const Color(0xFF162032);
    final landBorder = Paint()
      ..color = const Color(0xFF233554)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final outline in _continents) {
      if (outline.isEmpty) continue;
      final path = Path();
      final first = _project(outline.first.dx, outline.first.dy, size);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < outline.length; i++) {
        final pt = _project(outline[i].dx, outline[i].dy, size);
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, landFill);
      canvas.drawPath(path, landBorder);
    }

    // ── Build ally / rival ID sets from game state ────────────
    final alliedIds = <String>{};
    final rivalIds = <String>{};
    for (final name in game.alliedCountries) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) alliedIds.add(id);
    }
    for (final name in game.sanctionedCountries) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) rivalIds.add(id);
    }
    // Also include country's natural allies/rivals from model
    for (final name in game.country.allies) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) alliedIds.add(id);
    }
    for (final name in game.country.rivals) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) rivalIds.add(id);
    }
    final playerId = game.country.id;

    // ── Country dots ──────────────────────────────────────────
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue; // drawn separately on top
      final latLng = entry.value;
      final pos = _project(latLng.dx, latLng.dy, size);

      if (alliedIds.contains(id)) {
        _drawDot(canvas, pos, const Color(0xFF4CAF50), 3.0);
      } else if (rivalIds.contains(id)) {
        _drawDot(canvas, pos, const Color(0xFFF44336), 3.0);
      } else {
        _drawDot(canvas, pos, const Color(0xFF2A4060), 2.0);
      }
    }

    // ── Player's country (highlighted) ───────────────────────
    final playerLatLng = CountryCoordinates.all[playerId];
    if (playerLatLng != null) {
      final pos = _project(playerLatLng.dx, playerLatLng.dy, size);

      // Outer glow rings
      for (var ring = 4; ring >= 1; ring--) {
        canvas.drawCircle(
          pos,
          ring * 5.5,
          Paint()..color = AppColors.accent.withValues(alpha: 0.05 * ring),
        );
      }

      // Pulsing ring
      canvas.drawCircle(
        pos,
        10,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Core dot
      canvas.drawCircle(pos, 5, Paint()..color = AppColors.accent);

      // Country name label
      _drawLabel(canvas, pos, '${game.country.flag} ${game.country.name}', size);
    }
  }

  void _drawDot(Canvas canvas, Offset pos, Color color, double radius) {
    canvas.drawCircle(pos, radius, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Size mapSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          shadows: [Shadow(blurRadius: 4, color: AppColors.accent.withValues(alpha: 0.6))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);

    // Position label to avoid going off screen edges
    double lx = pos.dx + 11;
    double ly = pos.dy - tp.height / 2;
    if (lx + tp.width > mapSize.width - 6) lx = pos.dx - tp.width - 11;
    if (ly < 18) ly = 18;
    if (ly + tp.height > mapSize.height - 18) ly = mapSize.height - 18 - tp.height;

    // Background pill
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(lx - 4, ly - 2, tp.width + 8, tp.height + 4),
      const Radius.circular(5),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xCC071020));

    tp.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter old) =>
      old.game.country.id != game.country.id ||
      old.game.alliedCountries != game.alliedCountries ||
      old.game.sanctionedCountries != game.sanctionedCountries;
}
