# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

**c_editor** is a cross-platform **Flutter** desktop/mobile/web app — a Level Editor for Plants vs. Zombies 2 Chinese. Package name: `C-Editor`. It is a purely client-side application with no backend services, databases, or Docker containers.

Source: https://github.com/CyberSteve777/c-editor-flutter

### SDK requirements

- **Flutter SDK ≥ 3.41** (ships with Dart ≥ 3.11, which satisfies the `^3.9.2` constraint in `pubspec.yaml`).
- **Cursor Cloud (Linux):** Flutter is installed at `/home/ubuntu/flutter` and added to PATH via `~/.bashrc`.
- **Windows (local):** Install the [Flutter SDK for Windows](https://docs.flutter.dev/get-started/install/windows), enable **Windows desktop** (`flutter config --enable-windows-desktop`), and install **Visual Studio 2022** (or Build Tools) with the **Desktop development with C++** workload. Run `flutter doctor` until the Windows toolchain shows no blocking issues.

### Linux desktop build dependencies

The following system packages are required for `flutter build linux` / `flutter run -d linux`:

- `cmake`, `clang`, `ninja-build`, `lld`, `llvm-18`, `libgtk-3-dev`, `pkg-config`, `liblzma-dev`, `libstdc++-14-dev`

A `libstdc++.so` symlink must exist at `/usr/lib/x86_64-linux-gnu/libstdc++.so` (pointing to `libstdc++.so.6`). If missing, create it: `sudo ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so`.

### Windows desktop notes

- No extra packages beyond what `flutter doctor` lists for the VS C++ toolchain.
- Use **PowerShell** or **cmd**; chain commands with `;` (PowerShell does not support `&&` in older versions).
- Release output: `build\windows\x64\runner\Release\` (executable and DLLs in that folder).
- First launch still requires choosing a writable **level library** folder (any local path the user can read/write).

### Common commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Regenerate l10n | `flutter gen-l10n` |
| Lint / analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Build Linux | `flutter build linux` |
| Run (debug, Linux) | `flutter run -d linux` |
| Build Windows | `flutter build windows` |
| Run (debug, Windows) | `flutter run -d windows` |
| Run (debug, Chrome) | `flutter run -d chrome` |

### Gotchas

- The app requires a writable folder configured as its "level library" on first launch. Create or pick a directory from the initial setup screen (Linux, Windows, and other platforms).
- `flutter analyze` may report pre-existing info/warning-level lint issues. Treat new errors as regressions.
- EGL/DRI3 warnings at app launch (`libEGL warning: DRI3 error`) are expected in headless/container Linux environments and do not affect functionality.
- Localization files under `lib/l10n/` are auto-generated (`generate: true` in `pubspec.yaml`). Do not edit them directly; edit `assets/l10n/*.arb` instead, then run `flutter gen-l10n`.
- Edit ARB files for user-facing copy (about screen, credits, etc.); keep `lib/screens/about_screen.dart` in sync when adding new localized keys or link behavior.
- External URLs (GitHub, Discord, level upload hub, etc.) live in `assets/meta/links.json` and are loaded via `lib/data/app_links.dart` — change links there rather than hardcoding in Dart.
