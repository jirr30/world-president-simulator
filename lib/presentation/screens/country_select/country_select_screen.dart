import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/country_model.dart';
import '../../providers/country_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/country_flag.dart';

class CountrySelectScreen extends ConsumerStatefulWidget {
  const CountrySelectScreen({super.key});

  @override
  ConsumerState<CountrySelectScreen> createState() => _CountrySelectScreenState();
}

class _CountrySelectScreenState extends ConsumerState<CountrySelectScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countries = ref.watch(filteredCountriesProvider);
    final continents = ref.watch(continentsProvider);
    final selectedContinent = ref.watch(selectedContinentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Select Your Country'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search country...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins'),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          // Continent filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ContinentChip(
                  label: 'All',
                  selected: selectedContinent == null,
                  color: AppColors.textSecondary,
                  onTap: () {
                    ref.read(selectedContinentProvider.notifier).state = null;
                    ref.read(searchQueryProvider.notifier).state = '';
                    _searchCtrl.clear();
                  },
                ),
                ...continents.map((c) => _ContinentChip(
                  label: c,
                  selected: selectedContinent == c,
                  color: _continentColor(c),
                  onTap: () {
                    ref.read(selectedContinentProvider.notifier).state = c;
                    ref.read(searchQueryProvider.notifier).state = '';
                    _searchCtrl.clear();
                  },
                )),
              ],
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${countries.length} countries',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          // Country list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: countries.length,
              itemBuilder: (_, i) => _CountryTile(
                country: countries[i],
                onTap: () => _onCountrySelected(context, ref, countries[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCountrySelected(BuildContext context, WidgetRef ref, CountryModel country) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CountryPreviewSheet(
        country: country,
        onStart: () {
          ref.read(gameProvider.notifier).startGame(country);
          context.go('/dashboard');
        },
      ),
    );
  }

  Color _continentColor(String c) {
    const map = {
      'Asia': AppColors.diplomacy,
      'Europe': AppColors.primary,
      'Africa': AppColors.warning,
      'North America': AppColors.economy,
      'South America': AppColors.social,
      'Oceania': AppColors.danger,
    };
    return map[c] ?? AppColors.textMuted;
  }
}

class _ContinentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ContinentChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final CountryModel country;
  final VoidCallback onTap;

  const _CountryTile({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            CountryFlag(flag: country.flag, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${country.capital} • ${country.continent}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  country.gdpFormatted,
                  style: const TextStyle(
                    color: AppColors.economy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  country.populationFormatted,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CountryPreviewSheet extends StatelessWidget {
  final CountryModel country;
  final VoidCallback onStart;

  const _CountryPreviewSheet({required this.country, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${country.capital} • ${country.governmentLabel}',
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
          const SizedBox(height: 20),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 12),
          _StatRow('Population', country.populationFormatted, Icons.people_rounded, AppColors.social),
          _StatRow('GDP', country.gdpFormatted, Icons.trending_up_rounded, AppColors.economy),
          _StatRow('GDP per Capita', '\$${country.gdpPerCapita.toStringAsFixed(0)}', Icons.person_rounded, AppColors.economy),
          _StatRow('Military Budget', '\$${country.militaryBudgetBillion.toStringAsFixed(1)}B', Icons.shield_rounded, AppColors.military),
          _StatRow('HDI', country.humanDevelopmentIndex.toStringAsFixed(3), Icons.bar_chart_rounded, AppColors.diplomacy),
          _StatRow('Unemployment', '${country.unemploymentRate.toStringAsFixed(1)}%', Icons.work_off_rounded, AppColors.warning),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, color: AppColors.background),
              label: const Text('Lead This Nation', style: TextStyle(color: AppColors.background)),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
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
              fontWeight: FontWeight.w600,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
