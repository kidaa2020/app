import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/features/today/providers/today_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/models/meal_type.dart';
import 'package:healthbuddy/features/today/widgets/daily_summary_card.dart';
import 'package:healthbuddy/features/today/widgets/meal_section.dart';
import 'package:healthbuddy/features/today/screens/barcode_scanner_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(dailyTotalsProvider);
    final entries = ref.watch(todayEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoy', style: AppTextStyles.h1),
                Text(
                  _formatDate(DateTime.now()),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            toolbarHeight: 72,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DailySummaryCard(totals: totals),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ...MealType.values.map((mealType) {
            final mealEntries =
                entries.where((e) => e.mealType == mealType).toList();
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MealSection(
                  mealType: mealType,
                  entries: mealEntries,
                  onDelete: (id) {
                    ref.read(todayEntriesProvider.notifier).deleteEntry(id);
                  },
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodOptions(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir comida'),
        backgroundColor: AppColors.mintGreen,
        foregroundColor: AppColors.darkText,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  void _showAddFoodOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.subtleText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Añadir alimento', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              icon: Icons.qr_code_scanner,
              title: 'Escanear código de barras',
              subtitle: 'Buscar producto automáticamente',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BarcodeScannerScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
              icon: Icons.edit_note,
              title: 'Entrada manual',
              subtitle: 'Introducir datos nutricionales',
              onTap: () {
                Navigator.pop(context);
                _showManualEntryDialog(context, ref);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.mintGreenDark, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyBold),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.subtleText),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();
    final qtyController = TextEditingController(text: '100');
    MealType selectedMeal = MealType.meal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Entrada manual', style: AppTextStyles.h3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del alimento',
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MealType>(
                  value: selectedMeal,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de comida',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  items: MealType.values
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('${m.icon} ${m.label}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedMeal = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad (g)',
                    prefixIcon: Icon(Icons.scale),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Valores por 100g:', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'kcal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: protController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Prot (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carb (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Grasa (g)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final entry = FoodEntry(
                  id: const Uuid().v4(),
                  productName: nameController.text.isEmpty
                      ? 'Alimento'
                      : nameController.text,
                  calories: double.tryParse(calController.text) ?? 0,
                  proteins: double.tryParse(protController.text) ?? 0,
                  carbs: double.tryParse(carbController.text) ?? 0,
                  fats: double.tryParse(fatController.text) ?? 0,
                  quantity: double.tryParse(qtyController.text) ?? 100,
                  mealType: selectedMeal,
                  date: DateTime.now(),
                );
                ref.read(todayEntriesProvider.notifier).addEntry(entry);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
