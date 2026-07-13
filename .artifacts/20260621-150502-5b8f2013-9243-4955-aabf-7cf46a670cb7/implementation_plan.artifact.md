# Fix UI Overflow in Level Preview

This plan addresses several UI overflow issues in the level preview dialog, ensuring it looks good on mobile devices and various scaling levels.

## User Review Required

> [!NOTE]
> I will be making some layout changes that might slightly change the look on very narrow screens (e.g., stacking the sidebar vertically instead of horizontally).

## Proposed Changes

### Level Preview Dialog

#### [level_preview_dialog.dart](file:///C:/Users/1/StudioProjects/zov-editor-flutter/lib/screens/common/level_preview_dialog.dart)

- **Title Row**: Wrap the level filename in `Expanded` with `TextOverflow.ellipsis` to prevent pushing the close button off-screen.
- **Summary Card**:
    - Ensure labels and values are wrapped in `Flexible` or `Expanded` where necessary.
    - Improve the "legend" display at the bottom for mobile.
- **Seed Bank Card**:
    - Wrap the "Plant level" text in `Expanded` to prevent horizontal overflow when "Level 0 plants use their corresponding..." is displayed.
- **Pre-placed Card (Tabs)**:
    - Wrap `_buildPrePlacedTabSwitcher` and `_buildPlantTypeTabSwitcher` content in `SingleChildScrollView(scrollDirection: Axis.horizontal)` to allow scrolling if tabs exceed screen width.
- **Responsive Layout**:
    - Modify `_buildPrePlacedCard` to use a vertical layout (sidebar above grid) on narrow screens (e.g., width < 600) instead of a horizontal `Row`.
- **Modules Card**:
    - Ensure status icons and feature list don't overflow by using `Flexible` and `Wrap` appropriately.

## Verification Plan

### Manual Verification
- Run the app on a mobile emulator or physical device.
- Open the level preview for `2_card_pick_example.json` (and other levels with many modules).
- Verify that no horizontal overflow indicators (yellow/black stripes) are visible.
- Test with different UI scaling settings (if available in the app) to ensure responsiveness.
- Verify that the tab bar in the "Placement" section is scrollable if it doesn't fit the width.
