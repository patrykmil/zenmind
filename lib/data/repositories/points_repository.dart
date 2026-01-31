import '../datasource/points_remote_ds.dart';
import '../models/profile_stats.dart';

class PointsRepository {
  final PointsRemoteDataSource remote;
  PointsRepository(this.remote);

  Future<int> awardDailyReactionPoints(String userId) =>
      remote.awardDailyReactionPoints(userId);

  Future<int> awardWeeklyTaskPoints(String userId, String taskId) =>
      remote.awardWeeklyTaskPoints(userId, taskId);

  Future<int> awardAllWeeklyTasksBonus(String userId) =>
      remote.awardAllWeeklyTasksBonus(userId);

  Future<int> revokeWeeklyTaskPoints(String userId, String taskId) =>
      remote.revokeWeeklyTaskPoints(userId, taskId);

  Future<int> revokeAllWeeklyTasksBonus(String userId) =>
      remote.revokeAllWeeklyTasksBonus(userId);

  Future<int> getTotalPoints(String userId) => remote.getTotalPoints(userId);

  Stream<int> getTotalPointsStream(String userId) =>
      remote.getTotalPointsStream(userId);

  Stream<ProfileStats> getProfileStatsStream(String userId) =>
      remote.getProfileStatsStream(userId);

  Future<int> getCurrentStreak(String userId) =>
      remote.getCurrentStreak(userId);
}
