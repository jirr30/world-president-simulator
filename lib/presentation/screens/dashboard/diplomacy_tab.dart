import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/datasources/countries_data.dart';
import '../../../services/simulation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/country_flag.dart';

class DiplomacyTab extends ConsumerWidget {
  final GameStateModel game;

  const DiplomacyTab({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Player-formed (manageable)
    final playerAllies = game.alliedCountries
        .map((n) => CountriesData.byName(n) ?? CountriesData.byId(n))
        .where((c) => c != null)
        .cast<dynamic>()
        .toList();
    final playerSanctioned = game.sanctionedCountries
        .map((n) => CountriesData.byName(n) ?? CountriesData.byId(n))
        .where((c) => c != null)
        .cast<dynamic>()
        .toList();

    // Native (from country data — display only)
    final nativeAllies = game.country.allies
        .map((n) => CountriesData.byName(n) ?? CountriesData.byId(n))
        .where((c) => c != null)
        .cast<dynamic>()
        .where((c) => !game.alliedCountries.contains(c.name))
        .toList();
    final nativeRivals = game.country.rivals
        .map((n) => CountriesData.byName(n) ?? CountriesData.byId(n))
        .where((c) => c != null)
        .cast<dynamic>()
        .where((c) => !game.sanctionedCountries.contains(c.name))
        .toList();

    void showMsg(String msg, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ));
    }

    void noCapital(int need) => showMsg(
        '💎 Not enough Political Capital (need $need, have ${game.politicalCapital})',
        AppColors.danger);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Reputation stat ──────────────────────────────────
        StatCard(
          label: 'Diplomatic Reputation',
          value: '${game.diplomaticReputation.toStringAsFixed(0)}/100',
          icon: Icons.public_rounded,
          color: AppColors.diplomacy,
          progress: game.diplomaticReputation / 100,
          subtitle: _reputationLabel(game.diplomaticReputation),
        ),
        const SizedBox(height: 12),

        // ── Summary chips ────────────────────────────────────
        Row(
          children: [
            _SummaryChip(
              icon: Icons.handshake_rounded,
              label: '${playerAllies.length + nativeAllies.length} Allies',
              color: AppColors.economy,
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              icon: Icons.gavel_rounded,
              label: '${playerSanctioned.length + nativeRivals.length} Rivals',
              color: AppColors.danger,
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              icon: Icons.trending_up_rounded,
              label: '+${(playerAllies.length * 0.1).toStringAsFixed(1)}% GDP/yr',
              color: AppColors.economy,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Player-formed alliances ──────────────────────────
        if (playerAllies.isNotEmpty) ...[
          _SectionHeader(title: '🤝 Your Alliances', count: playerAllies.length),
          const SizedBox(height: 8),
          ...playerAllies.map((c) => _RelationTile(
            country: c,
            isAlly: true,
            isManageable: true,
            capitalLabel: '💎${SimulationEngine.breakCost} to break',
            actionLabel: 'Break Alliance',
            actionColor: AppColors.warning,
            canAfford: game.politicalCapital >= SimulationEngine.breakCost,
            onAction: () {
              if (game.politicalCapital < SimulationEngine.breakCost) {
                noCapital(SimulationEngine.breakCost);
                return;
              }
              ref.read(gameProvider.notifier).breakAlliance(c.name);
              showMsg('Alliance with ${c.name} ended.', AppColors.warning);
            },
          )),
          const SizedBox(height: 16),
        ],

        // ── Player-imposed sanctions ─────────────────────────
        if (playerSanctioned.isNotEmpty) ...[
          _SectionHeader(title: '⚖️ Your Sanctions', count: playerSanctioned.length),
          const SizedBox(height: 8),
          ...playerSanctioned.map((c) => _RelationTile(
            country: c,
            isAlly: false,
            isManageable: true,
            capitalLabel: '💎${SimulationEngine.liftCost} to lift',
            actionLabel: 'Lift Sanctions',
            actionColor: AppColors.diplomacy,
            canAfford: game.politicalCapital >= SimulationEngine.liftCost,
            onAction: () {
              if (game.politicalCapital < SimulationEngine.liftCost) {
                noCapital(SimulationEngine.liftCost);
                return;
              }
              ref.read(gameProvider.notifier).liftSanction(c.name);
              showMsg('Sanctions on ${c.name} lifted.', AppColors.diplomacy);
            },
          )),
          const SizedBox(height: 16),
        ],

        // ── Native/historic allies ───────────────────────────
        if (nativeAllies.isNotEmpty) ...[
          _SectionHeader(title: '🏛️ Historic Allies', count: nativeAllies.length,
              subtitle: 'Pre-existing — cannot be changed'),
          const SizedBox(height: 8),
          ...nativeAllies.map((c) => _RelationTile(
            country: c,
            isAlly: true,
            isManageable: false,
            capitalLabel: '',
            actionLabel: '',
            actionColor: AppColors.economy,
            canAfford: false,
            onAction: () {},
          )),
          const SizedBox(height: 16),
        ],

        // ── Native/historic rivals ───────────────────────────
        if (nativeRivals.isNotEmpty) ...[
          _SectionHeader(title: '⚔️ Historic Rivals', count: nativeRivals.length,
              subtitle: 'Pre-existing — cannot be changed'),
          const SizedBox(height: 8),
          ...nativeRivals.map((c) => _RelationTile(
            country: c,
            isAlly: false,
            isManageable: false,
            capitalLabel: '',
            actionLabel: '',
            actionColor: AppColors.danger,
            canAfford: false,
            onAction: () {},
          )),
          const SizedBox(height: 16),
        ],

        if (playerAllies.isEmpty && playerSanctioned.isEmpty &&
            nativeAllies.isEmpty && nativeRivals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No diplomatic relations yet.\nTap any country on the map to form alliances or impose sanctions.',
                style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        const SizedBox(height: 80),
      ],
    );
  }

  String _reputationLabel(double v) {
    if (v >= 80) return 'Highly Respected';
    if (v >= 60) return 'Well-regarded';
    if (v >= 40) return 'Neutral Standing';
    if (v >= 20) return 'Controversial';
    return 'Pariah State';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final String? subtitle;

  const _SectionHeader({required this.title, required this.count, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14),
              ),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RelationTile extends StatelessWidget {
  final dynamic country;
  final bool isAlly;
  final bool isManageable;
  final String capitalLabel;
  final String actionLabel;
  final Color actionColor;
  final bool canAfford;
  final VoidCallback onAction;

  const _RelationTile({
    required this.country,
    required this.isAlly,
    required this.isManageable,
    required this.capitalLabel,
    required this.actionLabel,
    required this.actionColor,
    required this.canAfford,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlly ? AppColors.economy : AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CountryFlag(flag: country.flag, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13),
                ),
                Text(
                  country.continent,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          if (isManageable) ...[
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: canAfford
                      ? actionColor.withValues(alpha: 0.12)
                      : AppColors.cardBorder.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: canAfford ? actionColor.withValues(alpha: 0.4) : AppColors.cardBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      actionLabel,
                      style: TextStyle(
                        color: canAfford ? actionColor : AppColors.textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      capitalLabel,
                      style: TextStyle(
                        color: (canAfford ? actionColor : AppColors.textMuted).withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isAlly ? 'Historic' : 'Rival',
                style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
