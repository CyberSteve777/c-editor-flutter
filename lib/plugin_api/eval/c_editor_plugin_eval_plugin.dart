import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:c_editor/plugin_api/eval/host_wrappers.dart';

/// Registers C-Editor plugin host types and curated widget factories with dart_eval.
class CEditorPluginEvalPlugin implements EvalPlugin {
  const CEditorPluginEvalPlugin();

  static const libraryUri = 'package:c_editor/plugin_api.dart';

  @override
  String get identifier => 'package:c_editor';

  @override
  void configureForCompile(BridgeDeclarationRegistry registry) {
    registry.defineBridgeClass($CPluginAssets.$declaration);
    registry.defineBridgeClass($CPluginHost.$declaration);

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        libraryUri,
        'editorWarningBanner',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($Widget.$type),
          namedParams: [
            BridgeParameter(
              'title',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'message',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
    );

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        libraryUri,
        'pvzAddButton',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($Widget.$type),
          namedParams: [
            BridgeParameter(
              'onPressed',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
              false,
            ),
            BridgeParameter(
              'size',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double)),
              true,
            ),
            BridgeParameter(
              'label',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'useSecondaryColor',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool)),
              true,
            ),
          ],
        ),
      ),
    );

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        libraryUri,
        'addItemCard',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($Widget.$type),
          namedParams: [
            BridgeParameter(
              'onPressed',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
              false,
            ),
            BridgeParameter(
              'width',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.double)),
              true,
            ),
            BridgeParameter(
              'minHeight',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.double),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),
    );

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        libraryUri,
        'appBarSearchField',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($Widget.$type),
          namedParams: [
            BridgeParameter(
              'hintText',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'onChanged',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.function)),
              false,
            ),
            BridgeParameter(
              'query',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              true,
            ),
            BridgeParameter(
              'onClear',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.function),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),
    );

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        libraryUri,
        'hostAssetImage',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($Widget.$type),
          namedParams: [
            BridgeParameter(
              'assetPath',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
            BridgeParameter(
              'width',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.double),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'height',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.double),
                nullable: true,
              ),
              true,
            ),
            BridgeParameter(
              'fit',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/painting/box_fit.dart',
                    'BoxFit',
                  ),
                ),
              ),
              true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void configureForRuntime(Runtime runtime) {
    runtime
      ..registerBridgeFunc(
        libraryUri,
        'editorWarningBanner',
        bridgeEditorWarningBanner,
      )
      ..registerBridgeFunc(libraryUri, 'pvzAddButton', bridgePvzAddButton)
      ..registerBridgeFunc(libraryUri, 'addItemCard', bridgeAddItemCard)
      ..registerBridgeFunc(
        libraryUri,
        'appBarSearchField',
        bridgeAppBarSearchField,
      )
      ..registerBridgeFunc(libraryUri, 'hostAssetImage', bridgeHostAssetImage);
  }
}
