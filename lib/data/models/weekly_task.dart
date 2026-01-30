import 'package:flutter/material.dart';

class WeeklyTask {
  final IconData icon;
  final String title;
  final String subtitle;
  bool isDone;

  WeeklyTask({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDone = false,
  });
}
