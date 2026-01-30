class MoodOption {
  final String emoji;
  final String label;
  final int score;

  const MoodOption(this.emoji, this.label, this.score);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodOption &&
          runtimeType == other.runtimeType &&
          emoji == other.emoji &&
          label == other.label &&
          score == other.score;

  @override
  int get hashCode => emoji.hashCode ^ label.hashCode ^ score.hashCode;
}
