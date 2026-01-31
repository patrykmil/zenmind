part of 'points_bloc.dart';

sealed class PointsEvent extends Equatable {
  const PointsEvent();
  @override
  List<Object?> get props => [];
}

class PointsLoadRequested extends PointsEvent {
  final String userId;

  const PointsLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class PointsAwarded extends PointsEvent {
  final int points;
  final String reason;

  const PointsAwarded({required this.points, required this.reason});

  @override
  List<Object?> get props => [points, reason];
}

class PointsHistoryChanged extends PointsEvent {
  final String userId;

  const PointsHistoryChanged({required this.userId});

  @override
  List<Object?> get props => [userId];
}
