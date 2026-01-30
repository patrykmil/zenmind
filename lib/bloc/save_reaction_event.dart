part of 'save_reaction_bloc.dart';

sealed class SaveReactionEvent extends Equatable {
  const SaveReactionEvent();
  @override
  List<Object?> get props => [];
}

class ReactionSubmitPressed extends SaveReactionEvent {
  final String userId;
  final MoodOption mood;

  const ReactionSubmitPressed({required this.userId, required this.mood});

  @override
  List<Object?> get props => [userId, mood];
}
