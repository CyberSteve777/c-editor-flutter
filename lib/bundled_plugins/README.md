# Bundled plugins

First-party plugins shipped with C-Editor. They use the same package contract
as external `.cplugin` packages (see `plugin_example/hello_cplugin`):

- `manifest.json` (id, authors, contributors, icon, links, incompatibilities,
  optional `configurable`, …)
- `lib/main.dart` with `initialize(CPluginHost)` entrypoint
- `lib/` Dart sources (barrel + `src/`)
- `assets/l10n/{locale}.arb` for plugin-exclusive strings (ARB; `@key` placeholder metadata applied at runtime)
  — include `pluginName` and `pluginDescription` (display metadata; not in the manifest)
- optional `assets/config_schema.json` mapping config keys to ARB title/description keys
- other `assets/**` JSON/files for non-l10n extra data
- documentary `pubspec.yaml` / `analysis_options.yaml` (embedded in `c_editor`; not a separate workspace path dep)

Set `"configurable": true` so Plugins shows a Settings button (default `false`).
Persist with `host.readConfigJson` / `writeConfigJson` (UTF-8 JSON; Unicode OK).

Catalog: [`bundled_plugins.dart`](bundled_plugins.dart) via `CPluginPackageSpec`.
Ids use the `team.international2c.*` prefix. Users can disable bundled plugins,
but cannot uninstall them.

| Plugin | Id | Path                                         |
|--------|----|----------------------------------------------|
| Level preview image generator | `team.international2c.preview_img` | [preview_img_cplugin/](preview_img_cplugin/) |
| Level testing mod creator | `team.international2c.level_testing_mod` | [level_test_cplugin/](level_test_cplugin/)   |

Pack an eval-safe external build (where supported):

```bash
flutter test test/tools/compile_preview_img_cplugin_test.dart
```
