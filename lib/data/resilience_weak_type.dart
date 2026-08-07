import 'package:c_editor/data/tag_assets.dart';
import 'package:c_editor/l10n/app_localizations.dart';

enum ResilienceWeakType { physics, poison, electric, magic, ice, fire }

const weakTypeToJsonValue = <ResilienceWeakType, int>{
  ResilienceWeakType.physics: 1,
  ResilienceWeakType.poison: 2,
  ResilienceWeakType.electric: 3,
  ResilienceWeakType.magic: 4,
  ResilienceWeakType.ice: 5,
  ResilienceWeakType.fire: 6,
};

const weakTypeFromJsonValue = <int, ResilienceWeakType>{
  1: ResilienceWeakType.physics,
  2: ResilienceWeakType.poison,
  3: ResilienceWeakType.electric,
  4: ResilienceWeakType.magic,
  5: ResilienceWeakType.ice,
  6: ResilienceWeakType.fire,
};

const resilienceWeakTypeJsonValues = <int>[1, 2, 3, 4, 5, 6];

ResilienceWeakType? resilienceWeakTypeFromJson(int value) =>
    weakTypeFromJsonValue[value];

int resilienceWeakTypeToJson(ResilienceWeakType type) =>
    weakTypeToJsonValue[type]!;

String resilienceWeakTypeLabelForValue(AppLocalizations? l10n, int value) {
  final type = resilienceWeakTypeFromJson(value);
  if (type == null) {
    final isZh = l10n?.localeName.startsWith('zh') == true;
    return isZh
        ? '\u672a\u77e5\u7c7b\u578b\uff08\u503c\uff1a$value\uff09'
        : 'Unknown type (value: $value)';
  }

  return switch (type) {
    ResilienceWeakType.physics => l10n?.resiliencePhysics ?? 'Physics',
    ResilienceWeakType.poison => l10n?.resiliencePoison ?? 'Poison',
    ResilienceWeakType.electric => l10n?.resilienceElectric ?? 'Electric',
    ResilienceWeakType.magic => l10n?.resilienceMagic ?? 'Magic',
    ResilienceWeakType.ice => l10n?.resilienceIce ?? 'Ice',
    ResilienceWeakType.fire => l10n?.resilienceFire ?? 'Fire',
  };
}

String? resilienceWeakTypeIconForValue(int value) {
  final type = resilienceWeakTypeFromJson(value);
  if (type == null) return null;

  return switch (type) {
    ResilienceWeakType.physics => TagAssets.attributeIcons[1],
    ResilienceWeakType.poison => TagAssets.attributeIcons[2],
    ResilienceWeakType.electric => TagAssets.attributeIcons[3],
    ResilienceWeakType.magic => TagAssets.attributeIcons[4],
    ResilienceWeakType.ice => TagAssets.attributeIcons[5],
    ResilienceWeakType.fire => TagAssets.attributeIcons[6],
  };
}
