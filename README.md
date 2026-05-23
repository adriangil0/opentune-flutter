# OpenTune Flutter — Android & iOS

Versión multiplataforma de [OpenTune](https://github.com/Arturo254/OpenTune) construida con Flutter.
Funciona en **Android** e **iOS** desde el mismo código fuente.

---

## Estructura del proyecto

```
opentune_flutter/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── router.dart                  # Rutas de navegación
│   ├── services/
│   │   └── innertube_service.dart   # API de YouTube Music
│   ├── providers/
│   │   ├── player_provider.dart     # Estado del reproductor
│   │   └── theme_provider.dart      # Tema de la app
│   ├── screens/
│   │   ├── home_screen.dart         # Pantalla de inicio
│   │   ├── search_screen.dart       # Búsqueda
│   │   ├── explore_screen.dart      # Explorar + tendencias
│   │   ├── library_screen.dart      # Biblioteca personal
│   │   ├── player_screen.dart       # Reproductor completo
│   │   └── settings_screen.dart     # Ajustes
│   └── widgets/
│       ├── scaffold_with_navbar.dart # Navbar compartido
│       └── mini_player.dart         # Mini reproductor
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
├── ios/
│   └── Runner/
│       └── Info.plist
└── pubspec.yaml
```

---

## Requisitos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.16+ |
| Dart | 3.0+ |
| Android Studio / VS Code | Cualquier versión reciente |
| **Para iOS: Mac con Xcode** | **15+** |
| **Para iOS: Apple Developer Account** | **$99 USD/año** |

---

## Instalación paso a paso

### 1. Instalar Flutter

```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalación
flutter doctor
```

Descarga oficial: https://flutter.dev/docs/get-started/install

### 2. Clonar y configurar el proyecto

```bash
# Copiar la carpeta opentune_flutter a tu Mac
# Luego instalar dependencias:
cd opentune_flutter
flutter pub get
```

### 3. Compilar para Android

```bash
flutter build apk --release
# El APK estará en: build/outputs/flutter-apk/app-release.apk
```

### 4. Compilar para iOS (requiere Mac + Xcode)

```bash
# Abrir en Xcode primero
open ios/Runner.xcworkspace

# Luego compilar desde terminal:
flutter build ios --release

# Para instalar en dispositivo físico:
flutter run --release
```

---

## Funcionalidades implementadas

- [x] Reproducción de YouTube Music sin anuncios
- [x] Reproductor completo con controles (play, pausa, siguiente, anterior)
- [x] Mini reproductor persistente
- [x] Búsqueda de canciones
- [x] Explorar géneros y tendencias
- [x] Biblioteca personal
- [x] Reproducción en segundo plano (Android e iOS)
- [x] Notificaciones de control de medios
- [x] Material Design 3
- [x] Tema claro/oscuro
- [x] Modo aleatorio y repetición
- [ ] Letras sincronizadas (próximamente)
- [ ] Descarga offline (próximamente)
- [ ] Integración de cuenta Google (próximamente)

---

## Arquitectura

- **State Management**: Riverpod
- **Navegación**: GoRouter
- **Audio**: just_audio + just_audio_background
- **Red**: Dio + InnerTube API
- **Cache**: Hive + cached_network_image
- **UI**: Material Design 3 + Jetpack Compose equivalente en Flutter

---

## Diferencias con la versión Android original

| Característica | Android (Kotlin) | Flutter (esta versión) |
|---|---|---|
| UI framework | Jetpack Compose | Flutter/Material 3 |
| Lenguaje | Kotlin | Dart |
| Plataformas | Android | Android + iOS |
| Audio | ExoPlayer/Media3 | just_audio |
| Navegación | Navigation Component | GoRouter |
| Estado | ViewModel/StateFlow | Riverpod |

---

## Licencia

GPL-3.0 — igual que el proyecto original OpenTune.
© 2024 Arturo Cervantes
