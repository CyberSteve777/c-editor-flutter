import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Weather module (rain/snow/dark). Ported from RainDarkPropertiesEP.kt
class RainDarkPropertiesScreen extends StatefulWidget {
  const RainDarkPropertiesScreen({
    super.key,
    required this.currentRtid,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
  });

  final String currentRtid;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<RainDarkPropertiesScreen> createState() =>
      _RainDarkPropertiesScreenState();
}

class _RainDarkPropertiesScreenState extends State<RainDarkPropertiesScreen> {
  static const _aliases = ['DefaultSnow', 'LightningRain', 'DefaultRainDark'];

  String _activeAlias() {
    final targetAliases = _aliases.toSet();
    final found = widget.levelDef.modules.firstWhere(
      (rtid) => targetAliases.contains(RtidParser.parse(rtid)?.alias),
      orElse: () => widget.currentRtid,
    );
    return RtidParser.parse(found)?.alias ?? 'DefaultSnow';
  }

  void _selectOption(String newAlias) {
    final current = _activeAlias();
    if (newAlias == current) return;

    final targetAliases = _aliases.toSet();
    var index = widget.levelDef.modules.indexWhere(
      (rtid) => targetAliases.contains(RtidParser.parse(rtid)?.alias),
    );
    if (index == -1) {
      index = widget.levelDef.modules.indexOf(widget.currentRtid);
    }
    if (index != -1) {
      widget.levelDef.modules[index] = RtidParser.build(
        newAlias,
        'LevelModules',
      );
      widget.onChanged();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final activeAlias = _activeAlias();

    final options = [
      _WeatherOption(
        alias: 'DefaultSnow',
        label:
            l10n?.weatherOption_DefaultSnow_label ??
            'Frostbite Caves (DefaultSnow)',
        description:
            l10n?.weatherOption_DefaultSnow_desc ??
            'Snowing effect from Frostbite Caves',
        icon: Icons.ac_unit,
      ),
      _WeatherOption(
        alias: 'LightningRain',
        label:
            l10n?.weatherOption_LightningRain_label ??
            'Thunderstorm (LightningRain)',
        description:
            l10n?.weatherOption_LightningRain_desc ??
            'Rain and lightning from Dark Ages Day 8',
        icon: Icons.thunderstorm,
      ),
      _WeatherOption(
        alias: 'DefaultRainDark',
        label:
            l10n?.weatherOption_DefaultRainDark_label ??
            'Dark Ages (DefaultRainDark)',
        description:
            l10n?.weatherOption_DefaultRainDark_desc ??
            'Rain effect from Dark Ages',
        icon: Icons.dark_mode,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.weatherSettings ?? 'Weather settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.weatherModule ?? 'Weather module',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.moduleHelpWeatherBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.referenceModules ?? 'Reference modules',
                  body: l10n?.moduleHelpWeatherRef ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: RadioGroup<String>(
        groupValue: activeAlias,
        onChanged: (val) {
          if (val != null) _selectOption(val);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n?.selectWeatherType ?? 'Select weather type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((opt) {
              final isSelected = opt.alias == activeAlias;
              return Card(
                elevation: 2,
                color: isSelected
                    ? theme.colorScheme.surfaceTint.withValues(alpha: 0.12)
                    : theme.cardColor,
                child: InkWell(
                  onTap: () => _selectOption(opt.alias),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Radio<String>(value: opt.alias),
                        const SizedBox(width: 8),
                        Icon(
                          opt.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WeatherOption {
  const _WeatherOption({
    required this.alias,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String alias;
  final String label;
  final String description;
  final IconData icon;
}
