// Prefer the Flutter test harness (flutter_eval needs the Flutter toolchain):
//
//   flutter test test/tools/compile_hello_cplugin_test.dart
//
// This stub remains so docs that mention `dart run tools/compile_hello_cplugin.dart`
// can point authors to the working command.
void main() {
  // ignore: avoid_print
  print(
    'Use: flutter test test/tools/compile_hello_cplugin_test.dart\n'
    'Plain dart run cannot load flutter_eval bridges.',
  );
}
