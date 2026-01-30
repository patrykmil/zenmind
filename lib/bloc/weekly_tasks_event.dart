part of 'weekly_tasks_bloc.dart';

sealed class WeeklyTasksEvent extends Equatable {
  const WeeklyTasksEvent();
  @override
  List<Object?> get props => [];
}

class WeeklyTasksLoadRequested extends WeeklyTasksEvent {
  final String userId;

  const WeeklyTasksLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class WeeklyTaskToggled extends WeeklyTasksEvent {
  final String userId;
  final String taskId;
  final bool isDone;

  const WeeklyTaskToggled({
    required this.userId,
    required this.taskId,
    required this.isDone,
  });

  @override
  List<Object?> get props => [userId, taskId, isDone];
}
