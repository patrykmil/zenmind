class PointsCalculator {
  PointsCalculator._();

  static int calculatePoints(int moodScore) {
    final clampedScore = moodScore.clamp(1, 5);
    return clampedScore * 10;
  }
}
