import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReactionEntry extends Equatable {
  final String id;
  final int score;
  final DateTime createdAt;

  const ReactionEntry({
    required this.id,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'score': score,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ReactionEntry.fromMap(Map<String, dynamic> map) => ReactionEntry(
    id: map['id'] as String,
    score: map['score'] as int,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );

  @override
  List<Object?> get props => [id, score, createdAt];
}
