import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/approval_bar.dart';
import '../../widgets/common/country_flag.dart';
import '../../../services/simulation_engine.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  final String? reason;

  const GameOverScreen({super.key, this.reason});

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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
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

    final reason = widget.reason;
    final isImpeached = reason == 'impeached';
    final isInvaded = reason == 'invaded';
    final legacy = SimulationEngine.getLegacyRating(game);
    final avgApproval = game.approvalHistory.isNotEmpty
        ? game.approvalHistory.reduce((a, b) => a + b) /
            game.approvalHistory.length
        : game.approvalRating;
    final approvalColor = (isImpeached || isInvaded) ? AppColors.danger : AppColors.approvalColor(avgApproval);
    final emoji = isImpeached ? '🔥' : isInvaded ? '💀' : _legacyEmoji(avgApproval);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Row(
            children: [
              // ── Left: hero panel ───────────────────────────────
              SizedBox(
                width: 240,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        approvalColor.withValues(alpha: 0.15),
                        AppColors.surface,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(emoji, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text(
                        isImpeached ? context.l10n.impeachedBadge : isInvaded ? context.l10n.invadedBadge : context.l10n.termEndedBadge,
                        style: TextStyle(
                          color: (isImpeached || isInvaded) ? AppColors.danger : AppColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 2.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isImpeached ? context.l10n.removedFromPower : isInvaded ? context.l10n.countryFallen : legacy,
                        style: TextStyle(
                          color: approvalColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CountryFlag(flag: game.country.flag, size: 22),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              game.country.name,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${game.startYear} – ${game.currentYear}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ApprovalBar(approval: avgApproval),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.avgApprovalStat(avgApproval.toStringAsFixed(0)),
                        style: TextStyle(
                          color: approvalColor,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(gameProvider.notifier).endGame();
                            context.go('/select');
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppColors.background, size: 16),
                          label: Text(context.l10n.playAgain,
                              style: TextStyle(
                                  color: AppColors.background,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(gameProvider.notifier).endGame();
                            context.go('/home');
                          },
                          icon: const Icon(Icons.home_rounded, size: 16),
                          label: Text(context.l10n.mainMenu,
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.cardBorder),

              // ── Right: stats + verdict ─────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    Text(
                      context.l10n.finalReport,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Stats 2-col grid
                    _StatGrid([
                      _StatDef(context.l10n.avgApproval,
                          '${avgApproval.toStringAsFixed(0)}%',
                          Icons.thumb_up_rounded, approvalColor),
                      _StatDef(context.l10n.finalGdp,
                          game.gdpBillion >= 1000
                              ? '\$${(game.gdpBillion / 1000).toStringAsFixed(1)}T'
                              : '\$${game.gdpBillion.toStringAsFixed(0)}B',
                          Icons.trending_up_rounded, AppColors.economy),
                      _StatDef(context.l10n.statGdpGrowth,
                          '${game.gdpGrowthRate > 0 ? '+' : ''}${game.gdpGrowthRate.toStringAsFixed(1)}%',
                          Icons.bar_chart_rounded, AppColors.economy),
                      _StatDef(context.l10n.statHappiness,
                          '${game.happiness.toStringAsFixed(0)}%',
                          Icons.sentiment_satisfied_rounded, AppColors.accent),
                      _StatDef(context.l10n.militaryStat,
                          '${game.militaryStrength.toStringAsFixed(0)}/100',
                          Icons.shield_rounded, AppColors.military),
                      _StatDef(context.l10n.diplomacy,
                          '${game.diplomaticReputation.toStringAsFixed(0)}/100',
                          Icons.public_rounded, AppColors.diplomacy),
                      _StatDef(context.l10n.education,
                          '${game.educationIndex.toStringAsFixed(0)}/100',
                          Icons.school_rounded, AppColors.social),
                      _StatDef(context.l10n.nationalDebt,
                          '${game.nationalDebt.toStringAsFixed(0)}% GDP',
                          Icons.account_balance_rounded,
                          game.nationalDebt > 80
                              ? AppColors.danger
                              : AppColors.economy),
                      _StatDef(context.l10n.policiesApplied,
                          '${game.activePolicies.length}',
                          Icons.policy_rounded, AppColors.info),
                      _StatDef(context.l10n.yearsInPower,
                          '${game.yearsInOffice}',
                          Icons.calendar_today_rounded, AppColors.textSecondary),
                    ]),
                    const SizedBox(height: 14),
                    // Verdict
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history_edu_rounded,
                                  color: approvalColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.historicalVerdict,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isImpeached
                                ? _impeachmentText(context, game.approvalRating, game.country.name)
                                : isInvaded
                                    ? context.l10n.invadedVerdictText(game.country.name)
                                    : _verdictText(context, avgApproval, game.country.name),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  String _impeachmentText(BuildContext context, double approval, String countryName) {
    final l10n = context.l10n;
    if (approval <= 5) return l10n.impeachText1(countryName);
    if (approval <= 10) return l10n.impeachText2(countryName);
    return l10n.impeachText3(countryName);
  }

  String _verdictText(BuildContext context, double approval, String countryName) {
    final l10n = context.l10n;
    if (approval >= 80) return l10n.verdictGreat(countryName);
    if (approval >= 65) return l10n.verdictGood(countryName);
    if (approval >= 50) return l10n.verdictAverage(countryName);
    if (approval >= 35) return l10n.verdictPoor(countryName);
    return l10n.verdictBad(countryName);
  }
}

class _StatDef {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatDef(this.label, this.value, this.icon, this.color);
}

class _StatGrid extends StatelessWidget {
  final List<_StatDef> items;

  const _StatGrid(this.items);

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: _StatTile(items[i])),
          const SizedBox(width: 8),
          Expanded(
            child: i + 1 < items.length
                ? _StatTile(items[i + 1])
                : const SizedBox(),
          ),
        ],
      ));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }
}

class _StatTile extends StatelessWidget {
  final _StatDef d;

  const _StatTile(this.d);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: d.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: d.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(d.icon, color: d.color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.label,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'Poppins'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(d.value,
                    style: TextStyle(
                        color: d.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
