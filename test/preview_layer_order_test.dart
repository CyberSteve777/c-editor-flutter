import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _background = kPreviewBackgroundLayerId;

PreviewLayer _layer(
  String id, {
  int zIndex = 0,
  PreviewLayerKind kind = PreviewLayerKind.text,
}) => PreviewLayer(
  id: id,
  kind: kind,
  bounds: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
  zIndex: zIndex,
  text: id,
);

PreviewDocument _document() => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    stem: 'Unknown',
    assetPath: 'assets/meta/icon.png',
  ),
  layers: [
    _layer('a', zIndex: 10),
    _layer('b', zIndex: 20),
    _layer('c', zIndex: 30),
  ],
);

List<String> _ids(PreviewDocument document) => [
  for (final entry in document.orderedLayerEntries) entry.id,
];

void _expectUniqueRanks(PreviewDocument document) {
  final entries = document.orderedLayerEntries;
  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    expect(
      entry.isBackground ? document.backgroundZIndex : entry.layer!.zIndex,
      index,
    );
  }
  expect(entries.where((entry) => entry.isBackground), hasLength(1));
  expect(entries.map((entry) => entry.id).toSet(), hasLength(entries.length));
}

void main() {
  test('empty documents expose only their non-content background', () {
    final document = PreviewDocument(
      banner: PreviewBannerRef(
        kind: PreviewBannerSourceKind.userFile,
        userFilePath: 'banner.png',
      ),
    );
    expect(_ids(document), [_background]);
    expect(document.orderedLayerEntries.single.isBackground, isTrue);
    expect(document.orderedLayerEntries.single.layer, isNull);
    expect(document.layerById(_background), isNull);
    expect(document.sortedLayers, isEmpty);
    for (final action in PreviewLayerOrderAction.values) {
      expect(document.canMoveLayer(_background, action), isFalse);
      expect(document.moveLayer(_background, action), isFalse);
    }
    expect(document.reorderLayers([_background]), isFalse);
    expect(document.backgroundZIndex, isNull);
    expect(_ids(document.copy()), [_background]);
  });

  test(
    'legacy ordering is stable and leaves background below negative ranks',
    () {
      final first = _layer('first', zIndex: 4);
      final second = _layer('second', zIndex: 4);
      final negative = _layer('negative', zIndex: -5);
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.stageMapped),
        layers: [first, second, negative],
      );
      for (var read = 0; read < 3; read++) {
        expect(_ids(document), [_background, 'negative', 'first', 'second']);
        expect(document.sortedLayers, [negative, first, second]);
      }
      expect(document.layers, [first, second, negative]);
      expect(document.backgroundZIndex, isNull);
      expect(document.layers.map((layer) => layer.zIndex), [4, 4, -5]);
      expect(_ids(document.copy()), _ids(document));
    },
  );

  test('stored background ranks have a deterministic tie-break', () {
    final document = PreviewDocument(
      banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
      backgroundZIndex: 5,
      layers: [
        _layer('first', zIndex: 5),
        _layer('lower', zIndex: 1),
        _layer('second', zIndex: 5),
      ],
    );
    expect(_ids(document), ['lower', _background, 'first', 'second']);
    expect(document.backgroundZIndex, 5);
    expect(document.layers.map((layer) => layer.zIndex), [5, 1, 5]);
  });

  final contentMoves = <PreviewLayerOrderAction, List<String>>{
    PreviewLayerOrderAction.toFront: [_background, 'a', 'c', 'b'],
    PreviewLayerOrderAction.forward: [_background, 'a', 'c', 'b'],
    PreviewLayerOrderAction.backward: [_background, 'b', 'a', 'c'],
    PreviewLayerOrderAction.toBack: ['b', _background, 'a', 'c'],
  };
  for (final move in contentMoves.entries) {
    test('content supports ${move.key.name} with unique ranks', () {
      final document = _document();
      expect(document.canMoveLayer('b', move.key), isTrue);
      expect(document.moveLayer('b', move.key), isTrue);
      expect(_ids(document), move.value);
      expect(
        document.sortedLayers.map((layer) => layer.id),
        move.value.where((id) => id != _background),
      );
      _expectUniqueRanks(document);
    });
  }

  final backgroundMoves = <PreviewLayerOrderAction, List<String>>{
    PreviewLayerOrderAction.toFront: ['a', 'b', 'c', _background],
    PreviewLayerOrderAction.forward: ['a', 'b', _background, 'c'],
    PreviewLayerOrderAction.backward: [_background, 'a', 'b', 'c'],
    PreviewLayerOrderAction.toBack: [_background, 'a', 'b', 'c'],
  };
  for (final move in backgroundMoves.entries) {
    test(
      'background supports ${move.key.name} without replacing its banner',
      () {
        final document = _document();
        final banner = document.banner;
        expect(document.moveLayerToIndex(_background, 1), isTrue);
        expect(document.canMoveLayer(_background, move.key), isTrue);
        expect(document.moveLayer(_background, move.key), isTrue);
        expect(_ids(document), move.value);
        expect(document.banner, same(banner));
        expect(document.banner.stem, 'Unknown');
        expect(document.banner.assetPath, 'assets/meta/icon.png');
        _expectUniqueRanks(document);
      },
    );
  }

  test(
    'invalid and boundary moves do not normalize or mutate legacy state',
    () {
      final document = _document();
      for (final action in PreviewLayerOrderAction.values) {
        expect(document.canMoveLayer('missing', action), isFalse);
        expect(document.moveLayer('missing', action), isFalse);
      }
      expect(
        document.canMoveLayer(_background, PreviewLayerOrderAction.backward),
        isFalse,
      );
      expect(
        document.canMoveLayer('c', PreviewLayerOrderAction.forward),
        isFalse,
      );
      expect(
        document.moveLayer(_background, PreviewLayerOrderAction.toBack),
        isFalse,
      );
      expect(
        document.moveLayer(_background, PreviewLayerOrderAction.backward),
        isFalse,
      );
      expect(document.moveLayer('c', PreviewLayerOrderAction.forward), isFalse);
      expect(document.moveLayer('c', PreviewLayerOrderAction.toFront), isFalse);
      expect(document.moveLayerToIndex('missing', 1), isFalse);
      expect(document.moveLayerToIndex('b', -1), isFalse);
      expect(document.moveLayerToIndex('b', 4), isFalse);
      expect(document.moveLayerToIndex('b', 2), isFalse);
      expect(document.reorderLayers(_ids(document)), isFalse);
      expect(_ids(document), [_background, 'a', 'b', 'c']);
      expect(document.backgroundZIndex, isNull);
      expect(document.layers.map((layer) => layer.zIndex), [10, 20, 30]);
    },
  );

  test('arbitrary moves use final indices in either drag direction', () {
    final document = _document();
    expect(document.moveLayerToIndex('a', 3), isTrue);
    expect(_ids(document), [_background, 'b', 'c', 'a']);
    expect(document.moveLayerToIndex('a', 0), isTrue);
    expect(_ids(document), ['a', _background, 'b', 'c']);
    expect(document.moveLayerToIndex(_background, 3), isTrue);
    expect(_ids(document), ['a', 'b', 'c', _background]);
    expect(document.moveLayerToIndex('c', 1), isTrue);
    expect(_ids(document), ['a', 'c', 'b', _background]);
    _expectUniqueRanks(document);
  });

  test('complete permutations reject invalid sets atomically', () {
    final document = _document();
    for (final invalid in <List<String>>[
      [],
      ['a', 'b', 'c'],
      [_background, 'a', 'a', 'c'],
      [_background, 'a', 'b', 'unknown'],
      [_background, 'a', 'b', 'c', 'extra'],
    ]) {
      expect(() => document.reorderLayers(invalid), throwsArgumentError);
      expect(_ids(document), [_background, 'a', 'b', 'c']);
      expect(document.backgroundZIndex, isNull);
      expect(document.layers.map((layer) => layer.zIndex), [10, 20, 30]);
    }
    expect(document.reorderLayers(['c', 'a', _background, 'b']), isTrue);
    expect(_ids(document), ['c', 'a', _background, 'b']);
    _expectUniqueRanks(document);
    expect(document.reorderLayers(['c', 'a', _background, 'b']), isFalse);
  });

  test(
    'copy and undo snapshots independently preserve background and content ranks',
    () {
      final document = _document();
      final original = document.copy();
      document.reorderLayers(['c', _background, 'b', 'a']);
      final reordered = document.copy();
      document.moveLayer(_background, PreviewLayerOrderAction.toFront);
      document.banner.stem = 'Changed';
      document.layerById('a')!.text = 'Changed';
      expect(_ids(original), [_background, 'a', 'b', 'c']);
      expect(original.backgroundZIndex, isNull);
      expect(original.layers.map((layer) => layer.zIndex), [10, 20, 30]);
      expect(_ids(reordered), ['c', _background, 'b', 'a']);
      _expectUniqueRanks(reordered);
      expect(reordered.banner.stem, 'Unknown');
      expect(reordered.layerById('a')!.text, 'a');
      expect(reordered.banner, isNot(same(document.banner)));
      expect(reordered.layerById('a'), isNot(same(document.layerById('a'))));
      expect(_ids(reordered.copy()), _ids(reordered));
    },
  );

  test(
    'new layers are always above a reordered background and existing content',
    () {
      final document = _document();
      document.moveLayer(_background, PreviewLayerOrderAction.toFront);
      final added = _layer('new', zIndex: -100);
      document.addLayer(added);
      expect(_ids(document), ['a', 'b', 'c', _background, 'new']);
      expect(document.layers.last, same(added));
      _expectUniqueRanks(document);
      document.moveLayer('b', PreviewLayerOrderAction.toFront);
      document.layers.removeWhere((layer) => layer.id == 'a');
      document.addLayer(_layer('next', zIndex: -200));
      expect(_ids(document), ['c', _background, 'new', 'b', 'next']);
      _expectUniqueRanks(document);
      expect(_ids(document.copy()), _ids(document));
    },
  );

  test(
    'adding to legacy empty documents puts content above exactly one banner',
    () {
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.stageMapped),
      );
      document.addLayer(_layer('first', zIndex: -100));
      document.addLayer(_layer('second', zIndex: -100));
      expect(_ids(document), [_background, 'first', 'second']);
      _expectUniqueRanks(document);
    },
  );

  test('new content cannot reuse an existing or background identity', () {
    final document = _document();
    expect(() => document.addLayer(_layer('a')), throwsArgumentError);
    expect(() => document.addLayer(_layer(_background)), throwsArgumentError);
    expect(_ids(document), [_background, 'a', 'b', 'c']);
    expect(document.backgroundZIndex, isNull);
    expect(document.layers.map((layer) => layer.zIndex), [10, 20, 30]);
  });

  test('every content kind remains in order including invisible layers', () {
    final document = PreviewDocument(
      banner: PreviewBannerRef(kind: PreviewBannerSourceKind.stageMapped),
      layers: [
        for (final kind in PreviewLayerKind.values)
          _layer(kind.name, zIndex: kind.index, kind: kind)..visible = false,
      ],
    );
    expect(_ids(document), [
      _background,
      ...PreviewLayerKind.values.map((kind) => kind.name),
    ]);
    document.moveLayer(_background, PreviewLayerOrderAction.toFront);
    expect(_ids(document), [
      ...PreviewLayerKind.values.map((kind) => kind.name),
      _background,
    ]);
    expect(
      document.sortedLayers.map((layer) => layer.kind),
      PreviewLayerKind.values,
    );
    expect(document.sortedLayers.every((layer) => !layer.visible), isTrue);
    _expectUniqueRanks(document);
  });
}
