# Level Preview (bundled plugin)

First-party C-Editor plugin that provides level preview from the editor AppBar
and the level-list file menu.

Layout matches `examples/hello_cplugin` (Flutter package shape):

```
level_preview_cplugin/
  manifest.json             # In-process entry (package:c_editor/.../lib/main.dart)
  pubspec.yaml              # Documentary metadata (not a root workspace path dep)
  analysis_options.yaml
  README.md
  lib/
    main.dart               # Bundled initialize → registration.dart
    level_preview_cplugin.dart
    src/
      registration.dart     # registerLevelPreview + open helpers
      level_preview_dialog.dart
      level_preview_widgets.dart
  eval_src/
    main.dart               # Eval-safe thin initialize (plugin_api only)
  assets/l10n/{en,ru,zh}.arb   # plugin-exclusive ARB strings
  assets/icon.png
```

Localization uses ARB under `assets/l10n/` (`host.localize`). Other plugin JSON/files belong elsewhere under `assets/` (not in `l10n/`).

This folder lives under `lib/bundled_plugins/` (part of the `c_editor` package)
instead of a separate pub package, so it can use host APIs without a circular
path dependency. It is **disable-only** (not uninstallable).

## In-process vs external `.cplugin`

| Mode | Entry | Notes |
|------|--------|--------|
| **Bundled (in-process)** | `lib/main.dart` → `lib/src/registration.dart` | Uses host dialogs / hooks; loaded with the app. Manifest `entry.library` is `package:c_editor/bundled_plugins/level_preview_cplugin/lib/main.dart`. |
| **External pack** | `eval_src/main.dart` | Thin dart_eval-safe source (only `package:c_editor/plugin_api.dart`). Registers actions and calls `host.openLevelPreview`. |

Build the external artifact:

```bash
flutter test test/tools/compile_level_preview_cplugin_test.dart
```

Output: `build/level_preview.cplugin` with packed manifest entry
`package:level_preview_cplugin/main.dart`, plus `assets/l10n` from this plugin.

Installing over the reserved bundled id `team.international2c.level_preview` is
rejected by the host — the `.cplugin` is for build verification and future
packaging, not as an overlay install on top of the bundled plugin.

Shared lawn-grid helpers used by the editor stay in
`lib/screens/common/level_preview_grid_helpers.dart`.
