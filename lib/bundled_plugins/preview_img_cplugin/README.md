# Level preview image generator (bundled plugin)

First-party plugin that generates and exports PNG level preview images.
**Level Overview** (plants / zombies / layout dialog) lives in the base editor
under `lib/screens/level_overview/`.

Layout matches `plugin_example/hello_cplugin` (Flutter package shape):

```
preview_img_cplugin/
  manifest.json
  lib/main.dart → registration.dart
  lib/src/preview/**          # generator + settings
  assets/l10n/{en,ru,zh}.arb
  assets/config_schema.json
  eval_src/main.dart          # eval-safe settings stub
```

When enabled, sets `PluginHostHooks.openPreviewImageGenerator` so the host
Level Overview dialog can open the generator. Settings remain on this plugin
(`configurable: true`).

Plugin id: `team.international2c.preview_img`
