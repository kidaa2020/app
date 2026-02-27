import 'package:flutter/material.dart';
import 'package:healthbuddy/core/theme/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  final double progress;

  const XpProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(6)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: AppColors.mintGreen.withOpacity(0.2), blurRadius: 6)],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
