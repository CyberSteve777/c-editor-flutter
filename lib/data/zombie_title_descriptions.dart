import 'package:flutter/widgets.dart';
import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';

class ZombieTitleDescriptions {
  ZombieTitleDescriptions._();

  static String resolveCategoryTemplate(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      'zombie_title_crystal' =>
        l10n?.ztPerkCategoryDescCrystal ??
            'Grants immunity against instant-kill effects. Damage can only be received once every A seconds, each hit deals B damage, and health is reduced by X.',
      'zombie_title_gravity' =>
        l10n?.ztPerkCategoryDescGravity ??
            'Knockback or knockoff effects are no longer effective.',
      'zombie_title_shield' =>
        l10n?.ztPerkCategoryDescShield ??
            'The first N instances of damage are invalidated, and immunity to instant-kill effects persists throughout the perk\'s duration.',
      'zombie_title_immunecontrol' =>
        l10n?.ztPerkCategoryDescImmuneControl ??
            'P% more resistance against control effects.',
      'zombie_title_anticontrol' =>
        l10n?.ztPerkCategoryDescAntiControl ??
            'When under the influence of a control effect, received damage is reduced by P%.',
      'zombie_title_attack' =>
        l10n?.ztPerkCategoryDescAttack ??
            'Attack power increased by P%.',
      'zombie_title_speed' =>
        l10n?.ztPerkCategoryDescSpeed ??
            'Walking speed increased by P%.',
      _ => '',
    };
  }

  static String resolve(BuildContext context, ZombieTitleEntry entry) {
    final l10n = AppLocalizations.of(context);
    final props = entry.numericProperties;

    return switch (entry.type) {
      'zombie_title_crystal' => l10n?.ztPerkDescCrystal(
            _formatValue(props['DamageTakenInterval'] ?? 0.1),
            _formatValue(props['DamageTotalTaken'] ?? 1),
            _formatHpReduced(props['HPReduced'] ?? 0),
          ) ??
          _fallbackCrystal(props),
      'zombie_title_gravity' =>
        l10n?.ztPerkDescGravity ??
            'Knockback or knockoff effects are no longer effective.',
      'zombie_title_shield' => l10n?.ztPerkDescShield(
            _formatValue(props['ShieldNum'] ?? 0),
          ) ??
          _fallbackShield(props),
      'zombie_title_immunecontrol' => l10n?.ztPerkDescImmuneControl(
            _formatPercent(props['ReducedControlPercent'] ?? 0),
          ) ??
          _fallbackImmuneControl(props),
      'zombie_title_anticontrol' => l10n?.ztPerkDescAntiControl(
            _formatPercent(props['ReducedDamagePercent'] ?? 0),
          ) ??
          _fallbackAntiControl(props),
      'zombie_title_attack' => l10n?.ztPerkDescAttack(
            _formatPercent(props['ImprovedDamagePercent'] ?? 0),
          ) ??
          _fallbackAttack(props),
      'zombie_title_speed' => l10n?.ztPerkDescSpeed(
            _formatPercent(props['ImprovedSpeedPercent'] ?? 0),
          ) ??
          _fallbackSpeed(props),
      _ => '',
    };
  }

  static String _formatValue(num value) {
    if (value is int) return value.toString();
    if (value == value.roundToDouble()) return value.round().toString();
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String _formatPercent(num value) {
    if (value > 0 && value <= 1) {
      final pct = value * 100;
      if (pct == pct.roundToDouble()) return '${pct.round()}%';
      return '${pct.toStringAsFixed(1)}%';
    }
    return '${_formatValue(value)}%';
  }

  static String _formatHpReduced(num value) {
    if (value > 0 && value <= 1) return _formatPercent(value);
    return _formatValue(value);
  }

  static String _fallbackCrystal(Map<String, num> props) {
    return 'Grants immunity against instant-kill effects. Damage can only be received once every ${_formatValue(props['DamageTakenInterval'] ?? 0.1)} seconds, each hit deals ${_formatValue(props['DamageTotalTaken'] ?? 1)} damage, and health is reduced by ${_formatHpReduced(props['HPReduced'] ?? 0)}.';
  }

  static String _fallbackShield(Map<String, num> props) {
    return 'The first ${_formatValue(props['ShieldNum'] ?? 0)} instances of damage are invalidated, and immunity to instant-kill effects persists throughout the perk\'s duration.';
  }

  static String _fallbackImmuneControl(Map<String, num> props) {
    return '${_formatPercent(props['ReducedControlPercent'] ?? 0)} more resistance against control effects.';
  }

  static String _fallbackAntiControl(Map<String, num> props) {
    return 'When under the influence of a control effect, received damage is reduced by ${_formatPercent(props['ReducedDamagePercent'] ?? 0)}.';
  }

  static String _fallbackAttack(Map<String, num> props) {
    return 'Attack power increased by ${_formatPercent(props['ImprovedDamagePercent'] ?? 0)}.';
  }

  static String _fallbackSpeed(Map<String, num> props) {
    return 'Walking speed increased by ${_formatPercent(props['ImprovedSpeedPercent'] ?? 0)}.';
  }
}
