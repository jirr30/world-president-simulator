import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../services/simulation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/stat_card.dart';

class MilitaryTab extends ConsumerWidget {
  final GameStateModel game;

  const MilitaryTab({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            StatCard(
              label: 'Military Strength',
              value: '${game.militaryStrength.toStringAsFixed(0)}/100',
              icon: Icons.shield_rounded,
              color: AppColors.military,
              progress: game.militaryStrength / 100,
            ),
            StatCard(
              label: 'Military Budget',
              value: '\$${game.militaryBudget.toStringAsFixed(1)}B',
              icon: Icons.monetization_on_rounded,
              color: AppColors.military,
              subtitle: '${(game.militaryBudget / game.gdpBillion * 100).toStringAsFixed(1)}% GDP',
            ),
            StatCard(
              label: 'Active Troops',
              value: game.troopCountFormatted,
              icon: Icons.people_rounded,
              color: AppColors.military,
            ),
            StatCard(
              label: 'Readiness',
              value: '${game.militaryReadiness.toStringAsFixed(0)}%',
              icon: Icons.military_tech_rounded,
              color: AppColors.military,
              progress: game.militaryReadiness / 100,
            ),
            StatCard(
              label: 'War Status',
              value: game.atWar ? 'At War' : 'At Peace',
              icon: game.atWar ? Icons.local_fire_department_rounded : Icons.handshake_rounded,
              color: game.atWar ? AppColors.danger : AppColors.economy,
            ),
            StatCard(
              label: 'Stability',
              value: '${game.stability.toStringAsFixed(0)}%',
              icon: Icons.security_rounded,
              color: AppColors.diplomacy,
              progress: game.stability / 100,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _WarControlsCard(game: game, ref: ref),
        const SizedBox(height: 16),
        _MilitaryBudgetSliderCard(game: game, ref: ref),
        const SizedBox(height: 16),
        _MilitaryRankCard(strength: game.militaryStrength),
        const SizedBox(height: 16),
        _StrategicResourcesCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// War Controls
// ─────────────────────────────────────────────────────────────────────────────

class _WarControlsCard extends StatefulWidget {
  final GameStateModel game;
  final WidgetRef ref;

  const _WarControlsCard({required this.game, required this.ref});

  @override
  State<_WarControlsCard> createState() => _WarControlsCardState();
}

class _WarControlsCardState extends State<_WarControlsCard> {
  Future<void> _confirmDeclare() async {
    final capital = widget.game.politicalCapital;
    if (capital < SimulationEngine.warDeclarationCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Need 💎${SimulationEngine.warDeclarationCost} political capital to declare war.',
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.danger,
      ));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚔️  Declare War?',
            style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will put your country on a war footing.',
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            _WarEffectRow('Cost', '💎${SimulationEngine.warDeclarationCost} political capital', AppColors.warning),
            _WarEffectRow('Diplomatic Rep', '−5', AppColors.danger),
            _WarEffectRow('Happiness / yr', '−3.0', AppColors.danger),
            _WarEffectRow('Stability / yr', '−1.5', AppColors.danger),
            _WarEffectRow('GDP Growth / yr', '−1.5%', AppColors.danger),
            _WarEffectRow('Troops / yr', '−15K (losses)', AppColors.danger),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Declare War', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.ref.read(gameProvider.notifier).declareWar();
  }

  Future<void> _confirmPeace() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🕊️  Sue for Peace?',
            style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('End the conflict and return to peacetime.',
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            _WarEffectRow('Cost', '💎${SimulationEngine.peaceCost} political capital', AppColors.warning),
            _WarEffectRow('Happiness', '+5', AppColors.economy),
            _WarEffectRow('Stability', '+3', AppColors.economy),
            _WarEffectRow('Diplomatic Rep', '+3', AppColors.economy),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.economy),
            child: const Text('Sue for Peace', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.ref.read(gameProvider.notifier).sueForPeace();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final atWar = game.atWar;
    final borderColor = atWar ? AppColors.danger : AppColors.cardBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: atWar ? 0.5 : 1.0)),
        gradient: atWar
            ? LinearGradient(
                colors: [AppColors.danger.withValues(alpha: 0.08), AppColors.card],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (atWar ? AppColors.danger : AppColors.military).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  atWar ? Icons.local_fire_department_rounded : Icons.handshake_rounded,
                  color: atWar ? AppColors.danger : AppColors.military,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  atWar ? 'Active Conflict' : 'War & Conflict',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (atWar ? AppColors.danger : AppColors.economy).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  atWar ? 'AT WAR' : 'AT PEACE',
                  style: TextStyle(
                    color: atWar ? AppColors.danger : AppColors.economy,
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          if (atWar) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 10),
            const Text(
              'Ongoing war penalties (per year):',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _WarEffectChip(Icons.mood_bad_rounded, 'Happiness', '−3/yr', AppColors.danger),
                const SizedBox(width: 6),
                _WarEffectChip(Icons.shield_outlined, 'Stability', '−1.5/yr', AppColors.danger),
                const SizedBox(width: 6),
                _WarEffectChip(Icons.trending_down_rounded, 'GDP', '−1.5%/yr', AppColors.danger),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _WarEffectChip(Icons.people_rounded, 'Troops', '−15K/yr', AppColors.danger),
                const SizedBox(width: 6),
                _WarEffectChip(Icons.military_tech_rounded, 'Readiness', '−1/yr', AppColors.danger),
                const SizedBox(width: 6),
                _WarEffectChip(Icons.public_rounded, 'Diplo Rep', '−2/yr', AppColors.danger),
              ],
            ),
            const SizedBox(height: 12),
            if (game.militaryStrength < 25.0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.crisis_alert_rounded, color: AppColors.danger, size: 13),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Military critically weak — peace negotiations will be forced at end of year.',
                        style: TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmPeace,
                icon: const Icon(Icons.handshake_rounded, size: 16),
                label: Text('Sue for Peace  (💎${SimulationEngine.peaceCost})',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.economy,
                  side: const BorderSide(color: AppColors.economy),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Your country is currently at peace.',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'Declaring war will impose severe annual penalties on happiness, stability, and GDP growth until peace is negotiated.',
              style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: game.politicalCapital >= SimulationEngine.warDeclarationCost
                    ? _confirmDeclare
                    : null,
                icon: const Icon(Icons.local_fire_department_rounded, size: 16),
                label: Text('Declare War  (💎${SimulationEngine.warDeclarationCost})',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: game.politicalCapital >= SimulationEngine.warDeclarationCost
                        ? AppColors.danger
                        : AppColors.textMuted,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WarEffectRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _WarEffectRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12))),
          Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WarEffectChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WarEffectChip(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 10),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontFamily: 'Poppins', fontSize: 9)),
            ]),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Military Budget Slider
// ─────────────────────────────────────────────────────────────────────────────

class _MilitaryBudgetSliderCard extends StatefulWidget {
  final GameStateModel game;
  final WidgetRef ref;

  const _MilitaryBudgetSliderCard({required this.game, required this.ref});

  @override
  State<_MilitaryBudgetSliderCard> createState() => _MilitaryBudgetSliderCardState();
}

class _MilitaryBudgetSliderCardState extends State<_MilitaryBudgetSliderCard> {
  late double _draftPct; // percentage of GDP

  @override
  void initState() {
    super.initState();
    _draftPct = _currentPct.clamp(0.5, 15.0);
  }

  @override
  void didUpdateWidget(_MilitaryBudgetSliderCard old) {
    super.didUpdateWidget(old);
    // Resync when a year passes (GDP changes, budget stays same → ratio shifts)
    if (old.game.currentYear != widget.game.currentYear) {
      _draftPct = _currentPct.clamp(0.5, 15.0);
    }
  }

  double get _currentPct =>
      widget.game.militaryBudget / widget.game.gdpBillion.clamp(1.0, double.infinity) * 100;

  double get _draftBudget => widget.game.gdpBillion * _draftPct / 100;

  double get _strengthEffect => (_draftPct - 2.5) * 0.25;
  double get _readinessEffect => _draftPct >= 3.0 ? 0.4 : _draftPct >= 1.5 ? 0.0 : -0.5;
  double get _troopEffect => _draftPct >= 4.0 ? 3.0 : _draftPct >= 2.0 ? 0.0 : -2.0;

  bool get _changed => (_draftPct - _currentPct).abs() >= 0.1;

  String _fmt(double v) {
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}T';
    return '\$${v.toStringAsFixed(1)}B';
  }

  String _fmtEffect(double v, String unit) {
    final sign = v >= 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(1)}$unit/yr';
  }

  String get _label {
    if (_draftPct < 1.0) return 'Minimal — defense capability degrading';
    if (_draftPct < 2.0) return 'Low — basic deterrence only';
    if (_draftPct < 3.5) return 'Moderate — balanced defense';
    if (_draftPct < 6.0) return 'High — strong regional power';
    if (_draftPct < 10.0) return 'Very High — major military investment';
    return 'Maximum — full military-industrial complex';
  }

  Color get _labelColor {
    if (_draftPct < 1.5) return AppColors.danger;
    if (_draftPct < 3.5) return AppColors.economy;
    if (_draftPct < 8.0) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.military.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.military.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded, color: AppColors.military, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Military Budget',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 15),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmt(_draftBudget),
                    style: const TextStyle(color: AppColors.military, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 20),
                  ),
                  Text(
                    '${_draftPct.toStringAsFixed(1)}% of GDP',
                    style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.military,
              inactiveTrackColor: AppColors.military.withValues(alpha: 0.2),
              thumbColor: AppColors.military,
              overlayColor: AppColors.military.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _draftPct,
              min: 0.5,
              max: 15.0,
              divisions: 29,
              onChanged: (v) => setState(() => _draftPct = v),
              onChangeEnd: (v) {
                widget.ref.read(gameProvider.notifier).setMilitaryBudget(
                  widget.game.gdpBillion * v / 100,
                );
              },
            ),
          ),

          // Range labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0.5%', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
                const Text('15%', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _labelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _label,
              style: TextStyle(color: _labelColor, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          // Effect chips
          Row(
            children: [
              _EffectChip(
                icon: Icons.shield_rounded,
                label: 'Strength',
                value: _fmtEffect(_strengthEffect, ''),
                color: _strengthEffect >= 0 ? AppColors.military : AppColors.danger,
              ),
              const SizedBox(width: 8),
              _EffectChip(
                icon: Icons.military_tech_rounded,
                label: 'Readiness',
                value: _fmtEffect(_readinessEffect, ''),
                color: _readinessEffect >= 0 ? AppColors.military : AppColors.danger,
              ),
              const SizedBox(width: 8),
              _EffectChip(
                icon: Icons.people_rounded,
                label: 'Troops',
                value: _fmtEffect(_troopEffect, 'K'),
                color: _troopEffect >= 0 ? AppColors.military : AppColors.danger,
              ),
            ],
          ),

          if (_changed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.military, size: 13),
                const SizedBox(width: 5),
                Text(
                  'New budget ${_draftPct.toStringAsFixed(1)}% GDP (${_fmt(_draftBudget)}) takes effect next year.',
                  style: const TextStyle(color: AppColors.military, fontFamily: 'Poppins', fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EffectChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 11),
                const SizedBox(width: 3),
                Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontFamily: 'Poppins', fontSize: 10)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strategic Resources
// ─────────────────────────────────────────────────────────────────────────────

class _StrategicResourcesCard extends StatelessWidget {
  final GameStateModel game;

  const _StrategicResourcesCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.resources.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Strategic Resources',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          _ResourceBar(
            label: 'Natural Resources',
            value: game.naturalResourceIndex,
            icon: Icons.terrain_rounded,
            color: AppColors.resources,
          ),
          const SizedBox(height: 10),
          _ResourceBar(
            label: 'Oil & Energy Reserves',
            value: game.oilReserves,
            icon: Icons.local_gas_station_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _ResourceBar extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _ResourceBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}/100',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Military Rank
// ─────────────────────────────────────────────────────────────────────────────

class _MilitaryRankCard extends StatelessWidget {
  final double strength;

  const _MilitaryRankCard({required this.strength});

  String get _rank {
    if (strength >= 90) return 'Global Superpower';
    if (strength >= 75) return 'Major Military Power';
    if (strength >= 55) return 'Regional Power';
    if (strength >= 35) return 'Moderate Force';
    if (strength >= 15) return 'Limited Capability';
    return 'Minimal Defense';
  }

  String get _emoji {
    if (strength >= 90) return '⭐';
    if (strength >= 75) return '🔱';
    if (strength >= 55) return '🛡️';
    if (strength >= 35) return '⚔️';
    return '🪖';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.military.withValues(alpha: 0.2), AppColors.militaryDark.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.military.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Military Classification',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _rank,
                style: const TextStyle(
                  color: AppColors.military,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
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
