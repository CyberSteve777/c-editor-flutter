import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/screens/select/music_suffix_selection_screen.dart';
import 'package:c_editor/screens/select/stage_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await MusicSuffixCatalog.init();
    await StageRepository.init();
    await CustomStagePresetRepository.init();
  });

  Future<void> setNarrowView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget maxTextApp(Widget home) {
    return MaterialApp(
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        );
      },
      home: home,
    );
  }

  testWidgets('lawn and music grids contain maximum-scale text', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      maxTextApp(
        StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          onStageSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      maxTextApp(
        MusicSuffixSelectionScreen(
          currentCodename: '',
          onCodenameSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preset custom lawns stack details below the image', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      maxTextApp(
        StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          onStageSelected: (_) {},
          onBack: () {},
          onCreateCustomStage: () {},
          onCreateCustomStageFromPreset: (_) async => null,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    final preset = CustomStagePresetRepository.presets.first;
    await tester.scrollUntilVisible(
      find.text(preset.alias),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    final iconRect = tester.getRect(find.byType(AssetImageWidget).first);
    final aliasRect = tester.getRect(find.text(preset.alias));
    expect(aliasRect.top, greaterThan(iconRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom portal animation uses the separated picker', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomPortalPropertiesScreen(
          levelFile: PvzLevelFile(objects: []),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SeparatedOptionPickerField<String>), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
