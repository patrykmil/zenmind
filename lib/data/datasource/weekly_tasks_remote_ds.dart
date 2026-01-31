import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCompletion {
  final String taskId;
  final bool isDone;
  final DateTime completedAt;

  TaskCompletion({
    required this.taskId,
    required this.isDone,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {'taskId': taskId, 'isDone': isDone, 'completedAt': completedAt};
  }

  factory TaskCompletion.fromMap(Map<String, dynamic> map) {
    return TaskCompletion(
      taskId: map['taskId'] as String,
      isDone: map['isDone'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class WeeklyTasksRemoteDataSource {
  final FirebaseFirestore firestore;
  WeeklyTasksRemoteDataSource(this.firestore);

  Stream<Map<String, bool>> getWeeklyTasksStatusStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('taskCompletions')
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final mondayStart = DateTime(monday.year, monday.month, monday.day);
          final sundayEnd = mondayStart.add(const Duration(days: 7));

          final statusMap = <String, bool>{};
          for (final doc in snapshot.docs) {
            final completion = TaskCompletion.fromMap(doc.data());
            if (completion.isDone &&
                completion.completedAt.isAfter(mondayStart) &&
                completion.completedAt.isBefore(sundayEnd)) {
              statusMap[completion.taskId] = true;
            }
          }
          return statusMap;
        });
  }

  Future<void> markTaskComplete(String userId, String taskId) async {
    final now = DateTime.now();
    final completion = TaskCompletion(
      taskId: taskId,
      isDone: true,
      completedAt: now,
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('taskCompletions')
        .doc(taskId)
        .set(completion.toMap());
  }

  Future<void> markTaskIncomplete(String userId, String taskId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('taskCompletions')
        .doc(taskId)
        .delete();
  }

  Future<TaskCompletion?> getTaskCompletion(
    String userId,
    String taskId,
  ) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('taskCompletions')
        .doc(taskId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return TaskCompletion.fromMap(doc.data()!);
  }
}
