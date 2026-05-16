import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/models/game_state_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/stat_card.dart';

class SocialTab extends ConsumerWidget {
  final GameStateModel game;

  const SocialTab({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
              label: l10n.educationIndex,
              value: '${game.educationIndex.toStringAsFixed(0)}/100',
              icon: Icons.school_rounded,
              color: AppColors.social,
              progress: game.educationIndex / 100,
            ),
            StatCard(
              label: l10n.healthcareLabel,
              value: '${game.healthcareIndex.toStringAsFixed(0)}/100',
              icon: Icons.local_hospital_rounded,
              color: AppColors.info,
              progress: game.healthcareIndex / 100,
            ),
            StatCard(
              label: l10n.literacyRate,
              value: '${game.literacyRate.toStringAsFixed(1)}%',
              icon: Icons.menu_book_rounded,
              color: AppColors.social,
              progress: game.literacyRate / 100,
            ),
            StatCard(
              label: l10n.statCorruption,
              value: '${game.corruption.toStringAsFixed(0)}%',
              icon: Icons.gavel_rounded,
              color: game.corruption < 30 ? AppColors.economy : game.corruption < 60 ? AppColors.warning : AppColors.danger,
              progress: game.corruption / 100,
            ),
            StatCard(
              label: l10n.foodSecurity,
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
              label: l10n.agriOutput,
              value: game.agriculturalOutput >= 1000
                  ? '\$${(game.agriculturalOutput / 1000).toStringAsFixed(1)}T'
                  : '\$${game.agriculturalOutput.toStringAsFixed(0)}B',
              icon: Icons.agriculture_rounded,
              color: AppColors.food,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SocialBudgetCard(game: game, ref: ref),
        const SizedBox(height: 16),
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

  String _status(BuildContext context) {
    final l10n = context.l10n;
    final f = game.foodSecurity;
    if (f >= 80) return l10n.foodSurplus;
    if (f >= 60) return l10n.foodSecure;
    if (f >= 40) return l10n.moderateRisk;
    if (f >= 20) return l10n.foodInsecure;
    return l10n.famineCrisis;
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
              Text(
                context.l10n.foodAgricultureStatus,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _status(context),
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
          Text(
            context.l10n.populationOverview,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _PopStat(context.l10n.totalPopulation, _popFormatted, Icons.groups_rounded),
          _PopStat(context.l10n.growthRate, _growthRate, Icons.trending_up_rounded),
          _PopStat(context.l10n.capitalCity, game.country.capital, Icons.location_city_rounded),
          _PopStat(context.l10n.continent, game.country.continent, Icons.public_rounded),
          _PopStat(context.l10n.government, game.country.governmentLabel, Icons.account_balance_rounded),
          _PopStat(context.l10n.happinessScore, '${game.happiness.toStringAsFixed(0)}/100', Icons.sentiment_satisfied_rounded),
        ],
      ),
    );
  }
}

// ─── Social Budget Card ────────────────────────────────────────────────────────

class _SocialBudgetCard extends StatelessWidget {
  final GameStateModel game;
  final WidgetRef ref;

  const _SocialBudgetCard({required this.game, required this.ref});

  String _fmt(double v) {
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}T';
    if (v >= 1) return '\$${v.toStringAsFixed(1)}B';
    return '\$${(v * 1000).toStringAsFixed(0)}M';
  }

  @override
  Widget build(BuildContext context) {
    final maxBudget = game.gdpBillion * 0.08;
    final hcPct = game.healthcareBudget / game.gdpBillion.clamp(1, double.infinity) * 100;
    final edPct = game.educationBudget / game.gdpBillion.clamp(1, double.infinity) * 100;

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
          Text(
            context.l10n.socialInvestment,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.socialInvestmentSub,
            style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11),
          ),
          const SizedBox(height: 16),

          // Healthcare slider
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, color: AppColors.info, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(context.l10n.healthcareLabel, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
              ),
              Text(
                game.healthcareBudget > 0 ? '${_fmt(game.healthcareBudget)} (${hcPct.toStringAsFixed(1)}% GDP)' : context.l10n.none,
                style: TextStyle(color: game.healthcareBudget > 0 ? AppColors.info : AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: game.healthcareBudget.clamp(0.0, maxBudget),
            min: 0.0,
            max: maxBudget,
            divisions: 40,
            activeColor: AppColors.info,
            inactiveColor: AppColors.cardBorder,
            onChanged: (v) => ref.read(gameProvider.notifier).setHealthcareBudget(v),
          ),
          if (game.healthcareBudget > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _EffectChip('+${(hcPct * 0.5).toStringAsFixed(1)} HC/yr', AppColors.info),
                  const SizedBox(width: 6),
                  _EffectChip('+${(hcPct * 0.08).toStringAsFixed(2)} happiness', AppColors.accent),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Education slider
          Row(
            children: [
              const Icon(Icons.school_rounded, color: AppColors.social, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(context.l10n.educationLabel, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
              ),
              Text(
                game.educationBudget > 0 ? '${_fmt(game.educationBudget)} (${edPct.toStringAsFixed(1)}% GDP)' : context.l10n.none,
                style: TextStyle(color: game.educationBudget > 0 ? AppColors.social : AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: game.educationBudget.clamp(0.0, maxBudget),
            min: 0.0,
            max: maxBudget,
            divisions: 40,
            activeColor: AppColors.social,
            inactiveColor: AppColors.cardBorder,
            onChanged: (v) => ref.read(gameProvider.notifier).setEducationBudget(v),
          ),
          if (game.educationBudget > 0)
            Row(
              children: [
                _EffectChip('+${(edPct * 0.5).toStringAsFixed(1)} EDU/yr', AppColors.social),
                const SizedBox(width: 6),
                _EffectChip('-${(edPct * 0.05).toStringAsFixed(2)} corruption', AppColors.economy),
              ],
            ),
        ],
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  final String label;
  final Color color;
  const _EffectChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Population stat row ───────────────────────────────────────────────────────

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
