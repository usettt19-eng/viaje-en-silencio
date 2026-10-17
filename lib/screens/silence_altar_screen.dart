import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress.dart';

enum AmbientSound { silence, rain, wind }

/// "Altar de Silencio": temporizador de quietud con animación de respiración.
class SilenceAltarScreen extends StatefulWidget {
  final int suggestedMinutes;
  const SilenceAltarScreen({super.key, this.suggestedMinutes = 10});

  @override
  State<SilenceAltarScreen> createState() => _SilenceAltarScreenState();
}

class _SilenceAltarScreenState extends State<SilenceAltarScreen>
    with SingleTickerProviderStateMixin {
  static const _prefsKey = 'progress_v1';
  // Ciclo de respiración: inhala 4s, quietud 2s, exhala 6s.
  static const _inhale = 4, _hold = 2, _exhale = 6;
  static const _cycle = _inhale + _hold + _exhale;

  late int _minutes;
  AmbientSound _sound = AmbientSound.silence;
  bool _running = false;
  bool _finished = false;
  int _remaining = 0; // segundos
  int _elapsedInCycle = 0;
  Timer? _ticker;
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _minutes = widget.suggestedMinutes.clamp(1, 20);
    _remaining = _minutes * 60;
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _cycle),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  String get _phase {
    if (_elapsedInCycle < _inhale) return 'Inhala';
    if (_elapsedInCycle < _inhale + _hold) return 'En quietud';
    return 'Exhala';
  }

  /// Escala del círculo: crece al inhalar, se mantiene, decrece al exhalar.
  double get _scale {
    final t = _elapsedInCycle + _breath.value * 0; // el tick de 1s marca la fase
    if (t < _inhale) return 0.55 + 0.45 * (t / _inhale);
    if (t < _inhale + _hold) return 1.0;
    return 1.0 - 0.45 * ((t - _inhale - _hold) / _exhale);
  }

  void _start() {
    HapticFeedback.lightImpact();
    setState(() {
      _running = true;
      _finished = false;
      _elapsedInCycle = 0;
    });
    // TODO: reproducir sonido ambiental según _sound (paquete audioplayers + assets).
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _complete();
        return;
      }
      setState(() {
        _remaining--;
        _elapsedInCycle = (_elapsedInCycle + 1) % _cycle;
      });
    });
  }

  void _stop({bool resetTime = true}) {
    _ticker?.cancel();
    setState(() {
      _running = false;
      if (resetTime) _remaining = _minutes * 60;
    });
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _remaining = 0;
      _running = false;
      _finished = true;
    });
    await _saveMinutes(_minutes);
  }

  Future<void> _saveMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final p = raw != null ? Progress.fromJson(raw) : const Progress();
    await prefs.setString(
      _prefsKey,
      p.copyWith(totalSilenceMinutes: p.totalSilenceMinutes + minutes).toJson(),
    );
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return PopScope(
      canPop: !_running,
      onPopInvoked: (didPop) async {
        if (didPop || !_running) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('¿Terminar la sesión?'),
            content: const Text('Si sales ahora, estos minutos no se sumarán.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Seguir en silencio')),
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Salir')),
            ],
          ),
        );
        if (leave == true && mounted) {
          _ticker?.cancel();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _running
            ? null // Modo Enfoque: sin distracciones durante la sesión.
            : AppBar(
                title: const Text('Altar de Silencio'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (!_running && !_finished) ..._settings(theme),
                const Spacer(),
                _breathingCircle(theme, color),
                const SizedBox(height: 24),
                Text(
                  _finished
                      ? 'Sesión completada'
                      : (_running ? _phase : 'Cuando estés listo'),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(_fmt(_remaining),
                    style: theme.textTheme.displayLarge
                        ?.copyWith(fontWeight: FontWeight.w300)),
                if (_finished) ...[
                  const SizedBox(height: 8),
                  Text('+$_minutes min de quietud registrados',
                      style: theme.textTheme.bodyMedium),
                ],
                const Spacer(),
                _controls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _settings(ThemeData theme) => [
        Text('Duración: $_minutes min', style: theme.textTheme.titleMedium),
        Slider(
          min: 1,
          max: 20,
          divisions: 19,
          value: _minutes.toDouble(),
          label: '$_minutes min',
          onChanged: (v) => setState(() {
            _minutes = v.round();
            _remaining = _minutes * 60;
          }),
        ),
        const SizedBox(height: 8),
        SegmentedButton<AmbientSound>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
                value: AmbientSound.silence,
                icon: Icon(Icons.volume_off_outlined),
                label: Text('Silencio')),
            ButtonSegment(
                value: AmbientSound.rain,
                icon: Icon(Icons.water_drop_outlined),
                label: Text('Lluvia')),
            ButtonSegment(
                value: AmbientSound.wind,
                icon: Icon(Icons.air),
                label: Text('Viento')),
          ],
          selected: {_sound},
          onSelectionChanged: (s) => setState(() => _sound = s.first),
        ),
      ];

  Widget _breathingCircle(ThemeData theme, Color color) {
    final scale = _running ? _scale : (_finished ? 1.0 : 0.7);
    return SizedBox(
      height: 260,
      width: 260,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          width: 260 * scale,
          height: 260 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Icon(
            _finished ? Icons.check : Icons.spa_outlined,
            size: 48,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _controls() {
    if (_running) {
      return OutlinedButton.icon(
        onPressed: () => _stop(),
        icon: const Icon(Icons.stop),
        label: const Text('Terminar'),
      );
    }
    if (_finished) {
      return FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Volver al recorrido'),
      );
    }
    return FilledButton.icon(
      onPressed: _start,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Comenzar'),
    );
  }
}
