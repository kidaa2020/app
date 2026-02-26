import 'package:flutter/material.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/models/meal_type.dart';

class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<FoodEntry> entries;
  final Function(String) onDelete;

  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalCals = entries.fold<double>(0, (sum, e) => sum + e.scaledCalories);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: Text(mealType.icon, style: const TextStyle(fontSize: 24)),
          title: Text(mealType.label, style: AppTextStyles.bodyBold),
          subtitle: Text(
            entries.isEmpty
                ? 'Sin registros'
                : '${entries.length} items • ${totalCals.toStringAsFixed(0)} kcal',
            style: AppTextStyles.caption,
          ),
          children: entries.map((entry) => _buildEntryTile(context, entry)).toList(),
        ),
      ),
    );
  }

  Widget _buildEntryTile(BuildContext context, FoodEntry entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.1),
        child: const Icon(Icons.delete, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(entry.id),
      child: ListTile(
        dense: true,
        title: Text(entry.productName, style: AppTextStyles.body),
        subtitle: Text('${entry.quantity.toStringAsFixed(0)}g', style: AppTextStyles.caption),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.scaledCalories.toStringAsFixed(0)} kcal',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.calorieColor),
            ),
            Text(
              'P${entry.scaledProteins.toStringAsFixed(0)} C${entry.scaledCarbs.toStringAsFixed(0)} G${entry.scaledFats.toStringAsFixed(0)}',
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
