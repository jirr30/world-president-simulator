import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/country_coordinates.dart';
import '../../../data/datasources/countries_data.dart';
import '../../../data/datasources/events_data.dart';
import '../../../data/models/country_model.dart';
import '../../../data/models/game_state_model.dart';
import '../../providers/game_provider.dart';

class MapGameScreen extends ConsumerStatefulWidget {
  const MapGameScreen({super.key});

  @override
  ConsumerState<MapGameScreen> createState() => _MapGameScreenState();
}

class _MapGameScreenState extends ConsumerState<MapGameScreen> {
  String? _tappedCountryId;
  bool _showStatsPanel = false;
  Size _mapSize = Size.zero;
  Offset? _pendingTapMap; // in map coordinates (set by GestureDetector inside InteractiveViewer)
  late final TransformationController _transformController;
  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _transformController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final zoom = _transformController.value.getMaxScaleOnAxis();
    if ((zoom - _currentZoom).abs() > 0.08) {
      setState(() => _currentZoom = zoom);
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360 * size.width;
    final latC = lat.clamp(-85.0, 85.0) * pi / 180;
    final mercN = log(tan(pi / 4 + latC / 2));
    final y = size.height * (1 - (mercN + pi) / (2 * pi));
    return Offset(x.clamp(0.0, size.width), y.clamp(0.0, size.height));
  }

  void _handleTap() {
    final mapPos = _pendingTapMap;
    _pendingTapMap = null;
    if (mapPos == null || _mapSize == Size.zero) return;

    // Tap threshold scales inversely with zoom (smaller target in zoomed-out view)
    final threshold = 44.0 / _currentZoom;

    String? nearest;
    double nearestDist = threshold;
    for (final entry in CountryCoordinates.all.entries) {
      final pos = _project(entry.value.dx, entry.value.dy, _mapSize);
      final d = (mapPos - pos).distance;
      if (d < nearestDist) {
        nearestDist = d;
        nearest = entry.key;
      }
    }

    setState(() {
      _tappedCountryId =
          (nearest != null && nearest != _tappedCountryId) ? nearest : null;
      _showStatsPanel = false;
    });
  }

  void _zoomBy(double factor) {
    if (_mapSize == Size.zero) return;
    final m = _transformController.value;
    final currentScale = m.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(1.0, 8.0);
    if ((newScale - currentScale).abs() < 0.01) return;

    // Zoom centered on screen center
    final cx = _mapSize.width / 2;
    final cy = _mapSize.height / 2;
    // focal point in map coords
    final s = currentScale;
    final tx = m[12];
    final ty = m[13];
    final fx = (cx - tx) / s;
    final fy = (cy - ty) / s;
    // New translation to keep focal point at screen center
    final ntx = cx - fx * newScale;
    final nty = cy - fy * newScale;
    // Clamp translation so map stays within screen
    final maxTx = 0.0;
    final minTx = -(newScale - 1) * _mapSize.width;
    final maxTy = 0.0;
    final minTy = -(newScale - 1) * _mapSize.height;

    _transformController.value = Matrix4.identity()
      ..translate(ntx.clamp(minTx, maxTx), nty.clamp(minTy, maxTy))
      ..scale(newScale);
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _onAdvanceYear(GameStateModel game) {
    final state = ref.read(gameProvider.notifier).advanceYear();
    if (state.isTermOver) {
      context.go('/gameover');
      return;
    }
    if (state.currentYear % 3 != 0) {
      final events = EventsData.getRandomEvents(
        count: 1,
        continent: state.country.continent,
      );
      if (events.isNotEmpty) {
        ref.read(pendingEventProvider.notifier).state = events.first;
        context.go('/event');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final approvalColor = AppColors.approvalColor(game.approvalRating);

    CountryModel? tappedCountry;
    if (_tappedCountryId != null) {
      tappedCountry = CountriesData.byId(_tappedCountryId!);
    }
    final showCountryPanel = tappedCountry != null && !_showStatsPanel;
    final isPlayerTapped = _tappedCountryId == game.country.id;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // ── 1. Fullscreen interactive map ──────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              _mapSize = Size(constraints.maxWidth, constraints.maxHeight);
              return InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 8.0,
                boundaryMargin: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _mapSize.width,
                  height: _mapSize.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _pendingTapMap = d.localPosition,
                    onTap: _handleTap,
                    child: CustomPaint(
                      painter: _FullMapPainter(
                        game: game,
                        tappedId: _tappedCountryId,
                        zoom: _currentZoom,
                      ),
                      size: _mapSize,
                    ),
                  ),
                ),
              );
            },
          ),

          // ── 2. Top HUD ─────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _TopHud(
              game: game,
              showingStats: _showStatsPanel,
              onHome: () => _confirmLeave(context),
              onToggleStats: () => setState(() {
                _showStatsPanel = !_showStatsPanel;
                if (_showStatsPanel) _tappedCountryId = null;
              }),
            ),
          ),

          // ── 3. Bottom HUD ──────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomHud(
              game: game,
              approvalColor: approvalColor,
              onPolicies: () => context.go('/policies'),
              onAdvanceYear: () => _onAdvanceYear(game),
            ),
          ),

          // ── 4. Zoom controls ───────────────────────────────────
          Positioned(
            left: 10,
            bottom: 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapBtn(
                  icon: Icons.add_rounded,
                  onTap: () => _zoomBy(1.5),
                ),
                const SizedBox(height: 4),
                _MapBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => _zoomBy(1 / 1.5),
                ),
                if (_currentZoom > 1.2) ...[
                  const SizedBox(height: 4),
                  _MapBtn(
                    icon: Icons.center_focus_strong_rounded,
                    onTap: _resetZoom,
                  ),
                ],
              ],
            ),
          ),

          // ── 5. Country info panel (slides from right) ──────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            right: showCountryPanel ? 0 : -272,
            top: 50, bottom: 60,
            width: 268,
            child: showCountryPanel
                ? _CountryPanel(
                    country: tappedCountry,
                    game: game,
                    isPlayer: isPlayerTapped,
                    onClose: () => setState(() => _tappedCountryId = null),
                  )
                : const SizedBox.shrink(),
          ),

          // ── 6. Stats panel (slides from right) ─────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            right: _showStatsPanel ? 0 : -308,
            top: 50, bottom: 60,
            width: 304,
            child: _StatsPanel(
              game: game,
              approvalColor: approvalColor,
              onClose: () => setState(() => _showStatsPanel = false),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Game?',
            style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins')),
        content: const Text('Game is auto-saved. You can continue from the main menu.',
            style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).leaveGame();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zoom button
// ─────────────────────────────────────────────────────────────────────────────
class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top HUD
// ─────────────────────────────────────────────────────────────────────────────
class _TopHud extends StatelessWidget {
  final GameStateModel game;
  final bool showingStats;
  final VoidCallback onHome;
  final VoidCallback onToggleStats;

  const _TopHud({
    required this.game,
    required this.showingStats,
    required this.onHome,
    required this.onToggleStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xD8071020), Color(0x00071020)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: onHome,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 2),
          Text(game.country.flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  game.country.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${game.leaderTitle}  •  Year ${game.currentYear}  •  Term ${game.yearsInOffice}/${game.termDurationYears}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.save_rounded, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToggleStats,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: showingStats
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : const Color(0x44071020),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: showingStats
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      color: showingStats
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 15),
                  const SizedBox(width: 4),
                  Text(
                    'Stats',
                    style: TextStyle(
                      color: showingStats
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom HUD
// ─────────────────────────────────────────────────────────────────────────────
class _BottomHud extends StatelessWidget {
  final GameStateModel game;
  final Color approvalColor;
  final VoidCallback onPolicies;
  final VoidCallback onAdvanceYear;

  const _BottomHud({
    required this.game,
    required this.approvalColor,
    required this.onPolicies,
    required this.onAdvanceYear,
  });

  @override
  Widget build(BuildContext context) {
    final gdpStr = game.gdpBillion >= 1000
        ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T'
        : '\$${game.gdpBillion.toStringAsFixed(0)}B';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xD8071020), Color(0x00071020)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(56, 18, 12, 8),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${game.approvalRating.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: approvalColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  height: 1.0,
                ),
              ),
              Text(
                'Approval',
                style: TextStyle(
                  color: approvalColor.withValues(alpha: 0.65),
                  fontSize: 9,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          const SizedBox(width: 10),
          _HudChip(
              icon: Icons.trending_up_rounded,
              color: AppColors.economy,
              label: 'GDP',
              value: gdpStr),
          const SizedBox(width: 6),
          _HudChip(
              icon: Icons.sentiment_satisfied_rounded,
              color: AppColors.accent,
              label: 'Happy',
              value: '${game.happiness.toStringAsFixed(0)}%'),
          const SizedBox(width: 6),
          _HudChip(
              icon: Icons.balance_rounded,
              color: AppColors.diplomacy,
              label: 'Stable',
              value: '${game.stability.toStringAsFixed(0)}%'),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onPolicies,
            icon: const Icon(Icons.policy_rounded,
                size: 14, color: AppColors.accent),
            label: const Text(
              'Policies',
              style: TextStyle(
                  color: AppColors.accent,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onAdvanceYear,
            icon: const Icon(Icons.skip_next_rounded,
                size: 15, color: AppColors.background),
            label: Text(
              'Year ${game.currentYear + 1}',
              style: const TextStyle(
                color: AppColors.background,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _HudChip(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 8,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country Info Panel
// ─────────────────────────────────────────────────────────────────────────────
class _CountryPanel extends StatelessWidget {
  final CountryModel country;
  final GameStateModel game;
  final bool isPlayer;
  final VoidCallback onClose;

  const _CountryPanel({
    required this.country,
    required this.game,
    required this.isPlayer,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isAlly = game.alliedCountries.contains(country.name) ||
        game.country.allies.contains(country.name);
    final isRival = game.sanctionedCountries.contains(country.name) ||
        game.country.rivals.contains(country.name);

    final Color relationColor;
    final String relationLabel;
    if (isPlayer) {
      relationColor = AppColors.accent;
      relationLabel = 'Your Nation';
    } else if (isAlly) {
      relationColor = const Color(0xFF4CAF50);
      relationLabel = 'Allied';
    } else if (isRival) {
      relationColor = AppColors.danger;
      relationLabel = 'Rival';
    } else {
      relationColor = AppColors.textSecondary;
      relationLabel = 'Neutral';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: relationColor.withValues(alpha: 0.07),
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(16)),
              border: const Border(
                  bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        country.continent,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: relationColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: relationColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    relationLabel,
                    style: TextStyle(
                      color: relationColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _PanelRow('Capital', country.capital,
                      Icons.location_city_rounded),
                  _PanelRow('Government', _govLabel(country.governmentType),
                      Icons.account_balance_rounded),
                  _PanelRow('Population', country.populationFormatted,
                      Icons.people_rounded),
                  _PanelRow('GDP', country.gdpFormatted,
                      Icons.trending_up_rounded),
                  _PanelRow('GDP / Capita',
                      '\$${country.gdpPerCapita.toStringAsFixed(0)}',
                      Icons.attach_money_rounded),
                  _PanelRow('HDI',
                      country.humanDevelopmentIndex.toStringAsFixed(3),
                      Icons.school_rounded),
                  _PanelRow('Literacy',
                      '${(country.literacyRate * 100).toStringAsFixed(0)}%',
                      Icons.menu_book_rounded),
                  _PanelRow('Unemployment',
                      '${country.unemploymentRate.toStringAsFixed(1)}%',
                      Icons.work_off_rounded),
                  if (country.allies.isNotEmpty)
                    _PanelRow('Allies', country.allies.take(3).join(', '),
                        Icons.handshake_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _govLabel(String type) {
    const labels = <String, String>{
      'democracy': 'Democracy',
      'republic': 'Republic',
      'constitutional_monarchy': 'Const. Monarchy',
      'absolute_monarchy': 'Monarchy',
      'communist': 'Communist',
      'theocracy': 'Theocracy',
      'authoritarian': 'Authoritarian',
      'federal_republic': 'Federal Republic',
      'parliamentary': 'Parliamentary',
      'military_junta': 'Military Junta',
    };
    return labels[type] ?? type.replaceAll('_', ' ');
  }
}

class _PanelRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PanelRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 13),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Panel
// ─────────────────────────────────────────────────────────────────────────────
class _StatsPanel extends StatelessWidget {
  final GameStateModel game;
  final Color approvalColor;
  final VoidCallback onClose;

  const _StatsPanel({
    required this.game,
    required this.approvalColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final gdpStr = game.gdpBillion >= 1000
        ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T'
        : '\$${game.gdpBillion.toStringAsFixed(0)}B';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Text(game.country.flag,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _Section('Approval'),
                _Row('Rating', '${game.approvalRating.toStringAsFixed(0)}%',
                    approvalColor, Icons.thumb_up_rounded),
                const SizedBox(height: 10),
                _Section('Economy'),
                _Row('GDP', gdpStr, AppColors.economy,
                    Icons.trending_up_rounded),
                _Row(
                    'Growth',
                    '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%',
                    game.gdpGrowthRate >= 0
                        ? AppColors.economy
                        : AppColors.danger,
                    Icons.bar_chart_rounded),
                _Row('Inflation',
                    '${game.inflation.toStringAsFixed(1)}%',
                    AppColors.warning, Icons.price_change_rounded),
                _Row('Unemployment',
                    '${game.unemploymentRate.toStringAsFixed(1)}%',
                    AppColors.textSecondary, Icons.work_off_rounded),
                _Row('National Debt',
                    '${game.nationalDebt.toStringAsFixed(0)}% GDP',
                    game.nationalDebt > 80
                        ? AppColors.danger
                        : AppColors.economy,
                    Icons.account_balance_rounded),
                const SizedBox(height: 10),
                _Section('Society'),
                _Row('Happiness',
                    '${game.happiness.toStringAsFixed(0)}%',
                    AppColors.accent, Icons.sentiment_satisfied_rounded),
                _Row('Stability',
                    '${game.stability.toStringAsFixed(0)}%',
                    AppColors.diplomacy, Icons.balance_rounded),
                _Row('Corruption',
                    '${game.corruption.toStringAsFixed(0)}%',
                    game.corruption > 60
                        ? AppColors.danger
                        : AppColors.warning,
                    Icons.warning_amber_rounded),
                _Row('Education',
                    '${game.educationIndex.toStringAsFixed(0)}/100',
                    AppColors.social, Icons.school_rounded),
                _Row('Healthcare',
                    '${game.healthcareIndex.toStringAsFixed(0)}/100',
                    AppColors.social, Icons.local_hospital_rounded),
                const SizedBox(height: 10),
                _Section('Military & Diplomacy'),
                _Row('Military Str.',
                    '${game.militaryStrength.toStringAsFixed(0)}/100',
                    AppColors.military, Icons.shield_rounded),
                _Row('Reputation',
                    '${game.diplomaticReputation.toStringAsFixed(0)}/100',
                    AppColors.diplomacy, Icons.public_rounded),
                if (game.atWar)
                  _Row('Status', 'AT WAR', AppColors.danger,
                      Icons.warning_rounded),
                if (game.activePolicies.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _Section('Active Policies (${game.activePolicies.length})'),
                  ...game.activePolicies.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Icon(p.categoryIcon,
                                color: p.categoryColor, size: 12),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontFamily: 'Poppins',
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _Row(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Continent outlines (lat, lng as Offset.dx, Offset.dy)
// ─────────────────────────────────────────────────────────────────────────────
const List<List<Offset>> _continents = [
  // Eurasia
  [
    Offset(71, -10), Offset(71, 180), Offset(65, 180),
    Offset(60, 163), Offset(50, 145), Offset(42, 132),
    Offset(33, 130), Offset(22, 121), Offset(9, 110),
    Offset(1, 104),  Offset(1, 95),   Offset(5, 77),
    Offset(24, 60),  Offset(22, 57),  Offset(12, 44),
    Offset(30, 32),  Offset(36, 36),  Offset(42, 41),
    Offset(47, 38),  Offset(36, -9),  Offset(43, -9),
    Offset(48, -5),  Offset(55, -7),  Offset(58, -6),
    Offset(71, -10),
  ],
  // Africa
  [
    Offset(37, -5),  Offset(37, 12),  Offset(33, 12),
    Offset(30, 32),  Offset(22, 37),  Offset(12, 51),
    Offset(0, 42),   Offset(-5, 40),  Offset(-12, 40),
    Offset(-26, 35), Offset(-35, 27), Offset(-35, 18),
    Offset(-22, 14), Offset(-7, 12),  Offset(5, 8),
    Offset(5, 2),    Offset(4, -7),   Offset(5, -16),
    Offset(14, -17), Offset(22, -17), Offset(32, -9),
    Offset(37, -5),
  ],
  // North America
  [
    Offset(72, -142), Offset(72, -95), Offset(72, -65),
    Offset(62, -64),  Offset(50, -55), Offset(47, -53),
    Offset(44, -64),  Offset(25, -80), Offset(16, -86),
    Offset(9, -80),   Offset(8, -77),  Offset(20, -105),
    Offset(22, -109), Offset(30, -117),Offset(45, -124),
    Offset(60, -140), Offset(72, -142),
  ],
  // South America
  [
    Offset(12, -72), Offset(10, -62), Offset(8, -59),
    Offset(5, -51),  Offset(-3, -35), Offset(-12, -37),
    Offset(-23, -43),Offset(-33, -52),Offset(-35, -57),
    Offset(-55, -65),Offset(-55, -68),Offset(-45, -74),
    Offset(-35, -73),Offset(-20, -70),Offset(-5, -81),
    Offset(2, -78),  Offset(10, -72), Offset(12, -72),
  ],
  // Australia
  [
    Offset(-12, 114),Offset(-12, 136),Offset(-12, 142),
    Offset(-17, 147),Offset(-24, 154),Offset(-38, 147),
    Offset(-38, 140),Offset(-35, 136),Offset(-38, 129),
    Offset(-35, 117),Offset(-22, 114),Offset(-12, 114),
  ],
  // Greenland
  [
    Offset(83, -30), Offset(76, -18), Offset(70, -22),
    Offset(60, -45), Offset(65, -52), Offset(72, -57),
    Offset(83, -30),
  ],
  // Japan
  [
    Offset(45, 141), Offset(42, 141), Offset(38, 141),
    Offset(34, 137), Offset(32, 131), Offset(34, 130),
    Offset(39, 141), Offset(43, 145), Offset(45, 141),
  ],
  // UK
  [
    Offset(58, -5), Offset(56, -5), Offset(51, -5),
    Offset(51, 2),  Offset(53, 1),  Offset(57, -2),
    Offset(58, -5),
  ],
  // New Zealand
  [
    Offset(-35, 174), Offset(-41, 175), Offset(-46, 170),
    Offset(-46, 168), Offset(-41, 172), Offset(-35, 174),
  ],
  // Madagascar
  [
    Offset(-12, 49), Offset(-16, 50), Offset(-25, 47),
    Offset(-25, 44), Offset(-18, 43), Offset(-12, 49),
  ],
  // Philippines
  [
    Offset(18, 122), Offset(16, 120), Offset(10, 122),
    Offset(8, 124),  Offset(10, 125), Offset(14, 124),
    Offset(18, 122),
  ],
  // Indonesia
  [
    Offset(5, 95),  Offset(3, 106), Offset(-7, 107),
    Offset(-9, 114),Offset(-5, 115),Offset(1, 117),
    Offset(4, 118), Offset(1, 108), Offset(5, 95),
  ],
];

// Countries with a visual territory halo (large/medium landmass)
const Set<String> _largeCountries = {
  'russia', 'canada', 'usa', 'china', 'brazil', 'australia',
  'india', 'argentina', 'kazakhstan', 'algeria', 'saudi_arabia',
  'mexico', 'indonesia', 'iran', 'mongolia', 'peru', 'angola',
  'ethiopia', 'bolivia', 'mali', 'south_africa', 'colombia',
  'egypt', 'pakistan', 'nigeria', 'sudan', 'libya', 'chad',
  'niger', 'mauritania', 'namibia', 'mozambique', 'tanzania',
  'zimbabwe', 'zambia', 'congo_dr',
};

const Set<String> _mediumCountries = {
  'france', 'spain', 'germany', 'ukraine', 'thailand', 'sweden',
  'norway', 'finland', 'poland', 'iraq', 'afghanistan', 'yemen',
  'venezuela', 'chile', 'kenya', 'cameroon', 'ghana', 'senegal',
  'myanmar', 'vietnam', 'morocco', 'uzbekistan', 'malaysia',
  'turkey', 'somalia', 'madagascar', 'central_african_republic',
  'south_sudan', 'botswana', 'paraguay', 'ecuador', 'oman',
};

// ─────────────────────────────────────────────────────────────────────────────
// Fullscreen Map Painter
// ─────────────────────────────────────────────────────────────────────────────
class _FullMapPainter extends CustomPainter {
  final GameStateModel game;
  final String? tappedId;
  final double zoom;

  _FullMapPainter({required this.game, this.tappedId, this.zoom = 1.0});

  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360 * size.width;
    final latC = lat.clamp(-85.0, 85.0) * pi / 180;
    final mercN = log(tan(pi / 4 + latC / 2));
    final y = size.height * (1 - (mercN + pi) / (2 * pi));
    return Offset(x.clamp(0.0, size.width), y.clamp(0.0, size.height));
  }

  double _haloRadius(String id) {
    if (_largeCountries.contains(id)) return 18.0;
    if (_mediumCountries.contains(id)) return 10.0;
    return 0.0; // no halo
  }

  double _dotRadius(String id) {
    if (_largeCountries.contains(id)) return 5.5;
    if (_mediumCountries.contains(id)) return 4.5;
    return 3.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── Ocean ─────────────────────────────────────────────────
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFF0A1628));

    // ── Grid ──────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF16253A)
      ..strokeWidth = 0.8;
    for (var lng = -180; lng <= 180; lng += 30) {
      final x = (lng + 180) / 360 * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var lat = -60; lat <= 60; lat += 30) {
      final y = _project(lat.toDouble(), 0, size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Equator
    final eqY = _project(0, 0, size).dy;
    canvas.drawLine(
      Offset(0, eqY), Offset(size.width, eqY),
      Paint()..color = const Color(0xFF1E3A55)..strokeWidth = 1.2,
    );

    // ── Continent fills ────────────────────────────────────────
    final landFill = Paint()..color = const Color(0xFF162032);
    final landBorder = Paint()
      ..color = const Color(0xFF233554)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

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

    // ── Continent labels ───────────────────────────────────────
    _drawContinentLabels(canvas, size);

    // ── Build relationship sets ────────────────────────────────
    final alliedIds = <String>{};
    final rivalIds = <String>{};
    for (final name in [...game.alliedCountries, ...game.country.allies]) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) alliedIds.add(id);
    }
    for (final name in [...game.sanctionedCountries, ...game.country.rivals]) {
      final id = CountryCoordinates.resolveId(name);
      if (id != null) rivalIds.add(id);
    }
    final playerId = game.country.id;

    // ── Territory halos (drawn before dots) ───────────────────
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;
      final halo = _haloRadius(id);
      if (halo <= 0) continue;
      final pos = _project(entry.value.dx, entry.value.dy, size);
      final Color haloColor;
      if (alliedIds.contains(id)) {
        haloColor = const Color(0xFF4CAF50);
      } else if (rivalIds.contains(id)) {
        haloColor = const Color(0xFFF44336);
      } else {
        haloColor = const Color(0xFF2A4060);
      }
      canvas.drawCircle(
        pos, halo,
        Paint()..color = haloColor.withValues(alpha: 0.12),
      );
    }

    // Player halo
    final playerLatLng = CountryCoordinates.all[playerId];
    if (playerLatLng != null) {
      final pos = _project(playerLatLng.dx, playerLatLng.dy, size);
      canvas.drawCircle(
        pos, 22,
        Paint()..color = AppColors.accent.withValues(alpha: 0.1),
      );
    }

    // ── Country dots ──────────────────────────────────────────
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;
      final pos = _project(entry.value.dx, entry.value.dy, size);
      final radius = _dotRadius(id);

      if (id == tappedId) {
        // Tapped highlight
        canvas.drawCircle(
          pos, radius + 8,
          Paint()..color = Colors.white.withValues(alpha: 0.1),
        );
        canvas.drawCircle(
          pos, radius + 5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.white.withValues(alpha: 0.6),
        );
        canvas.drawCircle(pos, radius + 1, Paint()..color = Colors.white);
      } else if (alliedIds.contains(id)) {
        canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFF4CAF50));
      } else if (rivalIds.contains(id)) {
        canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFFF44336));
      } else {
        canvas.drawCircle(pos, radius - 1, Paint()..color = const Color(0xFF2A4060));
      }
    }

    // ── Country name labels ────────────────────────────────────
    // Always show: player + allies + rivals + tapped
    // At zoom > 2.5: show all countries
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;
      final isAlly = alliedIds.contains(id);
      final isRival = rivalIds.contains(id);
      final isTapped = id == tappedId;
      final showAtThisZoom = zoom >= 2.5;

      if (!isAlly && !isRival && !isTapped && !showAtThisZoom) continue;

      final pos = _project(entry.value.dx, entry.value.dy, size);
      final country = CountriesData.byId(id);
      if (country == null) continue;

      final label = '${country.flag} ${country.name}';
      final Color labelColor;
      if (isTapped) {
        labelColor = Colors.white;
      } else if (isAlly) {
        labelColor = const Color(0xFF66BB6A);
      } else if (isRival) {
        labelColor = const Color(0xFFEF5350);
      } else {
        labelColor = AppColors.textSecondary;
      }

      _drawCountryLabel(canvas, pos, label, labelColor, size);
    }

    // ── Player country (top layer) ─────────────────────────────
    if (playerLatLng != null) {
      final pos = _project(playerLatLng.dx, playerLatLng.dy, size);

      // Glow rings
      for (var ring = 4; ring >= 1; ring--) {
        canvas.drawCircle(
          pos, ring * 6.5,
          Paint()..color = AppColors.accent.withValues(alpha: 0.06 * ring),
        );
      }
      canvas.drawCircle(
        pos, 13,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.drawCircle(pos, 7, Paint()..color = AppColors.accent);

      _drawCountryLabel(
        canvas, pos,
        '${game.country.flag} ${game.country.name}',
        AppColors.accent, size,
        glowing: true,
      );
    }
  }

  void _drawContinentLabels(Canvas canvas, Size size) {
    final entries = [
      (55.0, 20.0, 'EUROPE'),
      (50.0, 90.0, 'ASIA'),
      (5.0,  20.0, 'AFRICA'),
      (40.0, -100.0, 'N. AMERICA'),
      (-20.0, -55.0, 'S. AMERICA'),
      (-25.0, 135.0, 'AUSTRALIA'),
    ];
    for (final e in entries) {
      final pos = _project(e.$1, e.$2, size);
      final tp = TextPainter(
        text: TextSpan(
          text: e.$3,
          style: const TextStyle(
            color: Color(0xFF1E3A55),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawCountryLabel(
    Canvas canvas, Offset pos, String text, Color color, Size mapSize, {
    bool glowing = false,
  }) {
    final style = TextStyle(
      color: color,
      fontSize: glowing ? 11 : 9.5,
      fontWeight: glowing ? FontWeight.w700 : FontWeight.w600,
      shadows: glowing
          ? [Shadow(blurRadius: 5, color: color.withValues(alpha: 0.7))]
          : null,
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 160);

    double lx = pos.dx + (glowing ? 15 : 10);
    double ly = pos.dy - tp.height / 2;
    if (lx + tp.width > mapSize.width - 8) lx = pos.dx - tp.width - (glowing ? 15 : 10);
    if (ly < 20) ly = 20;
    if (ly + tp.height > mapSize.height - 20) ly = mapSize.height - 20 - tp.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lx - 4, ly - 2, tp.width + 8, tp.height + 4),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xCC071020),
    );
    tp.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(covariant _FullMapPainter old) =>
      old.game.country.id != game.country.id ||
      old.game.alliedCountries != game.alliedCountries ||
      old.game.sanctionedCountries != game.sanctionedCountries ||
      old.tappedId != tappedId ||
      (old.zoom < 2.5) != (zoom < 2.5);
}
