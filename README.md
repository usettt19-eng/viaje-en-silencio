# Viaje en Silencio: 40 Días (Flutter)

## Estructura de carpetas

```
viaje_en_silencio/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── theme/
    │   └── app_theme.dart          # Paleta cálida, tipografías, modo noche warm
    ├── models/
    │   ├── week.dart               # Semana temática (5 días)
    │   ├── day_entry.dart          # Entrada diaria (8 bloques del libro)
    │   ├── journal_entry.dart      # Respuestas y notas privadas
    │   └── progress.dart           # Días, minutos de quietud, desafíos
    ├── data/
    │   └── content_repository.dart # Contenido de las 8 semanas
    ├── screens/
    │   ├── home_screen.dart        # "El Recorrido de Hoy"
    │   ├── silence_altar_screen.dart   (siguiente paso)
    │   ├── journal_screen.dart         (siguiente paso)
    │   ├── journey_map_screen.dart     (siguiente paso)
    │   └── settings_screen.dart        (siguiente paso)
    ├── widgets/
    │   └── day_section_card.dart   # Tarjeta expandible reutilizable
    └── services/
        ├── local_db.dart           # SQLite (sqflite) para diario privado
        ├── notification_service.dart
        └── auth_service.dart       # Huella / FaceID / PIN
```

## Ejecutar

```
flutter pub get
flutter run
```

Las pantallas marcadas "siguiente paso" están pendientes.
