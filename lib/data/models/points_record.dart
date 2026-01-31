import 'package:equatable/equatable.dart';

class PointsRecord extends Equatable {
  final String id;
  final String userId;
  final int points;
  final String reason;
  final DateTime createdAt;

  const PointsRecord({
    required this.id,
    required this.userId,
    required this.points,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'reason': reason,
      'createdAt': createdAt,
    };
  }

  factory PointsRecord.fromMap(Map<String, dynamic> map) {
    return PointsRecord(
      id: map['id'] as String,
      userId: map['userId'] as String,
      points: map['points'] as int,
      reason: map['reason'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, points, reason, createdAt];
}
