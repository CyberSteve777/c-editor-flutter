import 'package:flutter/material.dart';

/// Web stub - no dart:io, no permission_handler.
Future<void> ensureStoragePermission(BuildContext context) async {}

bool get isLevelFileShareSupported => false;

Future<void> shareLevelFile({
  required BuildContext context,
  required String itemPath,
  required String caption,
  required String failureMessage,
  required void Function(String message) onFailure,
}) async {}
