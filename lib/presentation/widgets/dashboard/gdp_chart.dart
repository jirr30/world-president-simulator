import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class GdpChart extends StatelessWidget {
  final List<double> history;
  final String currency;

  const GdpChart({super.key, required this.history, this.currency = 'B'});

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Not enough data yet',
            style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
          ),
        ),
      );
    }

    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = history.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = history.reduce((a, b) => a > b ? a : b) * 1.05;

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.cardBorder,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= history.length) return const SizedBox.shrink();
                  return Text(
                    'Y$idx',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.economy,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.economy,
                  strokeWidth: 1.5,
                  strokeColor: AppColors.background,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.economy.withValues(alpha: 0.3),
                    AppColors.economy.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
