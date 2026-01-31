import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/points_repository.dart';
import '../data/models/profile_stats.dart';

part 'points_event.dart';
part 'points_state.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final PointsRepository repo;

  PointsBloc({required this.repo}) : super(const PointsState()) {
    on<PointsLoadRequested>(_onLoadRequested);
    on<PointsAwarded>(_onPointsAwarded);
    on<PointsHistoryChanged>(_onPointsHistoryChanged);
  }

  Future<void> _onLoadRequested(
    PointsLoadRequested event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    try {
      await emit.forEach(
        repo.getTotalPointsStream(event.userId),
        onData: (totalPoints) {
          return state.copyWith(
            status: PointsStatus.success,
            totalPoints: totalPoints,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: PointsStatus.failure,
            errorMessage: 'Failed to load points: $error',
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PointsStatus.failure,
          errorMessage: 'Failed to load points: $e',
        ),
      );
    }
  }

  Future<void> _onPointsAwarded(
    PointsAwarded event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(lastAwardedPoints: event.points));
  }

  Future<void> _onPointsHistoryChanged(
    PointsHistoryChanged event,
    Emitter<PointsState> emit,
  ) async {
    emit(state.copyWith(status: PointsStatus.loading));
    try {
      await emit.forEach(
        repo.getProfileStatsStream(event.userId),
        onData: (profileStats) {
          return state.copyWith(
            status: PointsStatus.success,
            profileStats: profileStats,
            totalPoints: profileStats.totalPoints,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: PointsStatus.failure,
            errorMessage: 'Failed to load profile stats: $error',
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PointsStatus.failure,
          errorMessage: 'Failed to load profile stats: $e',
        ),
      );
    }
  }
}
