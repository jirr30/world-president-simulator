import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
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
  late Animation<double> _slide;
  int? _selectedChoice;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(pendingEventProvider);

    if (event == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/dashboard'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slide.value),
          child: Opacity(opacity: _ctrl.value, child: child),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [event.severityColor.withValues(alpha: 0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.severityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: event.severityColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: event.severityColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                event.severityLabel.toUpperCase(),
                                style: TextStyle(
                                  color: event.severityColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Text('⚡ NEW EVENT', style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          letterSpacing: 1,
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.emoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Choices
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Your Response:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...event.choices.asMap().entries.map((entry) {
                        final i = entry.key;
                        final choice = entry.value;
                        final isSelected = _selectedChoice == i;

                        return _ChoiceCard(
                          choice: choice,
                          isSelected: isSelected,
                          showEffects: _resolved && isSelected,
                          onTap: _resolved ? null : () => setState(() => _selectedChoice = i),
                        );
                      }),
                      const SizedBox(height: 16),
                      if (_selectedChoice != null && !_resolved)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Confirm Decision',
                              style: TextStyle(
                                color: AppColors.background,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      if (_resolved)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(pendingEventProvider.notifier).state = null;
                              context.go('/dashboard');
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.background),
                            label: const Text(
                              'Continue Governing',
                              style: TextStyle(
                                color: AppColors.background,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    if (_selectedChoice == null) return;
    final event = ref.read(pendingEventProvider);
    if (event == null) return;

    final choice = event.choices[_selectedChoice!];
    ref.read(gameProvider.notifier).applyEventChoice(choice);
    setState(() => _resolved = true);
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
    final borderColor = isSelected ? AppColors.accent : AppColors.cardBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.textMuted,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.accent : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 12, color: AppColors.background)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    choice.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                choice.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),
            ),
            if (showEffects) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: choice.effects.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: e.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
