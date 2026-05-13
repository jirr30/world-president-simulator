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
          ],
        ),
        const SizedBox(height: 20),
        _PopulationCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _PopulationCard extends StatelessWidget {
  final GameStateModel game;

  const _PopulationCard({required this.game});

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
          _PopStat('Total Population', game.country.populationFormatted, Icons.groups_rounded),
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
