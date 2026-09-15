import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web index opts into a cover viewport and loads the mobile input fix', () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains('viewport-fit=cover'));
    expect(html, contains('mobile_web_input.js'));
    expect(html, contains('flt-semantics-placeholder'));
    expect(html, contains('overscroll-behavior: none'));
  });

  test('mobile web input script shrinks the a11y placeholder and tracks visualViewport', () {
    final js = File('web/mobile_web_input.js').readAsStringSync();
    expect(js, contains('flt-semantics-placeholder'));
    expect(js, contains('pointer-events'));
    expect(js, contains('visualViewport'));
    expect(js, contains('viewport-fit=cover'));
    expect(js, contains('flutter-first-frame'));
  });
}
