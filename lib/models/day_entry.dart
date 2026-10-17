class DayEntry {
  final int number; // 1..40
  final int weekNumber;
  final String title;
  final String intro; // Introducción y reflexión temática
  final String story; // Historia compartida
  final String teaching; // Enseñanza y fundamento bíblico
  final String verseText;
  final String verseReference;
  final String challenge; // Desafío práctico
  final int challengeMinutes; // Minutos sugeridos en el Altar de Silencio
  final String prayer;
  final List<String> questions; // Preguntas para reflexionar

  const DayEntry({
    required this.number,
    required this.weekNumber,
    required this.title,
    required this.intro,
    required this.story,
    required this.teaching,
    required this.verseText,
    required this.verseReference,
    required this.challenge,
    required this.challengeMinutes,
    required this.prayer,
    required this.questions,
  });
}
