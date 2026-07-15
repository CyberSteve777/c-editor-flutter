# Task Management

- [x] Add localization for level selection step
- [x] Implement `selectingLevels` step in `ExportScreen`
    - [x] Update `ExportStep` enum and state
    - [x] Update file filtering in `_loadDirectory`
    - [x] Implement multi-selection logic in `_buildStepContent`
    - [x] Update transition from archive selection to level selection
    - [x] Update navigation and "Proceed" button logic
- [x] Fix initial visibility bug (files not showing on first load)
- [x] Fix back button behavior (return to disclaimer from archive root)
- [/] Verify implementation
    - [x] Code review and manual logic check
    - [ ] Run `flutter gen-l10n` (Waiting for environment or user)
    - [ ] Run `flutter analyze` (Waiting for environment or user)
