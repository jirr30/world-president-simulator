import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../widgets/common/stat_card.dart';

class EconomyTab extends StatelessWidget {
  final GameStateModel game;

  const EconomyTab({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(title: 'Economic Indicators'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              label: 'Total GDP',
              value: game.gdpBillion >= 1000
                  ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T'
                  : '\$${game.gdpBillion.toStringAsFixed(0)}B',
              icon: Icons.account_balance_rounded,
              color: AppColors.economy,
            ),
            StatCard(
              label: 'GDP per Capita',
              value: '\$${game.gdpPerCapita.toStringAsFixed(0)}',
              icon: Icons.person_rounded,
              color: AppColors.economy,
            ),
            StatCard(
              label: 'GDP Growth',
              value: '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
              color: game.gdpGrowthRate >= 0 ? AppColors.economy : AppColors.danger,
            ),
            StatCard(
              label: 'Inflation',
              value: '${game.inflation.toStringAsFixed(1)}%',
              icon: Icons.price_change_rounded,
              color: game.inflation < 4 ? AppColors.economy : game.inflation < 8 ? AppColors.warning : AppColors.danger,
            ),
            StatCard(
              label: 'Unemployment',
              value: '${game.unemploymentRate.toStringAsFixed(1)}%',
              icon: Icons.work_off_rounded,
              color: game.unemploymentRate < 5 ? AppColors.economy : game.unemploymentRate < 10 ? AppColors.warning : AppColors.danger,
              progress: game.unemploymentRate / 60,
            ),
            StatCard(
              label: 'Tax Rate',
              value: '${game.taxRate.toStringAsFixed(0)}%',
              icon: Icons.receipt_long_rounded,
              color: AppColors.diplomacy,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DebtCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  final GameStateModel game;

  const _DebtCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final color = game.nationalDebt < 50
        ? AppColors.economy
        : game.nationalDebt < 100
            ? AppColors.warning
            : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'National Debt',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
              Text(
                '${game.nationalDebt.toStringAsFixed(0)}% of GDP',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (game.nationalDebt / 200).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            game.nationalDebt < 50
                ? 'Healthy debt level — economy is sustainable.'
                : game.nationalDebt < 100
                    ? 'Moderate debt — monitor carefully.'
                    : 'Dangerous debt level — risk of default!',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        fontSize: 16,
      ),
    );
  }
}
