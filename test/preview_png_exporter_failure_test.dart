import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Image extends Fake implements ui.Image {
  _Image({this.byteData, this.error});

  final ByteData? byteData;
  final Object? error;
  final formats = <ui.ImageByteFormat>[];

  @override
  Future<ByteData?> toByteData({
    ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba,
  }) async {
    formats.add(format);
    if (error != null) throw error!;
    return byteData;
  }
}

Matcher _failure(PreviewPngExportFailure failure) =>
    isA<PreviewPngExportException>().having(
      (exception) => exception.failure,
      'failure',
      failure,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final failure in PreviewPngExportFailure.values) {
    test('known $failure errors retain an inspectable failure reason', () {
      final exception = PreviewPngExportException(failure);
      expect(exception, isA<Exception>());
      expect(exception.failure, failure);
      expect(
        exception.toString(),
        'PreviewPngExportException(${failure.name})',
      );
    });
  }

  test(
    'missing PNG data reports encoding before checking the library',
    () async {
      final image = _Image();
      await expectLater(
        PreviewPngExporter.export(image: image, levelFileName: 'test.json'),
        throwsA(_failure(PreviewPngExportFailure.encoding)),
      );
      expect(image.formats, [ui.ImageByteFormat.png]);
    },
  );

  for (final emptyPath in <String?>[null, '']) {
    test('a $emptyPath library path reports libraryNotConfigured', () async {
      SharedPreferences.setMockInitialValues({'folder_path': ?emptyPath});
      final image = _Image(byteData: ByteData(4));
      await expectLater(
        PreviewPngExporter.export(image: image, levelFileName: 'test.json'),
        throwsA(_failure(PreviewPngExportFailure.libraryNotConfigured)),
      );
      expect(image.formats, [ui.ImageByteFormat.png]);
    });
  }

  test('unexpected encoder errors are not replaced or swallowed', () async {
    final original = StateError('Unexpected encoder failure');
    final image = _Image(error: original);
    await expectLater(
      PreviewPngExporter.export(image: image, levelFileName: 'test.json'),
      throwsA(same(original)),
    );
    expect(image.formats, [ui.ImageByteFormat.png]);
  });
}
