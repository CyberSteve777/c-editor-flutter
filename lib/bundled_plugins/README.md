# Bundled plugins

First-party plugins shipped with C-Editor. They use the same package contract
as external `.cplugin` packages (see `examples/hello_cplugin`):

- `manifest.json` (id, authors, contributors, icon, links, incompatibilities, …)
- `lib/main.dart` with `initialize(CPluginHost)` entrypoint
- `lib/` Dart sources (barrel + `src/`)
- `assets/l10n/{locale}.arb` for plugin-exclusive strings (ARB; `@` metadata ok)
- other `assets/**` JSON/files for non-l10n extra data
- documentary `pubspec.yaml` / `analysis_options.yaml` (embedded in `c_editor`; not a separate workspace path dep)

Catalog: [`bundled_plugins.dart`](bundled_plugins.dart) via `CPluginPackageSpec`.
Ids use the `team.international2c.*` prefix. Users can disable bundled plugins,
but cannot uninstall them.

| Plugin | Id | Path |
|--------|----|------|
| Level Preview | `team.international2c.level_preview` | [level_preview_cplugin/](level_preview_cplugin/) |

Pack an eval-safe external build (where supported):

```bash
flutter test test/tools/compile_level_preview_cplugin_test.dart
```
