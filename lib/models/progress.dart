import 'dart:convert';

class Progress {
  final int currentDay; // 1..40
  final Set<int> completedChallenges;
  final Set<int> favoriteDays;
  final int totalSilenceMinutes;

  const Progress({
    this.currentDay = 1,
    this.completedChallenges = const {},
    this.favoriteDays = const {},
    this.totalSilenceMinutes = 0,
  });

  int get currentWeek => ((currentDay - 1) ~/ 5) + 1;
  int get daysCompleted => completedChallenges.length;

  Progress copyWith({
    int? currentDay,
    Set<int>? completedChallenges,
    Set<int>? favoriteDays,
    int? totalSilenceMinutes,
  }) =>
      Progress(
        currentDay: currentDay ?? this.currentDay,
        completedChallenges: completedChallenges ?? this.completedChallenges,
        favoriteDays: favoriteDays ?? this.favoriteDays,
        totalSilenceMinutes: totalSilenceMinutes ?? this.totalSilenceMinutes,
      );

  String toJson() => jsonEncode({
        'currentDay': currentDay,
        'completed': completedChallenges.toList(),
        'favorites': favoriteDays.toList(),
        'minutes': totalSilenceMinutes,
      });

  factory Progress.fromJson(String source) {
    final m = jsonDecode(source) as Map<String, dynamic>;
    return Progress(
      currentDay: m['currentDay'] as int,
      completedChallenges: (m['completed'] as List).cast<int>().toSet(),
      favoriteDays: (m['favorites'] as List).cast<int>().toSet(),
      totalSilenceMinutes: m['minutes'] as int,
    );
  }
}
