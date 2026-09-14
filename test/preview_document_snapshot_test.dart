import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PreviewDocument _document() => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    stem: 'egypt',
    assetPath: 'assets/banner.png',
  ),
  layers: [
    PreviewLayer(
      id: 'text',
      kind: PreviewLayerKind.text,
      bounds: const Rect.fromLTWH(0.1, 0.1, 0.4, 0.1),
      text: 'Saved text',
      textStyle: PreviewTextStyleData(fontSize: 32),
    ),
    PreviewLayer(
      id: 'icons',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(0.2, 0.3, 0.4, 0.3),
      sections: [
        PreviewIconSection(
          title: 'Wave',
          rows: [
            PreviewIconRow(
              items: [PreviewItem(id: 'pea', assetPath: 'assets/pea.png')],
              iconSize: 36,
            ),
          ],
        ),
      ],
      containedTexts: [PreviewContainedText(id: 'caption', text: 'Caption')],
    ),
  ],
);

void main() {
  test('snapshot remains independent from mutable nested document content', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    final unchangedCopy = document.copy();
    expect(snapshot.matches(unchangedCopy), isTrue);
    document.layers.last.containedTexts.single.style.fontSize += 2;
    expect(snapshot.matches(document), isFalse);
    expect(snapshot.matches(unchangedCopy), isTrue);
  });

  test('equivalent rich-text runs and legacy text do not count as edits', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    final layer = document.layers.first;
    layer.ensureTextRuns();
    expect(snapshot.matches(document), isTrue);
    layer.textRuns = [
      PreviewTextRun(text: 'Saved ', style: layer.textStyle!.copy()),
      PreviewTextRun(text: 'text', style: layer.textStyle!.copy()),
    ];
    expect(snapshot.matches(document), isTrue);
    layer.textRuns.last.style.outlineColor = Colors.red;
    expect(snapshot.matches(document), isFalse);
  });

  test('outline width changes count as content changes', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    document.layers.first.textStyle!.outlineWidth += 1;
    expect(snapshot.matches(document), isFalse);
  });

  test(
    'materializing empty text for editing does not change the saved preview',
    () {
      final document = _document();
      final layer = document.layers.first;
      layer.text = '';
      final snapshot = PreviewDocumentSnapshot.capture(document);
      layer.ensureTextRuns();
      expect(snapshot.matches(document), isTrue);
      layer.textRuns.single.style.color = Colors.red;
      expect(snapshot.matches(document), isTrue);
      layer.setPlainText('New text');
      expect(snapshot.matches(document), isFalse);
    },
  );

  test('row size and contained caption bounds count as content changes', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    document.layers.last.sections.single.rows.single.iconSize = 48;
    expect(snapshot.matches(document), isFalse);
    document.layers.last.sections.single.rows.single.iconSize = 36;
    expect(snapshot.matches(document), isTrue);
    document.layers.last.containedTexts.single.bounds = const Rect.fromLTWH(
      0.2,
      0.2,
      0.6,
      0.4,
    );
    expect(snapshot.matches(document), isFalse);
  });

  test('equivalent order ranks match but moving the background does not', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    document.layers.first.zIndex = 10;
    document.layers.last.zIndex = 20;
    expect(snapshot.matches(document), isTrue);
    document.backgroundZIndex = 15;
    expect(snapshot.matches(document), isFalse);
  });

  test('changing banner source is detected independently of layer content', () {
    final document = _document();
    final snapshot = PreviewDocumentSnapshot.capture(document);
    document.banner.stem = 'pirate';
    expect(snapshot.matches(document), isFalse);
  });
}
