# Vendored flutter_eval

Patched copy of [flutter_eval](https://pub.dev/packages/flutter_eval) **0.8.2** for compatibility with newer Flutter SDKs.

## Local patches

- `$Container.isAntiAlias` — Flutter added `Container.isAntiAlias`; the pub release does not implement it yet, which breaks compilation.

When an upstream flutter_eval release includes this (and other Flutter API deltas), switch `pubspec.yaml` back to the pub.dev dependency and remove this folder.
