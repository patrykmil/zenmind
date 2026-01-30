class ProfileStats {
  final int total;
  final int today;
  final int streak;
  final int totalPoints;
  final int todayPoints;

  const ProfileStats({
    required this.total,
    required this.today,
    required this.streak,
    required this.totalPoints,
    required this.todayPoints,
  });

  factory ProfileStats.empty() {
    return const ProfileStats(
      total: 0,
      today: 0,
      streak: 0,
      totalPoints: 0,
      todayPoints: 0,
    );
  }
}
