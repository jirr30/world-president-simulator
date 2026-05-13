import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/dashboard/gdp_chart.dart';

class OverviewTab extends StatelessWidget {
  final GameStateModel game;

  const OverviewTab({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            StatCard(
              label: 'Happiness',
              value: '${game.happiness.toStringAsFixed(0)}%',
              icon: Icons.sentiment_satisfied_rounded,
              color: AppColors.accent,
              progress: game.happiness / 100,
            ),
            StatCard(
              label: 'Stability',
              value: '${game.stability.toStringAsFixed(0)}%',
              icon: Icons.balance_rounded,
              color: AppColors.diplomacy,
              progress: game.stability / 100,
            ),
            StatCard(
              label: 'GDP Growth',
              value: '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
              color: game.gdpGrowthRate >= 0 ? AppColors.economy : AppColors.danger,
              subtitle: game.gdpGrowthRate >= 2 ? 'Booming' : game.gdpGrowthRate >= 0 ? 'Stable' : 'Recession',
            ),
            StatCard(
              label: 'Corruption',
              value: '${game.corruption.toStringAsFixed(0)}%',
              icon: Icons.warning_amber_rounded,
              color: game.corruption < 30 ? AppColors.economy : game.corruption < 60 ? AppColors.warning : AppColors.danger,
              progress: game.corruption / 100,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // GDP Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GDP History',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '\$${(game.gdpBillion >= 1000 ? '${(game.gdpBillion / 1000).toStringAsFixed(1)}T' : '${game.gdpBillion.toStringAsFixed(0)}B')}',
                    style: const TextStyle(
                      color: AppColors.economy,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GdpChart(history: game.gdpHistory),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Allies & Rivals
        if (game.alliedCountries.isNotEmpty || game.sanctionedCountries.isNotEmpty) ...[
          _RelationsCard(game: game),
          const SizedBox(height: 16),
        ],
        // Active policies
        if (game.activePolicies.isNotEmpty) ...[
          const Text(
            'Active Policies',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...game.activePolicies.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.categoryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(p.categoryIcon, color: p.categoryColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: p.categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.categoryLabel,
                    style: TextStyle(
                      color: p.categoryColor,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _RelationsCard extends StatelessWidget {
  final GameStateModel game;

  const _RelationsCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diplomatic Relations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          if (game.alliedCountries.isNotEmpty) ...[
            const Text('Allies', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: game.alliedCountries.take(8).map((id) => _RelationChip(id: id, isAlly: true)).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (game.sanctionedCountries.isNotEmpty) ...[
            const Text('Rivals', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: game.sanctionedCountries.take(8).map((id) => _RelationChip(id: id, isAlly: false)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RelationChip extends StatelessWidget {
  final String id;
  final bool isAlly;

  const _RelationChip({required this.id, required this.isAlly});

  @override
  Widget build(BuildContext context) {
    final color = isAlly ? AppColors.economy : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        id,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    );
  }
}
