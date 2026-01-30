import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WeeklyTask extends Equatable {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;

  const WeeklyTask({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDone = false,
  });

  WeeklyTask copyWith({
    String? id,
    IconData? icon,
    String? title,
    String? subtitle,
    bool? isDone,
  }) {
    return WeeklyTask(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [id, icon, title, subtitle, isDone];
}
