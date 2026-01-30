import 'package:flutter/material.dart';
import 'package:belfort/core/constants/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.greenPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFFF7043),
                  Color(0xFFE11D48),
                ],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.local_fire_department,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$streakDays',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current streak',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.greenDark.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
