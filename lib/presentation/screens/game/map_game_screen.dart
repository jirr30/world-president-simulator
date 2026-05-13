import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/buildings_data.dart';
import '../../../data/datasources/country_coordinates.dart';
import '../../../data/datasources/countries_data.dart';
import '../../../data/datasources/events_data.dart';
import '../../../data/models/country_model.dart';
import '../../../data/models/game_state_model.dart';
import '../../../services/simulation_engine.dart';
import '../../providers/game_provider.dart';

class MapGameScreen extends ConsumerStatefulWidget {
  const MapGameScreen({super.key});

  @override
  ConsumerState<MapGameScreen> createState() => _MapGameScreenState();
}

class _MapGameScreenState extends ConsumerState<MapGameScreen> {
  String? _tappedCountryId;
  bool _showStatsPanel = false;
  bool _showTutorial = false;
  bool _tutorialChecked = false;
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AdvanceConfirmSheet(
        game: game,
        onConfirm: () {
          Navigator.pop(context);
          _doAdvanceYear(game);
        },
      ),
    );
  }

  void _doAdvanceYear(GameStateModel oldGame) {
    final newState = ref.read(gameProvider.notifier).advanceYear();

    if (newState.approvalRating <= 15.0) {
      context.go('/gameover', extra: 'impeached');
      return;
    }
    if (newState.isTermOver) {
      context.go('/gameover');
      return;
    }

    // Show year summary, then trigger events after dismiss
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) => _YearSummarySheet(
        oldGame: oldGame,
        newGame: newState,
        onDone: () {
          Navigator.pop(context);
          _triggerEvent(newState);
        },
      ),
    ).then((_) => _triggerEvent(newState));
  }

  void _triggerEvent(GameStateModel state) {
    if (state.currentYear % 3 != 0) {
      final events = EventsData.getRandomEvents(count: 1, continent: state.country.continent);
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

    // Show tutorial on first play
    if (!_tutorialChecked) {
      _tutorialChecked = true;
      if (game.yearsInOffice == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showTutorial = true);
        });
      }
    }

    final approvalColor = AppColors.approvalColor(game.approvalRating);

    CountryModel? tappedCountry;
    if (_tappedCountryId != null) {
      tappedCountry = CountriesData.byId(_tappedCountryId!);
    }
    final showCountryPanel = tappedCountry != null && !_showStatsPanel;
    final isPlayerTapped = _tappedCountryId == game.country.id;

    return Scaffold(
      backgroundColor: const Color(0xFF0C2340),
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
                    child: Stack(
                      children: [
                        // ── Accurate world map (SVG with real country borders) ──
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/images/world_map.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        // ── Interactive overlay (markers, labels) ──
                        CustomPaint(
                          painter: _FullMapPainter(
                            game: game,
                            tappedId: _tappedCountryId,
                            zoom: _currentZoom,
                          ),
                          size: _mapSize,
                        ),
                      ],
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
              onBuildings: () => context.go('/buildings'),
              onTreasury: () => _showTreasurySheet(context, game),
              onToggleStats: () => setState(() {
                _showStatsPanel = !_showStatsPanel;
                if (_showStatsPanel) _tappedCountryId = null;
              }),
            ),
          ),

          // ── 3. Critical approval banner ────────────────────────
          if (game.approvalRating <= 20.0)
            Positioned(
              bottom: 62, left: 56, right: 12,
              child: _CriticalApprovalBanner(approval: game.approvalRating),
            ),

          // ── 4. Bottom HUD ──────────────────────────────────────
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

          // ── 7. Tutorial overlay (first play) ───────────────────
          if (_showTutorial)
            Positioned.fill(
              child: _TutorialOverlay(
                onDone: () => setState(() => _showTutorial = false),
              ),
            ),
        ],
      ),
    );
  }

  void _showTreasurySheet(BuildContext context, GameStateModel game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TreasurySheet(game: game),
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
  final VoidCallback onBuildings;
  final VoidCallback onTreasury;

  const _TopHud({
    required this.game,
    required this.showingStats,
    required this.onHome,
    required this.onToggleStats,
    required this.onBuildings,
    required this.onTreasury,
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
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTreasury,
            child: _TreasuryBadge(treasury: game.treasury, tappable: true),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onBuildings,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x44071020),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city_rounded, color: AppColors.resources, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Build',
                    style: TextStyle(color: AppColors.resources, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
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
class _BottomHud extends StatefulWidget {
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
  State<_BottomHud> createState() => _BottomHudState();
}

class _BottomHudState extends State<_BottomHud>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final approvalColor = widget.approvalColor;
    final isWarning = game.approvalRating <= 25.0;
    final isCritical = game.approvalRating <= 18.0;

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
          // Approval display with pulse when at risk
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final glowAlpha = isWarning ? (_pulse.value * 0.35) : 0.0;
              return Container(
                padding: isWarning
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
                    : EdgeInsets.zero,
                decoration: isWarning
                    ? BoxDecoration(
                        color: AppColors.danger.withValues(alpha: glowAlpha * 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: glowAlpha + 0.2),
                          width: 1.5,
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isWarning) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.danger.withValues(alpha: 0.6 + _pulse.value * 0.4),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                        ],
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
                      ],
                    ),
                    Text(
                      isCritical ? 'IMPEACH RISK' : isWarning ? 'Low Approval' : 'Approval',
                      style: TextStyle(
                        color: isWarning
                            ? AppColors.danger.withValues(alpha: 0.55 + _pulse.value * 0.45)
                            : approvalColor.withValues(alpha: 0.65),
                        fontSize: 9,
                        fontFamily: 'Poppins',
                        fontWeight: isWarning ? FontWeight.w700 : FontWeight.normal,
                        letterSpacing: isCritical ? 0.8 : 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
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
          const SizedBox(width: 6),
          _CapitalChip(capital: game.politicalCapital),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: widget.onPolicies,
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
            onPressed: widget.onAdvanceYear,
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

// ─────────────────────────────────────────────────────────────────────────────
// Critical approval banner
// ─────────────────────────────────────────────────────────────────────────────
class _CriticalApprovalBanner extends StatefulWidget {
  final double approval;

  const _CriticalApprovalBanner({required this.approval});

  @override
  State<_CriticalApprovalBanner> createState() => _CriticalApprovalBannerState();
}

class _CriticalApprovalBannerState extends State<_CriticalApprovalBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (widget.approval - 15.0).clamp(0.0, 5.0);
    final label = remaining <= 1
        ? 'CRITICAL — Advance year to trigger impeachment!'
        : 'Approval dangerously low — impeached at 15%';

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15 + _pulse.value * 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.5 + _pulse.value * 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gavel_rounded,
              color: AppColors.danger.withValues(alpha: 0.7 + _pulse.value * 0.3),
              size: 14,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.danger.withValues(alpha: 0.8 + _pulse.value * 0.2),
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.25 + _pulse.value * 0.15),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${widget.approval.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.danger.withValues(alpha: 0.9 + _pulse.value * 0.1),
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HUD chips
// ─────────────────────────────────────────────────────────────────────────────
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

class _TreasuryBadge extends StatelessWidget {
  final double treasury;
  final bool tappable;
  const _TreasuryBadge({required this.treasury, this.tappable = false});

  @override
  Widget build(BuildContext context) {
    final isNeg = treasury < 0;
    final color = isNeg ? AppColors.danger : AppColors.economy;
    final abs = treasury.abs();
    final label = abs >= 1000
        ? '${isNeg ? '-' : ''}\$${(abs / 1000).toStringAsFixed(1)}T'
        : '${isNeg ? '-' : ''}\$${abs.toStringAsFixed(0)}B';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 11, height: 1.1)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.1)),
          if (tappable) ...[
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 12),
          ],
        ],
      ),
    );
  }
}

class _CapitalChip extends StatelessWidget {
  final int capital;
  const _CapitalChip({required this.capital});

  @override
  Widget build(BuildContext context) {
    final isLow = capital < 5;
    final color = isLow ? AppColors.danger : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 11, height: 1.1)),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$capital',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  height: 1.1,
                ),
              ),
              Text(
                'Capital',
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
class _CountryPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAlly    = game.alliedCountries.contains(country.name);
    final nativeAlly    = game.country.allies.contains(country.name);
    final playerSanction = game.sanctionedCountries.contains(country.name);
    final nativeRival   = game.country.rivals.contains(country.name);

    final isAlly  = playerAlly  || nativeAlly;
    final isRival = playerSanction || nativeRival;

    final Color relationColor;
    final String relationLabel;
    if (isPlayer) {
      relationColor = AppColors.accent;
      relationLabel = 'Your Nation';
    } else if (isAlly) {
      relationColor = const Color(0xFF4CAF50);
      relationLabel = playerAlly ? 'Allied' : 'Historic Ally';
    } else if (isRival) {
      relationColor = AppColors.danger;
      relationLabel = playerSanction ? 'Sanctioned' : 'Rival';
    } else {
      relationColor = AppColors.textSecondary;
      relationLabel = 'Neutral';
    }

    final capital = game.politicalCapital;

    void doAction(VoidCallback action, String successMsg, Color color) {
      action();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(successMsg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ));
    }

    void notEnoughCapital(int need) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('💎 Not enough Political Capital (need $need, have $capital)',
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 2),
      ));
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
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: relationColor.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
              border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
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
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: relationColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: relationColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    relationLabel,
                    style: TextStyle(color: relationColor, fontSize: 9, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
          ),

          // ── Country info ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PanelRow('Capital', country.capital, Icons.location_city_rounded),
                  _PanelRow('Government', _govLabel(country.governmentType), Icons.account_balance_rounded),
                  _PanelRow('Population', country.populationFormatted, Icons.people_rounded),
                  _PanelRow('GDP', country.gdpFormatted, Icons.trending_up_rounded),
                  _PanelRow('GDP / Capita', '\$${country.gdpPerCapita.toStringAsFixed(0)}', Icons.attach_money_rounded),
                  _PanelRow('HDI', country.humanDevelopmentIndex.toStringAsFixed(3), Icons.school_rounded),
                  _PanelRow('Literacy', '${(country.literacyRate * 100).toStringAsFixed(0)}%', Icons.menu_book_rounded),
                  _PanelRow('Unemployment', '${country.unemploymentRate.toStringAsFixed(1)}%', Icons.work_off_rounded),
                  if (country.allies.isNotEmpty)
                    _PanelRow('Allies', country.allies.take(3).join(', '), Icons.handshake_rounded),
                ],
              ),
            ),
          ),

          // ── Diplomacy actions ────────────────────────────────
          if (!isPlayer) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIPLOMACY',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'Poppins', fontWeight: FontWeight.w700, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),

                  // Alliance actions
                  if (playerAlly) ...[
                    _DiplomacyButton(
                      icon: Icons.handshake_rounded,
                      label: 'Break Alliance',
                      sub: '💎${SimulationEngine.breakCost} · −8 reputation',
                      color: AppColors.warning,
                      canAfford: capital >= SimulationEngine.breakCost,
                      onTap: () => doAction(
                        () => ref.read(gameProvider.notifier).breakAlliance(country.name),
                        '🤝 Alliance with ${country.name} ended.',
                        AppColors.warning,
                      ),
                      onNoCapital: () => notEnoughCapital(SimulationEngine.breakCost),
                    ),
                  ] else if (nativeAlly) ...[
                    _DiplomacyInfo(
                      icon: Icons.handshake_rounded,
                      label: 'Historic Ally — cannot break',
                      color: const Color(0xFF4CAF50),
                    ),
                  ] else if (!isRival) ...[
                    _DiplomacyButton(
                      icon: Icons.handshake_rounded,
                      label: 'Propose Alliance',
                      sub: '💎${SimulationEngine.allianceCost} · +6 rep · +0.4% GDP',
                      color: const Color(0xFF4CAF50),
                      canAfford: capital >= SimulationEngine.allianceCost,
                      requireRep: game.diplomaticReputation < 30,
                      onTap: () => doAction(
                        () => ref.read(gameProvider.notifier).proposeAlliance(country.name),
                        '🤝 Alliance formed with ${country.name}!',
                        const Color(0xFF4CAF50),
                      ),
                      onNoCapital: () => notEnoughCapital(SimulationEngine.allianceCost),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Sanction actions
                  if (playerSanction) ...[
                    _DiplomacyButton(
                      icon: Icons.gavel_rounded,
                      label: 'Lift Sanctions',
                      sub: '💎${SimulationEngine.liftCost} · +3 reputation',
                      color: AppColors.diplomacy,
                      canAfford: capital >= SimulationEngine.liftCost,
                      onTap: () => doAction(
                        () => ref.read(gameProvider.notifier).liftSanction(country.name),
                        '✅ Sanctions on ${country.name} lifted.',
                        AppColors.diplomacy,
                      ),
                      onNoCapital: () => notEnoughCapital(SimulationEngine.liftCost),
                    ),
                  ] else if (nativeRival) ...[
                    _DiplomacyInfo(
                      icon: Icons.gavel_rounded,
                      label: 'Historic Rival — sanctions fixed',
                      color: AppColors.danger,
                    ),
                  ] else if (!isAlly) ...[
                    _DiplomacyButton(
                      icon: Icons.gavel_rounded,
                      label: 'Impose Sanctions',
                      sub: '💎${SimulationEngine.sanctionCost} · −4 rep · trade hit',
                      color: AppColors.danger,
                      canAfford: capital >= SimulationEngine.sanctionCost,
                      onTap: () => doAction(
                        () => ref.read(gameProvider.notifier).imposeSanction(country.name),
                        '⚠️ Sanctions imposed on ${country.name}.',
                        AppColors.danger,
                      ),
                      onNoCapital: () => notEnoughCapital(SimulationEngine.sanctionCost),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

class _DiplomacyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final bool canAfford;
  final bool requireRep;
  final VoidCallback onTap;
  final VoidCallback onNoCapital;

  const _DiplomacyButton({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.canAfford,
    required this.onTap,
    required this.onNoCapital,
    this.requireRep = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !canAfford || requireRep;
    return GestureDetector(
      onTap: disabled ? (canAfford ? null : onNoCapital) : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: disabled ? AppColors.cardBorder.withValues(alpha: 0.3) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: disabled ? AppColors.cardBorder : color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: disabled ? AppColors.textMuted : color, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requireRep ? '$label (need 30+ rep)' : label,
                    style: TextStyle(
                      color: disabled ? AppColors.textMuted : color,
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: (disabled ? AppColors.textMuted : color).withValues(alpha: 0.7),
                      fontFamily: 'Poppins',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiplomacyInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DiplomacyInfo({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 13),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color.withValues(alpha: 0.6), fontFamily: 'Poppins', fontSize: 10),
            ),
          ),
        ],
      ),
    );
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
                _Row('Political Capital', '💎 ${game.politicalCapital}',
                    AppColors.accent, Icons.star_rounded),
                _Row('Treasury', game.treasuryFormatted,
                    game.treasuryIsNegative ? AppColors.danger : AppColors.economy,
                    Icons.monetization_on_rounded),
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
// Treasury detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _TreasurySheet extends StatelessWidget {
  final GameStateModel game;
  const _TreasurySheet({required this.game});

  @override
  Widget build(BuildContext context) {
    // Budget calculations
    final taxIncome = game.gdpBillion * game.taxRate / 100;
    final baseSpending = game.gdpBillion * 0.20;
    final policySpending = game.activePolicies.fold(0.0, (s, p) => s + p.cost);
    double buildingMaint = 0;
    for (final b in BuildingsData.all) {
      final lvl = game.buildingLevels[b.id] ?? 0;
      if (lvl > 0) buildingMaint += lvl * b.moneyCostPerLevel * 0.02;
    }
    final netPerYear = taxIncome - baseSpending - game.militaryBudget - policySpending - buildingMaint;
    final isNeg = game.treasury < 0;
    final balColor = isNeg ? AppColors.danger : AppColors.economy;
    final netColor = netPerYear >= 0 ? AppColors.economy : AppColors.danger;

    String fmt(double v) {
      final abs = v.abs();
      final sign = v < 0 ? '-' : '+';
      if (abs >= 1000) return '$sign\$${(abs / 1000).toStringAsFixed(1)}T';
      return '$sign\$${abs.toStringAsFixed(0)}B';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Header row
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Treasury & Budget',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 17)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: balColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: balColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Balance', style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(game.treasuryFormatted,
                        style: TextStyle(color: balColor, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 28)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Net / year', style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(fmt(netPerYear),
                        style: TextStyle(color: netColor, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          if (isNeg) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('Treasury defisit — GDP growth dan happiness terdampak',
                        style: TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          const Text('RINCIAN ANGGARAN',
              style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          // Income
          _SheetBudgetRow(Icons.arrow_downward_rounded, 'Pendapatan Pajak', taxIncome, AppColors.economy,
              sub: 'GDP \$${game.gdpBillion >= 1000 ? '${(game.gdpBillion / 1000).toStringAsFixed(1)}T' : '${game.gdpBillion.toStringAsFixed(0)}B'} × ${game.taxRate.toStringAsFixed(0)}%'),
          const _SheetDivider(),

          // Expenses
          _SheetBudgetRow(Icons.arrow_upward_rounded, 'Belanja Pemerintah', -baseSpending, AppColors.danger, sub: '20% dari GDP'),
          _SheetBudgetRow(Icons.shield_rounded, 'Anggaran Militer', -game.militaryBudget, AppColors.military),
          if (policySpending > 0)
            _SheetBudgetRow(Icons.policy_rounded, 'Kebijakan Aktif (${game.activePolicies.length})', -policySpending, AppColors.social,
                sub: 'biaya tahunan gabungan'),
          if (buildingMaint > 0)
            _SheetBudgetRow(Icons.location_city_rounded, 'Perawatan Bangunan', -buildingMaint, AppColors.resources,
                sub: '2%/lv/tahun'),
          const SizedBox(height: 8),

          // Net bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: netColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: netColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net per tahun', style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
                Text(fmt(netPerYear), style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetBudgetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final String? sub;

  const _SheetBudgetRow(this.icon, this.label, this.value, this.color, {this.sub});

  @override
  Widget build(BuildContext context) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    final formatted = abs >= 1000
        ? '$sign\$${(abs / 1000).toStringAsFixed(1)}T'
        : '$sign\$${abs.toStringAsFixed(0)}B';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
                if (sub != null)
                  Text(sub!, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10)),
              ],
            ),
          ),
          Text(formatted,
              style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.cardBorder, height: 1, indent: 40);
}


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
// Advance Year — Confirm Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AdvanceConfirmSheet extends StatelessWidget {
  final GameStateModel game;
  final VoidCallback onConfirm;

  const _AdvanceConfirmSheet({required this.game, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final taxIncome = game.gdpBillion * game.taxRate / 100;
    final baseSpending = game.gdpBillion * 0.20;
    final policySpending = game.activePolicies.fold(0.0, (s, p) => s + p.cost);
    double maint = 0;
    for (final b in BuildingsData.all) {
      final lvl = game.buildingLevels[b.id] ?? 0;
      if (lvl > 0) maint += lvl * b.moneyCostPerLevel * 0.02;
    }
    final net = taxIncome - baseSpending - game.militaryBudget - policySpending - maint;
    final netColor = net >= 0 ? AppColors.economy : AppColors.danger;
    final prevApproval = game.approvalHistory.length >= 2
        ? game.approvalHistory[game.approvalHistory.length - 2]
        : game.approvalRating;
    final approvalTrend = game.approvalRating - prevApproval;

    String _fmt(double v) => v.abs() >= 1000
        ? '\$${(v.abs() / 1000).toStringAsFixed(1)}T'
        : '\$${v.abs().toStringAsFixed(0)}B';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            const Text('⏭️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Advance to Year ${game.currentYear + 1}',
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Term year ${game.yearsInOffice + 1} of ${game.termDurationYears}',
                  style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
            ]),
          ]),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 14),

          // Budget preview
          const Text('BUDGET PROJECTION', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          _ConfirmRow('Tax Revenue', '+${_fmt(taxIncome)}', AppColors.economy),
          _ConfirmRow('Gov. Spending', '-${_fmt(baseSpending)}', AppColors.danger),
          _ConfirmRow('Military', '-${_fmt(game.militaryBudget)}', AppColors.military),
          if (policySpending > 0) _ConfirmRow('Policies', '-${_fmt(policySpending)}', AppColors.social),
          if (maint > 0) _ConfirmRow('Maintenance', '-${_fmt(maint)}', AppColors.resources),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: netColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: netColor.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Net this year', style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${net >= 0 ? '+' : '-'}${_fmt(net)}', style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 14),

          // Approval
          Row(children: [
            const Icon(Icons.thumb_up_rounded, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text('Current approval: ${game.approvalRating.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Text(
              '${approvalTrend >= 0 ? '▲' : '▼'} ${approvalTrend.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: approvalTrend >= 0 ? AppColors.economy : AppColors.danger,
                fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
              ),
            ),
          ]),
          if (game.approvalRating <= 25) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 13),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('Approval critical — impeached if it drops below 15%',
                      style: TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 11)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.skip_next_rounded, size: 16, color: Colors.white),
                label: Text('Advance to ${game.currentYear + 1}',
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ConfirmRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Container(width: 3, height: 11, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12))),
      Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Year Summary Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _YearSummarySheet extends StatelessWidget {
  final GameStateModel oldGame;
  final GameStateModel newGame;
  final VoidCallback onDone;

  const _YearSummarySheet({required this.oldGame, required this.newGame, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final changes = _buildChanges();
    final approvalColor = AppColors.approvalColor(newGame.approvalRating);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Row(children: [
            const Text('📅', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Year ${newGame.currentYear} Summary',
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Political Capital earned: +${newGame.politicalCapital - oldGame.politicalCapital > 0 ? newGame.politicalCapital - oldGame.politicalCapital : 0} 💎',
                  style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
            ])),
            // Approval badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: approvalColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: approvalColor.withValues(alpha: 0.4)),
              ),
              child: Column(children: [
                Text('${newGame.approvalRating.toStringAsFixed(0)}%',
                    style: TextStyle(color: approvalColor, fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, height: 1)),
                Text('Approval', style: TextStyle(color: approvalColor.withValues(alpha: 0.7), fontFamily: 'Poppins', fontSize: 9)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),

          if (changes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('No significant changes this year.', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 13))),
            )
          else ...[
            const Text('STAT CHANGES', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: changes.map((c) => _ChangeBadge(change: c)).toList()),
          ],

          // Low approval warning in summary
          if (newGame.approvalRating <= 25) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  newGame.approvalRating <= 20
                      ? 'CRITICAL: Impeachment imminent if approval drops below 15%!'
                      : 'Warning: Approval at ${newGame.approvalRating.toStringAsFixed(0)}% — take action before next year.',
                  style: const TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
                )),
              ]),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  List<_Change> _buildChanges() {
    final list = <_Change>[];
    void add(String label, String emoji, double before, double after, String unit, {bool lowerIsBetter = false, bool isCurrency = false}) {
      final delta = after - before;
      if (delta.abs() < 0.2) return;
      list.add(_Change(label, emoji, delta, after, unit, lowerIsBetter: lowerIsBetter, isCurrency: isCurrency));
    }
    add('Approval',     '👑', oldGame.approvalRating,     newGame.approvalRating,     '%');
    add('Happiness',    '😊', oldGame.happiness,           newGame.happiness,           '%');
    add('GDP Growth',   '📈', oldGame.gdpGrowthRate,       newGame.gdpGrowthRate,       '%');
    add('Stability',    '⚖️', oldGame.stability,           newGame.stability,           '%');
    add('Inflation',    '💸', oldGame.inflation,            newGame.inflation,            '%', lowerIsBetter: true);
    add('Unemployment', '👷', oldGame.unemploymentRate,    newGame.unemploymentRate,    '%', lowerIsBetter: true);
    add('Diplo. Rep.',  '🌐', oldGame.diplomaticReputation,newGame.diplomaticReputation,'/100');
    add('Food Security','🌾', oldGame.foodSecurity,        newGame.foodSecurity,        '%');
    add('Military',     '🛡️', oldGame.militaryStrength,    newGame.militaryStrength,    '/100');
    add('Treasury',     '🪙', oldGame.treasury,             newGame.treasury,             'B', isCurrency: true);
    return list;
  }
}

class _Change {
  final String label;
  final String emoji;
  final double delta;
  final double newValue;
  final String unit;
  final bool lowerIsBetter;
  final bool isCurrency;
  _Change(this.label, this.emoji, this.delta, this.newValue, this.unit, {this.lowerIsBetter = false, this.isCurrency = false});
  bool get isPositive => lowerIsBetter ? delta < 0 : delta > 0;
}

class _ChangeBadge extends StatelessWidget {
  final _Change change;
  const _ChangeBadge({required this.change});

  @override
  Widget build(BuildContext context) {
    final color = change.isPositive ? AppColors.economy : AppColors.danger;
    final arrow = change.delta > 0 ? '▲' : '▼';
    final String deltaStr;
    if (change.isCurrency) {
      final abs = change.delta.abs();
      deltaStr = abs >= 1000 ? '\$${(abs / 1000).toStringAsFixed(1)}T' : '\$${abs.toStringAsFixed(0)}B';
    } else {
      deltaStr = change.delta.abs().toStringAsFixed(1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(change.emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(change.label, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 9)),
          Row(children: [
            Text('$arrow ', style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
            Text(change.isCurrency ? deltaStr : '$deltaStr${change.unit}',
                style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tutorial Overlay (first play)
// ─────────────────────────────────────────────────────────────────────────────
class _TutorialOverlay extends StatefulWidget {
  final VoidCallback onDone;
  const _TutorialOverlay({required this.onDone});

  @override
  State<_TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<_TutorialOverlay> with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  static const _steps = [
    (Icons.public_rounded,         '🌍 Welcome, World Leader!',     'You are now in charge of a nation. The world map shows all countries — tap any to view details or manage diplomatic relations.', false),
    (Icons.skip_next_rounded,      '⏭️ Advance the Year',            'Tap the "Year XXXX" button to move time forward. Each year your economy, happiness, and approval update based on your choices.', true),
    (Icons.thumb_up_rounded,       '👑 Approval Rating',             'Keep your approval above 15% or you\'ll be impeached! Balance tax rates, policies, and happiness to stay in power.', true),
    (Icons.policy_rounded,         '📋 Policies & Buildings',        'Spend 💎 Political Capital on policies, and 🪙 Treasury on buildings. Always build a Power Plant first — other buildings need electricity!', false),
    (Icons.account_balance_rounded,'🪙 Treasury & Diplomacy',        'Your treasury funds the nation. Tap the 🪙 badge to see the full budget. Tap any country to form alliances or impose sanctions.', false),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      _ctrl.reverse().then((_) {
        setState(() => _step++);
        _ctrl.forward();
      });
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;
    final atBottom = step.$4; // position card at top when true (pointing to bottom HUD)

    return Stack(
      children: [
        // Semi-transparent overlay
        Container(color: Colors.black.withValues(alpha: 0.65)),

        // Tutorial card
        Positioned(
          top: atBottom ? null : null,
          bottom: atBottom ? 75 : null,
          left: 16,
          right: 16,
          // Center vertically when not at bottom
          child: atBottom
              ? FadeTransition(opacity: _fade, child: _buildCard(step, isLast))
              : Center(child: FadeTransition(opacity: _fade, child: _buildCard(step, isLast))),
        ),
      ],
    );
  }

  Widget _buildCard((IconData, String, String, bool) step, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(step.$1, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TIP ${_step + 1}/${_steps.length}',
                    style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10, letterSpacing: 1.0)),
                Text(step.$2,
                    style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15)),
              ])),
            ]),
            const SizedBox(height: 12),
            Text(step.$3,
                style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13, height: 1.6)),
            const SizedBox(height: 16),
            Row(children: [
              // Step dots
              ...List.generate(_steps.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _step ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i == _step ? AppColors.accent : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
              const Spacer(),
              if (!isLast)
                TextButton(
                  onPressed: widget.onDone,
                  child: const Text('Skip', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12)),
                ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isLast ? 'Got it!' : 'Next →',
                    style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

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
    // SVG background handles ocean, land, grid lines, and continent colors.
    // This painter draws only interactive markers on top.

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

    // ── Territory halos for ally/rival countries ──────────────
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;
      final isAlly  = alliedIds.contains(id);
      final isRival = rivalIds.contains(id);
      if (!isAlly && !isRival) continue;
      final halo = _haloRadius(id);
      if (halo <= 0) continue;
      final pos = _project(entry.value.dx, entry.value.dy, size);
      final haloColor = isAlly ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
      canvas.drawCircle(pos, halo,
          Paint()..color = haloColor.withValues(alpha: 0.18));
    }

    // Player halo
    final playerLatLng = CountryCoordinates.all[playerId];
    if (playerLatLng != null) {
      final pos = _project(playerLatLng.dx, playerLatLng.dy, size);
      canvas.drawCircle(
        pos, 26,
        Paint()..color = AppColors.accent.withValues(alpha: 0.12),
      );
    }

    // ── Country markers (only meaningful states) ──────────────
    // Neutral countries have no dot — tap anywhere on the map to select.
    // Only ally (green), rival (red), and tapped (white ring) get markers.
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;
      final isAlly   = alliedIds.contains(id);
      final isRival  = rivalIds.contains(id);
      final isTapped = id == tappedId;
      if (!isAlly && !isRival && !isTapped) continue;

      final pos    = _project(entry.value.dx, entry.value.dy, size);
      final radius = _dotRadius(id);

      if (isTapped) {
        canvas.drawCircle(pos, radius + 8,
            Paint()..color = Colors.white.withValues(alpha: 0.12));
        canvas.drawCircle(pos, radius + 5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = Colors.white.withValues(alpha: 0.7));
        canvas.drawCircle(pos, radius + 1, Paint()..color = Colors.white);
      } else if (isAlly) {
        canvas.drawCircle(pos, radius + 1,
            Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.3));
        canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFF4CAF50));
      } else if (isRival) {
        canvas.drawCircle(pos, radius + 1,
            Paint()..color = const Color(0xFFF44336).withValues(alpha: 0.3));
        canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFFF44336));
      }
    }

    // ── Country name labels ────────────────────────────────────
    // Neutral labels: large=always, medium=zoom≥1.8, small=zoom≥3.0
    // Ally / rival / tapped: always, with colored box.
    for (final entry in CountryCoordinates.all.entries) {
      final id = entry.key;
      if (id == playerId) continue;

      final isAlly   = alliedIds.contains(id);
      final isRival  = rivalIds.contains(id);
      final isTapped = id == tappedId;

      final isLarge  = _largeCountries.contains(id);
      final isMedium = _mediumCountries.contains(id);

      if (!isAlly && !isRival && !isTapped) {
        // Neutral — show based on country size and current zoom
        final minZoom = isLarge ? 1.0 : isMedium ? 1.8 : 3.0;
        if (zoom < minZoom) continue;
      }

      final pos = _project(entry.value.dx, entry.value.dy, size);
      final country = CountriesData.byId(id);
      if (country == null) continue;

      final label = '${country.flag} ${country.name}';

      if (isTapped) {
        _drawCountryLabel(canvas, pos, label, Colors.white, size);
      } else if (isAlly) {
        _drawCountryLabel(canvas, pos, label, const Color(0xFF66BB6A), size);
      } else if (isRival) {
        _drawCountryLabel(canvas, pos, label, const Color(0xFFEF5350), size);
      } else {
        _drawNeutralLabel(canvas, pos, label, size, large: isLarge);
      }
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

  // Simple centered label for neutral countries — no background box, text shadow only.
  void _drawNeutralLabel(Canvas canvas, Offset pos, String text, Size mapSize, {bool large = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xDDFFFFFF),
          fontSize: large ? 9.5 : 8.5,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(blurRadius: 3, color: Color(0xCC000000), offset: Offset(0, 1)),
            Shadow(blurRadius: 6, color: Color(0x88000000)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 150);

    double lx = pos.dx - tp.width / 2;
    double ly = pos.dy + 5;
    lx = lx.clamp(2.0, mapSize.width  - tp.width  - 2);
    ly = ly.clamp(2.0, mapSize.height - tp.height - 2);
    tp.paint(canvas, Offset(lx, ly));
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
      Paint()..color = const Color(0xD0060F1E),
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
