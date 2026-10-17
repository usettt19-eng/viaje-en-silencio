import '../models/day_entry.dart';
import '../models/week.dart';

/// Contenido de ejemplo. Reemplaza los textos con el contenido real del libro.
class ContentRepository {
  static const weeks = <Week>[
    Week(number: 1, title: 'Descubriendo el Valor del Silencio', subtitle: 'Apagar el ruido externo'),
    Week(number: 2, title: 'Silenciar el Ruido Interior', subtitle: 'Ansiedad, pensamientos y quietud'),
    Week(number: 3, title: 'El Silencio como Encuentro con Dios', subtitle: 'Oración contemplativa'),
    Week(number: 4, title: 'Silencio y Sanidad Emocional', subtitle: 'Heridas, duelo y perdón'),
    Week(number: 5, title: 'El Silencio en las Relaciones', subtitle: 'Escucha activa y presencia'),
    Week(number: 6, title: 'Silencio como Disciplina Espiritual', subtitle: 'Ayuno de ruido y lugar fijo'),
    Week(number: 7, title: 'Silencio ante la Adversidad', subtitle: 'Esperar cuando Dios parece callar'),
    Week(number: 8, title: 'Renovación y un Nuevo Comienzo', subtitle: 'Sostener el hábito'),
  ];

  static Week weekFor(int dayNumber) => weeks[(dayNumber - 1) ~/ 5];

  static const _day1 = DayEntry(
    number: 1,
    weekNumber: 1,
    title: 'El primer paso hacia la quietud',
    intro: 'Vivimos rodeados de ruido: notificaciones, pantallas, prisas. Hoy comienzas un viaje distinto, '
        'uno que empieza por detenerte y reconocer cuánto ruido has normalizado.',
    story: '[Historia compartida del Día 1 — pega aquí el texto del libro.]',
    teaching: 'La Escritura presenta el silencio como un lugar de encuentro, no de vacío. '
        'Callar nos permite escuchar lo que el ruido sofoca.',
    verseText: 'Estad quietos, y conoced que yo soy Dios.',
    verseReference: 'Salmo 46:10',
    challenge: 'Dedica 15 minutos a estar en silencio, sin teléfono ni música.',
    challengeMinutes: 15,
    prayer: 'Señor, aquieta mi corazón. Enséñame a escucharte en medio del silencio. Amén.',
    questions: [
      '¿Qué ruidos dominan mi día?',
      '¿Qué siento cuando todo queda en silencio?',
    ],
  );

  /// Devuelve la entrada del día. Los días sin contenido cargado usan
  /// una plantilla provisional para poder probar la app completa.
  static DayEntry dayFor(int n) {
    if (n == 1) return _day1;
    final week = weekFor(n);
    return DayEntry(
      number: n,
      weekNumber: week.number,
      title: 'Día $n — ${week.subtitle}',
      intro: '[Introducción del Día $n.]',
      story: '[Historia compartida del Día $n.]',
      teaching: '[Enseñanza y fundamento bíblico del Día $n.]',
      verseText: '[Versículo clave del Día $n.]',
      verseReference: '',
      challenge: '[Desafío práctico del Día $n.]',
      challengeMinutes: 10,
      prayer: '[Oración guiada del Día $n.]',
      questions: const ['[Pregunta 1]', '[Pregunta 2]'],
    );
  }
}
