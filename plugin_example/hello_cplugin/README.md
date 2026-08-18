# Hello C-Editor plugin

Sample plugin for C-Editor's `.cplugin` / flutter_eval system.

This folder is a **normal Flutter package**. Debug by loading it into the real
C-Editor app, then compile to `.cplugin` for shipping.

## Debug (with C-Editor)

```bash
# From C-Editor repo root — run the real app with your plugin path:
flutter run -d windows --dart-define=CPLUGIN_DEBUG_PATH=plugin_example/hello_cplugin
# Or Android Studio: Run configuration → Additional run args:
# --dart-define=CPLUGIN_DEBUG_PATH=C:\full\path\to\your_plugin
```

You can also use the Plugins screen → **Load folder (debug)** → pick the plugin
package root (folder with `manifest.json` + `lib/`).

Then open the editor / Plugins to use registered screens and UI elements.

After edits: hot restart, or re-run **Load folder (debug)** (EVC recompile; not
Dart hot reload of plugin code).

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
3. Debug with C-Editor (`CPLUGIN_DEBUG_PATH` or **Load folder (debug)**).
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
- Localization: `host.localize(context, 'someKey')` looks up plugin
  `assets/l10n/{locale}.arb` (Flutter ARB), then `en.arb`, then curated host
  ARB keys. Pass ICU args as the 4th parameter:
  `host.localize(context, 'hello', null, {'name': 'Ada'})` /
  `{count, plural, …}`. `@key` placeholder metadata (`type`, `format`,
  `optionalParameters`) is applied like Flutter gen-l10n.
  Put display metadata in ARB as `pluginName` / `pluginDescription`
  (not in `manifest.json`). Use other files under `assets/` for non-l10n data.

Bundled plugins (e.g. Level Overview) ship with the editor and can only be
disabled, not uninstalled. Imported `.cplugin` packages are stored under the
level library’s `.plugins` folder on native platforms (hidden from the file
list) and in browser storage on web.
