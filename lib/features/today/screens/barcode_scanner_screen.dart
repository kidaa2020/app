import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/data/datasources/remote/open_food_facts_api.dart';
import 'package:healthbuddy/data/models/food_entry.dart';
import 'package:healthbuddy/data/models/meal_type.dart';
import 'package:healthbuddy/data/models/product.dart';
import 'package:healthbuddy/features/today/providers/today_provider.dart';
import 'package:healthbuddy/features/pet/providers/pet_provider.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final OpenFoodFactsApi _api = OpenFoodFactsApi();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Escanear código', style: AppTextStyles.h3.copyWith(color: Colors.white)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mintGreen, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Apunta al código de barras del producto',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.mintGreen),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    final product = await _api.getProductByBarcode(barcode);

    if (!mounted) return;

    if (product != null) {
      _showProductDetail(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto no encontrado para: $barcode'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isProcessing = false);
      _controller.start();
    }
  }

  void _showProductDetail(Product product) {
    MealType selectedMeal = MealType.meal;
    final qtyController = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtleText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.name, style: AppTextStyles.h3),
              if (product.servingSize != null)
                Text('Porción: ${product.servingSize}',
                    style: AppTextStyles.caption),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroChip('🔥', product.caloriesPer100g.toStringAsFixed(0), 'kcal', AppColors.calorieColor),
                    _macroChip('🥩', product.proteinsPer100g.toStringAsFixed(1), 'g prot', AppColors.proteinColor),
                    _macroChip('🌾', product.carbsPer100g.toStringAsFixed(1), 'g carb', AppColors.carbColor),
                    _macroChip('🧈', product.fatsPer100g.toStringAsFixed(1), 'g grasa', AppColors.fatColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad consumida (g)',
                  prefixIcon: Icon(Icons.scale),
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
                    .map((m) => DropdownMenuItem(value: m,
                        child: Text('${m.icon} ${m.label}')))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedMeal = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final qty = double.tryParse(qtyController.text) ?? 100;
                    final entry = FoodEntry(
                      id: const Uuid().v4(),
                      productName: product.name,
                      barcode: product.barcode,
                      calories: product.caloriesPer100g,
                      proteins: product.proteinsPer100g,
                      carbs: product.carbsPer100g,
                      fats: product.fatsPer100g,
                      quantity: qty,
                      mealType: selectedMeal,
                      date: DateTime.now(),
                    );
                    ref.read(todayEntriesProvider.notifier).addEntry(entry);

                    ref.read(petProvider.notifier).addXp(AppConstants.xpPerMealLogged);

                    final mealsToday = ref.read(todayEntriesProvider).length;
                    if (mealsToday == AppConstants.xpDailyBonusThreshold) {
                      ref.read(petProvider.notifier).addXp(AppConstants.xpDailyBonus);
                    }

                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} añadido (+${AppConstants.xpPerMealLogged} XP)'),
                        backgroundColor: AppColors.mintGreenDark,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir al diario'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _isProcessing = false);
      _controller.start();
    });
  }

  Widget _macroChip(String emoji, String value, String unit, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyBold.copyWith(color: color)),
        Text(unit, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}
