part of 'save_reaction_bloc.dart';

enum SaveReactionStatus { initial, loading, success, failure }

class SaveReactionState extends Equatable {
  final SaveReactionStatus status;
  final String? errorMessage;

  const SaveReactionState({
    this.status = SaveReactionStatus.initial,
    this.errorMessage,
  });

  SaveReactionState copyWith({
    SaveReactionStatus? status,
    String? errorMessage,
  }) {
    return SaveReactionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
