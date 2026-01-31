import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/points_record.dart';
import '../models/profile_stats.dart';

class StreakTracker {
  final String userId;
  final int currentStreak;
  final DateTime lastReactionDate;
  final int longestStreak;
  final List<DateTime> streakDates;

  StreakTracker({
    required this.userId,
    required this.currentStreak,
    required this.lastReactionDate,
    required this.longestStreak,
    required this.streakDates,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'lastReactionDate': lastReactionDate.toIso8601String(),
      'longestStreak': longestStreak,
      'streakDates': streakDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory StreakTracker.fromMap(Map<String, dynamic> map) {
    return StreakTracker(
      userId: map['userId'] as String,
      currentStreak: map['currentStreak'] as int? ?? 0,
      lastReactionDate: DateTime.parse(
        map['lastReactionDate'] as String? ?? '',
      ),
      longestStreak: map['longestStreak'] as int? ?? 0,
      streakDates:
          (map['streakDates'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
    );
  }
}

class PointsRemoteDataSource {
  final FirebaseFirestore firestore;
  final Uuid uuid;

  PointsRemoteDataSource(this.firestore, {Uuid? uuid})
    : uuid = uuid ?? const Uuid();

  Future<int> awardDailyReactionPoints(String userId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingPoints = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .where('reason', isEqualTo: 'daily_reaction')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .get();

    if (existingPoints.docs.isNotEmpty) {
      return 0;
    }

    const points = 5;
    final record = PointsRecord(
      id: uuid.v4(),
      userId: userId,
      points: points,
      reason: 'daily_reaction',
      createdAt: DateTime.now(),
    );

    await _updateStreak(userId);

    await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .doc(record.id)
        .set({
          'userId': record.userId,
          'points': record.points,
          'reason': record.reason,
          'createdAt': Timestamp.fromDate(record.createdAt),
        });

    return points;
  }

  Future<int> awardWeeklyTaskPoints(String userId, String taskId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingPoints = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .where('reason', isEqualTo: 'weekly_task_$taskId')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .get();

    if (existingPoints.docs.isNotEmpty) {
      return 0;
    }

    const points = 10;
    final record = PointsRecord(
      id: uuid.v4(),
      userId: userId,
      points: points,
      reason: 'weekly_task_$taskId',
      createdAt: DateTime.now(),
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .doc(record.id)
        .set({
          'userId': record.userId,
          'points': record.points,
          'reason': record.reason,
          'createdAt': Timestamp.fromDate(record.createdAt),
        });

    return points;
  }

  Future<int> awardAllWeeklyTasksBonus(String userId) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);

    final existingBonus = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .where('reason', isEqualTo: 'all_weekly_tasks_bonus')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(mondayStart),
        )
        .get();

    if (existingBonus.docs.isNotEmpty) {
      return 0;
    }

    const points = 40;
    final record = PointsRecord(
      id: uuid.v4(),
      userId: userId,
      points: points,
      reason: 'all_weekly_tasks_bonus',
      createdAt: DateTime.now(),
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .doc(record.id)
        .set({
          'userId': record.userId,
          'points': record.points,
          'reason': record.reason,
          'createdAt': Timestamp.fromDate(record.createdAt),
        });

    return points;
  }

  Future<int> revokeWeeklyTaskPoints(String userId, String taskId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingPoints = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .where('reason', isEqualTo: 'weekly_task_$taskId')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .get();

    int revokedPoints = 0;
    for (final doc in existingPoints.docs) {
      revokedPoints += doc['points'] as int? ?? 0;
      await doc.reference.delete();
    }

    return revokedPoints;
  }

  Future<int> revokeAllWeeklyTasksBonus(String userId) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);

    final existingBonus = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .where('reason', isEqualTo: 'all_weekly_tasks_bonus')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(mondayStart),
        )
        .get();

    int revokedPoints = 0;
    for (final doc in existingBonus.docs) {
      revokedPoints += doc['points'] as int? ?? 0;
      await doc.reference.delete();
    }

    return revokedPoints;
  }

  Future<int> getTotalPoints(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      total += doc['points'] as int? ?? 0;
    }
    return total;
  }

  Stream<int> getTotalPointsStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory')
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (final doc in snapshot.docs) {
            total += doc['points'] as int? ?? 0;
          }
          return total;
        });
  }

  Stream<ProfileStats> getProfileStatsStream(String userId) {
    final reactionsCollection = firestore
        .collection('users')
        .doc(userId)
        .collection('reactions');

    final pointsCollection = firestore
        .collection('users')
        .doc(userId)
        .collection('pointsHistory');

    return reactionsCollection.snapshots().asyncExpand((reactionsSnapshot) {
      return pointsCollection.snapshots().map((pointsSnapshot) {
        return _calculateProfileStats(reactionsSnapshot, pointsSnapshot);
      });
    });
  }

  Future<int> getCurrentStreak(String userId) async {
    return await _calculateCurrentStreak(userId);
  }

  ProfileStats _calculateProfileStats(
    QuerySnapshot<Map<String, dynamic>> reactionsSnapshot,
    QuerySnapshot<Map<String, dynamic>> pointsSnapshot,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final total = reactionsSnapshot.size;
    final Set<String> daysWithReactions = <String>{};
    int todayCount = 0;

    for (final doc in reactionsSnapshot.docs) {
      final data = doc.data();
      final createdAt = data['createdAt'];
      if (createdAt != null) {
        final dt = createdAt is Timestamp
            ? createdAt.toDate()
            : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
        final dateKey = _dateKey(DateTime(dt.year, dt.month, dt.day));
        daysWithReactions.add(dateKey);

        if (_dateKey(todayStart) == dateKey) todayCount++;
      }
    }

    int streak = 0;
    const int maxLookbackDays = 60;

    for (int i = 0; i < maxLookbackDays; i++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _dateKey(day);

      if (daysWithReactions.contains(key)) {
        streak++;
      } else {
        break;
      }
    }

    int totalPoints = 0;
    int todayPoints = 0;

    for (final doc in pointsSnapshot.docs) {
      final data = doc.data();
      final points = data['points'] as int? ?? 0;
      totalPoints += points;

      final createdAt = data['createdAt'];
      if (createdAt != null) {
        final dt = createdAt is Timestamp
            ? createdAt.toDate()
            : DateTime.parse(createdAt as String);
        if (dt.isAfter(todayStart) || dt.isAtSameMomentAs(todayStart)) {
          todayPoints += points;
        }
      }
    }

    return ProfileStats(
      total: total,
      today: todayCount,
      streak: streak,
      totalPoints: totalPoints,
      todayPoints: todayPoints,
    );
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<int> _calculateCurrentStreak(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allReactions = await firestore
        .collection('users')
        .doc(userId)
        .collection('reactions')
        .get();

    if (allReactions.docs.isEmpty) {
      return 0;
    }

    final reactionDates =
        allReactions.docs
            .map((doc) {
              final data = doc.data();
              final createdAt = data['createdAt'];
              return createdAt.toDate();
            })
            .map((dt) => DateTime(dt.year, dt.month, dt.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final mostRecentDate = reactionDates.first;
    final yesterday = today.subtract(const Duration(days: 1));

    if (mostRecentDate.isBefore(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = mostRecentDate;

    for (final date in reactionDates) {
      if (date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  Future<void> _updateStreak(String userId) async {
    final currentStreak = await _calculateCurrentStreak(userId);

    int streakBonusPoints = 0;
    if (currentStreak == 7) {
      streakBonusPoints = 20;
    } else if (currentStreak == 14) {
      streakBonusPoints = 50;
    } else if (currentStreak == 30) {
      streakBonusPoints = 100;
    }

    if (streakBonusPoints > 0) {
      final record = PointsRecord(
        id: uuid.v4(),
        userId: userId,
        points: streakBonusPoints,
        reason: 'streak_$currentStreak',
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(userId)
          .collection('pointsHistory')
          .doc(record.id)
          .set({
            'userId': record.userId,
            'points': record.points,
            'reason': record.reason,
            'createdAt': Timestamp.fromDate(record.createdAt),
          });
    }
  }
}
