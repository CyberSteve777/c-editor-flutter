# Task Management

- [ ] Fix 6x10 grid initialization issue
    - [ ] Add `ReferenceRepository.init()` to `LevelPreviewDialog` initialization
- [ ] Fix text color visibility issues
    - [ ] Audit `onSurface` usage with low alpha in `Heian Wind`, `Vasebreaker`, and `Summary` cards
    - [ ] Ensure `Challenge Details` dialogs use theme-appropriate colors
- [ ] Refactor tab switchers
    - [ ] Remove padding from `_buildPrePlacedTabSwitcher`, `_buildPlantTypeTabSwitcher`, `_buildSubCategoryHeader`
    - [ ] Move scrollbars directly under the switchers
- [ ] Fix layout overflow errors
    - [ ] Investigate line 2623 (Modules card)
    - [ ] Investigate line 2089 (PrePlaced card)
    - [ ] Investigate line 2562 (Chip list section)
    - [ ] Investigate line 1987 (PrePlaced card)
- [ ] Sync Challenge Details dialogs with themes and scales
