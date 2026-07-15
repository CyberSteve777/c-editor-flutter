import 'package:c_editor/l10n/app_localizations.dart';

class WorldInfo {
  final String codename;
  final int levelCount;
  final String iconAsset;
  final String Function(AppLocalizations l10n) nameGetter;

  const WorldInfo({
    required this.codename,
    required this.levelCount,
    required this.iconAsset,
    required this.nameGetter,
  });

  String getIconPath() => 'assets/images/round_icons/$iconAsset';
}
