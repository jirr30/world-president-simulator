import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/buildings_data.dart';
import '../../../data/models/building_model.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/policy_model.dart';
import '../../providers/game_provider.dart';

class BuildingsScreen extends ConsumerStatefulWidget {
  const BuildingsScreen({super.key});

  @override
  ConsumerState<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends ConsumerState<BuildingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    if (game == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No active game', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    final levels = game.buildingLevels;
    final capacity = BuildingsData.calcEnergyCapacity(levels);
    final consumption = BuildingsData.calcEnergyConsumption(levels);
    final available = capacity - consumption;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Infrastructure',
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          _EnergyChip(capacity: capacity, consumption: consumption),
          _TreasuryBadge(treasury: game.treasury),
          _CapitalBadge(capital: game.politicalCapital),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(icon: Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFD700)), text: 'Energy'),
            Tab(icon: Icon(Icons.shield_rounded, size: 16, color: Color(0xFFFF5722)), text: 'Military'),
            Tab(icon: Icon(Icons.restaurant_rounded, size: 16, color: Color(0xFF76C442)), text: 'Food'),
            Tab(icon: Icon(Icons.terrain_rounded, size: 16, color: Color(0xFFFF6D00)), text: 'Resources'),
          ],
        ),
      ),
      body: Column(
        children: [
          _EnergyBar(capacity: capacity, consumption: consumption, available: available),
          if (capacity == 0) const _NoPowerBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _BuildingList(category: BuildingCategory.energy, game: game, available: available, treasury: game.treasury, onBuild: _doBuild),
                _BuildingList(category: BuildingCategory.military, game: game, available: available, treasury: game.treasury, onBuild: _doBuild),
                _BuildingList(category: BuildingCategory.food, game: game, available: available, treasury: game.treasury, onBuild: _doBuild),
                _BuildingList(category: BuildingCategory.resources, game: game, available: available, treasury: game.treasury, onBuild: _doBuild),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _doBuild(BuildingModel building) {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final currentLevel = game.buildingLevels[building.id] ?? 0;

    if (game.politicalCapital < building.capitalCostPerLevel) {
      _snack('💎 Not enough Political Capital (need ${building.capitalCostPerLevel}, have ${game.politicalCapital}).', AppColors.danger);
      return;
    }

    if (game.treasury < building.moneyCostPerLevel) {
      final needed = building.moneyCostPerLevel.toStringAsFixed(0);
      final have = game.treasury.toStringAsFixed(0);
      _snack('🪙 Not enough Treasury (need \$$needed B, have \$$have B). Wait for annual income!', AppColors.danger);
      return;
    }

    if (!building.isPowerPlant && currentLevel == 0) {
      final levels = game.buildingLevels;
      final available = BuildingsData.calcEnergyCapacity(levels) - BuildingsData.calcEnergyConsumption(levels);
      if (available < building.energyConsumption) {
        _snack('⚡ Not enough energy (need ${building.energyConsumption.toStringAsFixed(0)} MW, only ${available.toStringAsFixed(0)} MW free). Build more power plants!', AppColors.warning);
        return;
      }
    }

    ref.read(gameProvider.notifier).buildOrUpgrade(building.id);

    final isNew = currentLevel == 0;
    _snack(
      isNew ? '🏗️ ${building.name} built!' : '⬆️ ${building.name} upgraded to Level ${currentLevel + 1}!',
      AppColors.success,
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Energy bar header
// ─────────────────────────────────────────────────────────────────────────────
class _EnergyBar extends StatelessWidget {
  final double capacity;
  final double consumption;
  final double available;

  const _EnergyBar({required this.capacity, required this.consumption, required this.available});

  @override
  Widget build(BuildContext context) {
    final ratio = capacity > 0 ? (consumption / capacity).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.85 ? AppColors.danger : ratio > 0.65 ? AppColors.warning : AppColors.accent;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 14),
              const SizedBox(width: 6),
              const Text('Power Grid', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${consumption.toStringAsFixed(0)} / ${capacity.toStringAsFixed(0)} MW used',
                style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '(${available.toStringAsFixed(0)} MW free)',
                style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No power warning banner
// ─────────────────────────────────────────────────────────────────────────────
class _NoPowerBanner extends StatelessWidget {
  const _NoPowerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚡ No power capacity! Go to the Energy tab and build a power plant first — all other buildings require electricity.',
              style: TextStyle(color: AppColors.warning, fontFamily: 'Poppins', fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar chips
// ─────────────────────────────────────────────────────────────────────────────
class _EnergyChip extends StatelessWidget {
  final double capacity;
  final double consumption;

  const _EnergyChip({required this.capacity, required this.consumption});

  @override
  Widget build(BuildContext context) {
    final available = capacity - consumption;
    final isCritical = capacity > 0 && available < 20;
    final color = isCritical ? AppColors.warning : AppColors.accent;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            capacity == 0 ? 'No Power' : '${available.toStringAsFixed(0)} MW',
            style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TreasuryBadge extends StatelessWidget {
  final double treasury;

  const _TreasuryBadge({required this.treasury});

  @override
  Widget build(BuildContext context) {
    final isNeg = treasury < 0;
    final color = isNeg ? AppColors.danger : AppColors.economy;
    final abs = treasury.abs();
    final label = abs >= 1000
        ? '${isNeg ? '-' : ''}\$${(abs / 1000).toStringAsFixed(1)}T'
        : '${isNeg ? '-' : ''}\$${abs.toStringAsFixed(0)}B';
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CapitalBadge extends StatelessWidget {
  final int capital;

  const _CapitalBadge({required this.capital});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text('$capital', style: const TextStyle(color: AppColors.accent, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Building list per category
// ─────────────────────────────────────────────────────────────────────────────
class _BuildingList extends StatelessWidget {
  final BuildingCategory category;
  final GameStateModel game;
  final double available;
  final double treasury;
  final void Function(BuildingModel) onBuild;

  const _BuildingList({
    required this.category,
    required this.game,
    required this.available,
    required this.treasury,
    required this.onBuild,
  });

  @override
  Widget build(BuildContext context) {
    final buildings = BuildingsData.byCategory(category);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: buildings.length,
      itemBuilder: (_, i) {
        final b = buildings[i];
        final level = game.buildingLevels[b.id] ?? 0;
        return _BuildingCard(
          building: b,
          currentLevel: level,
          capital: game.politicalCapital,
          energyAvailable: available,
          treasury: treasury,
          onBuild: () => onBuild(b),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual building card
// ─────────────────────────────────────────────────────────────────────────────
class _BuildingCard extends StatelessWidget {
  final BuildingModel building;
  final int currentLevel;
  final int capital;
  final double energyAvailable;
  final double treasury;
  final VoidCallback onBuild;

  const _BuildingCard({
    required this.building,
    required this.currentLevel,
    required this.capital,
    required this.energyAvailable,
    required this.treasury,
    required this.onBuild,
  });

  bool get isBuilt => currentLevel > 0;
  bool get isMaxLevel => currentLevel >= building.maxLevel;
  bool get canAffordCapital => capital >= building.capitalCostPerLevel;
  bool get canAffordTreasury => treasury >= building.moneyCostPerLevel;
  bool get hasEnoughEnergy =>
      building.isPowerPlant || currentLevel > 0 || energyAvailable >= building.energyConsumption;
  bool get canBuild => !isMaxLevel && canAffordCapital && canAffordTreasury && hasEnoughEnergy;

  String get _buttonLabel {
    if (!canAffordCapital) return '💎 Need ${building.capitalCostPerLevel}';
    if (!canAffordTreasury) return '🪙 Need \$${building.moneyCostPerLevel.toStringAsFixed(0)}B';
    if (!building.isPowerPlant && currentLevel == 0 && !hasEnoughEnergy) {
      return '⚡ Need ${building.energyConsumption.toStringAsFixed(0)} MW';
    }
    if (currentLevel == 0) return 'Build';
    return 'Upgrade → Lv ${currentLevel + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final color = building.categoryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBuilt ? color.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: isBuilt ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(building.icon, color: color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      _LevelBar(level: currentLevel, maxLevel: building.maxLevel, color: color),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (building.isPowerPlant)
                  _InfoBadge('⚡ +${building.energyProductionPerLevel.toStringAsFixed(0)}/lv', color: AppColors.accent)
                else if (building.energyConsumption > 0)
                  _InfoBadge(
                    '⚡ -${building.energyConsumption.toStringAsFixed(0)} MW',
                    color: isBuilt ? AppColors.warning : AppColors.textMuted,
                  ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins', height: 1.4),
                ),
                const SizedBox(height: 10),

                // Per-level effects
                if (building.effectsPerLevel.isNotEmpty) ...[
                  const Text('Bonus per level / year:', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'Poppins')),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: building.effectsPerLevel.map((e) => _EffectBadge(e)).toList(),
                  ),
                  const SizedBox(height: 10),
                ],

                // Power info row
                if (building.isPowerPlant) ...[
                  Row(children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Generates +${building.energyProductionPerLevel.toStringAsFixed(0)} MW per level  •  Max ${building.maxLevel} levels',
                      style: const TextStyle(color: AppColors.accent, fontSize: 11, fontFamily: 'Poppins'),
                    ),
                  ]),
                  const SizedBox(height: 10),
                ] else if (building.energyConsumption > 0) ...[
                  Row(children: [
                    Icon(Icons.bolt_rounded, color: isBuilt ? AppColors.warning : AppColors.textMuted, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Requires ${building.energyConsumption.toStringAsFixed(0)} MW to operate${isBuilt ? '' : '  •  not yet built'}',
                      style: TextStyle(
                        color: isBuilt ? AppColors.warning : AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                ],

                // Cost + action row
                Row(
                  children: [
                    _CostChip(
                      '🪙 \$${building.moneyCostPerLevel.toStringAsFixed(0)}B/lv',
                      accent: canAffordTreasury ? AppColors.economy : AppColors.danger,
                    ),
                    const SizedBox(width: 6),
                    _CostChip(
                      '💎 ${building.capitalCostPerLevel}/lv',
                      accent: canAffordCapital ? AppColors.accent : AppColors.danger,
                    ),
                    const Spacer(),
                    if (isMaxLevel)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✓ Max Level',
                          style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: canBuild ? onBuild : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBuild ? color : AppColors.cardBorder,
                          disabledBackgroundColor: AppColors.cardBorder,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _buttonLabel,
                          style: TextStyle(
                            color: canBuild ? Colors.white : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  final int level;
  final int maxLevel;
  final Color color;

  const _LevelBar({required this.level, required this.maxLevel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(maxLevel, (i) => Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 12,
            height: 5,
            decoration: BoxDecoration(
              color: i < level ? color : color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
        const SizedBox(width: 5),
        Text(
          level == 0 ? 'Not Built' : 'Lv $level / $maxLevel',
          style: TextStyle(
            color: level == 0 ? AppColors.textMuted : color,
            fontSize: 9,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoBadge(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
    );
  }
}

class _EffectBadge extends StatelessWidget {
  final StatEffect effect;

  const _EffectBadge(this.effect);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.economy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.economy.withValues(alpha: 0.3)),
      ),
      child: Text(
        '+${effect.delta.toStringAsFixed(1)} ${effect.statName}/yr',
        style: const TextStyle(color: AppColors.economy, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  final String label;
  final Color? accent;

  const _CostChip(this.label, {this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color != null ? color.withValues(alpha: 0.1) : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(5),
        border: color != null ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textSecondary,
          fontSize: 10,
          fontWeight: color != null ? FontWeight.w700 : FontWeight.normal,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
