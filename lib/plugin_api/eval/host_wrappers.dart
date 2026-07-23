import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/painting.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugin_api/c_plugin_widgets.dart' as widgets;

const _lib = 'package:c_editor/plugin_api.dart';

/// dart_eval wrapper for [CPluginAssets].
class $CPluginAssets implements $Instance {
  $CPluginAssets.wrap(this.$value);

  static const $type = BridgeTypeRef(BridgeTypeSpec(_lib, 'CPluginAssets'));

  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {},
    methods: {
      'image': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($ImageProvider.$type),
          params: [
            BridgeParameter(
              'relativePath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
      'readString': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
            ]),
          ),
          params: [
            BridgeParameter(
              'relativePath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
    },
    wrap: true,
  );

  @override
  final CPluginAssets $value;

  late final $Instance _superclass = $Object($value);

  @override
  CPluginAssets get $reified => $value;

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'image':
        return $Function((runtime, target, args) {
          final path = args[0]!.$value as String;
          return $ImageProvider.wrap($value.image(path));
        });
      case 'readString':
        return $Function((runtime, target, args) {
          final path = args[0]!.$value as String;
          return $Future.wrap(
            $value.readString(path).then((s) => $String(s)),
          );
        });
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper for [CPluginHost].
class $CPluginHost implements $Instance {
  $CPluginHost.wrap(this.$value);

  static const $type = BridgeTypeRef(BridgeTypeSpec(_lib, 'CPluginHost'));

  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {},
    methods: {
      'registerScreen': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'title',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'builder',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
              false,
            ),
          ],
        ),
      ),
      'registerUiElement': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'title',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'slot',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'builder',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
              false,
            ),
            BridgeParameter(
              'iconCodePoint',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.int),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),
      'getOpenLevelJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string),
            nullable: true,
          ),
        ),
      ),
      'applyOpenLevelJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          params: [
            BridgeParameter(
              'json',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
      'saveOpenLevel': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
        ),
      ),
      'loadLevelJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string),
                nullable: true,
              ),
            ]),
          ),
          params: [
            BridgeParameter(
              'filePath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
      'saveLevelJson': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          params: [
            BridgeParameter(
              'filePath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'json',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
      'localize': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation($BuildContext.$type),
              false,
            ),
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'fallback',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),
    },
    getters: {
      'pluginId': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
        ),
      ),
      'assets': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($CPluginAssets.$type),
        ),
      ),
      'hasOpenLevel': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool)),
        ),
      ),
      'openLevelPath': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string),
            nullable: true,
          ),
        ),
      ),
      'openLevelFileName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string),
            nullable: true,
          ),
        ),
      ),
    },
    wrap: true,
  );

  @override
  final CPluginHost $value;

  late final $Instance _superclass = $Object($value);

  @override
  CPluginHost get $reified => $value;

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'pluginId':
        return $String($value.pluginId);
      case 'assets':
        return $CPluginAssets.wrap($value.assets);
      case 'hasOpenLevel':
        return $bool($value.hasOpenLevel);
      case 'openLevelPath':
        final path = $value.openLevelPath;
        return path == null ? const $null() : $String(path);
      case 'openLevelFileName':
        final name = $value.openLevelFileName;
        return name == null ? const $null() : $String(name);
      case 'getOpenLevelJson':
        return $Function((runtime, target, args) {
          final json = $value.getOpenLevelJson();
          return json == null ? const $null() : $String(json);
        });
      case 'applyOpenLevelJson':
        return $Function((runtime, target, args) {
          final json = args[0]!.$value as String;
          $value.applyOpenLevelJson(json);
          return null;
        });
      case 'saveOpenLevel':
        return $Function((runtime, target, args) {
          return $Future.wrap($value.saveOpenLevel().then((_) => null));
        });
      case 'loadLevelJson':
        return $Function((runtime, target, args) {
          final path = args[0]!.$value as String;
          return $Future.wrap(
            $value.loadLevelJson(path).then(
              (json) => json == null ? const $null() : $String(json),
            ),
          );
        });
      case 'saveLevelJson':
        return $Function((runtime, target, args) {
          final path = args[0]!.$value as String;
          final json = args[1]!.$value as String;
          return $Future.wrap(
            $value.saveLevelJson(path, json).then((_) => null),
          );
        });
      case 'localize':
        return $Function((runtime, target, args) {
          final context = args[0]!.$value as BuildContext;
          final key = args[1]!.$value as String;
          final fallback =
              args.length > 2 ? args[2]?.$value as String? : null;
          return $String($value.localize(context, key, fallback));
        });
      case 'registerScreen':
        return $Function((runtime, target, args) {
          final id = args[0]!.$value as String;
          final title = args[1]!.$value as String;
          final builder = args[2]! as EvalCallable;
          $value.registerScreen(id, title, _wrapBuilder(runtime, builder));
          return null;
        });
      case 'registerUiElement':
        return $Function((runtime, target, args) {
          final id = args[0]!.$value as String;
          final title = args[1]!.$value as String;
          final slot = args[2]!.$value as String;
          final builder = args[3]! as EvalCallable;
          final iconCodePoint = args.length > 4
              ? (args[4]?.$value as num?)?.toInt()
              : null;
          $value.registerUiElement(
            id,
            title,
            slot,
            _wrapBuilder(runtime, builder),
            iconCodePoint,
          );
          return null;
        });
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static CPluginScreenBuilder _wrapBuilder(
    Runtime runtime,
    EvalCallable builder,
  ) {
    return (context) {
      final result = builder.call(
        runtime,
        null,
        [$BuildContext.wrap(context)],
      );
      if (result == null) {
        return const SizedBox.shrink();
      }
      final value = result.$value;
      if (value is Widget) return value;
      return const SizedBox.shrink();
    };
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

$Value? bridgeEditorWarningBanner(
  Runtime runtime,
  $Value? target,
  List<$Value?> args,
) {
  final title = args.isNotEmpty ? args[0]?.$value as String? : null;
  final message = (args.length > 1 ? args[1]?.$value as String? : null) ?? '';
  return $Widget.wrap(
    widgets.editorWarningBanner(title: title, message: message),
  );
}

$Value? bridgePvzAddButton(
  Runtime runtime,
  $Value? target,
  List<$Value?> args,
) {
  final onPressed = args[0]! as EvalCallable;
  final size =
      (args.length > 1 ? args[1]?.$value as num? : null)?.toDouble() ?? 48;
  final label = args.length > 2 ? args[2]?.$value as String? : null;
  final useSecondary =
      args.length > 3 ? (args[3]?.$value as bool? ?? false) : false;
  return $Widget.wrap(
    widgets.pvzAddButton(
      onPressed: () => onPressed.call(runtime, null, []),
      size: size,
      label: label,
      useSecondaryColor: useSecondary,
    ),
  );
}

$Value? bridgeAddItemCard(
  Runtime runtime,
  $Value? target,
  List<$Value?> args,
) {
  final onPressed = args[0]! as EvalCallable;
  final width =
      (args.length > 1 ? args[1]?.$value as num? : null)?.toDouble() ?? 100;
  final minHeight =
      args.length > 2 ? (args[2]?.$value as num?)?.toDouble() : null;
  return $Widget.wrap(
    widgets.addItemCard(
      onPressed: () => onPressed.call(runtime, null, []),
      width: width,
      minHeight: minHeight,
    ),
  );
}

$Value? bridgeAppBarSearchField(
  Runtime runtime,
  $Value? target,
  List<$Value?> args,
) {
  final hintText = args[0]!.$value as String;
  final onChanged = args[1]! as EvalCallable;
  final query = args.length > 2 ? (args[2]?.$value as String? ?? '') : '';
  final onClear = args.length > 3 ? args[3] as EvalCallable? : null;
  return $Widget.wrap(
    widgets.appBarSearchField(
      hintText: hintText,
      onChanged: (value) => onChanged.call(runtime, null, [$String(value)]),
      query: query,
      onClear: onClear == null ? null : () => onClear.call(runtime, null, []),
    ),
  );
}

$Value? bridgeHostAssetImage(
  Runtime runtime,
  $Value? target,
  List<$Value?> args,
) {
  final assetPath = args[0]!.$value as String;
  final width = args.length > 1 ? (args[1]?.$value as num?)?.toDouble() : null;
  final height = args.length > 2 ? (args[2]?.$value as num?)?.toDouble() : null;
  final fit = args.length > 3 && args[3] != null
      ? args[3]!.$value as BoxFit
      : BoxFit.cover;
  return $Widget.wrap(
    widgets.hostAssetImage(
      assetPath: assetPath,
      width: width,
      height: height,
      fit: fit,
    ),
  );
}
