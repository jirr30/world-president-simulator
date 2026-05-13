import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/policies_data.dart';
import '../../../data/models/policy_model.dart';
import '../../providers/game_provider.dart';

class PolicyScreen extends ConsumerStatefulWidget {
  const PolicyScreen({super.key});

  @override
  ConsumerState<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends ConsumerState<PolicyScreen>
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Policies'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (game != null) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (game.treasuryIsNegative ? AppColors.danger : AppColors.economy).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (game.treasuryIsNegative ? AppColors.danger : AppColors.economy).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      game.treasuryFormatted,
                      style: TextStyle(
                        color: game.treasuryIsNegative ? AppColors.danger : AppColors.economy,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '${game.politicalCapital}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up_rounded, color: AppColors.economy, size: 18), text: 'Economic'),
            Tab(icon: Icon(Icons.shield_rounded, color: AppColors.military, size: 18), text: 'Military'),
            Tab(icon: Icon(Icons.people_rounded, color: AppColors.social, size: 18), text: 'Social'),
            Tab(icon: Icon(Icons.public_rounded, color: AppColors.diplomacy, size: 18), text: 'Diplomatic'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PolicyList(
            category: PolicyCategory.economic,
            game: game,
            onApply: _applyPolicy,
            playerCapital: game?.politicalCapital ?? 0,
          ),
          _PolicyList(
            category: PolicyCategory.military,
            game: game,
            onApply: _applyPolicy,
            playerCapital: game?.politicalCapital ?? 0,
          ),
          _PolicyList(
            category: PolicyCategory.social,
            game: game,
            onApply: _applyPolicy,
            playerCapital: game?.politicalCapital ?? 0,
          ),
          _PolicyList(
            category: PolicyCategory.diplomatic,
            game: game,
            onApply: _applyPolicy,
            playerCapital: game?.politicalCapital ?? 0,
          ),
        ],
      ),
    );
  }

  void _applyPolicy(PolicyModel policy) {
    final game = ref.read(gameProvider);
    if (game == null) return;

    if (game.politicalCapital < policy.capitalCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💎 Not enough Political Capital (need ${policy.capitalCost}, have ${game.politicalCapital}).',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (game.approvalRating < policy.minApprovalToApply) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need at least ${policy.minApprovalToApply}% approval to apply this policy.',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final alreadyActive = game.activePolicies.any((p) => p.id == policy.id);
    if (alreadyActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${policy.name} is already active.',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ref.read(gameProvider.notifier).applyPolicy(policy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ ${policy.name} has been applied!',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _PolicyList extends StatelessWidget {
  final PolicyCategory category;
  final dynamic game;
  final void Function(PolicyModel) onApply;
  final int playerCapital;

  const _PolicyList({
    required this.category,
    required this.game,
    required this.onApply,
    required this.playerCapital,
  });

  @override
  Widget build(BuildContext context) {
    final policies = PoliciesData.byCategory(category);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: policies.length,
      itemBuilder: (_, i) {
        final policy = policies[i];
        final isActive = game?.activePolicies.any((p) => p.id == policy.id) ?? false;

        return _PolicyCard(
          policy: policy,
          isActive: isActive,
          canAfford: playerCapital >= policy.capitalCost,
          playerCapital: playerCapital,
          onApply: () => onApply(policy),
        );
      },
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final bool isActive;
  final bool canAfford;
  final int playerCapital;
  final VoidCallback onApply;

  const _PolicyCard({
    required this.policy,
    required this.isActive,
    required this.canAfford,
    required this.playerCapital,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? policy.categoryColor.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: policy.categoryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: policy.categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(policy.categoryIcon, color: policy.categoryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    policy.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.economy.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: AppColors.economy,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Effects
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: policy.effects.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: e.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: e.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      e.label,
                      style: TextStyle(
                        color: e.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Capital cost badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: canAfford
                              ? AppColors.accent.withValues(alpha: 0.35)
                              : AppColors.danger.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${policy.capitalCost}',
                            style: TextStyle(
                              color: canAfford ? AppColors.accent : AppColors.danger,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (policy.cost > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.economy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.economy.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '🪙 \$${policy.cost.toStringAsFixed(0)}B/yr',
                          style: const TextStyle(color: AppColors.economy, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (policy.minApprovalToApply > 0) ...[
                      const Icon(Icons.thumb_up_rounded, color: AppColors.accent, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '${policy.minApprovalToApply}%+',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!isActive)
                      ElevatedButton(
                        onPressed: canAfford ? onApply : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? policy.categoryColor : AppColors.cardBorder,
                          disabledBackgroundColor: AppColors.cardBorder,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          canAfford ? 'Apply' : 'Need 💎${policy.capitalCost}',
                          style: TextStyle(
                            color: canAfford ? Colors.white : AppColors.textMuted,
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
