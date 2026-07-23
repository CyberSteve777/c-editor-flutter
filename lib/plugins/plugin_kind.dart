/// Whether a plugin ships with the editor or was installed by the user.
enum PluginKind {
  /// First-party plugin registered in-process (not uninstallable).
  bundled,

  /// User-installed `.cplugin` (uninstallable).
  imported,
}
