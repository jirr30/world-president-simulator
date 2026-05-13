import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/buildings_data.dart';
import '../../../data/models/game_state_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/stat_card.dart';

class EconomyTab extends ConsumerWidget {
  final GameStateModel game;

  const EconomyTab({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        _TaxSliderCard(game: game, ref: ref),
        const SizedBox(height: 16),
        _TreasuryCard(game: game),
        const SizedBox(height: 16),
        _DebtCard(game: game),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _TaxSliderCard extends StatefulWidget {
  final GameStateModel game;
  final WidgetRef ref;

  const _TaxSliderCard({required this.game, required this.ref});

  @override
  State<_TaxSliderCard> createState() => _TaxSliderCardState();
}

class _TaxSliderCardState extends State<_TaxSliderCard> {
  late double _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.game.taxRate;
  }

  @override
  void didUpdateWidget(_TaxSliderCard old) {
    super.didUpdateWidget(old);
    // Sync only if the saved value changed externally (year advance)
    if ((old.game.taxRate - widget.game.taxRate).abs() > 0.1 &&
        (_draft - old.game.taxRate).abs() < 0.1) {
      _draft = widget.game.taxRate;
    }
  }

  String get _label {
    if (_draft < 10) return 'Ultra Low — private sector surge';
    if (_draft < 15) return 'Very Low — minimal public services';
    if (_draft < 20) return 'Low — lean government';
    if (_draft < 28) return 'Moderate — balanced budget';
    if (_draft < 35) return 'High — strong public investment';
    if (_draft < 45) return 'Very High — risk of capital flight';
    return 'Extreme — severe economic drag';
  }

  Color get _labelColor {
    if (_draft < 15) return AppColors.economy;
    if (_draft < 28) return AppColors.economy;
    if (_draft < 35) return AppColors.warning;
    if (_draft < 45) return AppColors.warning;
    return AppColors.danger;
  }

  // GDP growth effect relative to 25% baseline
  double get _gdpEffect {
    final taxDelta = (_draft - 25.0) / 5.0;
    double effect = -(taxDelta * 0.25);
    if (_draft < 15) effect += 0.5;
    return effect;
  }

  // Happiness effect relative to 25% baseline
  double get _happinessEffect {
    final taxDelta = (_draft - 25.0) / 5.0;
    double effect = -(taxDelta * 0.4);
    if (_draft < 15) effect -= 0.5;
    return effect;
  }

  double get _projectedIncome => widget.game.gdpBillion * _draft / 100;

  bool get _changed => (_draft - widget.game.taxRate).abs() >= 0.5;

  @override
  Widget build(BuildContext context) {
    final incomeStr = _projectedIncome >= 1000
        ? '\$${(_projectedIncome / 1000).toStringAsFixed(1)}T'
        : '\$${_projectedIncome.toStringAsFixed(0)}B';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.diplomacy.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.diplomacy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.diplomacy, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tax Policy',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 15),
                ),
              ),
              // Big rate display
              Text(
                '${_draft.toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.diplomacy, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.diplomacy,
              inactiveTrackColor: AppColors.diplomacy.withValues(alpha: 0.2),
              thumbColor: AppColors.diplomacy,
              overlayColor: AppColors.diplomacy.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _draft,
              min: 5,
              max: 60,
              divisions: 55,
              onChanged: (v) => setState(() => _draft = v),
              onChangeEnd: (v) {
                widget.ref.read(gameProvider.notifier).setTaxRate(v);
              },
            ),
          ),

          // Min/max labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('5%', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
                const Text('60%', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _labelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _label,
              style: TextStyle(color: _labelColor, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          // Effects row
          Row(
            children: [
              _EffectChip(
                icon: Icons.account_balance_rounded,
                label: 'Revenue',
                value: incomeStr,
                color: AppColors.economy,
              ),
              const SizedBox(width: 8),
              _EffectChip(
                icon: Icons.trending_up_rounded,
                label: 'GDP Growth',
                value: '${_gdpEffect >= 0 ? '+' : ''}${_gdpEffect.toStringAsFixed(2)}%/yr',
                color: _gdpEffect >= 0 ? AppColors.economy : AppColors.danger,
              ),
              const SizedBox(width: 8),
              _EffectChip(
                icon: Icons.mood_rounded,
                label: 'Happiness',
                value: '${_happinessEffect >= 0 ? '+' : ''}${_happinessEffect.toStringAsFixed(1)}/yr',
                color: _happinessEffect >= 0 ? AppColors.economy : AppColors.danger,
              ),
            ],
          ),

          // Pending change notice
          if (_changed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 13),
                const SizedBox(width: 5),
                Text(
                  'New rate ${_draft.toStringAsFixed(0)}% takes full effect next year.',
                  style: const TextStyle(color: AppColors.accent, fontFamily: 'Poppins', fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EffectChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 11),
                const SizedBox(width: 3),
                Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontFamily: 'Poppins', fontSize: 10)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TreasuryCard extends StatelessWidget {
  final GameStateModel game;

  const _TreasuryCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final taxIncome = game.gdpBillion * game.taxRate / 100;
    final baseSpending = game.gdpBillion * 0.20;
    final policySpending = game.activePolicies.fold(0.0, (s, p) => s + p.cost);
    double buildingMaint = 0;
    for (final b in BuildingsData.all) {
      final lvl = game.buildingLevels[b.id] ?? 0;
      if (lvl > 0) buildingMaint += lvl * b.moneyCostPerLevel * 0.02;
    }
    final netPerYear = taxIncome - baseSpending - game.militaryBudget - policySpending - buildingMaint;
    final isNeg = game.treasury < 0;
    final balanceColor = isNeg ? AppColors.danger : AppColors.economy;
    final netColor = netPerYear >= 0 ? AppColors.economy : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: balanceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Treasury', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 15)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    game.treasuryFormatted,
                    style: TextStyle(color: balanceColor, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 18),
                  ),
                  Text(
                    '${netPerYear >= 0 ? '+' : ''}${netPerYear >= 1000 ? '\$${(netPerYear / 1000).toStringAsFixed(1)}T' : '\$${netPerYear.toStringAsFixed(0)}B'}/yr',
                    style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          _BudgetRow('Tax Revenue', taxIncome, AppColors.economy),
          _BudgetRow('Base Gov. Spending', -baseSpending, AppColors.danger),
          _BudgetRow('Military Budget', -game.militaryBudget, AppColors.military),
          if (policySpending > 0)
            _BudgetRow('Active Policies', -policySpending, AppColors.social),
          if (buildingMaint > 0)
            _BudgetRow('Building Maintenance', -buildingMaint, AppColors.resources),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: netColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: netColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net per year', style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
                Text(
                  '${netPerYear >= 0 ? '+' : ''}\$${netPerYear.abs().toStringAsFixed(0)}B',
                  style: TextStyle(color: netColor, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (isNeg) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 13),
                const SizedBox(width: 5),
                const Text('Treasury deficit — GDP growth and happiness penalized', style: TextStyle(color: AppColors.danger, fontFamily: 'Poppins', fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BudgetRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final sign = value >= 0 ? '+' : '-';
    final abs = value.abs();
    final formatted = abs >= 1000
        ? '$sign\$${(abs / 1000).toStringAsFixed(1)}T'
        : '$sign\$${abs.toStringAsFixed(0)}B';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 3, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12))),
          Text(formatted, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
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
