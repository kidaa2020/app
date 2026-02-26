import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:healthbuddy/features/pet/providers/pet_provider.dart';
import 'package:healthbuddy/features/profile/providers/profile_provider.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';
import 'package:healthbuddy/core/theme/app_text_styles.dart';
import 'package:healthbuddy/core/utils/xp_calculator.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';
import 'package:healthbuddy/data/models/pet.dart';
import 'package:healthbuddy/data/models/pet_type.dart';
import 'package:healthbuddy/features/pet/widgets/xp_progress_bar.dart';

class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen>
    with SingleTickerProviderStateMixin {
  String? _encouragement;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _isFeeding = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final user = ref.watch(userProvider);

    if (pet == null) {
      return _buildPetSelection();
    }

    final level = pet.level;
    final levelName = XpCalculator.getLevelName(level);
    final progress = XpCalculator.progressToNextLevel(pet.xp);
    final xpToNext = XpCalculator.xpForNextLevel(pet.xp);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('Tu Mascota', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(pet.name, style: AppTextStyles.subtitle),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _onPetTap,
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _bounceAnimation.value,
                    child: child,
                  ),
                  child: _buildPetAvatar(pet),
                ),
              ),
              if (_encouragement != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.mintGreen.withValues(alpha: 0.2), blurRadius: 8)],
                    ),
                    child: Text(_encouragement!, style: AppTextStyles.body),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nivel $level', style: AppTextStyles.h2),
                            Text(levelName, style: AppTextStyles.caption),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${pet.xp} XP', style: AppTextStyles.bodyBold.copyWith(color: AppColors.mintGreenDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    XpProgressBar(progress: progress),
                    const SizedBox(height: 4),
                    if (xpToNext > 0)
                      Text('$xpToNext XP para nivel ${level + 1}', style: AppTextStyles.caption)
                    else
                      Text('¡Nivel máximo!', style: AppTextStyles.caption.copyWith(color: AppColors.mintGreenDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isFeeding ? null : _feedPet,
                  icon: const Text('🍖', style: TextStyle(fontSize: 20)),
                  label: Text(
                    'Alimentar (${AppConstants.feedPetCost} 🪙)',
                    style: AppTextStyles.button.copyWith(color: AppColors.darkText),
                  ),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Monedas: ${user?.totalCoins ?? 0} 🪙', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    final size = 120.0 + (pet.level * 15.0);
    final colors = _getPetColors(pet.type);
    final hasAura = pet.level >= 4;

    // Use image for Fennec levels 1-4 if available
    final String assetPath =
        'assets/images/${pet.type.name.toLowerCase()}_level${pet.level}.png';

    return Container(
      width: size + 40,
      height: size + 40,
      decoration: hasAura
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            )
          : null,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: size * 0.8,
              height: size * 0.8,
              errorBuilder: (context, error, stackTrace) => Text(
                pet.type.emoji,
                style: TextStyle(fontSize: 40 + (pet.level * 8.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getPetColors(PetType type) {
    switch (type) {
      case PetType.fennec:
        return [const Color(0xFFFDCB6E), const Color(0xFFE17055)];
      case PetType.lemur:
        return [const Color(0xFFA29BFE), const Color(0xFF6C5CE7)];
      case PetType.chameleon:
        return [const Color(0xFF55EFC4), const Color(0xFF00B894)];
      case PetType.komodo:
        return [const Color(0xFFFF7675), const Color(0xFFD63031)];
    }
  }

  void _onPetTap() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    final msgs = AppConstants.encouragementMessages;
    setState(() => _encouragement = msgs[Random().nextInt(msgs.length)]);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _encouragement = null);
    });
  }

  Future<void> _feedPet() async {
    setState(() => _isFeeding = true);
    final success = await ref.read(petProvider.notifier).feedPet();
    if (success) {
      _bounceController.forward().then((_) => _bounceController.reverse());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🍖 ¡Tu mascota ha comido!'), backgroundColor: AppColors.mintGreenDark));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tienes suficientes monedas. ¡Entrena más!'), backgroundColor: AppColors.error));
    }
    if (mounted) setState(() => _isFeeding = false);
  }

  Widget _buildPetSelection() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text('¡Elige tu compañero!', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('Tu mascota crecerá contigo mientras mejoras tu salud', style: AppTextStyles.subtitle, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
                  itemCount: PetType.values.length,
                  itemBuilder: (context, index) => _buildPetOption(PetType.values[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetOption(PetType type) {
    final colors = _getPetColors(type);
    return GestureDetector(
      onTap: () => _selectPet(type),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: colors)),
              child: Center(child: Text(type.emoji, style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 12),
            Text(type.displayName, style: AppTextStyles.bodyBold),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(type.description, style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPet(PetType type) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nombre de tu ${type.displayName}', style: AppTextStyles.h3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Ej: Buddy, Chispa...', prefixIcon: Text(type.emoji, style: const TextStyle(fontSize: 24))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.isEmpty ? type.displayName : nameController.text;
              final pet = Pet(id: const Uuid().v4(), type: type, name: name);
              ref.read(petProvider.notifier).createPet(pet);
              Navigator.pop(ctx);
            },
            child: const Text('¡Elegir!'),
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({super.key, required Animation<double> animation, required this.builder, this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, child);
}
