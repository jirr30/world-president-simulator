import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_state_model.dart';
import '../../widgets/common/stat_card.dart';

class MilitaryTab extends StatelessWidget {
  final GameStateModel game;

  const MilitaryTab({super.key, required this.game});

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
        _MilitaryRankCard(strength: game.militaryStrength),
        const SizedBox(height: 16),
        _StrategicResourcesCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

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
