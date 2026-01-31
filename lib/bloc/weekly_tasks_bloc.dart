import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/weekly_tasks_repository.dart';
import '../data/repositories/points_repository.dart';

part 'weekly_tasks_event.dart';
part 'weekly_tasks_state.dart';

class WeeklyTasksBloc extends Bloc<WeeklyTasksEvent, WeeklyTasksState> {
  final WeeklyTasksRepository repo;
  final PointsRepository pointsRepo;

  WeeklyTasksBloc({required this.repo, required this.pointsRepo})
    : super(const WeeklyTasksState()) {
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
        await pointsRepo.awardWeeklyTaskPoints(event.userId, event.taskId);

        final updatedStatus = Map<String, bool>.from(state.taskStatus);
        updatedStatus[event.taskId] = true;

        final completedCount = updatedStatus.values
            .where((isDone) => isDone)
            .length;

        if (completedCount == 5) {
          await pointsRepo.awardAllWeeklyTasksBonus(event.userId);
        }
      } else {
        final completion = await repo.getTaskCompletion(
          event.userId,
          event.taskId,
        );

        final wasAllCompleted =
            state.taskStatus.values.where((isDone) => isDone).length == 5;

        await repo.markTaskIncomplete(event.userId, event.taskId);

        if (completion != null) {
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);

          if (completion.completedAt.isAfter(todayStart) ||
              completion.completedAt.isAtSameMomentAs(todayStart)) {
            await pointsRepo.revokeWeeklyTaskPoints(event.userId, event.taskId);
          }
        }

        if (wasAllCompleted) {
          await pointsRepo.revokeAllWeeklyTasksBonus(event.userId);
        }
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
