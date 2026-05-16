import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/country_model.dart';
import '../../../data/datasources/countries_data.dart';
import '../../../services/simulation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/country_flag.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum _Filter { all, allies, neutral, sanctioned }

enum _Rel { playerAlly, nativeAlly, neutral, playerSanctioned, nativeRival }

extension _RelX on _Rel {
  Color get color => switch (this) {
        _Rel.playerAlly => AppColors.economy,
        _Rel.nativeAlly => const Color(0xFF4CAF50),
        _Rel.neutral => AppColors.textSecondary,
        _Rel.playerSanctioned => AppColors.danger,
        _Rel.nativeRival => AppColors.danger,
      };

  String get label => switch (this) {
        _Rel.playerAlly => 'Allied',
        _Rel.nativeAlly => 'Historic Ally',
        _Rel.neutral => 'Neutral',
        _Rel.playerSanctioned => 'Sanctioned',
        _Rel.nativeRival => 'Historic Rival',
      };

  bool get isAlly => this == _Rel.playerAlly || this == _Rel.nativeAlly;
  bool get isSanctioned => this == _Rel.playerSanctioned || this == _Rel.nativeRival;
  int get _order => switch (this) {
        _Rel.playerAlly => 0,
        _Rel.nativeAlly => 1,
        _Rel.neutral => 2,
        _Rel.playerSanctioned => 3,
        _Rel.nativeRival => 4,
      };
}

// ─── Confirmation item data ───────────────────────────────────────────────────

class _ConfirmItem {
  final String text;
  final Color color;
  final IconData icon;
  const _ConfirmItem(this.text, this.color, this.icon);
}

// ─── Main widget ──────────────────────────────────────────────────────────────

class DiplomacyTab extends ConsumerStatefulWidget {
  final GameStateModel game;
  const DiplomacyTab({super.key, required this.game});

  @override
  ConsumerState<DiplomacyTab> createState() => _DiplomacyTabState();
}

class _DiplomacyTabState extends ConsumerState<DiplomacyTab> {
  String _query = '';
  _Filter _filter = _Filter.all;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  GameStateModel get _live => ref.read(gameProvider) ?? widget.game;

  // Compute relation for a country given live game state
  static _Rel _rel(CountryModel c, GameStateModel g) {
    if (g.alliedCountries.contains(c.name)) return _Rel.playerAlly;
    if (g.country.allies.contains(c.name)) return _Rel.nativeAlly;
    if (g.sanctionedCountries.contains(c.name)) return _Rel.playerSanctioned;
    if (g.country.rivals.contains(c.name)) return _Rel.nativeRival;
    return _Rel.neutral;
  }

  // Build sorted + filtered browse list
  List<(CountryModel, _Rel)> _buildList(GameStateModel game) {
    final q = _query.toLowerCase();
    return CountriesData.all
        .where((c) => c.id != game.country.id)
        .map((c) => (c, _rel(c, game)))
        .where((p) {
          if (q.isNotEmpty && !p.$1.name.toLowerCase().contains(q)) return false;
          return switch (_filter) {
            _Filter.all => true,
            _Filter.allies => p.$2.isAlly,
            _Filter.neutral => p.$2 == _Rel.neutral,
            _Filter.sanctioned => p.$2.isSanctioned,
          };
        })
        .toList()
      ..sort((a, b) {
        final c = a.$2._order.compareTo(b.$2._order);
        return c != 0 ? c : a.$1.name.compareTo(b.$1.name);
      });
  }

  // ── Snackbar helper ─────────────────────────────────────────────────────────

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Confirmation bottom sheet ────────────────────────────────────────────────

  Future<bool> _confirm({
    required String title,
    required String flag,
    required String subtitle,
    required List<_ConfirmItem> costItems,
    required List<_ConfirmItem> effectItems,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        title: title,
        flag: flag,
        subtitle: subtitle,
        costItems: costItems,
        effectItems: effectItems,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
      ),
    );
    return result == true;
  }

  // ── Action handlers ──────────────────────────────────────────────────────────

  Future<void> _handleAlly(CountryModel c) async {
    final game = _live;
    final repOk = game.diplomaticReputation >= 30;

    if (!repOk) {
      _snack('Diplomatic reputation too low (need ≥30 to form alliances).', AppColors.danger);
      return;
    }
    if (game.politicalCapital < SimulationEngine.allianceCost) {
      _snack('💎 Not enough Political Capital (need ${SimulationEngine.allianceCost}).', AppColors.danger);
      return;
    }

    final ok = await _confirm(
      title: 'Form Alliance with ${c.name}?',
      flag: c.flag,
      subtitle: '${c.name} · ${c.continent}',
      costItems: [
        _ConfirmItem('💎 ${SimulationEngine.allianceCost} Political Capital', AppColors.danger, Icons.diamond_rounded),
      ],
      effectItems: [
        _ConfirmItem('+6 Diplomatic Reputation', AppColors.diplomacy, Icons.public_rounded),
        _ConfirmItem('+0.4% GDP Growth per year', AppColors.economy, Icons.trending_up_rounded),
        _ConfirmItem('+2 Happiness', AppColors.accent, Icons.sentiment_satisfied_rounded),
        _ConfirmItem('+1.5 Stability per year', AppColors.diplomacy, Icons.balance_rounded),
        _ConfirmItem('+0.1% GDP/yr bonus per total ally', AppColors.economy, Icons.handshake_rounded),
      ],
      confirmLabel: 'Form Alliance',
      confirmColor: AppColors.economy,
    );
    if (!ok || !mounted) return;
    ref.read(gameProvider.notifier).proposeAlliance(c.name);
    _snack('🤝 Alliance formed with ${c.name}!', AppColors.economy);
  }

  Future<void> _handleBreak(CountryModel c) async {
    final game = _live;
    if (game.politicalCapital < SimulationEngine.breakCost) {
      _snack('💎 Not enough Political Capital (need ${SimulationEngine.breakCost}).', AppColors.danger);
      return;
    }

    final ok = await _confirm(
      title: 'Break Alliance with ${c.name}?',
      flag: c.flag,
      subtitle: '${c.name} · ${c.continent}',
      costItems: [
        _ConfirmItem('💎 ${SimulationEngine.breakCost} Political Capital', AppColors.danger, Icons.diamond_rounded),
      ],
      effectItems: [
        _ConfirmItem('-8 Diplomatic Reputation', AppColors.danger, Icons.public_rounded),
        _ConfirmItem('-0.3% GDP Growth', AppColors.danger, Icons.trending_down_rounded),
        _ConfirmItem('Lose ongoing alliance GDP bonus', AppColors.warning, Icons.money_off_rounded),
      ],
      confirmLabel: 'Break Alliance',
      confirmColor: AppColors.warning,
    );
    if (!ok || !mounted) return;
    ref.read(gameProvider.notifier).breakAlliance(c.name);
    _snack('✂️ Alliance with ${c.name} ended.', AppColors.warning);
  }

  Future<void> _handleSanction(CountryModel c) async {
    final game = _live;
    if (game.politicalCapital < SimulationEngine.sanctionCost) {
      _snack('💎 Not enough Political Capital (need ${SimulationEngine.sanctionCost}).', AppColors.danger);
      return;
    }

    final ok = await _confirm(
      title: 'Impose Sanctions on ${c.name}?',
      flag: c.flag,
      subtitle: '${c.name} · ${c.continent}',
      costItems: [
        _ConfirmItem('💎 ${SimulationEngine.sanctionCost} Political Capital', AppColors.danger, Icons.diamond_rounded),
      ],
      effectItems: [
        _ConfirmItem('-4 Diplomatic Reputation', AppColors.danger, Icons.public_rounded),
        _ConfirmItem('-0.05% GDP Growth per sanctioned country/yr', AppColors.danger, Icons.trending_down_rounded),
        _ConfirmItem('Stops ongoing trade benefits', AppColors.warning, Icons.block_rounded),
      ],
      confirmLabel: 'Impose Sanctions',
      confirmColor: AppColors.danger,
    );
    if (!ok || !mounted) return;
    ref.read(gameProvider.notifier).imposeSanction(c.name);
    _snack('⚠️ Sanctions imposed on ${c.name}.', AppColors.danger);
  }

  Future<void> _handleLift(CountryModel c) async {
    final game = _live;
    if (game.politicalCapital < SimulationEngine.liftCost) {
      _snack('💎 Not enough Political Capital (need ${SimulationEngine.liftCost}).', AppColors.danger);
      return;
    }

    final ok = await _confirm(
      title: 'Lift Sanctions on ${c.name}?',
      flag: c.flag,
      subtitle: '${c.name} · ${c.continent}',
      costItems: [
        _ConfirmItem('💎 ${SimulationEngine.liftCost} Political Capital', AppColors.danger, Icons.diamond_rounded),
      ],
      effectItems: [
        _ConfirmItem('+3 Diplomatic Reputation', AppColors.diplomacy, Icons.public_rounded),
        _ConfirmItem('Removes -0.05% GDP drag/yr', AppColors.economy, Icons.trending_up_rounded),
        _ConfirmItem('Opens path to future alliance', AppColors.accent, Icons.handshake_rounded),
      ],
      confirmLabel: 'Lift Sanctions',
      confirmColor: AppColors.diplomacy,
    );
    if (!ok || !mounted) return;
    ref.read(gameProvider.notifier).liftSanction(c.name);
    _snack('✅ Sanctions on ${c.name} lifted.', AppColors.diplomacy);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider) ?? widget.game;
    final browseList = _buildList(game);
    final repOk = game.diplomaticReputation >= 30;

    // Pre-compute left panel lists
    final playerAllies = CountriesData.all
        .where((c) => game.alliedCountries.contains(c.name))
        .toList();
    final playerSanctioned = CountriesData.all
        .where((c) => game.sanctionedCountries.contains(c.name))
        .toList();
    final nativeAllies = CountriesData.all
        .where((c) =>
            game.country.allies.contains(c.name) &&
            !game.alliedCountries.contains(c.name))
        .toList();
    final nativeRivals = CountriesData.all
        .where((c) =>
            game.country.rivals.contains(c.name) &&
            !game.sanctionedCountries.contains(c.name))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left: Active Relations ─────────────────────────────
        SizedBox(
          width: 252,
          child: _LeftPanel(
            game: game,
            playerAllies: playerAllies,
            playerSanctioned: playerSanctioned,
            nativeAllies: nativeAllies,
            nativeRivals: nativeRivals,
            onBreak: _handleBreak,
            onLift: _handleLift,
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),

        // ── Right: Country Browser ─────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BrowserBar(
                controller: _searchCtrl,
                query: _query,
                filter: _filter,
                total: browseList.length,
                onQueryChanged: (q) => setState(() => _query = q),
                onFilterChanged: (f) => setState(() => _filter = f),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
              Expanded(
                child: browseList.isEmpty
                    ? const Center(
                        child: Text(
                          'No countries match your search.',
                          style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 80),
                        itemCount: browseList.length,
                        itemBuilder: (_, i) {
                          final (c, rel) = browseList[i];
                          return _CountryBrowserTile(
                            country: c,
                            rel: rel,
                            capital: game.politicalCapital,
                            repOk: repOk,
                            onAlly: rel == _Rel.neutral ? () => _handleAlly(c) : null,
                            onBreak: rel == _Rel.playerAlly ? () => _handleBreak(c) : null,
                            onSanction: rel == _Rel.neutral ? () => _handleSanction(c) : null,
                            onLift: rel == _Rel.playerSanctioned ? () => _handleLift(c) : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Left Panel — Active Relations ────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  final GameStateModel game;
  final List<CountryModel> playerAllies;
  final List<CountryModel> playerSanctioned;
  final List<CountryModel> nativeAllies;
  final List<CountryModel> nativeRivals;
  final Future<void> Function(CountryModel) onBreak;
  final Future<void> Function(CountryModel) onLift;

  const _LeftPanel({
    required this.game,
    required this.playerAllies,
    required this.playerSanctioned,
    required this.nativeAllies,
    required this.nativeRivals,
    required this.onBreak,
    required this.onLift,
  });

  @override
  Widget build(BuildContext context) {
    final allAllies  = playerAllies.length + nativeAllies.length;
    final allRivals  = playerSanctioned.length + nativeRivals.length;
    final repOk      = game.diplomaticReputation >= 30;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
      children: [
        // Reputation bar
        _RepCard(game: game),
        const SizedBox(height: 12),

        // Summary chips
        Row(
          children: [
            _Chip(Icons.handshake_rounded, '$allAllies Allies', AppColors.economy),
            const SizedBox(width: 6),
            _Chip(Icons.gavel_rounded, '$allRivals Rivals', AppColors.danger),
          ],
        ),
        const SizedBox(height: 6),
        _Chip(
          Icons.trending_up_rounded,
          '+${(playerAllies.length * 0.1).toStringAsFixed(1)}% GDP/yr from alliances',
          AppColors.economy,
          fullWidth: true,
        ),

        // Rep warning
        if (!repOk) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.danger, size: 13),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Rep < 30 — alliances locked.\nImprove reputation to unlock.',
                    style: TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Your alliances
        if (playerAllies.isNotEmpty) ...[
          _LeftHeader('🤝 Your Alliances', playerAllies.length),
          const SizedBox(height: 6),
          ...playerAllies.map((c) => _LeftTile(
                country: c,
                badge: 'Break',
                badgeColor: AppColors.warning,
                canAfford: game.politicalCapital >= SimulationEngine.breakCost,
                cost: '💎${SimulationEngine.breakCost}',
                onTap: () => onBreak(c),
              )),
          const SizedBox(height: 14),
        ],

        // Your sanctions
        if (playerSanctioned.isNotEmpty) ...[
          _LeftHeader('⚖️ Your Sanctions', playerSanctioned.length),
          const SizedBox(height: 6),
          ...playerSanctioned.map((c) => _LeftTile(
                country: c,
                badge: 'Lift',
                badgeColor: AppColors.diplomacy,
                canAfford: game.politicalCapital >= SimulationEngine.liftCost,
                cost: '💎${SimulationEngine.liftCost}',
                onTap: () => onLift(c),
              )),
          const SizedBox(height: 14),
        ],

        // Historic allies
        if (nativeAllies.isNotEmpty) ...[
          _LeftHeader('🏛️ Historic Allies', nativeAllies.length, sub: 'Pre-existing'),
          const SizedBox(height: 6),
          ...nativeAllies.map((c) => _LeftTile(
                country: c,
                badge: 'Historic',
                badgeColor: const Color(0xFF4CAF50),
                canAfford: false,
                cost: '',
                onTap: null,
              )),
          const SizedBox(height: 14),
        ],

        // Historic rivals
        if (nativeRivals.isNotEmpty) ...[
          _LeftHeader('⚔️ Historic Rivals', nativeRivals.length, sub: 'Pre-existing'),
          const SizedBox(height: 6),
          ...nativeRivals.map((c) => _LeftTile(
                country: c,
                badge: 'Rival',
                badgeColor: AppColors.danger,
                canAfford: false,
                cost: '',
                onTap: null,
              )),
        ],

        if (playerAllies.isEmpty && playerSanctioned.isEmpty &&
            nativeAllies.isEmpty && nativeRivals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'No active relations.\nUse the browser →\nto form alliances.',
              style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _RepCard extends StatelessWidget {
  final GameStateModel game;
  const _RepCard({required this.game});

  String get _label {
    final v = game.diplomaticReputation;
    if (v >= 80) return 'Highly Respected';
    if (v >= 60) return 'Well-regarded';
    if (v >= 40) return 'Neutral Standing';
    if (v >= 20) return 'Controversial';
    return 'Pariah State';
  }

  @override
  Widget build(BuildContext context) {
    final v = game.diplomaticReputation;
    final color = v >= 60
        ? AppColors.diplomacy
        : v >= 30
            ? AppColors.warning
            : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public_rounded, color: color, size: 14),
              const SizedBox(width: 6),
              const Text('Diplomatic Reputation',
                  style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 11)),
              const Spacer(),
              Text('${v.toStringAsFixed(0)}/100',
                  style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (v / 100).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 5),
          Text(_label, style: TextStyle(color: color.withValues(alpha: 0.8), fontFamily: 'Poppins', fontSize: 10)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool fullWidth;

  const _Chip(this.icon, this.label, this.color, {this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final inner = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 5),
        Flexible(
          child: Text(label,
              style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ],
    );
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: inner,
    );
  }
}

class _LeftHeader extends StatelessWidget {
  final String title;
  final int count;
  final String? sub;

  const _LeftHeader(this.title, this.count, {this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 12)),
              if (sub != null)
                Text(sub!,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'Poppins')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(8)),
          child: Text('$count',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _LeftTile extends StatelessWidget {
  final CountryModel country;
  final String badge;
  final Color badgeColor;
  final bool canAfford;
  final String cost;
  final VoidCallback? onTap;

  const _LeftTile({
    required this.country,
    required this.badge,
    required this.badgeColor,
    required this.canAfford,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          CountryFlag(flag: country.flag, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(country.continent,
                    style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 9)),
              ],
            ),
          ),
          if (isInteractive)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (canAfford ? badgeColor : AppColors.cardBorder).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: (canAfford ? badgeColor : AppColors.cardBorder).withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(badge,
                        style: TextStyle(
                            color: canAfford ? badgeColor : AppColors.textMuted,
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                    if (cost.isNotEmpty)
                      Text(cost,
                          style: TextStyle(
                              color: (canAfford ? badgeColor : AppColors.textMuted).withValues(alpha: 0.7),
                              fontFamily: 'Poppins',
                              fontSize: 8)),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(badge,
                  style: TextStyle(
                      color: badgeColor.withValues(alpha: 0.8), fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ─── Browser Bar ──────────────────────────────────────────────────────────────

class _BrowserBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final _Filter filter;
  final int total;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_Filter> onFilterChanged;

  const _BrowserBar({
    required this.controller,
    required this.query,
    required this.filter,
    required this.total,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search $total countries…',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 16),
                  suffixIcon: query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onQueryChanged('');
                          },
                          child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.diplomacy)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter chips
          ..._Filter.values.map((f) {
            final selected = filter == f;
            final label = switch (f) {
              _Filter.all => 'All',
              _Filter.allies => 'Allies',
              _Filter.neutral => 'Neutral',
              _Filter.sanctioned => 'Sanctioned',
            };
            final color = switch (f) {
              _Filter.all => AppColors.textSecondary,
              _Filter.allies => AppColors.economy,
              _Filter.neutral => AppColors.diplomacy,
              _Filter.sanctioned => AppColors.danger,
            };
            return Padding(
              padding: const EdgeInsets.only(left: 5),
              child: GestureDetector(
                onTap: () => onFilterChanged(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.18) : AppColors.card,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: selected ? color.withValues(alpha: 0.5) : AppColors.cardBorder),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                        color: selected ? color : AppColors.textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Country Browser Tile ─────────────────────────────────────────────────────

class _CountryBrowserTile extends StatelessWidget {
  final CountryModel country;
  final _Rel rel;
  final int capital;
  final bool repOk;
  final VoidCallback? onAlly;
  final VoidCallback? onBreak;
  final VoidCallback? onSanction;
  final VoidCallback? onLift;

  const _CountryBrowserTile({
    required this.country,
    required this.rel,
    required this.capital,
    required this.repOk,
    this.onAlly,
    this.onBreak,
    this.onSanction,
    this.onLift,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rel.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          // Flag
          CountryFlag(flag: country.flag, size: 30),
          const SizedBox(width: 10),

          // Name + continent + GDP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${country.continent} · ${country.gdpFormatted}',
                  style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10),
                ),
              ],
            ),
          ),

          // Relation badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: rel.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: rel.color.withValues(alpha: 0.25)),
            ),
            child: Text(rel.label,
                style: TextStyle(
                    color: rel.color, fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w700)),
          ),

          // Action buttons
          _ActionButtons(
            rel: rel,
            capital: capital,
            repOk: repOk,
            onAlly: onAlly,
            onBreak: onBreak,
            onSanction: onSanction,
            onLift: onLift,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final _Rel rel;
  final int capital;
  final bool repOk;
  final VoidCallback? onAlly;
  final VoidCallback? onBreak;
  final VoidCallback? onSanction;
  final VoidCallback? onLift;

  const _ActionButtons({
    required this.rel,
    required this.capital,
    required this.repOk,
    this.onAlly,
    this.onBreak,
    this.onSanction,
    this.onLift,
  });

  @override
  Widget build(BuildContext context) {
    return switch (rel) {
      _Rel.playerAlly => _Btn(
          label: 'Break',
          icon: Icons.link_off_rounded,
          color: AppColors.warning,
          enabled: capital >= SimulationEngine.breakCost,
          cost: '💎${SimulationEngine.breakCost}',
          onTap: onBreak,
        ),
      _Rel.playerSanctioned => _Btn(
          label: 'Lift',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.diplomacy,
          enabled: capital >= SimulationEngine.liftCost,
          cost: '💎${SimulationEngine.liftCost}',
          onTap: onLift,
        ),
      _Rel.neutral => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn(
              label: 'Ally',
              icon: Icons.handshake_rounded,
              color: AppColors.economy,
              enabled: repOk && capital >= SimulationEngine.allianceCost,
              cost: repOk ? '💎${SimulationEngine.allianceCost}' : 'Rep<30',
              onTap: onAlly,
            ),
            const SizedBox(width: 5),
            _Btn(
              label: 'Sanction',
              icon: Icons.gavel_rounded,
              color: AppColors.danger,
              enabled: capital >= SimulationEngine.sanctionCost,
              cost: '💎${SimulationEngine.sanctionCost}',
              onTap: onSanction,
            ),
          ],
        ),
      _Rel.nativeAlly => _StaticBadge('Historic Ally', const Color(0xFF4CAF50)),
      _Rel.nativeRival => _StaticBadge('Historic Rival', AppColors.danger),
    };
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final String cost;
  final VoidCallback? onTap;

  const _Btn({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = enabled ? color : AppColors.textMuted;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: c.withValues(alpha: enabled ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: c.withValues(alpha: enabled ? 0.4 : 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 13),
            Text(label,
                style: TextStyle(color: c, fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w700)),
            Text(cost,
                style: TextStyle(color: c.withValues(alpha: 0.7), fontFamily: 'Poppins', fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

class _StaticBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StaticBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label,
          style: TextStyle(
              color: color.withValues(alpha: 0.7), fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Confirmation Bottom Sheet ────────────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String flag;
  final String subtitle;
  final List<_ConfirmItem> costItems;
  final List<_ConfirmItem> effectItems;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmSheet({
    required this.title,
    required this.flag,
    required this.subtitle,
    required this.costItems,
    required this.effectItems,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
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
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cost section
          _SheetSection(
            label: 'ONE-TIME COST',
            color: AppColors.danger,
            items: costItems,
          ),
          const SizedBox(height: 14),

          // Effects section
          _SheetSection(
            label: effectItems.any((i) => i.text.startsWith('+')) ? 'ANNUAL BENEFITS' : 'EFFECTS',
            color: confirmColor,
            items: effectItems,
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(confirmLabel,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String label;
  final Color color;
  final List<_ConfirmItem> items;

  const _SheetSection({required this.label, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.text,
                          style: TextStyle(
                              color: item.color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
