import 'package:flutter/material.dart';
import 'package:belfort/core/constants/app_colors.dart';

class PointsCard extends StatelessWidget {
  final int totalPoints;
  final int todayPoints;
  final VoidCallback onInfoTap;

  const PointsCard({
    super.key,
    required this.totalPoints,
    required this.todayPoints,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.darkContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Icon(
                  Icons.gps_fixed,
                  color: AppColors.softTint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Your points',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.softTint,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '$totalPoints  (+ $todayPoints today)',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.softTint,
                side: BorderSide(
                  color: AppColors.greenPrimary.withValues(alpha: 0.75),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onInfoTap,
              child: const Text(
                'See what you can get',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
