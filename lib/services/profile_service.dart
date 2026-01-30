import 'package:belfort/core/utils/date_utils.dart' as app_date_utils;
import 'package:belfort/core/utils/points_calculator.dart';
import 'package:belfort/data/models/profile_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final String userId;

  ProfileService(this._firestore, this.userId);

  CollectionReference<Map<String, dynamic>> get _reactionsCollection {
    return _firestore.collection('users').doc(userId).collection('reactions');
  }

  Stream<ProfileStats> createStatsStream() {
    if (userId.isEmpty) {
      return Stream.value(ProfileStats.empty());
    }

    return _reactionsCollection.snapshots().map((snapshot) {
      final now = DateTime.now();
      final todayKey = app_date_utils.DateUtils.toLocalDateKey(
        DateTime(now.year, now.month, now.day),
      );

      final total = snapshot.size;
      final Set<String> daysWithReactions = <String>{};
      int todayCount = 0;
      int totalPoints = 0;
      int todayPoints = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'];

        if (createdAt != null) {
          final dt = createdAt is Timestamp
              ? createdAt.toDate()
              : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
          final dateKey = app_date_utils.DateUtils.toLocalDateKey(
            DateTime(dt.year, dt.month, dt.day),
          );
          daysWithReactions.add(dateKey);
          if (dateKey == todayKey) todayCount++;
        }

        final score = data['score'];
        final scoreInt = (score is int) ? score : int.tryParse('$score');

        if (scoreInt != null && createdAt != null) {
          final pts = PointsCalculator.calculatePoints(scoreInt);
          totalPoints += pts;

          final dt = createdAt is Timestamp
              ? createdAt.toDate()
              : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
          final dateKey = app_date_utils.DateUtils.toLocalDateKey(
            DateTime(dt.year, dt.month, dt.day),
          );
          if (dateKey == todayKey) todayPoints += pts;
        }
      }

      final streak = _calculateStreak(daysWithReactions, now);

      return ProfileStats(
        total: total,
        today: todayCount,
        streak: streak,
        totalPoints: totalPoints,
        todayPoints: todayPoints,
      );
    });
  }

  int _calculateStreak(Set<String> daysWithReactions, DateTime now) {
    int streak = 0;
    const int maxLookbackDays = 60;

    for (int i = 0; i < maxLookbackDays; i++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = app_date_utils.DateUtils.toLocalDateKey(day);

      if (daysWithReactions.contains(key)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
