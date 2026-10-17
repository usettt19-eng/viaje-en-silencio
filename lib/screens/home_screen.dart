import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content_repository.dart';
import '../models/day_entry.dart';
import '../models/progress.dart';
import '../widgets/day_section_card.dart';
import 'silence_altar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _prefsKey = 'progress_v1';

  Progress _progress = const Progress();
  bool _loading = true;
  bool _morning = true; // true = mañana, false = noche

  @override
  void initState() {
    super.initState();
    _load();
    _morning = DateTime.now().hour < 17;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) _progress = Progress.fromJson(raw);
    } catch (_) {
      // Si los datos guardados fallan, se empieza desde el día 1.
      _progress = const Progress();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(Progress p) async {
    setState(() => _progress = p);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, p.toJson());
  }

  void _toggleChallenge(int day) {
    final set = {..._progress.completedChallenges};
    set.contains(day) ? set.remove(day) : set.add(day);
    _save(_progress.copyWith(completedChallenges: set));
  }

  void _toggleFavorite(int day) {
    final set = {..._progress.favoriteDays};
    set.contains(day) ? set.remove(day) : set.add(day);
    _save(_progress.copyWith(favoriteDays: set));
  }

  void _goToDay(int day) {
    if (day < 1 || day > 40) return;
    _save(_progress.copyWith(currentDay: day));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final dayNum = _progress.currentDay;
    final entry = ContentRepository.dayFor(dayNum);
    final week = ContentRepository.weekFor(dayNum);

    return Scaffold(
      appBar: AppBar(
        title: const Text('El Recorrido de Hoy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _header(theme, dayNum, week.number, week.title),
          const SizedBox(height: 16),
          _routineSelector(theme),
          const SizedBox(height: 16),
          Text(entry.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          if (_morning) ..._morningCards(theme, entry) else ..._nightCards(theme, entry),
          const SizedBox(height: 8),
          _dayNavigation(dayNum),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, int day, int week, String weekTitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Día $day de 40  ·  Semana $week',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            Text(weekTitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: day / 40, minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routineSelector(ThemeData theme) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
            value: true,
            icon: Icon(Icons.wb_sunny_outlined),
            label: Text('Mañana')),
        ButtonSegment(
            value: false,
            icon: Icon(Icons.nightlight_outlined),
            label: Text('Noche')),
      ],
      selected: {_morning},
      onSelectionChanged: (s) => setState(() => _morning = s.first),
    );
  }

  List<Widget> _morningCards(ThemeData theme, DayEntry e) {
    final done = _progress.completedChallenges.contains(e.number);
    final fav = _progress.favoriteDays.contains(e.number);
    return [
      DaySectionCard(
        icon: Icons.auto_stories_outlined,
        title: 'Introducción y Reflexión',
        initiallyExpanded: true,
        child: Text(e.intro, style: theme.textTheme.bodyLarge),
      ),
      DaySectionCard(
        icon: Icons.people_outline,
        title: 'Historia Compartida',
        child: Text(e.story, style: theme.textTheme.bodyLarge),
      ),
      DaySectionCard(
        icon: Icons.menu_book_outlined,
        title: 'Enseñanza y Fundamento Bíblico',
        child: Text(e.teaching, style: theme.textTheme.bodyLarge),
      ),
      DaySectionCard(
        icon: Icons.format_quote,
        title: 'Versículo Clave',
        initiallyExpanded: true,
        child: _verse(theme, e, fav),
      ),
      DaySectionCard(
        icon: Icons.flag_outlined,
        title: 'Desafío Práctico',
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.challenge, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: done,
              onChanged: (_) => _toggleChallenge(e.number),
              title: const Text('Marcar como completado'),
            ),
            const SizedBox(height: 4),
            FilledButton.tonalIcon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      SilenceAltarScreen(suggestedMinutes: e.challengeMinutes),
                ));
                _load(); // refresca los minutos acumulados
              },
              icon: const Icon(Icons.spa_outlined),
              label: Text('Altar de Silencio · ${e.challengeMinutes} min'),
            ),
          ],
        ),
      ),
      DaySectionCard(
        icon: Icons.volunteer_activism_outlined,
        title: 'Oración Guiada',
        child: Text(e.prayer,
            style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
      ),
    ];
  }

  List<Widget> _nightCards(ThemeData theme, DayEntry e) {
    return [
      DaySectionCard(
        icon: Icons.edit_note,
        title: 'Preguntas para Reflexionar',
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final q in e.questions) ...[
              Text(q, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              const TextField(
                maxLines: null,
                minLines: 2,
                decoration: InputDecoration(
                    hintText: 'Tu respuesta…', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
            ],
            // TODO: persistir en local_db.dart (SQLite) con JournalEntry.
          ],
        ),
      ),
      DaySectionCard(
        icon: Icons.volunteer_activism_outlined,
        title: 'Oración de la Noche',
        child: Text(e.prayer,
            style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
      ),
    ];
  }

  Widget _verse(ThemeData theme, DayEntry e, bool fav) {
    final full = '“${e.verseText}” — ${e.verseReference}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('“${e.verseText}”',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontStyle: FontStyle.italic, fontSize: 19)),
        const SizedBox(height: 4),
        Text(e.verseReference, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'Copiar',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: full));
                _snack('Versículo copiado');
              },
            ),
            IconButton(
              tooltip: 'Compartir',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(full),
            ),
            IconButton(
              tooltip: 'Favorito',
              icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _toggleFavorite(e.number),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dayNavigation(int day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: day > 1 ? () => _goToDay(day - 1) : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('Anterior'),
        ),
        TextButton.icon(
          onPressed: day < 40 ? () => _goToDay(day + 1) : null,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Siguiente'),
        ),
      ],
    );
  }
}
