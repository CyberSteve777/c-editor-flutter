import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Looks up a curated set of host [AppLocalizations] strings by ARB key.
String? lookupHostL10n(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return null;
  switch (key) {
    case 'cancel':
      return l10n.cancel;
    case 'confirm':
      return l10n.confirm;
    case 'error':
      return l10n.error;
    case 'warning':
      return l10n.warning;
    case 'info':
      return l10n.info;
    case 'success':
      return l10n.success;
    case 'pluginsTitle':
      return l10n.pluginsTitle;
    case 'save':
      return l10n.tooltipSave;
    case 'language':
      return l10n.language;
    case 'pluginBundledBadge':
      return l10n.pluginBundledBadge;
    default:
      return null;
  }
}
