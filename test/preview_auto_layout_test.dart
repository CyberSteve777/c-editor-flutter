import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _normalArea = Rect.fromLTWH(0.03, 0.32, 0.94, 0.65);

PreviewLayer _panel(String id, int count, {bool chrome = true}) {
  final items = [
    for (var i = 0; i < count; i++)
      PreviewItem(id: '$id-$i', assetPath: 'assets/meta/icon.png'),
  ];
  return PreviewLayer(
    id: id,
    kind: PreviewLayerKind.iconGrid,
    bounds: Rect.zero,
    items: items,
    sections: [PreviewIconSection(items: items)],
    showChrome: chrome,
    gridTitle: chrome ? id : null,
    sourceLabel: chrome ? 'Source' : null,
  );
}

Rect _visibleBounds(PreviewLayer layer) => Rect.fromLTWH(
  layer.bounds.left,
  layer.bounds.top,
  layer.bounds.width * layer.scale,
  layer.bounds.height * layer.scale,
);

void _expectCompleteLayout(List<PreviewLayer> layers, Rect area) {
  for (final layer in layers) {
    final visible = _visibleBounds(layer);
    expect(visible.left, greaterThanOrEqualTo(area.left - 0.000001));
    expect(visible.top, greaterThanOrEqualTo(area.top - 0.000001));
    expect(visible.right, lessThanOrEqualTo(area.right + 0.000001));
    expect(visible.bottom, lessThanOrEqualTo(area.bottom + 0.000001));
    final measured = previewIconGridIntrinsicSize(
      maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
      sections: layer.sections,
      showChrome: layer.showChrome,
      gridTitle: layer.gridTitle,
      sourceLabel: layer.sourceLabel,
    );
    expect(
      layer.bounds.height * kPreviewCanvasSize.height,
      greaterThanOrEqualTo(measured.height - 0.000001),
    );
    for (final other in layers) {
      if (identical(layer, other)) continue;
      expect(
        visible.deflate(0.000001).overlaps(_visibleBounds(other)),
        isFalse,
      );
    }
  }
}

void main() {
  testWidgets('composer applies complete packing in both initial styles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          objClass: 'SeedBankProperties',
          objData: {
            'PresetPlantList': [for (var i = 0; i < 48; i++) 'plant_$i'],
          },
        ),
        PvzObject(
          objClass: 'InitialZombieProperties',
          objData: {
            'InitialZombiePlacements': [
              for (var i = 0; i < 22; i++) {'TypeName': 'zombie_$i'},
            ],
          },
        ),
        PvzObject(
          objClass: 'InitialGridItemProperties',
          objData: {
            'InitialGridItemPlacements': [
              for (var i = 0; i < 3; i++) {'TypeName': 'grid_$i'},
            ],
          },
        ),
      ],
    );
    for (final style in PreviewAutoStyle.values) {
      final document = (await tester.runAsync(
        () => PreviewAutoComposer(
          levelFile: level,
          parsed: ParsedLevelData(objectMap: {}),
          fileName: 'Adaptive layout.json',
          banners: StageBannerResolver.forTest(stages: const {}),
          featureGroups: PreviewFeatureGroups.forTest(groups: const []),
          style: style,
        ).compose(),
      ))!;
      final panels = document.layers
          .where((layer) => layer.kind == PreviewLayerKind.iconGrid)
          .toList();
      _expectCompleteLayout(
        panels,
        style == PreviewAutoStyle.simple
            ? const Rect.fromLTWH(0.04, 0.06, 0.92, 0.64)
            : const Rect.fromLTWH(0.03, 0.20, 0.94, 0.77),
      );
      expect(document.layerById('plants')!.items.length, 48);
      expect(document.layerById('zombies')!.items.length, 22);
      if (style == PreviewAutoStyle.normal) {
        expect(document.layerById('grid_items')!.items.length, 3);
      }
      final textLayers = document.layers.where(
        (layer) => layer.kind == PreviewLayerKind.text,
      );
      for (final text in textLayers) {
        for (final panel in panels) {
          expect(text.bounds.overlaps(_visibleBounds(panel)), isFalse);
        }
      }
    }
  });

  test(
    'places grid items below short zombie panel without cropping plants',
    () {
      final layers = [
        _panel('Plants', 48),
        _panel('Zombies', 22),
        _panel('Grid items', 3),
      ];
      arrangePreviewIconGrids(layers, availableBounds: _normalArea);
      _expectCompleteLayout(layers, _normalArea);
      expect(layers[2].bounds.left, closeTo(layers[1].bounds.left, 0.000001));
      expect(
        layers[2].bounds.top,
        greaterThan(_visibleBounds(layers[1]).bottom),
      );
      expect(layers[0].sections.single.iconSize, greaterThanOrEqualTo(34));
      expect(layers.map((layer) => layer.items.length), [48, 22, 3]);
    },
  );

  for (final counts in [
    [1],
    [150],
    [2, 2],
    [48, 3],
    [3, 48],
    [3, 48, 24],
    [220, 3],
    [3, 220, 3],
    [220, 450, 80],
  ]) {
    test('keeps all content inside canvas for panel counts $counts', () {
      final layers = [
        for (var i = 0; i < counts.length; i++) _panel('Panel $i', counts[i]),
      ];
      arrangePreviewIconGrids(layers, availableBounds: _normalArea);
      _expectCompleteLayout(layers, _normalArea);
      expect(layers.map((layer) => layer.items.length), counts);
    });
  }

  test('long multiline sources are included in initial panel height', () {
    final layers = [_panel('Plants', 48), _panel('Zombies', 22)];
    layers[0].sourceLabel = List.filled(
      12,
      'Pre-placed plants and special challenge requirements',
    ).join(' ');
    arrangePreviewIconGrids(layers, availableBounds: _normalArea);
    _expectCompleteLayout(layers, _normalArea);
  });

  test('many boss sections scale their headings instead of cropping them', () {
    final layer = _panel('Zombies', 15);
    layer.sections = [
      for (final item in layer.items)
        PreviewIconSection(
          title: 'Zomboss: A boss with a long localized display name',
          items: [item],
          iconSize: 72,
        ),
    ];
    arrangePreviewIconGrids([layer], availableBounds: _normalArea);
    _expectCompleteLayout([layer], _normalArea);
    expect(layer.scale, lessThan(1));
    expect(layer.sections.length, 15);
  });

  test('simple layout keeps enlarged sparse icons above the caption', () {
    const area = Rect.fromLTWH(0.04, 0.06, 0.92, 0.64);
    final layers = [
      _panel('Plants', 2, chrome: false),
      _panel('Zombies', 2, chrome: false),
    ];
    for (final layer in layers) {
      fitSimplePreviewIconSections(
        sections: layer.sections,
        maxWidth: kPreviewCanvasSize.width * 0.40,
      );
    }
    arrangePreviewIconGrids(layers, availableBounds: area);
    _expectCompleteLayout(layers, area);
    expect(
      layers.every((layer) => layer.sections.single.iconSize > 100),
      isTrue,
    );
  });

  for (final scenario in ['normal', 'dense', 'long sources', 'boss sections']) {
    testWidgets('last initial icon is visible with $scenario', (tester) async {
      final layers = [
        _panel('Plants', scenario == 'dense' ? 220 : 48),
        _panel('Zombies', scenario == 'dense' ? 450 : 22),
        _panel('Grid items', scenario == 'dense' ? 80 : 3),
      ];
      layers[2].gridTitle = 'Grid items and collectibles';
      if (scenario == 'long sources') {
        layers[0].sourceLabel = List.filled(
          12,
          'Pre-placed plants and special challenge requirements',
        ).join(' ');
      }
      if (scenario == 'boss sections') {
        layers[1].items = layers[1].items.take(15).toList();
        layers[1].sections = [
          for (final item in layers[1].items)
            PreviewIconSection(
              title: 'Zomboss: A boss with a long localized display name',
              items: [item],
              iconSize: 72,
            ),
        ];
      }
      arrangePreviewIconGrids(layers, availableBounds: _normalArea);
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.stageMapped),
        layers: layers,
      );
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: PreviewCanvas(
                document: document,
                boundaryKey: boundaryKey,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bannerRect = tester.getRect(find.byKey(boundaryKey));
      for (final layer in layers) {
        final sectionIndex = layer.sections.length - 1;
        final rows = previewIconSectionRows(
          layer.sections.last,
          maxWidth:
              layer.bounds.width * kPreviewCanvasSize.width -
              kPreviewIconGridChromeInset,
        );
        final last = find.byKey(
          ValueKey(
            'preview-icon-item-${layer.id}-$sectionIndex-${rows.length - 1}-${rows.last.items.length - 1}',
          ),
        );
        expect(last, findsOneWidget);
        final rect = tester.getRect(last);
        final visible = _visibleBounds(layer);
        final panelRect = Rect.fromLTWH(
          bannerRect.left + visible.left * bannerRect.width,
          bannerRect.top + visible.top * bannerRect.height,
          visible.width * bannerRect.width,
          visible.height * bannerRect.height,
        ).inflate(0.01);
        expect(panelRect.contains(rect.topLeft), isTrue);
        expect(panelRect.contains(rect.bottomRight), isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
