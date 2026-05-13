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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left sidebar: search + filter ───────────────────
          SizedBox(
            width: 220,
            child: Container(
              color: AppColors.surface,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecondary, size: 18),
                            onPressed: () => context.go('/home'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Country',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textMuted, size: 18),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.primaryLight, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                            fontSize: 13),
                        onChanged: (v) =>
                            ref.read(searchQueryProvider.notifier).state = v,
                      ),
                    ),
                    // Continent filter label
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 4),
                      child: Text(
                        'CONTINENT',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    // Scrollable continent buttons — won't overflow on short screens
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ContinentButton(
                              label: 'All Regions',
                              icon: Icons.public_rounded,
                              selected: selectedContinent == null,
                              color: AppColors.textSecondary,
                              onTap: () {
                                ref.read(selectedContinentProvider.notifier).state = null;
                                ref.read(searchQueryProvider.notifier).state = '';
                                _searchCtrl.clear();
                              },
                            ),
                            ...continents.map((c) => _ContinentButton(
                              label: c,
                              icon: _continentIcon(c),
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
                    ),
                    // Footer count
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${countries.length} countries found',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Right: country grid ──────────────────────────────
          Expanded(
            child: SafeArea(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.0,
                ),
                itemCount: countries.length,
                itemBuilder: (_, i) => _CountryCard(
                  country: countries[i],
                  onTap: () => _onCountrySelected(context, ref, countries[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCountrySelected(
      BuildContext context, WidgetRef ref, CountryModel country) {
    showDialog(
      context: context,
      builder: (_) => _CountryPreviewDialog(
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
      'Europe': AppColors.primaryLight,
      'Africa': AppColors.warning,
      'North America': AppColors.economy,
      'South America': AppColors.social,
      'Oceania': AppColors.danger,
    };
    return map[c] ?? AppColors.textMuted;
  }

  IconData _continentIcon(String c) {
    const map = {
      'Asia': Icons.temple_buddhist_rounded,
      'Europe': Icons.account_balance_rounded,
      'Africa': Icons.landscape_rounded,
      'North America': Icons.terrain_rounded,
      'South America': Icons.forest_rounded,
      'Oceania': Icons.waves_rounded,
    };
    return map[c] ?? Icons.place_rounded;
  }
}

// ── Sidebar continent button ─────────────────────────────────────────────────
class _ContinentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ContinentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? color : AppColors.textMuted,
                size: 15),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
            if (selected) ...[
              const Spacer(),
              Icon(Icons.check_rounded, color: color, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Country card (grid item) ─────────────────────────────────────────────────
class _CountryCard extends StatelessWidget {
  final CountryModel country;
  final VoidCallback onTap;

  const _CountryCard({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            CountryFlag(flag: country.flag, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    country.capital,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  country.gdpFormatted,
                  style: const TextStyle(
                    color: AppColors.economy,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  country.populationFormatted,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country preview dialog (landscape-safe) ──────────────────────────────────
class _CountryPreviewDialog extends StatelessWidget {
  final CountryModel country;
  final VoidCallback onStart;

  const _CountryPreviewDialog({required this.country, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SizedBox(
        width: 600,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Flag + name + button
              Container(
                width: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.surface,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 12),
                    Text(
                      country.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.capital,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        country.governmentLabel,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onStart();
                        },
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: AppColors.background, size: 18),
                        label: const Text(
                          'Lead Nation',
                          style: TextStyle(
                            color: AppColors.background,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
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
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Stats
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Country Profile',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Stats grid (2 per row)
                      _StatGrid([
                        _StatItem('Population', country.populationFormatted,
                            Icons.people_rounded, AppColors.social),
                        _StatItem('GDP', country.gdpFormatted,
                            Icons.trending_up_rounded, AppColors.economy),
                        _StatItem(
                            'GDP per Capita',
                            '\$${country.gdpPerCapita.toStringAsFixed(0)}',
                            Icons.person_rounded,
                            AppColors.economy),
                        _StatItem(
                            'Military Budget',
                            '\$${country.militaryBudgetBillion.toStringAsFixed(1)}B',
                            Icons.shield_rounded,
                            AppColors.military),
                        _StatItem(
                            'HDI',
                            country.humanDevelopmentIndex.toStringAsFixed(3),
                            Icons.bar_chart_rounded,
                            AppColors.diplomacy),
                        _StatItem(
                            'Literacy Rate',
                            '${country.literacyRate.toStringAsFixed(0)}%',
                            Icons.school_rounded,
                            AppColors.social),
                        _StatItem(
                            'Unemployment',
                            '${country.unemploymentRate.toStringAsFixed(1)}%',
                            Icons.work_off_rounded,
                            AppColors.warning),
                        _StatItem(
                            'Corruption Index',
                            '${country.corruptionIndex.toStringAsFixed(0)}/100',
                            Icons.warning_amber_rounded,
                            country.corruptionIndex < 40
                                ? AppColors.economy
                                : AppColors.danger),
                      ]),
                      if (country.allies.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.cardBorder),
                        const SizedBox(height: 10),
                        const Text(
                          'Natural Allies',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: country.allies.take(6).map((a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.economy.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: AppColors.economy.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              a,
                              style: const TextStyle(
                                color: AppColors.economy,
                                fontSize: 11,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
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
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;

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

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatTile extends StatelessWidget {
  final _StatItem item;

  const _StatTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.value,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
