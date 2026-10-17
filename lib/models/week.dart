class Week {
  final int number; // 1..8
  final String title;
  final String subtitle;

  const Week({required this.number, required this.title, required this.subtitle});

  /// Los días de esta semana: (number-1)*5+1 .. number*5
  List<int> get dayNumbers =>
      List.generate(5, (i) => (number - 1) * 5 + i + 1);
}
