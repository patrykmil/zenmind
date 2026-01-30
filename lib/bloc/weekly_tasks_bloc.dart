import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/weekly_tasks_repository.dart';

part 'weekly_tasks_event.dart';
part 'weekly_tasks_state.dart';

class WeeklyTasksBloc extends Bloc<WeeklyTasksEvent, WeeklyTasksState> {
  final WeeklyTasksRepository repo;

  WeeklyTasksBloc({required this.repo}) : super(const WeeklyTasksState()) {
    on<WeeklyTasksLoadRequested>(_onLoadRequested);
    on<WeeklyTaskToggled>(_onTaskToggled);
  }

  Future<void> _onLoadRequested(
    WeeklyTasksLoadRequested event,
    Emitter<WeeklyTasksState> emit,
  ) async {
    emit(state.copyWith(status: WeeklyTasksStatus.loading));
    try {
      await emit.forEach(
        repo.getWeeklyTasksStatusStream(event.userId),
        onData: (taskStatus) {
          return state.copyWith(
            status: WeeklyTasksStatus.success,
            taskStatus: taskStatus,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: WeeklyTasksStatus.failure,
            errorMessage: 'Failed to load tasks: $error',
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WeeklyTasksStatus.failure,
          errorMessage: 'Failed to load tasks: $e',
        ),
      );
    }
  }

  Future<void> _onTaskToggled(
    WeeklyTaskToggled event,
    Emitter<WeeklyTasksState> emit,
  ) async {
    try {
      if (event.isDone) {
        await repo.markTaskComplete(event.userId, event.taskId);
      } else {
        await repo.markTaskIncomplete(event.userId, event.taskId);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WeeklyTasksStatus.failure,
          errorMessage: 'Failed to update task: $e',
        ),
      );
    }
  }
}
