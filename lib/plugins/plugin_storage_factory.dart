import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/plugins/plugin_storage_web.dart'
    if (dart.library.io) 'package:c_editor/plugins/plugin_storage_native.dart'
    as impl;

PluginStorage createPluginStorage(SharedPreferences prefs) =>
    impl.createPluginStorage(prefs);
