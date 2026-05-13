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
          ),
          _PolicyList(
            category: PolicyCategory.military,
            game: game,
            onApply: _applyPolicy,
          ),
          _PolicyList(
            category: PolicyCategory.social,
            game: game,
            onApply: _applyPolicy,
          ),
          _PolicyList(
            category: PolicyCategory.diplomatic,
            game: game,
            onApply: _applyPolicy,
          ),
        ],
      ),
    );
  }

  void _applyPolicy(PolicyModel policy) {
    final game = ref.read(gameProvider);
    if (game == null) return;

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

  const _PolicyList({
    required this.category,
    required this.game,
    required this.onApply,
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
          onApply: () => onApply(policy),
        );
      },
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final bool isActive;
  final VoidCallback onApply;

  const _PolicyCard({
    required this.policy,
    required this.isActive,
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
                    if (policy.cost > 0) ...[
                      const Icon(Icons.attach_money_rounded, color: AppColors.warning, size: 16),
                      Text(
                        'Cost: \$${policy.cost.toStringAsFixed(0)}B/year',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (policy.minApprovalToApply > 0) ...[
                      const Icon(Icons.thumb_up_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Requires ${policy.minApprovalToApply}% approval',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!isActive)
                      ElevatedButton(
                        onPressed: onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: policy.categoryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
