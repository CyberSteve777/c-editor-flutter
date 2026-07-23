# Implementation Plan - Level Export: Level Selection Step

Add a second step to the level export process that allows users to select which levels (.json and .rton files) they want to export after they have chosen a target level archive (.rsb.smf).

## User Review Required

> [!NOTE]
> The level selection step will use multi-selection. Tapping a file toggles its selection state, while tapping a folder navigates into it.

## Proposed Changes

### Localization

Add a new localization key for the level selection step description.

#### [app_en.arb](file:///C:/Users/1/StudioProjects/zov-editor-flutter/assets/l10n/app_en.arb)
- Add `"exportSelectLevels": "Select levels to export"`

#### [app_ru.arb](file:///C:/Users/1/StudioProjects/zov-editor-flutter/assets/l10n/app_ru.arb)
- Add `"exportSelectLevels": "Выберите уровни для экспорта"`

#### [app_zh.arb](file:///C:/Users/1/StudioProjects/zov-editor-flutter/assets/l10n/app_zh.arb)
- Add `"exportSelectLevels": "选择要导出的关卡"`

---

### Export Screen

Modify `ExportScreen` to handle the new `selectingLevels` step and implement multi-selection logic.

#### [export_screen.dart](file:///C:/Users/1/StudioProjects/zov-editor-flutter/lib/screens/export/export_screen.dart)

- Update `ExportStep` enum to include `selectingLevels`.
- Rename `selectingFile` to `selectingArchive` for clarity.
- Add `Set<String> _selectedLevelPaths = {}` to `_ExportScreenState`.
- Update `_loadDirectory` to filter files based on the current step:
    - `selectingArchive`: `.rsb.smf` files.
    - `selectingLevels`: `.json` and `.rton` files.
- Update `_buildStepContent` to:
    - Display the correct title/subtitle for each step.
    - Handle multi-selection for levels.
    - Transition from `selectingArchive` to `selectingLevels` after the backup dialog.
- Update `_onWillPop` to handle navigation between steps.
- Update the "Proceed" button to:
    - Be enabled only when at least one level is selected in the `selectingLevels` step.
    - Call `_finishExport()` (which pops the screen) when the "Proceed" button is clicked in the `selectingLevels` step.

```diff
-enum ExportStep { disclaimer, selectingFile }
+enum ExportStep { disclaimer, selectingArchive, selectingLevels }

 class _ExportScreenState extends State<ExportScreen> {
-  String? _selectedFilePath;
+  String? _selectedArchivePath;
+  final Set<String> _selectedLevelPaths = {};
   bool _noFilesFound = false;
   ExportStep _currentStep = ExportStep.disclaimer;
```

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no regressions.
- (Optional) If there are existing export tests, run them: `flutter test test/screens/export_screen_test.dart` (I'll check if it exists).

### Manual Verification
1. Open the **Export** screen.
2. Click **Proceed** on the Disclaimer.
3. Verify that the list shows only folders and `.rsb.smf` files.
4. Select an archive and click **Proceed**.
5. Choose whether to backup or not.
6. Verify that the screen transitions to the **Level Selection** step.
7. Verify that the list now shows only folders and `.json`/`.rton` files.
8. Verify that tapping multiple levels selects them (shows checkmark).
9. Verify that tapping a folder navigates into it.
10. Verify that clicking **Proceed** closes the screen.
11. Test the back button: it should navigate back to archive selection if at the root of level selection.
