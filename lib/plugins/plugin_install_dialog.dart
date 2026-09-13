import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/widgets/app_message.dart';

/// Preview + install dialog for a `.cplugin` package already read into [bytes].
///
/// Returns `true` if the plugin was installed successfully.
Future<bool> showCpluginInstallDialog(
  BuildContext context, {
  required Uint8List bytes,
}) async {
  final l10n = AppLocalizations.of(context)!;

  late final CPluginPackage package;
  try {
    package = const CPluginValidator().validate(bytes);
  } on CPluginValidationException catch (e) {
    AppMessage.show(
      context,
      l10n.pluginInvalidFile(e.message),
      icon: Icons.error_outline,
    );
    return false;
  } catch (e) {
    AppMessage.show(
      context,
      l10n.pluginInvalidFile(e.toString()),
      icon: Icons.error_outline,
    );
    return false;
  }

  final preview = InstalledPluginRecord(
    manifest: package.manifest,
    evcBytes: package.evcBytes,
    assets: package.assets,
    enabled: false,
    kind: PluginKind.imported,
  );
  final lang = Localizations.localeOf(context).languageCode;
  final name = preview.localizedName(lang);
  final description = preview.localizedDescription(lang);
  final icon = preview.iconImageProvider();

  final shouldInstall = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: icon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: icon,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.extension,
                            size: 72,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.extension,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pluginVersionLabel(package.manifest.version),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                description.isEmpty ? l10n.pluginNoDescription : description,
                style: theme.textTheme.bodyMedium,
              ),
              if (package.manifest.configurable) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.pluginConfigurable,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pluginInstallAction),
          ),
        ],
      );
    },
  );

  if (shouldInstall != true || !context.mounted) return false;

  try {
    final record = await PluginManager.instance.installBytes(bytes);
    if (!context.mounted) return true;
    AppMessage.show(
      context,
      l10n.pluginInstallSuccess(
        record.localizedName(Localizations.localeOf(context).languageCode),
      ),
      icon: Icons.check_circle,
    );
    return true;
  } on CPluginValidationException catch (e) {
    if (context.mounted) {
      AppMessage.show(
        context,
        l10n.pluginInvalidFile(e.message),
        icon: Icons.error_outline,
      );
    }
  } on StateError catch (e) {
    if (context.mounted) {
      final msg = e.message;
      AppMessage.show(
        context,
        msg.toString().contains('level library')
            ? l10n.pluginNoLibraryForInstall
            : l10n.pluginInstallFailed(e.toString()),
        icon: Icons.error_outline,
      );
    }
  } catch (e) {
    if (context.mounted) {
      AppMessage.show(
        context,
        l10n.pluginInstallFailed(e.toString()),
        icon: Icons.error_outline,
      );
    }
  }
  return false;
}
