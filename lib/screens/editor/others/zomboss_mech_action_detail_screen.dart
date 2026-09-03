import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

class ZombossMechActionDetailScreen extends StatelessWidget {
  const ZombossMechActionDetailScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    required this.rtid,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String rtid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = zombossMechAccent(context);
    final resolved = ZombossMechActionUtils.resolveAction(
      rtid: rtid,
      catalog: catalog,
      levelFile: levelFile,
    );
    final info = RtidParser.parse(rtid);
    final catalogAction = info == null
        ? null
        : catalog.catalogActionForAlias(info.alias);
    final objclass = catalogAction?.objclass ?? resolved?.levelObject?.objClass;
    final actionName = _actionName(context, resolved, catalogAction);
    final data = resolved == null
        ? <String, dynamic>{}
        : ZombossMechActionUtils.cloneMap(resolved.data);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.zombossMechActionDetails ?? 'Action Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: accent.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: accent.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoLine(
                    label: l10n?.aliasLabel ?? 'Alias',
                    value: info?.alias ?? resolved?.alias ?? rtid,
                  ),
                  _InfoLine(
                    label: l10n?.zombossMechActionRtid ?? 'RTID',
                    value: rtid,
                  ),
                  if (objclass != null && objclass.isNotEmpty)
                    _InfoLine(
                      label:
                          l10n?.zombossMechActionBaseObjclass ??
                          'Action Type (objclass)',
                      value: ZombossMechL10n.objclassLabel(context, objclass),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.zombossMechActionFields ?? 'Fields',
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (resolved == null || objclass == null)
            Text(
              l10n?.zombossMechNoActionsFound ?? 'No actions found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ZombossMechActionFieldsEditor(
              mechId: catalog.id,
              fields: resolved.fields,
              data: data,
              objclass: objclass,
              levelFile: levelFile,
              catalog: catalog,
              editable: false,
              onChanged: () {},
            ),
        ],
      ),
    );
  }

  String _actionName(
    BuildContext context,
    ZombossResolvedAction? resolved,
    ZombossMechCatalogAction? catalogAction,
  ) {
    final alias = resolved?.alias ?? RtidParser.parse(rtid)?.alias ?? rtid;
    if (catalogAction != null) {
      return ZombossMechL10n.implementationLabel(
        context,
        catalog.id,
        catalogAction.alias,
        fallback: alias,
      );
    }
    final objclass = resolved?.levelObject?.objClass;
    if (objclass != null && objclass.isNotEmpty) {
      return ZombossMechL10n.actionLabel(
        context,
        catalog.id,
        objclass,
        fallback: alias,
      );
    }
    return ZombossMechActionUtils.displayLabel(rtid);
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: EditorResponsiveLabelField(
        breakpoint: 420,
        labelWidth: 180,
        spacing: 8,
        label: Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        field: SelectableText(value, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
