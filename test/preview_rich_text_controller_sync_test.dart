import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('synchronous layer listener saves the final typed character', () {
    final layer = PreviewLayer(
      id: 'text',
      kind: PreviewLayerKind.text,
      bounds: const Rect.fromLTWH(0, 0, 1, 1),
      text: 'Hello',
    );
    final controller = PreviewRichTextController()..loadFromLayer(layer);
    addTearDown(controller.dispose);
    final listenerTexts = <String>[];
    controller.addListener(() {
      controller.applyToLayer(layer);
      listenerTexts.add(layer.plainText);
    });

    controller.value = const TextEditingValue(
      text: 'Hello!',
      selection: TextSelection.collapsed(offset: 6),
    );

    expect(listenerTexts, ['Hello!']);
    expect(layer.plainText, 'Hello!');
    expect(layer.text, 'Hello!');
    expect(layer.textRuns.single.text, 'Hello!');
  });

  test(
    'synchronous listener receives updated styled runs before notification',
    () {
      final layer = PreviewLayer(
        id: 'styled',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0, 0, 1, 1),
        textRuns: [
          PreviewTextRun(text: 'A', style: PreviewTextStyleData(fontSize: 12)),
          PreviewTextRun(text: 'B', style: PreviewTextStyleData(fontSize: 48)),
        ],
      );
      final controller = PreviewRichTextController()..loadFromLayer(layer);
      addTearDown(controller.dispose);
      controller.addListener(() => controller.applyToLayer(layer));

      controller.value = const TextEditingValue(
        text: 'AB!',
        selection: TextSelection.collapsed(offset: 3),
      );

      expect(layer.plainText, 'AB!');
      expect(layer.textRuns, hasLength(2));
      expect(layer.textRuns.first.text, 'A');
      expect(layer.textRuns.first.style.fontSize, 12);
      expect(layer.textRuns.last.text, 'B!');
      expect(layer.textRuns.last.style.fontSize, 48);
    },
  );
}
