class JournalEntry {
  final int dayNumber;
  final List<String> answers; // Una respuesta por pregunta
  final String notes; // Mis notas y reflexiones
  final DateTime updatedAt;

  const JournalEntry({
    required this.dayNumber,
    required this.answers,
    required this.notes,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() => {
        'day_number': dayNumber,
        'answers': answers.join('␞'), // separador poco común
        'notes': notes,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, Object?> m) => JournalEntry(
        dayNumber: m['day_number'] as int,
        answers: (m['answers'] as String).isEmpty
            ? []
            : (m['answers'] as String).split('␞'),
        notes: m['notes'] as String,
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  JournalEntry copyWith({List<String>? answers, String? notes}) => JournalEntry(
        dayNumber: dayNumber,
        answers: answers ?? this.answers,
        notes: notes ?? this.notes,
        updatedAt: DateTime.now(),
      );
}
