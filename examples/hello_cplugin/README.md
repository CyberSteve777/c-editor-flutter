# Hello C-Editor plugin

Sample plugin for C-Editor's `.cplugin` / flutter_eval system.

This folder is a **normal Flutter package**. Develop and hot-reload with the
debug host, then compile to `.cplugin` for shipping.

## Debug (hot reload)

```bash
cd examples/hello_cplugin/debug_host
flutter pub get
flutter run -d windows   # or chrome / linux / macos
```

Edit `lib/main.dart`, save, and hot-reload. The debug shell lists
`registerScreen` / `registerUiElement` contributions and mirrors editor AppBar
slots.

The shell lives in C-Editor as `PluginDebugApp`
(`package:c_editor/plugins/debug/plugin_debug_app.dart`) so any plugin project
can reuse it.

## Format (shipping)

A `.cplugin` file is a ZIP containing:

```
manifest.json   # required metadata + entrypoint
plugin.evc      # dart_eval/flutter_eval bytecode
assets/         # optional plugin-owned files
```

Entrypoint:

```dart
void initialize(CPluginHost host) { ... }
```

## Build / pack this sample

From the C-Editor repo root:

```bash
flutter test test/tools/compile_hello_cplugin_test.dart
```

Output: `build/hello.cplugin` (and unpacked files under `build/hello_cplugin/`).

Or pack a pre-built folder that already has `manifest.json` + `plugin.evc`:

```bash
dart run tools/pack_cplugin.dart build/hello_cplugin build/hello.cplugin
```

## Author workflow

1. Copy this package (or create a Flutter package that path-depends on `c_editor`).
2. Implement `void initialize(CPluginHost host)` in `lib/main.dart`
   (preferred name so dart_eval keeps it; set `entry.library` to
   `package:<name>/main.dart`).
3. Debug with a `debug_host` app using `PluginDebugApp`.
4. Compile to EVC (see test helper / dart_eval) and pack with `tools/pack_cplugin.dart`.
   Important: dart_eval only treats `/main.dart` as an entrypoint by default.
   The compile helper also adds your manifest `entry.library` to `compiler.entrypoints`.
5. Install in C-Editor: overflow menu → **Plugins** → Install from device or URL.
   If you still see "Cannot find package:…", uninstall the old plugin first and
   reinstall from a freshly built `.cplugin` (install now verifies `initialize`).

### Host API (v1)

- `host.registerScreen(id, title, builder)` — standalone screen listed on Plugins screen
- `host.registerUiElement(id, title, slot, builder, [iconCodePoint])` — inject a button into the base editor:
  - `'editorAppBar'` — IconButton in the editor AppBar
  - `'editorOverflow'` — item in the editor overflow menu
  - `'levelListOverflow'` — item in the level-list overflow menu
- `host.assets.image(path)` / `readString(path)` for plugin `assets/`
- Curated widgets: `editorWarningBanner`, `pvzAddButton`, `addItemCard`, `appBarSearchField`, `hostAssetImage`
- Level data (JSON strings; works on all platforms via the level library):
  - `host.hasOpenLevel` / `openLevelPath` / `openLevelFileName`
  - `host.getOpenLevelJson()` / `applyOpenLevelJson(json)` / `saveOpenLevel()`
  - `await host.loadLevelJson(path)` / `await host.saveLevelJson(path, json)`
    (if `path` is the open editor level, the editor session is updated too)
- Localization: `host.localize(context, 'levelPreview')` looks up host ARB keys
  and optional plugin `assets/l10n/{locale}.json`

Bundled plugins (e.g. Level Preview) ship with the editor and can only be
disabled, not uninstalled. Imported `.cplugin` packages are stored under the
level library’s `.plugins` folder on native platforms (hidden from the file
list) and in browser storage on web.
