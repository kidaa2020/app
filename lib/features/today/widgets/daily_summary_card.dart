import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';

class DailySummaryCard extends StatelessWidget {
  final Map<String, double> totals;

  const DailySummaryCard({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final calories = totals['calories'] ?? 0;
    final proteins = totals['proteins'] ?? 0;
    final carbs = totals['carbs'] ?? 0;
    final fats = totals['fats'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0FAF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintGreen.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _buildSections(proteins, carbs, fats),
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      calories.toStringAsFixed(0),
                      style: AppTextStyles.smallNumber.copyWith(
                        color: AppColors.calorieColor,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildMacroRow('Proteínas', proteins, 'g', AppColors.proteinColor),
                const SizedBox(height: 8),
                _buildMacroRow('Carbohidratos', carbs, 'g', AppColors.carbColor),
                const SizedBox(height: 8),
                _buildMacroRow('Grasas', fats, 'g', AppColors.fatColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double proteins, double carbs, double fats) {
    final total = proteins + carbs + fats;
    if (total == 0) {
      return [
        PieChartSectionData(value: 1, color: AppColors.divider, radius: 12, showTitle: false),
      ];
    }
    return [
      PieChartSectionData(value: proteins, color: AppColors.proteinColor, radius: 12, showTitle: false),
      PieChartSectionData(value: carbs, color: AppColors.carbColor, radius: 12, showTitle: false),
      PieChartSectionData(value: fats, color: AppColors.fatColor, radius: 12, showTitle: false),
    ];
  }

  Widget _buildMacroRow(String label, double value, String unit, Color color) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.caption)),
        Text('${value.toStringAsFixed(1)}$unit', style: AppTextStyles.bodyBold),
      ],
    );
  }
}
