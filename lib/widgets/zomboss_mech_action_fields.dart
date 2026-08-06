import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/models/zomboss_robot_spawn_entry.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';
import 'package:c_editor/widgets/zomboss_mech_robot_spawn_list.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:c_editor/widgets/zomboss_mech_zombie_type_list.dart';

/// Dynamic editors for zomboss action objdata from catalog field specs.
class ZombossMechActionFieldsEditor extends StatelessWidget {
  const ZombossMechActionFieldsEditor({
    super.key,
    required this.mechId,
    required this.fields,
    required this.data,
    required this.onChanged,
    this.editable = true,
    this.objclass = '',
    this.levelFile,
    this.depth = 0,
    this.fieldNamePrefix = '',
  });

  final String mechId;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;
  final bool editable;
  final String objclass;
  final PvzLevelFile? levelFile;
  final int depth;
  final String fieldNamePrefix;

  String _fullFieldName(ZombossMechFieldSpec field) {
    if (fieldNamePrefix.isEmpty) return field.name;
    return '${fieldNamePrefix}_${field.name}';
  }

  String _fieldLabel(BuildContext context, ZombossMechFieldSpec field) {
    if (mechId.isEmpty || objclass.isEmpty) return field.name;
    return ZombossMechL10n.fieldLabel(
      context,
      mechId,
      objclass,
      _fullFieldName(field),
      fallback: field.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final hasWeightedZombieList =
        fields.any((field) => field.name == 'ZombieNames') &&
        fields.any((field) => field.name == 'ZombieWeights');
    for (final field in fields) {
      if (field.name.isEmpty || field.name.startsWith('#')) continue;
      if (hasWeightedZombieList && field.name == 'ZombieWeights') continue;
      children.add(_buildField(context, field));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildField(BuildContext context, ZombossMechFieldSpec field) {
    final padding = EdgeInsets.only(left: depth * 12.0, top: 8, bottom: 4);
    final label = _fieldLabel(context, field);

    if (field.name == 'ZombieNames' &&
        fields.any((item) => item.name == 'ZombieWeights')) {
      final weightField = fields.firstWhere(
        (item) => item.name == 'ZombieWeights',
        orElse: () =>
            ZombossMechFieldSpec(name: 'ZombieWeights', type: 'List<int>'),
      );
      final ids = ZombossMechActionUtils.parseZombieTypeList(data[field.name]);
      final weights = _parseIntList(data['ZombieWeights'], ids.length);
      return Padding(
        padding: padding,
        child: ZombossMechWeightedZombieListEditor(
          fieldLabel: label,
          weightLabel: _fieldLabel(context, weightField),
          zombieIds: ids,
          weights: weights,
          editable: editable,
          onChanged: (nextIds, nextWeights) {
            data[field.name] = nextIds;
            data['ZombieWeights'] = nextWeights;
            onChanged();
          },
        ),
      );
    }

    if (ZombossMechActionUtils.isZombieTypeField(field)) {
      final raw = data[field.name];
      if (field.name == 'SpawnZombieTypes' &&
          (zombossActionUsesRobotSpawnList(objclass) ||
              ZombossRobotSpawnEntry.isRobotSpawnList(raw))) {
        final entries = ZombossRobotSpawnEntry.parseList(raw);
        return Padding(
          padding: padding,
          child: ZombossMechRobotSpawnListEditor(
            fieldLabel: label,
            entries: entries,
            levelFile: levelFile,
            editable: editable,
            onChanged: (next) {
              data[field.name] = ZombossRobotSpawnEntry.toJsonList(next);
              onChanged();
            },
          ),
        );
      }

      final isList = ZombossMechActionUtils.isZombieTypeListField(field);
      final ids = isList
          ? ZombossMechActionUtils.parseZombieTypeList(raw)
          : [if (raw != null && raw.toString().isNotEmpty) raw.toString()];
      return Padding(
        padding: padding,
        child: ZombossMechZombieTypeListEditor(
          fieldLabel: label,
          zombieIds: ids,
          editable: editable,
          isList: isList,
          onChanged: (next) {
            if (isList) {
              data[field.name] = next;
            } else {
              data[field.name] = next.isNotEmpty ? next.first : '';
            }
            onChanged();
          },
        ),
      );
    }

    if (field.name == 'PortalType' && field.type == 'string') {
      final value = data[field.name] ?? field.defaultValue ?? '';
      return Padding(
        padding: padding,
        child: PortalTypeSingleSelectField(
          label: label,
          value: value.toString(),
          editable: editable,
          onChanged: (next) {
            data[field.name] = next;
            onChanged();
          },
        ),
      );
    }

    if (field.type == 'object' && field.objectFields.isNotEmpty) {
      final nested = data[field.name];
      final nestedMap = nested is Map<String, dynamic>
          ? nested
          : nested is Map
          ? Map<String, dynamic>.from(nested)
          : ZombossMechActionUtils.defaultsFromFields(field.objectFields);
      if (nested is! Map) data[field.name] = nestedMap;
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            ZombossMechActionFieldsEditor(
              mechId: mechId,
              fields: field.objectFields,
              data: nestedMap,
              onChanged: onChanged,
              editable: editable,
              objclass: objclass,
              levelFile: levelFile,
              depth: depth,
              fieldNamePrefix: _fullFieldName(field),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: _ScalarField(
        field: field,
        label: label,
        value: data[field.name],
        editable: editable,
        onChanged: (v) {
          data[field.name] = v;
          onChanged();
        },
      ),
    );
  }

  List<int> _parseIntList(dynamic raw, int expectedLength) {
    final values = <int>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is int) {
          values.add(item);
        } else if (item is num) {
          values.add(item.toInt());
        } else {
          values.add(int.tryParse(item.toString()) ?? 100);
        }
      }
    }
    while (values.length < expectedLength) {
      values.add(100);
    }
    if (values.length > expectedLength) {
      return values.take(expectedLength).toList();
    }
    return values;
  }
}

class _ScalarField extends StatefulWidget {
  const _ScalarField({
    required this.field,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.editable,
  });

  final ZombossMechFieldSpec field;
  final String label;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool editable;

  @override
  State<_ScalarField> createState() => _ScalarFieldState();
}

class _ScalarFieldState extends State<_ScalarField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textValue);
    _focusNode = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() {
    final f = _focusNode.hasFocus;
    if (_focused != f) setState(() => _focused = f);
  }

  String get _textValue {
    final v = widget.value ?? widget.field.defaultValue ?? '';
    return v.toString();
  }

  @override
  void didUpdateWidget(covariant _ScalarField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.value != widget.value) {
      _controller.text = _textValue;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final label = widget.label;
    switch (field.type) {
      case 'bool':
        final checked = widget.value == true;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: checked,
          onChanged: widget.editable ? (v) => widget.onChanged(v) : null,
        );
      case 'int':
        if (ZombossMechActionUtils.usesLabeledIntInput(field)) {
          return TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: !widget.editable,
            decoration: editorInputDecoration(context, labelText: label),
            keyboardType: TextInputType.number,
            onChanged: widget.editable
                ? (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) widget.onChanged(parsed);
                  }
                : null,
          );
        }
        final intVal = _asInt(widget.value, field);
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 280;
            if (!widget.editable) {
              return Row(
                children: [
                  Expanded(child: Text(label)),
                  Text(
                    '$intVal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            }
            final stepper = Row(
              mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: intVal > -999999
                      ? () => widget.onChanged(intVal - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$intVal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => widget.onChanged(intVal + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Text(label), stepper],
              );
            }
            return Row(
              children: [
                Expanded(child: Text(label)),
                stepper,
              ],
            );
          },
        );
      case 'float':
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          readOnly: !widget.editable,
          decoration: editorInputDecoration(context, labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: widget.editable
              ? (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) widget.onChanged(parsed);
                }
              : null,
        );
      default:
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          readOnly: !widget.editable,
          decoration: editorInputDecoration(context, labelText: label),
          onChanged: widget.editable ? (v) => widget.onChanged(v) : null,
        );
    }
  }

  int _asInt(dynamic value, ZombossMechFieldSpec field) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (field.defaultValue is int) return field.defaultValue as int;
    if (field.defaultValue is num) return (field.defaultValue as num).toInt();
    return 0;
  }
}
