import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/datasources/countries_data.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/country_flag.dart';

class DiplomacyTab extends StatelessWidget {
  final GameStateModel game;

  const DiplomacyTab({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final allies = game.alliedCountries
        .map((id) => CountriesData.byId(id))
        .where((c) => c != null)
        .toList();
    final rivals = game.sanctionedCountries
        .map((id) => CountriesData.byId(id))
        .where((c) => c != null)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StatCard(
          label: 'Diplomatic Reputation',
          value: '${game.diplomaticReputation.toStringAsFixed(0)}/100',
          icon: Icons.public_rounded,
          color: AppColors.diplomacy,
          progress: game.diplomaticReputation / 100,
          subtitle: _reputationLabel(game.diplomaticReputation),
        ),
        const SizedBox(height: 20),
        if (allies.isNotEmpty) ...[
          const Text(
            '🤝 Allied Nations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...allies.map((c) => _CountryRelationTile(
            country: c!,
            isAlly: true,
          )),
          const SizedBox(height: 20),
        ],
        if (rivals.isNotEmpty) ...[
          const Text(
            '⚔️ Rival Nations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...rivals.map((c) => _CountryRelationTile(
            country: c!,
            isAlly: false,
          )),
        ],
        if (allies.isEmpty && rivals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No formal diplomatic relations yet.\nApply diplomatic policies to build alliances.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
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

class _CountryRelationTile extends StatelessWidget {
  final dynamic country;
  final bool isAlly;

  const _CountryRelationTile({required this.country, required this.isAlly});

  @override
  Widget build(BuildContext context) {
    final color = isAlly ? AppColors.economy : AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CountryFlag(flag: country.flag, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                Text(
                  country.continent,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAlly ? 'Ally' : 'Rival',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
