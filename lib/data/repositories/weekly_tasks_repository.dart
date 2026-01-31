import '../datasource/weekly_tasks_remote_ds.dart';

class WeeklyTasksRepository {
  final WeeklyTasksRemoteDataSource remote;
  WeeklyTasksRepository(this.remote);

  Stream<Map<String, bool>> getWeeklyTasksStatusStream(String userId) =>
      remote.getWeeklyTasksStatusStream(userId);

  Future<void> markTaskComplete(String userId, String taskId) =>
      remote.markTaskComplete(userId, taskId);

  Future<void> markTaskIncomplete(String userId, String taskId) =>
      remote.markTaskIncomplete(userId, taskId);

  Future<TaskCompletion?> getTaskCompletion(String userId, String taskId) =>
      remote.getTaskCompletion(userId, taskId);
}
