import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

bool get isLevelFileShareSupported => !Platform.isLinux;

Future<void> shareLevelFile({
  required BuildContext context,
  required String itemPath,
  required String caption,
  required String failureMessage,
  required void Function(String message) onFailure,
}) async {
  final shareOrigin = _sharePositionOrigin(context);

  try {
    if (Platform.isIOS) {
      if (!await LevelRepository.ensureFolderAccess()) {
        onFailure(failureMessage);
        return;
      }
    }

    final source = File(itemPath);
    if (!await source.exists()) {
      onFailure(failureMessage);
      return;
    }

    XFile shareFile;
    File? tempCopy;
    if (Platform.isIOS) {
      final tempPath = p.join(
        (await getTemporaryDirectory()).path,
        p.basename(itemPath),
      );
      await source.copy(tempPath);
      tempCopy = File(tempPath);
      shareFile = XFile(tempPath);
    } else {
      shareFile = XFile(itemPath);
    }

    await Share.shareXFiles(
      [shareFile],
      text: caption,
      sharePositionOrigin: shareOrigin,
    );

    if (tempCopy != null) {
      try {
        await tempCopy.delete();
      } catch (_) {}
    }
  } catch (_) {
    onFailure(failureMessage);
  }
}

Rect? _sharePositionOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }

  if (!Platform.isIOS) return null;

  final size = MediaQuery.sizeOf(context);
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 1,
    height: 1,
  );
}

Future<void> ensureStoragePermission(BuildContext context) async {
  if (!Platform.isAndroid) return;
  final manageStatus = await Permission.manageExternalStorage.status;
  if (manageStatus.isGranted) return;
  if (manageStatus.isRestricted) {
    var status = await Permission.storage.status;
    if (status.isDenied) status = await Permission.storage.request();
    if (status.isGranted) return;
  }
  if (context.mounted) {
    await showStoragePermissionDialog(context);
  }
}

Future<void> showStoragePermissionDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _StoragePermissionDialog(
      l10n: l10n,
      onDeny: () {
        Navigator.pop(ctx);
        SystemNavigator.pop();
      },
    ),
  );
}

class _StoragePermissionDialog extends StatefulWidget {
  const _StoragePermissionDialog({required this.l10n, required this.onDeny});

  final AppLocalizations? l10n;
  final VoidCallback onDeny;

  @override
  State<_StoragePermissionDialog> createState() =>
      _StoragePermissionDialogState();
}

class _StoragePermissionDialogState extends State<_StoragePermissionDialog>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndDismissIfGranted();
    }
  }

  Future<void> _checkAndDismissIfGranted() async {
    final manageStatus = await Permission.manageExternalStorage.status;
    if (manageStatus.isGranted && mounted) {
      Navigator.of(context).pop();
      return;
    }
    if (manageStatus.isRestricted &&
        await Permission.storage.isGranted &&
        mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(
        l10n?.storagePermissionDialogTitle ?? 'Storage Permission Required',
      ),
      content: Text(
        l10n?.storagePermissionDialogMessage ??
            'This app requires external storage access to open and save level files. Please grant "All files access" permission in Settings.',
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await Permission.manageExternalStorage.request();
          },
          child: Text(l10n?.storagePermissionGoToSettings ?? 'Go to settings'),
        ),
        TextButton(
          onPressed: widget.onDeny,
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.storagePermissionDeny ?? 'Deny'),
        ),
      ],
    );
  }
}
