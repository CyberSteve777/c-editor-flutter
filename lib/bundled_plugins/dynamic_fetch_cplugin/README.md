# Data Package Download (bundled)

Offers downloading `dynamic.rsb.smf` from
[Archiver2c/pvz2c-dynamic releases](https://github.com/Archiver2c/pvz2c-dynamic/releases)
when RSB export finds no `.rsb.smf` files in the level library.

## Layout

```
manifest.json
lib/main.dart
lib/src/
assets/l10n/{en,ru,zh}.arb
assets/icon.png
```

Uses host packages (`nice_downloader`, `http`) — bundled in-process only.
Disable from Plugins if you do not want the export prompt.
