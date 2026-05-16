import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../widgets/common/stat_card.dart';

class SocialTab extends StatelessWidget {
  final GameStateModel game;

  const SocialTab({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
              label: 'Education Index',
              value: '${game.educationIndex.toStringAsFixed(0)}/100',
              icon: Icons.school_rounded,
              color: AppColors.social,
              progress: game.educationIndex / 100,
            ),
            StatCard(
              label: 'Healthcare',
              value: '${game.healthcareIndex.toStringAsFixed(0)}/100',
              icon: Icons.local_hospital_rounded,
              color: AppColors.info,
              progress: game.healthcareIndex / 100,
            ),
            StatCard(
              label: 'Literacy Rate',
              value: '${game.literacyRate.toStringAsFixed(1)}%',
              icon: Icons.menu_book_rounded,
              color: AppColors.social,
              progress: game.literacyRate / 100,
            ),
            StatCard(
              label: 'Corruption',
              value: '${game.corruption.toStringAsFixed(0)}%',
              icon: Icons.gavel_rounded,
              color: game.corruption < 30 ? AppColors.economy : game.corruption < 60 ? AppColors.warning : AppColors.danger,
              progress: game.corruption / 100,
            ),
            StatCard(
              label: 'Food Security',
              value: '${game.foodSecurity.toStringAsFixed(0)}/100',
              icon: Icons.restaurant_rounded,
              color: game.foodSecurity > 60
                  ? AppColors.food
                  : game.foodSecurity > 35
                      ? AppColors.warning
                      : AppColors.danger,
              progress: game.foodSecurity / 100,
            ),
            StatCard(
              label: 'Agri. Output',
              value: game.agriculturalOutput >= 1000
                  ? '\$${(game.agriculturalOutput / 1000).toStringAsFixed(1)}T'
                  : '\$${game.agriculturalOutput.toStringAsFixed(0)}B',
              icon: Icons.agriculture_rounded,
              color: AppColors.food,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _FoodStatusCard(game: game),
        const SizedBox(height: 16),
        _PopulationCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _FoodStatusCard extends StatelessWidget {
  final GameStateModel game;

  const _FoodStatusCard({required this.game});

  String get _status {
    final f = game.foodSecurity;
    if (f >= 80) return 'Food Surplus';
    if (f >= 60) return 'Food Secure';
    if (f >= 40) return 'Moderate Risk';
    if (f >= 20) return 'Food Insecure';
    return 'Famine Crisis';
  }

  String get _emoji {
    final f = game.foodSecurity;
    if (f >= 80) return '🌾';
    if (f >= 60) return '🥗';
    if (f >= 40) return '⚠️';
    if (f >= 20) return '🍽️';
    return '🆘';
  }

  Color _color(BuildContext context) {
    final f = game.foodSecurity;
    if (f >= 60) return AppColors.food;
    if (f >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Food & Agriculture Status',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _status,
                style: TextStyle(
                  color: color,
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

class _PopulationCard extends StatelessWidget {
  final GameStateModel game;

  const _PopulationCard({required this.game});

  String get _popFormatted {
    final m = game.populationMillions > 0
        ? game.populationMillions
        : game.country.population / 1e6;
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)}B';
    if (m >= 1) return '${m.toStringAsFixed(1)}M';
    return '${(m * 1000).toStringAsFixed(0)}K';
  }

  String get _growthRate {
    final hc = game.healthcareIndex;
    final hap = game.happiness;
    final rate = (1.0 + (hc - 50) * 0.01 + (hap - 50) * 0.005 + (game.atWar ? -0.3 : 0.0)).clamp(0.1, 3.0);
    return '${rate >= 1.0 ? '+' : ''}${rate.toStringAsFixed(2)}%/yr';
  }

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
            'Population Overview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _PopStat('Total Population', _popFormatted, Icons.groups_rounded),
          _PopStat('Growth Rate', _growthRate, Icons.trending_up_rounded),
          _PopStat('Capital City', game.country.capital, Icons.location_city_rounded),
          _PopStat('Continent', game.country.continent, Icons.public_rounded),
          _PopStat('Government', game.country.governmentLabel, Icons.account_balance_rounded),
          _PopStat('Happiness Score', '${game.happiness.toStringAsFixed(0)}/100', Icons.sentiment_satisfied_rounded),
        ],
      ),
    );
  }
}

class _PopStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PopStat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.social, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
