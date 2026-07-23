# Hello C-Editor plugin

Sample plugin for C-Editor's `.cplugin` / flutter_eval system.

## Format

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

## Build this sample

From the C-Editor repo root:

```bash
# Compile example source to EVC and pack hello.cplugin
flutter test test/tools/compile_hello_cplugin_test.dart
```

Output: `build/hello.cplugin` (and unpacked files under `build/hello_cplugin/`).

Or pack a pre-built folder that already has `manifest.json` + `plugin.evc`:

```bash
dart run tools/pack_cplugin.dart build/hello_cplugin build/hello.cplugin
```

## Author workflow (custom plugins)

1. Write Dart that imports `package:flutter/material.dart` and `package:c_editor/plugin_api.dart`.
2. Export `void initialize(CPluginHost host)`.
3. Compile with `dart_eval` / the helper scripts, using:
   - `flutter_eval` bindings
   - C-Editor's `CEditorPluginEvalPlugin` bridges
4. Pack with `tools/pack_cplugin.dart`.
5. Install in C-Editor: overflow menu → **Plugins** → Install from device or URL.

### Host API (v1)

- `host.registerScreen(id, title, builder)`
- `host.assets.image(path)` / `readString(path)` for plugin `assets/`
- Curated widgets: `editorWarningBanner`, `pvzAddButton`, `addItemCard`, `appBarSearchField`, `hostAssetImage`

Plugins do **not** yet hook into level module/event editors.
