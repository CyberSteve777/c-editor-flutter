# Level Preview Fixes Walkthrough

I have addressed all the issues reported in the screenshots and the user list.

## Changes Implemented

### 1. 6x10 Grid Support
- Added `ReferenceRepository.init()` to the `LevelPreviewDialog` initialization. This ensures that stage data is correctly resolved even before entering the level editor, allowing the 6x10 grid (Deep Sea) to display immediately.

### 2. Text Visibility Improvements
- Audited all cards in the preview dialog and increased text visibility.
- Replaced low-alpha `onSurface` colors (0.4/0.5) with higher alpha (0.8/0.9) or explicit `onSurface` to ensure contrast on all backgrounds.
- Specifically fixed the Heian Wind, Vasebreaker, and Summary cards.

### 3. Tab Switcher Refactoring
- Restored the main category tabs (Plants, Zombies, etc.) to their original layout position alongside the "Placement" title.
- Properly implemented the external scrollbar pattern for **all** pill switchers (Main Categories, Plant Types, and Wave Sub-categories).
- Each pill list now has a dedicated, thin scrollbar area located strictly **underneath** the buttons.
- Both the button list and the underlying scrollbar share the same `ScrollController`, ensuring synchronized movement without any visual stretching or text obstruction.
- On mobile devices, these underlying scrollbar areas are completely removed for a cleaner look.

### 4. Layout Overflow Fixes
- Resolved several `RenderFlex` overflow errors reported in the console.
- Used `LayoutBuilder` with `Column` fallbacks for headers (Summary, Encounter, Modules cards) when the screen width is constrained.
- Applied `Flexible` and `Expanded` to text and icon elements in rows to prevent them from pushing beyond the available space.

### 5. Challenge Details Theme Synchronization
- Updated the Challenge Details dialogs to properly use `Theme.of(context)`.
- Ensured all text elements use `theme.colorScheme.onSurface` and respect the active theme (Light/Dark).
- Improved the responsiveness of the detail dialogs for different device scales.

### 6. Level Timer Display Fix
- Updated `ResourceChip` logic for the Level Timer to always show the time value (e.g., "120s") even on desktop platforms. Previously, this label was hidden on desktop to save space, but since it represents critical level configuration data, it is now visible.
### 7. Object Count Badge Scaling
- Implemented **inverse scaling** for the `ObjectCountBadge` (the "+N" indicator in grid cells).
- On small grids (e.g., mobile devices), the badge now grows relatively larger to remain readable.
- On large grids (e.g., desktop at max scale), the badge stays small and is pinned to the exact corner (`top: 1, right: 1`) to avoid covering the plant or zombie icon.
- Removed system `textScale` dependency from the badge to prevent it from overlapping content when large accessibility fonts are enabled.

### 8. Scrollbar Visibility on Mobile
- Configured all `Scrollbar` widgets in the Level Preview to hide the thumb on mobile devices (`Android`, `iOS`).
- On desktop platforms, the scrollbars remain visible for better navigation, but on mobile, they are now completely hidden to provide a cleaner UI, as requested.

## Verification Summary
- Static analysis via `analyze_file` passed with no errors.
- All reported code paths were manually reviewed for theme compliance and layout safety.
