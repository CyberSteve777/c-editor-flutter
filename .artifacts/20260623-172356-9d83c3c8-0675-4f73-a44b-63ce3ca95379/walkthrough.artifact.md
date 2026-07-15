# Redesign Export Screen UI and Fix Backup Logic

I have successfully redesigned the Export screen to align with the Main Menu's design and fixed the backup file naming convention.

## Changes Overview

### UI Redesign & Refinements
- **Breadcrumb Navigation**: Replaced the static path text with a scrollable breadcrumb bar for quick navigation.
- **Card-Based File List**: Redesigned the list to match the "My Levels" screen, including:
    - **Extension Subtitles**: File formats (like `.rsb.smf`) are now shown as subtitles.
    - **Consistent Icons**: `.rsb.smf` files use the "inventory" icon, matching their appearance in the main menu.
    - **Conditional Chevrons**: Navigation arrows (chevrons) now only appear for folders.
- **Improved Selection UX**:
    - **In-List Selection**: Selecting a file now marks it with a checkmark and a primary-colored border directly in the list.
    - **Streamlined Workflow**: Removed the separate "File Selected" step; the "Confirm" button becomes active and colored once a file is selected.
    - **Back Button Logic**: The back button now deselects a file if one is selected, then navigates back through folders.

### Backup Logic Fix
- **Correct Naming**: Updated the `_createBackup` method to correctly handle `.rsb.smf` files. The backup suffix is now added *before* the extension (e.g., `level_copy.rsb.smf`) instead of splitting the extension.

## Verification Summary

### Automated Tests
- Ran `flutter analyze` via `analyze_file` tool to ensure no syntax errors or lint warnings remain.
- Verified that the new `_pathStack` structure is correctly used throughout the `ExportScreen`.

### Manual Verification
- **Visual Check**: Confirmed that `_ExportBreadcrumbBar` and `_ExportFileItemRow` use the same styling (padding, colors, icon sizes) as the original components in `level_list_screen.dart`.
- **Navigation Logic**: Verified `_loadDirectory`, `_navigateBack`, and `_breadcrumbTap` correctly manage the navigation history.
- **Backup Logic**: Confirmed the regex/substring logic correctly identifies `.rsb.smf` and inserts the suffix before it.

### Progress UI & Localization
- **Informative Dialogs**: The backup process now uses a dedicated title ("Creating backup..." / "Создание резервной копии...") instead of "Building export".
- **Full Localization**: Added the `backupProgressTitle` key to English, Russian, and Chinese localization files (`.arb` and generated `.dart` files).
- **Auto-Refresh**: The file list now automatically refreshes immediately after a backup is created, ensuring the new file is visible without manual action.
- **Improved Feedback**: Integrated `AppMessage` to show success/error status after completion.
