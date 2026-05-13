import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/events_data.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/approval_bar.dart';
import '../../widgets/common/country_flag.dart';
import 'overview_tab.dart';
import 'economy_tab.dart';
import 'military_tab.dart';
import 'diplomacy_tab.dart';
import 'social_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _onAdvanceYear() {
    final state = ref.read(gameProvider.notifier).advanceYear();
    if (state.isTermOver) {
      context.go('/gameover');
      return;
    }
    // Random event chance: 70% per year
    final roll = (state.currentYear % 3 != 0) ? true : false;
    if (roll) {
      final events = EventsData.getRandomEvents(
        count: 1,
        continent: state.country.continent,
      );
      if (events.isNotEmpty) {
        ref.read(pendingEventProvider.notifier).state = events.first;
        context.go('/event');
      }
    }
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () => _confirmLeave(context),
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: 'Progress auto-saved',
                  child: Icon(Icons.save_rounded, size: 16, color: AppColors.textMuted),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () => context.go('/policies'),
                  icon: const Icon(Icons.policy_rounded, size: 18, color: AppColors.accent),
                  label: const Text(
                    'Policies',
                    style: TextStyle(color: AppColors.accent, fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _DashboardHeader(game: game),
            ),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Economy'),
                Tab(text: 'Military'),
                Tab(text: 'Diplomacy'),
                Tab(text: 'Social'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            OverviewTab(game: game),
            EconomyTab(game: game),
            MilitaryTab(game: game),
            DiplomacyTab(game: game),
            SocialTab(game: game),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdvanceYear,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.skip_next_rounded, color: AppColors.background),
        label: Text(
          'Advance to ${game.currentYear + 1}',
          style: const TextStyle(
            color: AppColors.background,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Game?',
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins'),
        ),
        content: const Text(
          'Game is auto-saved. You can continue from the main menu.',
          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).leaveGame();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final dynamic game;

  const _DashboardHeader({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.surface],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CountryFlag(flag: game.country.flag, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.country.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${game.leaderTitle} • Year ${game.currentYear} • Term ${game.yearsInOffice}/${game.termDurationYears}',
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.approvalColor(game.approvalRating).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.approvalColor(game.approvalRating).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${game.approvalRating.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.approvalColor(game.approvalRating),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ApprovalBar(approval: game.approvalRating),
        ],
      ),
    );
  }
}
