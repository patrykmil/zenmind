import 'package:belfort/data/models/mood_option.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/reaction_entry.dart';
import '../../data/repositories/reactions_repository.dart';
import '../../data/repositories/points_repository.dart';

part 'save_reaction_event.dart';
part 'save_reaction_state.dart';

class SaveReactionBloc extends Bloc<SaveReactionEvent, SaveReactionState> {
  final ReactionsRepository repo;
  final PointsRepository pointsRepo;
  final Uuid uuid;

  SaveReactionBloc({required this.repo, required this.pointsRepo, Uuid? uuid})
    : uuid = uuid ?? const Uuid(),
      super(const SaveReactionState()) {
    on<ReactionSubmitPressed>(_onSubmit);
  }

  Future<void> _onSubmit(
    ReactionSubmitPressed event,
    Emitter<SaveReactionState> emit,
  ) async {
    final mood = event.mood;

    if (mood.score < 1 || mood.score > 5) {
      emit(
        state.copyWith(
          status: SaveReactionStatus.failure,
          errorMessage: 'Invalid score',
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: SaveReactionStatus.loading, errorMessage: null),
    );

    try {
      final entry = ReactionEntry(
        id: uuid.v4(),
        score: mood.score,
        createdAt: DateTime.now(),
      );

      await repo.createReaction(event.userId, entry);

      await pointsRepo.awardDailyReactionPoints(event.userId);

      emit(state.copyWith(status: SaveReactionStatus.success));
      emit(state.copyWith(status: SaveReactionStatus.initial));
    } catch (e) {
      emit(
        state.copyWith(
          status: SaveReactionStatus.failure,
          errorMessage: 'Could not save reaction: $e',
        ),
      );
    }
  }
}
