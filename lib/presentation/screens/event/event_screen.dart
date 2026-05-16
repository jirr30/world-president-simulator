import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/models/event_model.dart';
import '../../providers/game_provider.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  int? _selectedChoice;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_selectedChoice == null) return;
    final event = ref.read(pendingEventProvider);
    if (event == null) return;
    ref.read(gameProvider.notifier).applyEventChoice(event.choices[_selectedChoice!]);
    setState(() => _resolved = true);
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(pendingEventProvider);

    if (event == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go('/dashboard'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Row(
            children: [
              // ── Left: event header ─────────────────────────────
              Expanded(
                flex: 42,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        event.severityColor.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: event.severityColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: event.severityColor.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: event.severityColor, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.severityLabel.toUpperCase(),
                                    style: TextStyle(
                                      color: event.severityColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '⚡ EVENT',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Emoji
                        Text(event.emoji, style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Description
                        Text(
                          event.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.cardBorder),

              // ── Right: choices + action ────────────────────────
              Expanded(
                flex: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text(
                        context.l10n.chooseYourResponse,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        children: [
                          ...event.choices.asMap().entries.map((entry) {
                            final i = entry.key;
                            final choice = entry.value;
                            return _ChoiceCard(
                              choice: choice,
                              isSelected: _selectedChoice == i,
                              showEffects: _resolved && _selectedChoice == i,
                              onTap: _resolved
                                  ? null
                                  : () => setState(() => _selectedChoice = i),
                            );
                          }),
                        ],
                      ),
                    ),
                    // Action button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: _resolved
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(pendingEventProvider.notifier)
                                      .state = null;
                                  context.go('/dashboard');
                                },
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.background, size: 18),
                                label: Text(
                                  context.l10n.continueGoverning,
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              )
                            : ElevatedButton(
                                onPressed:
                                    _selectedChoice != null ? _onConfirm : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedChoice != null
                                      ? AppColors.accent
                                      : AppColors.cardBorder,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  _selectedChoice != null
                                      ? context.l10n.confirmDecision
                                      : context.l10n.selectOptionFirst,
                                  style: TextStyle(
                                    color: _selectedChoice != null
                                        ? AppColors.background
                                        : AppColors.textMuted,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
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
}

class _ChoiceCard extends StatelessWidget {
  final EventChoice choice;
  final bool isSelected;
  final bool showEffects;
  final VoidCallback? onTap;

  const _ChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.showEffects,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textMuted,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.accent : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 11, color: AppColors.background)
                      : null,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    choice.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 27, top: 5),
              child: Text(
                choice.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),
            ),
            if (showEffects) ...[
              const SizedBox(height: 8),
              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 27),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: choice.effects
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: e.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              e.label,
                              style: TextStyle(
                                color: e.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
