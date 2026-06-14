import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/theme/app_theme.dart'
    show pvzLightOrangeDark, pvzLightOrangeLight;

/// Mechanism Plank / Connected Minecart properties editor.
///
/// Only mX and mWidth are editable because the other values may create invalid
/// in-game layouts.
class MechanismPlankPropertiesScreen extends StatefulWidget {
  const MechanismPlankPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<MechanismPlankPropertiesScreen> createState() =>
      _MechanismPlankPropertiesScreenState();
}

class _MechanismPlankPropertiesScreenState
    extends State<MechanismPlankPropertiesScreen> {
  late PvzObject _moduleObj;
  late Map<String, dynamic> _data;
  late (int rows, int cols) _gridDims;

  int get _gridRows => _gridDims.$1;
  int get _gridCols => _gridDims.$2;

  static const _railsAssetPath =
      'assets/images/others/kongfu_minecart_tracks.webp';
  static const _cartLeftAssetPath =
      'assets/images/others/kongfu_minecart_left.webp';
  static const _cartMiddleAssetPath =
      'assets/images/others/kongfu_minecart_middle.webp';
  static const _cartRightAssetPath =
      'assets/images/others/kongfu_minecart_right.webp';

  Map<String, dynamic> get _rect =>
      Map<String, dynamic>.from(_data['MechanismGearsRect'] as Map? ?? {});

  List<String> get _plankRows =>
      ((_data['MechanismPlankRows'] as List?) ?? ['0', '4'])
          .map((e) => e.toString())
          .toList();

  int get _mX => (_rect['mX'] as num?)?.toInt() ?? 0;
  int get _mY => (_rect['mY'] as num?)?.toInt() ?? 0;
  int get _mWidth => (_rect['mWidth'] as num?)?.toInt() ?? 4;
  int get _mHeight => (_rect['mHeight'] as num?)?.toInt() ?? 5;

  int get _maxMX => (_gridCols - 1).clamp(0, _gridCols).toInt();
  int get _maxWidth => (_gridCols - _mX).clamp(1, _gridCols).toInt();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Map<String, dynamic> _defaultData() {
    return {
      'MechanismGearsRect': {
        'mHeight': 5,
        'mWidth': 4,
        'mX': 0,
        'mY': 0,
      },
      'MechanismPlankRows': ['0', '4'],
    };
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? 'MechanismPlank';

    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );

    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: 'MechanismPlankProperties',
        objData: _defaultData(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }

    try {
      _data = Map<String, dynamic>.from(_moduleObj.objData as Map);
    } catch (_) {
      _data = _defaultData();
    }

    _data['MechanismGearsRect'] =
        Map<String, dynamic>.from(_data['MechanismGearsRect'] as Map? ?? {});
    _data['MechanismPlankRows'] =
        ((_data['MechanismPlankRows'] as List?) ?? ['0', '4'])
            .map((e) => e.toString())
            .toList();

    _gridDims = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    _normalizeValues();
  }

  void _normalizeValues() {
    final newMX = _mX.clamp(0, _maxMX).toInt();
    final newWidth = _mWidth
        .clamp(1, (_gridCols - newMX).clamp(1, _gridCols))
        .toInt();

    final rect = _rect;
    rect['mX'] = newMX;
    rect['mWidth'] = newWidth;

    // Preserve / restore the values that are intentionally not editable.
    rect.putIfAbsent('mY', () => 0);
    rect.putIfAbsent('mHeight', () => 5);

    _data['MechanismGearsRect'] = rect;
    _moduleObj.objData = _data;
  }

  void _setValues({
    required int mX,
    required int mWidth,
  }) {
    final newMX = mX.clamp(0, _maxMX).toInt();
    final newWidth = mWidth
        .clamp(1, (_gridCols - newMX).clamp(1, _gridCols))
        .toInt();

    final rect = _rect;
    rect['mX'] = newMX;
    rect['mWidth'] = newWidth;

    // Do not expose these in UI. Changing them may cause in-game bugs.
    rect.putIfAbsent('mY', () => 0);
    rect.putIfAbsent('mHeight', () => 5);

    _data['MechanismGearsRect'] = rect;
    _moduleObj.objData = _data;

    widget.onChanged();
    setState(() {});
  }

  void _setMX(int value) {
    _setValues(
      mX: value,
      mWidth: _mWidth,
    );
  }

  void _setMWidth(int value) {
    _setValues(
      mX: _mX,
      mWidth: value,
    );
  }

  Set<int> get _cartLocalRows => _plankRows
      .map((e) => int.tryParse(e))
      .whereType<int>()
      .toSet();

  bool _isInsideMechanismRect(int col, int row) {
    final localCol = col - _mX;
    final localRow = row - _mY;

    return localCol >= 0 &&
        localCol < _mWidth &&
        localRow >= 0 &&
        localRow < _mHeight;
  }

  bool _hasRailAt(int col, int row) {
    if (!_isInsideMechanismRect(col, row)) return false;

    final localRow = row - _mY;

    // In-game, the rail sprite is still drawn underneath the Connected
    // Minecart itself. Rails also appear on the lanes immediately above or
    // below a Connected Minecart, but do not fill the disconnected middle lane.
    // Default rows 0 and 4 with mHeight 5 therefore render rails on local rows
    // 0, 1, 3 and 4, while local row 2 stays empty.
    return _cartLocalRows.any((cartRow) {
      final distance = (localRow - cartRow).abs();
      return distance == 0 || distance == 1;
    });
  }

  bool _hasCartAt(int col, int row) {
    if (!_isInsideMechanismRect(col, row)) return false;

    final localRow = row - _mY;
    return _cartLocalRows.contains(localRow);
  }

  String _cartAssetPathForColumn(int col) {
    final localCol = col - _mX;
    if (_mWidth <= 1) return _cartMiddleAssetPath;
    if (localCol <= 0) return _cartLeftAssetPath;
    if (localCol >= _mWidth - 1) return _cartRightAssetPath;
    return _cartMiddleAssetPath;
  }

  bool _hasOutOfAreaWarning() {
    if (_mX < 0 || _mY < 0) return true;
    if (_mX + _mWidth > _gridCols) return true;
    if (_mY + _mHeight > _gridRows) return true;

    for (final cartRow in _cartLocalRows) {
      final absoluteRow = _mY + cartRow;
      if (cartRow < 0 || cartRow >= _mHeight) return true;
      if (absoluteRow < 0 || absoluteRow >= _gridRows) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gridColor = isDark ? const Color(0xFF503C34) : const Color(0xFFD7CCC8);
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.mechanismPlankSettings ?? 'Connected Minecart Settings',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_hasOutOfAreaWarning())
              _MechanismPlankWarningBanner(
                message: l10n?.mechanismPlankOutOfAreaWarning ??
                    'The current rail range may extend outside the playable area.',
              ),
            if (_hasOutOfAreaWarning()) const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StepperField(
                      label: l10n?.mechanismPlankStartColumn ?? 'Start Column',
                      value: _mX,
                      min: 0,
                      max: _maxMX,
                      onChanged: _setMX,
                    ),
                    const SizedBox(height: 12),
                    _StepperField(
                      label: l10n?.mechanismPlankTrackLength ?? 'Track Length',
                      value: _mWidth,
                      min: 1,
                      max: _maxWidth,
                      onChanged: _setMWidth,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MechanismPlankInfoBanner(
              message: l10n?.mechanismPlankEditNotice ??
                  'Only mX and mWidth are editable. Other parameters are preserved because changing them may cause in-game layout bugs.',
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              desktopScale: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: gridColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: AspectRatio(
                  aspectRatio: _gridCols / _gridRows,
                  child: Column(
                    children: List.generate(_gridRows, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(_gridCols, (c) {
                            final hasRail = _hasRailAt(c, r);
                            final hasCart = _hasCartAt(c, r);

                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: borderColor,
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: borderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (hasRail)
                                      Positioned.fill(
                                        child: Opacity(
                                          opacity: 0.85,
                                          child: AssetImageWidget(
                                            assetPath: _railsAssetPath,
                                            altCandidates: imageAltCandidates(
                                              _railsAssetPath,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (hasCart)
                                      Positioned.fill(
                                        child: Center(
                                          child: Transform.scale(
                                            scale: 0.9,
                                            child: AssetImageWidget(
                                              assetPath: _cartAssetPathForColumn(c),
                                              altCandidates: imageAltCandidates(
                                                _cartAssetPathForColumn(c),
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = value > min;
    final canIncrease = value < max;

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        IconButton(
          onPressed: canDecrease ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          onPressed: canIncrease ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}


class _MechanismPlankInfoBanner extends StatelessWidget {
  const _MechanismPlankInfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? pvzLightOrangeDark : pvzLightOrangeLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MechanismPlankWarningBanner extends StatelessWidget {
  const _MechanismPlankWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
