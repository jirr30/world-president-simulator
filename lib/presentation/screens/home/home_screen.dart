import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accent.withValues(alpha: 0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '🌍',
                    style: TextStyle(fontSize: 52),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'World\nPresident\nSimulator',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lead any of 100+ real nations.\nShape history. Leave a legacy.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  _HomeButton(
                    label: 'New Game',
                    icon: Icons.add_circle_rounded,
                    color: AppColors.accent,
                    onTap: () => context.go('/select'),
                  ),
                  const SizedBox(height: 14),
                  _HomeButton(
                    label: 'How to Play',
                    icon: Icons.help_outline_rounded,
                    color: AppColors.diplomacy,
                    onTap: () => _showHowToPlay(context),
                    outlined: true,
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      _FeatureChip(label: '195 Countries', icon: '🌐'),
                      SizedBox(width: 8),
                      _FeatureChip(label: 'Real Data', icon: '📊'),
                      SizedBox(width: 8),
                      _FeatureChip(label: 'Live Events', icon: '⚡'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _HowToPlaySheet(),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: color),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: AppColors.background),
              label: Text(label, style: const TextStyle(color: AppColors.background)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final String icon;

  const _FeatureChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToPlaySheet extends StatelessWidget {
  const _HowToPlaySheet();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('🌍', 'Choose Your Country', 'Pick from 195 real nations with actual economic and military data.'),
      ('📋', 'Apply Policies', 'Choose economic, military, social, or diplomatic policies each term.'),
      ('⚡', 'Handle Events', 'Random world events will challenge your leadership. Choose wisely.'),
      ('📅', 'Advance Year', 'Each year your decisions affect your approval rating and country stats.'),
      ('🏆', 'Leave a Legacy', 'Survive your full term and be judged by history after 5 years.'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Play',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$2,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.$3,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
