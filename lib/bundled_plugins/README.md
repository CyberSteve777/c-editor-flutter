# Bundled plugins

First-party plugins shipped with C-Editor. Each plugin uses the same layout
shape as author plugins under `examples/` (`manifest.json`, `main.dart`
entrypoint, `src/` for implementation).

Bundled plugins live inside the `c_editor` package (under this folder) so they
can call host APIs without a circular pub path dependency. Users can disable
them, but cannot uninstall them.

| Plugin | Path |
|--------|------|
| Level Preview | [level_preview_cplugin/](level_preview_cplugin/) |
