import 'package:flutter/material.dart';
import 'package:belfort/core/constants/app_colors.dart';
import 'package:belfort/data/models/weekly_task.dart';

class WeeklyTaskItem extends StatelessWidget {
  final WeeklyTask task;
  final ValueChanged<bool> onToggle;

  const WeeklyTaskItem({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onToggle(!task.isDone),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: task.isDone
              ? AppColors.greenPrimary.withValues(alpha: 0.14)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isDone ? AppColors.greenPrimary : AppColors.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              task.icon,
              color: task.isDone ? AppColors.greenDark : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isDone,
              onChanged: (v) => onToggle(v ?? false),
              activeColor: AppColors.greenPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
