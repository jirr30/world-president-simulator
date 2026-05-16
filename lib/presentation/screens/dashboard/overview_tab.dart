import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/models/game_state_model.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/dashboard/gdp_chart.dart';
import '../../widgets/dashboard/world_map_widget.dart';

class OverviewTab extends StatelessWidget {
  final GameStateModel game;

  const OverviewTab({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left panel: World Map ─────────────────────────────
        Expanded(
          flex: 55,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
            child: WorldMapWidget(game: game),
          ),
        ),

        // ── Divider ───────────────────────────────────────────
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),

        // ── Right panel: Stats ────────────────────────────────
        Expanded(
          flex: 45,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            children: [
              // Quick stats grid (2-col)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: l10n.statHappiness,
                    value: '${game.happiness.toStringAsFixed(0)}%',
                    icon: Icons.sentiment_satisfied_rounded,
                    color: AppColors.accent,
                    progress: game.happiness / 100,
                  ),
                  StatCard(
                    label: l10n.statStability,
                    value: '${game.stability.toStringAsFixed(0)}%',
                    icon: Icons.balance_rounded,
                    color: AppColors.diplomacy,
                    progress: game.stability / 100,
                  ),
                  StatCard(
                    label: l10n.statGdpGrowth,
                    value: '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    color: game.gdpGrowthRate >= 0 ? AppColors.economy : AppColors.danger,
                    subtitle: game.gdpGrowthRate >= 2
                        ? l10n.gdpStatusBooming
                        : game.gdpGrowthRate >= 0
                            ? l10n.gdpStatusStable
                            : l10n.gdpStatusRecession,
                  ),
                  StatCard(
                    label: l10n.statCorruption,
                    value: '${game.corruption.toStringAsFixed(0)}%',
                    icon: Icons.warning_amber_rounded,
                    color: game.corruption < 30
                        ? AppColors.economy
                        : game.corruption < 60
                            ? AppColors.warning
                            : AppColors.danger,
                    progress: game.corruption / 100,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // War status banner
              if (game.atWar) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.atWarBadge, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Poppins', letterSpacing: 1.0)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Military strength: ${game.militaryStrength.toStringAsFixed(0)}/100 · Troops: ${game.troopCount >= 1000 ? '${(game.troopCount / 1000).toStringAsFixed(1)}M' : '${game.troopCount.toStringAsFixed(0)}K'}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins'),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Population row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups_rounded, color: AppColors.social, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.population, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
                    const Spacer(),
                    Text(
                      () {
                        final m = game.populationMillions > 0 ? game.populationMillions : game.country.population / 1e6;
                        if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)}B';
                        if (m >= 1) return '${m.toStringAsFixed(1)}M';
                        return '${(m * 1000).toStringAsFixed(0)}K';
                      }(),
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // GDP + Approval charts side by side
              Row(
                children: [
                  Expanded(
                    child: _MiniChartCard(
                      title: l10n.statGdp,
                      value: game.gdpBillion >= 1000
                          ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T'
                          : '\$${game.gdpBillion.toStringAsFixed(0)}B',
                      color: AppColors.economy,
                      chart: GdpChart(history: game.gdpHistory),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniChartCard(
                      title: l10n.approval,
                      value: '${game.approvalRating.toStringAsFixed(0)}%',
                      color: AppColors.approvalColor(game.approvalRating),
                      chart: GdpChart(
                        history: game.approvalHistory,
                        lineColor: AppColors.approvalColor(game.approvalRating),
                        fixedMinY: 0,
                        fixedMaxY: 100,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Diplomatic Relations
              if (game.alliedCountries.isNotEmpty ||
                  game.sanctionedCountries.isNotEmpty) ...[
                _RelationsCard(game: game),
                const SizedBox(height: 14),
              ],

              // Active Policies
              if (game.activePolicies.isNotEmpty) ...[
                Text(
                  l10n.activePolicies,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...game.activePolicies.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.categoryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(p.categoryIcon, color: p.categoryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          p.categoryLabel,
                          style: TextStyle(
                            color: p.categoryColor,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
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
    );
  }
}

class _RelationsCard extends StatelessWidget {
  final GameStateModel game;

  const _RelationsCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.diplomaticRelations,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          if (game.alliedCountries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.allies,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: game.alliedCountries.take(6)
                  .map((id) => _RelationChip(name: id, isAlly: true))
                  .toList(),
            ),
          ],
          if (game.sanctionedCountries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.rivals,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: game.sanctionedCountries.take(6)
                  .map((id) => _RelationChip(name: id, isAlly: false))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniChartCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Widget chart;

  const _MiniChartCard({required this.title, required this.value, required this.color, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 12)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          chart,
        ],
      ),
    );
  }
}

class _RelationChip extends StatelessWidget {
  final String name;
  final bool isAlly;

  const _RelationChip({required this.name, required this.isAlly});

  @override
  Widget build(BuildContext context) {
    final color = isAlly ? AppColors.economy : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
