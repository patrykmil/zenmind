part of 'points_bloc.dart';

enum PointsStatus { initial, loading, success, failure }

class PointsState extends Equatable {
  final PointsStatus status;
  final int totalPoints;
  final int lastAwardedPoints;
  final ProfileStats? profileStats;
  final String? errorMessage;

  const PointsState({
    this.status = PointsStatus.initial,
    this.totalPoints = 0,
    this.lastAwardedPoints = 0,
    this.profileStats,
    this.errorMessage,
  });

  PointsState copyWith({
    PointsStatus? status,
    int? totalPoints,
    int? lastAwardedPoints,
    ProfileStats? profileStats,
    String? errorMessage,
  }) {
    return PointsState(
      status: status ?? this.status,
      totalPoints: totalPoints ?? this.totalPoints,
      lastAwardedPoints: lastAwardedPoints ?? this.lastAwardedPoints,
      profileStats: profileStats ?? this.profileStats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalPoints,
    lastAwardedPoints,
    profileStats,
    errorMessage,
  ];
}
