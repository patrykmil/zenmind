part of 'weekly_tasks_bloc.dart';

enum WeeklyTasksStatus { initial, loading, success, failure }

class WeeklyTasksState extends Equatable {
  final WeeklyTasksStatus status;
  final Map<String, bool> taskStatus;
  final String? errorMessage;

  const WeeklyTasksState({
    this.status = WeeklyTasksStatus.initial,
    this.taskStatus = const {},
    this.errorMessage,
  });

  WeeklyTasksState copyWith({
    WeeklyTasksStatus? status,
    Map<String, bool>? taskStatus,
    String? errorMessage,
  }) {
    return WeeklyTasksState(
      status: status ?? this.status,
      taskStatus: taskStatus ?? this.taskStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, taskStatus, errorMessage];
}
