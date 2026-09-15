/// Public API surface for C-Editor plugins.
///
/// Plugin source is compiled to EVC with dart_eval/flutter_eval and packaged
/// as a `.cplugin` ZIP. At runtime the host loads the bytecode and calls
/// `initialize(CPluginHost host)`.
library;

export 'c_plugin_host.dart';
export 'c_plugin_widgets.dart';
