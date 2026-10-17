import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ViajeEnSilencioApp());
}

class ViajeEnSilencioApp extends StatelessWidget {
  const ViajeEnSilencioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viaje en Silencio: 40 Días',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
