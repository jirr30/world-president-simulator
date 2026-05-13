import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/approval_bar.dart';
import '../../widgets/common/country_flag.dart';
import '../../../services/simulation_engine.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    if (game == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final legacy = SimulationEngine.getLegacyRating(game);
    final avgApproval = game.approvalHistory.isNotEmpty
        ? game.approvalHistory.reduce((a, b) => a + b) / game.approvalHistory.length
        : game.approvalRating;

    final emoji = _legacyEmoji(avgApproval);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.approvalColor(avgApproval).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 16),
                    const Text(
                      'YOUR TERM HAS ENDED',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      legacy,
                      style: TextStyle(
                        color: AppColors.approvalColor(avgApproval),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CountryFlag(flag: game.country.flag, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${game.country.name} • ${game.termStartYear}–${game.currentYear}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Stats summary
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Final Report',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ApprovalBar(approval: avgApproval),
                    const SizedBox(height: 20),
                    _FinalStatRow('Average Approval', '${avgApproval.toStringAsFixed(0)}%', Icons.thumb_up_rounded, AppColors.approvalColor(avgApproval)),
                    _FinalStatRow('Final GDP', game.gdpBillion >= 1000 ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T' : '\$${game.gdpBillion.toStringAsFixed(0)}B', Icons.trending_up_rounded, AppColors.economy),
                    _FinalStatRow('GDP Growth', '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%', Icons.bar_chart_rounded, AppColors.economy),
                    _FinalStatRow('Happiness', '${game.happiness.toStringAsFixed(0)}%', Icons.sentiment_satisfied_rounded, AppColors.accent),
                    _FinalStatRow('Military Power', '${game.militaryStrength.toStringAsFixed(0)}/100', Icons.shield_rounded, AppColors.military),
                    _FinalStatRow('Diplomatic Rep', '${game.diplomaticReputation.toStringAsFixed(0)}/100', Icons.public_rounded, AppColors.diplomacy),
                    _FinalStatRow('Education', '${game.educationIndex.toStringAsFixed(0)}/100', Icons.school_rounded, AppColors.social),
                    _FinalStatRow('National Debt', '${game.nationalDebt.toStringAsFixed(0)}% of GDP', Icons.account_balance_rounded, game.nationalDebt > 80 ? AppColors.danger : AppColors.economy),
                    _FinalStatRow('Policies Applied', '${game.activePolicies.length}', Icons.policy_rounded, AppColors.info),
                    const SizedBox(height: 24),
                    // Verdict
                    Container(
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
                            'Historical Verdict',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _verdictText(avgApproval, game),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(gameProvider.notifier).reset();
                          context.go('/select');
                        },
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.background),
                        label: const Text('Play Again', style: TextStyle(color: AppColors.background)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(gameProvider.notifier).reset();
                          context.go('/home');
                        },
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Main Menu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _legacyEmoji(double approval) {
    if (approval >= 80) return '👑';
    if (approval >= 65) return '🌟';
    if (approval >= 50) return '🤝';
    if (approval >= 35) return '😐';
    if (approval >= 20) return '😤';
    return '💀';
  }

  String _verdictText(double approval, dynamic game) {
    if (approval >= 80) {
      return 'History will remember your leadership with great admiration. You transformed ${game.country.name} into a beacon of prosperity and stability. Future generations will study your policies as a model of exceptional governance.';
    } else if (approval >= 65) {
      return 'You led ${game.country.name} competently and are generally well-regarded by your citizens. Your tenure saw genuine progress in key areas, even if some challenges remained unresolved.';
    } else if (approval >= 50) {
      return 'Your time as leader of ${game.country.name} was mixed. While you managed to keep the country stable, many citizens felt that more could have been accomplished with bolder decisions.';
    } else if (approval >= 35) {
      return 'Your leadership divided the nation. Significant protests and political opposition marked your term. ${game.country.name} faced considerable challenges under your governance.';
    } else {
      return 'Your term as leader of ${game.country.name} will be remembered as a turbulent and difficult period. Citizens suffered, institutions weakened, and the country\'s reputation declined significantly.';
    }
  }
}

class _FinalStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FinalStatRow(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
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
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
