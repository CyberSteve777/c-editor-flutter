# Level Preview (bundled plugin)

First-party C-Editor plugin that provides level preview from the editor AppBar
and the level-list file menu.

Layout mirrors custom plugins (`examples/hello_cplugin`):

```
level_preview_cplugin/
  manifest.json
  main.dart                 # initialize(CPluginHost)
  level_preview_cplugin.dart
  src/
    registration.dart       # BundledPlugin + open helpers
    level_preview_dialog.dart
    level_preview_widgets.dart
  README.md
```

This folder lives under `lib/bundled_plugins/` (part of the `c_editor` package)
instead of a separate pub package, so it can use host APIs without a circular
path dependency. It is **disable-only** (not uninstallable).

Shared lawn-grid helpers used by the editor stay in
`lib/screens/common/level_preview_grid_helpers.dart`.
