import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Level Library'**
  String get appTitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @switchFolder.
  ///
  /// In en, this message translates to:
  /// **'Switch folder'**
  String get switchFolder;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get ultra;

  /// No description provided for @uiSize.
  ///
  /// In en, this message translates to:
  /// **'UI size'**
  String get uiSize;

  /// No description provided for @plantTagInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get plantTagInternational;

  /// No description provided for @plantTagChinese.
  ///
  /// In en, this message translates to:
  /// **'China Only'**
  String get plantTagChinese;

  /// No description provided for @aboutSoftware.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSoftware;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// The caption text included when sharing a level file via the system share sheet
  ///
  /// In en, this message translates to:
  /// **'Level file: {name}'**
  String shareLevelFileText(String name);

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get selectFolder;

  /// No description provided for @storagePermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required. Enable \"Allow access to manage all files\" in Settings to open level files.'**
  String get storagePermissionHint;

  /// No description provided for @storagePermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get storagePermissionDialogTitle;

  /// No description provided for @storagePermissionDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This app requires external storage access to open and save level files. Please turn on \"Allow access to manage all files\" in Settings.'**
  String get storagePermissionDialogMessage;

  /// No description provided for @storagePermissionGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get storagePermissionGoToSettings;

  /// No description provided for @storagePermissionDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get storagePermissionDeny;

  /// No description provided for @initSetup.
  ///
  /// In en, this message translates to:
  /// **'Initial setup'**
  String get initSetup;

  /// No description provided for @selectFolderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a folder as the level storage directory.'**
  String get selectFolderPrompt;

  /// No description provided for @selectFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get selectFolderButton;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @levelLibraryPath.
  ///
  /// In en, this message translates to:
  /// **'Level library folder'**
  String get levelLibraryPath;

  /// No description provided for @levelLibraryPathHint.
  ///
  /// In en, this message translates to:
  /// **'Levels are stored in this folder. On iOS you can pick any folder; access is saved so it persists after restart.'**
  String get levelLibraryPathHint;

  /// No description provided for @pathCopied.
  ///
  /// In en, this message translates to:
  /// **'Path copied to clipboard'**
  String get pathCopied;

  /// No description provided for @useDefaultLibraryFolder.
  ///
  /// In en, this message translates to:
  /// **'Use default folder'**
  String get useDefaultLibraryFolder;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty'**
  String get emptyFolder;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @newLevel.
  ///
  /// In en, this message translates to:
  /// **'New level'**
  String get newLevel;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @convertHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertHelpTooltip;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? {detail}'**
  String confirmDeleteMessage(Object detail, Object name);

  /// No description provided for @folderDeleteDetail.
  ///
  /// In en, this message translates to:
  /// **'If it is a folder, its contents will also be deleted.'**
  String get folderDeleteDetail;

  /// No description provided for @levelDeleteDetail.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get levelDeleteDetail;

  /// No description provided for @confirmDeleteCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm permanent deletion'**
  String get confirmDeleteCheckbox;

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully renamed'**
  String get renameSuccess;

  /// No description provided for @renameFail.
  ///
  /// In en, this message translates to:
  /// **'Rename failed, file already exists'**
  String get renameFail;

  /// No description provided for @uploadLevel.
  ///
  /// In en, this message translates to:
  /// **'Upload to Creative Courtyard'**
  String get uploadLevel;

  /// No description provided for @uploadLevelConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are about to leave the editor and open the official Advanced Creation Courtyard Creator Hub website. After signing in with your email account, you can upload JSON level files from the editor to the in-game Creative Courtyard for other players to enjoy. Do you want to continue?'**
  String get uploadLevelConfirm;

  /// No description provided for @noLevelsFound.
  ///
  /// In en, this message translates to:
  /// **'No levels found'**
  String get noLevelsFound;

  /// No description provided for @searchLevel.
  ///
  /// In en, this message translates to:
  /// **'Search levels...'**
  String get searchLevel;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get proceed;

  /// No description provided for @copyReferenceOrDeep.
  ///
  /// In en, this message translates to:
  /// **'Copy reference or make a deep copy?'**
  String get copyReferenceOrDeep;

  /// No description provided for @copyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get copyReference;

  /// No description provided for @deepCopy.
  ///
  /// In en, this message translates to:
  /// **'Deep copy'**
  String get deepCopy;

  /// No description provided for @discordLabel.
  ///
  /// In en, this message translates to:
  /// **'Our Discord server:'**
  String get discordLabel;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @allLevelsCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLevelsCategory;

  /// No description provided for @favoritesCategory.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesCategory;

  /// No description provided for @newFolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for default name'**
  String get newFolderNameHint;

  /// No description provided for @emptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any favorite levels yet'**
  String get emptyFavorites;

  /// No description provided for @copyEventTarget.
  ///
  /// In en, this message translates to:
  /// **'Target wave'**
  String get copyEventTarget;

  /// No description provided for @targetWaveIndex.
  ///
  /// In en, this message translates to:
  /// **'Target wave number'**
  String get targetWaveIndex;

  /// No description provided for @moveToWaveIndex.
  ///
  /// In en, this message translates to:
  /// **'Move to wave number'**
  String get moveToWaveIndex;

  /// No description provided for @invalidWaveIndex.
  ///
  /// In en, this message translates to:
  /// **'Invalid wave number'**
  String get invalidWaveIndex;

  /// No description provided for @renamingFailed.
  ///
  /// In en, this message translates to:
  /// **'Renaming failed'**
  String get renamingFailed;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @copyLevel.
  ///
  /// In en, this message translates to:
  /// **'Copy level'**
  String get copyLevel;

  /// No description provided for @newFileName.
  ///
  /// In en, this message translates to:
  /// **'New file name'**
  String get newFileName;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied successfully'**
  String get copySuccess;

  /// No description provided for @copyFail.
  ///
  /// In en, this message translates to:
  /// **'Copy failed'**
  String get copyFail;

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'Moving: {name}'**
  String moving(Object name);

  /// No description provided for @movePrompt.
  ///
  /// In en, this message translates to:
  /// **'Navigate to target folder, then tap Paste'**
  String get movePrompt;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @movingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Moved successfully'**
  String get movingSuccess;

  /// No description provided for @movingFail.
  ///
  /// In en, this message translates to:
  /// **'Move failed'**
  String get movingFail;

  /// No description provided for @moveSameFolder.
  ///
  /// In en, this message translates to:
  /// **'Source and destination folders are the same'**
  String get moveSameFolder;

  /// No description provided for @moveFileExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'File already exists'**
  String get moveFileExistsTitle;

  /// No description provided for @moveFileExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'A file with this name already exists in the destination folder.'**
  String get moveFileExistsMessage;

  /// No description provided for @moveOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get moveOverwrite;

  /// No description provided for @fileOverwritten.
  ///
  /// In en, this message translates to:
  /// **'File was overwritten: {name}'**
  String fileOverwritten(Object name);

  /// No description provided for @moveSaveAsCopy.
  ///
  /// In en, this message translates to:
  /// **'Save as copy'**
  String get moveSaveAsCopy;

  /// No description provided for @moveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get moveCancelled;

  /// No description provided for @movedAs.
  ///
  /// In en, this message translates to:
  /// **'Moved and saved as {name}'**
  String movedAs(Object name);

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get folderCreated;

  /// No description provided for @createFail.
  ///
  /// In en, this message translates to:
  /// **'Create failed'**
  String get createFail;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get noTemplates;

  /// No description provided for @newLevelTemplate.
  ///
  /// In en, this message translates to:
  /// **'New level - Select template'**
  String get newLevelTemplate;

  /// No description provided for @nameLevel.
  ///
  /// In en, this message translates to:
  /// **'Name level'**
  String get nameLevel;

  /// No description provided for @levelCreated.
  ///
  /// In en, this message translates to:
  /// **'Level created'**
  String get levelCreated;

  /// No description provided for @levelCreateFail.
  ///
  /// In en, this message translates to:
  /// **'Create failed, file already exists'**
  String get levelCreateFail;

  /// No description provided for @adjustUiSize.
  ///
  /// In en, this message translates to:
  /// **'Adjust UI size'**
  String get adjustUiSize;

  /// No description provided for @currentScale.
  ///
  /// In en, this message translates to:
  /// **'Current scale: {percent}%'**
  String currentScale(Object percent);

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {count} cached files'**
  String cacheCleared(Object count);

  /// No description provided for @returnUp.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get returnUp;

  /// No description provided for @jsonFile.
  ///
  /// In en, this message translates to:
  /// **'JSON file'**
  String get jsonFile;

  /// No description provided for @convertToJson.
  ///
  /// In en, this message translates to:
  /// **'Convert to JSON'**
  String get convertToJson;

  /// No description provided for @convertToHotUpdateJson.
  ///
  /// In en, this message translates to:
  /// **'Convert to hot update json'**
  String get convertToHotUpdateJson;

  /// No description provided for @convertToEncryptedRton.
  ///
  /// In en, this message translates to:
  /// **'Convert to encrypted rton'**
  String get convertToEncryptedRton;

  /// No description provided for @conversionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversion required'**
  String get conversionRequiredTitle;

  /// No description provided for @conversionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This file must be converted to JSON before it can be opened in the editor.'**
  String get conversionRequiredMessage;

  /// No description provided for @convertAction.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertAction;

  /// No description provided for @conversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get conversionFailed;

  /// No description provided for @convertedMessage.
  ///
  /// In en, this message translates to:
  /// **'Converted: {name}'**
  String convertedMessage(Object name);

  /// No description provided for @softwareIntro.
  ///
  /// In en, this message translates to:
  /// **'Software intro'**
  String get softwareIntro;

  /// No description provided for @cEditor.
  ///
  /// In en, this message translates to:
  /// **'C-Editor'**
  String get cEditor;

  /// No description provided for @pvzEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PVZ2 Visual Level Editor'**
  String get pvzEditorSubtitle;

  /// No description provided for @introSection.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introSection;

  /// No description provided for @introText.
  ///
  /// In en, this message translates to:
  /// **'C-Editor is a visual level editing tool designed for Plants vs. Zombies 2 Chinese Edition. It aims to simplify editing level JSON files with an intuitive interface.'**
  String get introText;

  /// No description provided for @featuresSection.
  ///
  /// In en, this message translates to:
  /// **'Core features'**
  String get featuresSection;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'Modular editing: Manage level modules and events.'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'Multi-mode: I, Zombie, Vasebreaker, Last Stand, ZombossMech battle, and more.'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'Custom zombies: Inject and edit custom zombie properties.'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'Validation: Detect missing modules, broken references, and other issues.'**
  String get feature4;

  /// No description provided for @usageSection.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usageSection;

  /// No description provided for @usageText.
  ///
  /// In en, this message translates to:
  /// **'1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Tap a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Tap save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Tap the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.'**
  String get usageText;

  /// No description provided for @usageTextDesktop.
  ///
  /// In en, this message translates to:
  /// **'1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Click a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Click save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Tap the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.'**
  String get usageTextDesktop;

  /// No description provided for @usageTextMobile.
  ///
  /// In en, this message translates to:
  /// **'1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Tap a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Tap save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Tap the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.'**
  String get usageTextMobile;

  /// No description provided for @usageRecommendedLevelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Creative Courtyard · Recommended Levels Showcase:'**
  String get usageRecommendedLevelsLabel;

  /// No description provided for @discordInviteLabel.
  ///
  /// In en, this message translates to:
  /// **'Plants vs. Zombies Discord server invite link:'**
  String get discordInviteLabel;

  /// No description provided for @cEditorInviteLabel.
  ///
  /// In en, this message translates to:
  /// **'C-Editor Discord server invite link:'**
  String get cEditorInviteLabel;

  /// No description provided for @linksSubsection.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksSubsection;

  /// No description provided for @creditsSection.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsSection;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get authorLabel;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'CyberSteve777'**
  String get authorName;

  /// No description provided for @thanksLabel.
  ///
  /// In en, this message translates to:
  /// **'Special thanks:'**
  String get thanksLabel;

  /// No description provided for @thanksNames.
  ///
  /// In en, this message translates to:
  /// **'Devourdoom, Chara, Evilhack28, Rebus, KL12, vi_i_guess, Haruma, nineteendo'**
  String get thanksNames;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository:'**
  String get sourceLabel;

  /// No description provided for @issuesLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Issues:'**
  String get issuesLabel;

  /// No description provided for @zEditorAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'We would also like to express our sincere gratitude to the creators of Z-Editor. The development of this tool would not have been possible without the foundation they established.'**
  String get zEditorAcknowledgment;

  /// No description provided for @zEditorCreditsSubsection.
  ///
  /// In en, this message translates to:
  /// **'Z-Editor credits'**
  String get zEditorCreditsSubsection;

  /// No description provided for @zEditorAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get zEditorAuthorLabel;

  /// No description provided for @zEditorAuthorName.
  ///
  /// In en, this message translates to:
  /// **'降维打击'**
  String get zEditorAuthorName;

  /// No description provided for @zEditorThanksLabel.
  ///
  /// In en, this message translates to:
  /// **'Special thanks:'**
  String get zEditorThanksLabel;

  /// No description provided for @zEditorThanksNames.
  ///
  /// In en, this message translates to:
  /// **'星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名'**
  String get zEditorThanksNames;

  /// No description provided for @zEditorQqGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Z-Editor QQ group:'**
  String get zEditorQqGroupLabel;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Create infinite possibilities'**
  String get tagline;

  /// No description provided for @editorVersion.
  ///
  /// In en, this message translates to:
  /// **'Editor version: {version}'**
  String editorVersion(String version);

  /// No description provided for @supportedGameVersion.
  ///
  /// In en, this message translates to:
  /// **'Supported game version: {version}'**
  String supportedGameVersion(String version);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @templateBlankLevel.
  ///
  /// In en, this message translates to:
  /// **'Blank level'**
  String get templateBlankLevel;

  /// No description provided for @templateCardPickExample.
  ///
  /// In en, this message translates to:
  /// **'Regular level template'**
  String get templateCardPickExample;

  /// No description provided for @templateConveyorExample.
  ///
  /// In en, this message translates to:
  /// **'Conveyor-belt level template'**
  String get templateConveyorExample;

  /// No description provided for @templateLastStandExample.
  ///
  /// In en, this message translates to:
  /// **'Last Stand level template'**
  String get templateLastStandExample;

  /// No description provided for @templateIZombieExample.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie level template'**
  String get templateIZombieExample;

  /// No description provided for @templateVaseBreakerExample.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker level template'**
  String get templateVaseBreakerExample;

  /// No description provided for @templateZombossMechExample.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech battle level template'**
  String get templateZombossMechExample;

  /// No description provided for @templateZombossBattleExample.
  ///
  /// In en, this message translates to:
  /// **'Zomboss battle level template'**
  String get templateZombossBattleExample;

  /// No description provided for @templateCustomZombieExample.
  ///
  /// In en, this message translates to:
  /// **'Custom zombie level template'**
  String get templateCustomZombieExample;

  /// No description provided for @templateIPlantExample.
  ///
  /// In en, this message translates to:
  /// **'I, Plant level template'**
  String get templateIPlantExample;

  /// No description provided for @templateOldStyleExample.
  ///
  /// In en, this message translates to:
  /// **'Old-style level'**
  String get templateOldStyleExample;

  /// No description provided for @templateCustomStageExample.
  ///
  /// In en, this message translates to:
  /// **'Custom stage level template'**
  String get templateCustomStageExample;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @saveBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'Save before leaving?'**
  String get saveBeforeLeaving;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @stayInEditor.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayInEditor;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @failedToLoadLevel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load level'**
  String get failedToLoadLevel;

  /// No description provided for @noLevelDefinition.
  ///
  /// In en, this message translates to:
  /// **'No level definition'**
  String get noLevelDefinition;

  /// No description provided for @noLevelDefinitionHint.
  ///
  /// In en, this message translates to:
  /// **'Level definition module (LevelDefinition) was not found. This is the base node of the level file. Try adding it manually.'**
  String get noLevelDefinitionHint;

  /// No description provided for @levelBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get levelBasicInfo;

  /// No description provided for @levelBasicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, Index, Description, Lawn'**
  String get levelBasicInfoSubtitle;

  /// No description provided for @removeModule.
  ///
  /// In en, this message translates to:
  /// **'Remove module'**
  String get removeModule;

  /// No description provided for @zombieCategoryMain.
  ///
  /// In en, this message translates to:
  /// **'By World'**
  String get zombieCategoryMain;

  /// No description provided for @zombieCategorySize.
  ///
  /// In en, this message translates to:
  /// **'By Size'**
  String get zombieCategorySize;

  /// No description provided for @zombieCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get zombieCategoryOther;

  /// No description provided for @zombieCategoryCollection.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get zombieCategoryCollection;

  /// No description provided for @zombieTagAll.
  ///
  /// In en, this message translates to:
  /// **'All Zombies'**
  String get zombieTagAll;

  /// No description provided for @zombieTagEgyptPirate.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt / Pirate Seas'**
  String get zombieTagEgyptPirate;

  /// No description provided for @zombieTagWestFuture.
  ///
  /// In en, this message translates to:
  /// **'Wild West / Far Future'**
  String get zombieTagWestFuture;

  /// No description provided for @zombieTagDarkBeach.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages / Big Wave Beach'**
  String get zombieTagDarkBeach;

  /// No description provided for @zombieTagIceageLostcity.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves / Lost City'**
  String get zombieTagIceageLostcity;

  /// No description provided for @zombieTagKongfuSkycity.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World / Sky City'**
  String get zombieTagKongfuSkycity;

  /// No description provided for @zombieTagEightiesDino.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour / Jurassic Marsh'**
  String get zombieTagEightiesDino;

  /// No description provided for @zombieTagModernPvz1.
  ///
  /// In en, this message translates to:
  /// **'Modern Day / PvZ1'**
  String get zombieTagModernPvz1;

  /// No description provided for @zombieTagSteamRenai.
  ///
  /// In en, this message translates to:
  /// **'Steam Ages / Renaissance Ages'**
  String get zombieTagSteamRenai;

  /// No description provided for @zombieTagHenaiAtlantis.
  ///
  /// In en, this message translates to:
  /// **'Heian Ages / Underwater World'**
  String get zombieTagHenaiAtlantis;

  /// No description provided for @zombieTagTaleZCorp.
  ///
  /// In en, this message translates to:
  /// **'Fairytale Forest / ZCorp Takeover'**
  String get zombieTagTaleZCorp;

  /// No description provided for @zombieTagParkourSpeed.
  ///
  /// In en, this message translates to:
  /// **'Parkour Party / Speed Racing'**
  String get zombieTagParkourSpeed;

  /// No description provided for @zombieTagTothewest.
  ///
  /// In en, this message translates to:
  /// **'Journey to the West / Underground Palace'**
  String get zombieTagTothewest;

  /// No description provided for @zombieTagMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane'**
  String get zombieTagMemory;

  /// No description provided for @zombieTagUniverse.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe'**
  String get zombieTagUniverse;

  /// No description provided for @zombieTagFestival1.
  ///
  /// In en, this message translates to:
  /// **'Festival 1'**
  String get zombieTagFestival1;

  /// No description provided for @zombieTagFestival2.
  ///
  /// In en, this message translates to:
  /// **'Festival 2'**
  String get zombieTagFestival2;

  /// No description provided for @zombieTagRoman.
  ///
  /// In en, this message translates to:
  /// **'Ancient Rome'**
  String get zombieTagRoman;

  /// No description provided for @zombieTagCustom.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane Variants'**
  String get zombieTagCustom;

  /// No description provided for @zombieTagPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get zombieTagPet;

  /// No description provided for @zombieTagImp.
  ///
  /// In en, this message translates to:
  /// **'Imp'**
  String get zombieTagImp;

  /// No description provided for @zombieTagBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get zombieTagBasic;

  /// No description provided for @zombieTagFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get zombieTagFat;

  /// No description provided for @zombieTagStrong.
  ///
  /// In en, this message translates to:
  /// **'Bully'**
  String get zombieTagStrong;

  /// No description provided for @zombieTagGargantuar.
  ///
  /// In en, this message translates to:
  /// **'Gargantuar'**
  String get zombieTagGargantuar;

  /// No description provided for @zombieTagElite.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get zombieTagElite;

  /// No description provided for @zombieTagEvildave.
  ///
  /// In en, this message translates to:
  /// **'Compatible with IZ'**
  String get zombieTagEvildave;

  /// No description provided for @plantCategoryQuality.
  ///
  /// In en, this message translates to:
  /// **'By Quality'**
  String get plantCategoryQuality;

  /// No description provided for @plantCategoryRole.
  ///
  /// In en, this message translates to:
  /// **'By Role'**
  String get plantCategoryRole;

  /// No description provided for @plantCategoryAttribute.
  ///
  /// In en, this message translates to:
  /// **'By Attribute'**
  String get plantCategoryAttribute;

  /// No description provided for @plantCategoryWorld.
  ///
  /// In en, this message translates to:
  /// **'By World'**
  String get plantCategoryWorld;

  /// No description provided for @plantCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get plantCategoryOther;

  /// No description provided for @plantCategoryCollection.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get plantCategoryCollection;

  /// No description provided for @plantTagAll.
  ///
  /// In en, this message translates to:
  /// **'All Plants'**
  String get plantTagAll;

  /// No description provided for @plantTagWhite.
  ///
  /// In en, this message translates to:
  /// **'White Quality'**
  String get plantTagWhite;

  /// No description provided for @plantTagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Quality'**
  String get plantTagGreen;

  /// No description provided for @plantTagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Quality'**
  String get plantTagBlue;

  /// No description provided for @plantTagPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Quality'**
  String get plantTagPurple;

  /// No description provided for @plantTagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Quality'**
  String get plantTagOrange;

  /// No description provided for @plantTagRed.
  ///
  /// In en, this message translates to:
  /// **'Red Quality'**
  String get plantTagRed;

  /// No description provided for @plantTagSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get plantTagSupport;

  /// No description provided for @plantTagRanger.
  ///
  /// In en, this message translates to:
  /// **'Ranged'**
  String get plantTagRanger;

  /// No description provided for @plantTagSunProducer.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get plantTagSunProducer;

  /// No description provided for @plantTagDefence.
  ///
  /// In en, this message translates to:
  /// **'Tough'**
  String get plantTagDefence;

  /// No description provided for @plantTagVanguard.
  ///
  /// In en, this message translates to:
  /// **'Vanguard'**
  String get plantTagVanguard;

  /// No description provided for @plantTagTrapper.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get plantTagTrapper;

  /// No description provided for @plantTagFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get plantTagFire;

  /// No description provided for @plantTagIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get plantTagIce;

  /// No description provided for @plantTagMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get plantTagMagic;

  /// No description provided for @plantTagPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get plantTagPoison;

  /// No description provided for @plantTagElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get plantTagElectric;

  /// No description provided for @plantTagPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get plantTagPhysical;

  /// No description provided for @plantTagWorldTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get plantTagWorldTutorial;

  /// No description provided for @plantTagWorldEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt'**
  String get plantTagWorldEgypt;

  /// No description provided for @plantTagWorldPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas'**
  String get plantTagWorldPirate;

  /// No description provided for @plantTagWorldWildWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West'**
  String get plantTagWorldWildWest;

  /// No description provided for @plantTagWorldKongfu.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World'**
  String get plantTagWorldKongfu;

  /// No description provided for @plantTagWorldFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future'**
  String get plantTagWorldFuture;

  /// No description provided for @plantTagWorldDarkAges.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages'**
  String get plantTagWorldDarkAges;

  /// No description provided for @plantTagWorldBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach'**
  String get plantTagWorldBeach;

  /// No description provided for @plantTagWorldIceage.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves'**
  String get plantTagWorldIceage;

  /// No description provided for @plantTagWorldSkycity.
  ///
  /// In en, this message translates to:
  /// **'Sky City'**
  String get plantTagWorldSkycity;

  /// No description provided for @plantTagWorldLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City'**
  String get plantTagWorldLostCity;

  /// No description provided for @plantTagWorldEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour'**
  String get plantTagWorldEighties;

  /// No description provided for @plantTagWorldDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh'**
  String get plantTagWorldDino;

  /// No description provided for @plantTagWorldModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Day'**
  String get plantTagWorldModern;

  /// No description provided for @plantTagWorldSteam.
  ///
  /// In en, this message translates to:
  /// **'Steam Ages'**
  String get plantTagWorldSteam;

  /// No description provided for @plantTagWorldRenai.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Ages'**
  String get plantTagWorldRenai;

  /// No description provided for @plantTagWorldHeian.
  ///
  /// In en, this message translates to:
  /// **'Heian Ages'**
  String get plantTagWorldHeian;

  /// No description provided for @plantTagWorldAtlantis.
  ///
  /// In en, this message translates to:
  /// **'Underwater World'**
  String get plantTagWorldAtlantis;

  /// No description provided for @plantTagWorldFairytale.
  ///
  /// In en, this message translates to:
  /// **'Fairytale Forest'**
  String get plantTagWorldFairytale;

  /// No description provided for @plantTagWorldZcorp.
  ///
  /// In en, this message translates to:
  /// **'ZCorp Takeover'**
  String get plantTagWorldZcorp;

  /// No description provided for @plantTagWorldMausoleum.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace'**
  String get plantTagWorldMausoleum;

  /// No description provided for @plantTagOriginal.
  ///
  /// In en, this message translates to:
  /// **'PvZ1 Plants'**
  String get plantTagOriginal;

  /// No description provided for @plantTagParallel.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe'**
  String get plantTagParallel;

  /// No description provided for @plantTagSpecial.
  ///
  /// In en, this message translates to:
  /// **'Magic Hats'**
  String get plantTagSpecial;

  /// No description provided for @removeModuleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.'**
  String get removeModuleConfirm;

  /// No description provided for @confirmRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get confirmRemove;

  /// No description provided for @addModule.
  ///
  /// In en, this message translates to:
  /// **'Add module'**
  String get addModule;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Wave Timeline'**
  String get timeline;

  /// No description provided for @iZombie.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie'**
  String get iZombie;

  /// No description provided for @vaseBreaker.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker'**
  String get vaseBreaker;

  /// No description provided for @zombossMech.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech Battle'**
  String get zombossMech;

  /// No description provided for @zombossBattle.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Battle'**
  String get zombossBattle;

  /// No description provided for @moveSourceSameAsDest.
  ///
  /// In en, this message translates to:
  /// **'Source and target folder are the same'**
  String get moveSourceSameAsDest;

  /// No description provided for @moveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Moved successfully'**
  String get moveSuccess;

  /// No description provided for @moveFail.
  ///
  /// In en, this message translates to:
  /// **'Move failed'**
  String get moveFail;

  /// No description provided for @rootFolder.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get rootFolder;

  /// No description provided for @createEmptyWave.
  ///
  /// In en, this message translates to:
  /// **'Create empty wave'**
  String get createEmptyWave;

  /// No description provided for @createEmptyWaveContainer.
  ///
  /// In en, this message translates to:
  /// **'Create empty wave container'**
  String get createEmptyWaveContainer;

  /// No description provided for @deleteEmptyContainer.
  ///
  /// In en, this message translates to:
  /// **'Delete empty container'**
  String get deleteEmptyContainer;

  /// No description provided for @deleteWaveContainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wave container'**
  String get deleteWaveContainerTitle;

  /// No description provided for @deleteWaveContainerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the empty wave container? You can create a new one later.'**
  String get deleteWaveContainerConfirm;

  /// No description provided for @noWaveManager.
  ///
  /// In en, this message translates to:
  /// **'Wave Container Not Found'**
  String get noWaveManager;

  /// No description provided for @noWaveManagerHint.
  ///
  /// In en, this message translates to:
  /// **'Wave management is enabled, but the entity object (WaveManagerProperties) is missing. Please create an empty wave container.'**
  String get noWaveManagerHint;

  /// No description provided for @waveTimelineHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an event to edit it, or tap \"+\" to add a new one.'**
  String get waveTimelineHint;

  /// No description provided for @waveTimelineHintDetail.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on a wave to delete it.'**
  String get waveTimelineHintDetail;

  /// No description provided for @waveTimelineGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation Guide'**
  String get waveTimelineGuideTitle;

  /// No description provided for @waveTimelineGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe right: Manage wave events\nSwipe left: Delete a wave\nTap points: View spawn expectations'**
  String get waveTimelineGuideBody;

  /// No description provided for @waveTimelineGuideBodyDesktop.
  ///
  /// In en, this message translates to:
  /// **'Left-click a wave: Manage wave events\nClick delete: Remove a wave\nClick points: View spawn expectations'**
  String get waveTimelineGuideBodyDesktop;

  /// No description provided for @waveTimelineGuideBodyMobile.
  ///
  /// In en, this message translates to:
  /// **'Swipe right: Manage wave events\nSwipe left: Delete a wave\nTap points: View spawn expectations'**
  String get waveTimelineGuideBodyMobile;

  /// No description provided for @waveDeadLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Broken References'**
  String get waveDeadLinksTitle;

  /// No description provided for @waveDeadLinksClear.
  ///
  /// In en, this message translates to:
  /// **'Clear dead links'**
  String get waveDeadLinksClear;

  /// No description provided for @customZombieManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Zombie Management'**
  String get customZombieManagerTitle;

  /// No description provided for @customZombieEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom zombie data'**
  String get customZombieEmpty;

  /// No description provided for @switchCustomZombie.
  ///
  /// In en, this message translates to:
  /// **'Switch custom zombie'**
  String get switchCustomZombie;

  /// No description provided for @switchProperties.
  ///
  /// In en, this message translates to:
  /// **'Switch properties'**
  String get switchProperties;

  /// No description provided for @defaultPropertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultPropertiesLabel;

  /// No description provided for @addNewVariation.
  ///
  /// In en, this message translates to:
  /// **'+ Add new variation'**
  String get addNewVariation;

  /// No description provided for @editCustomZombieAlias.
  ///
  /// In en, this message translates to:
  /// **'Edit {alias}'**
  String editCustomZombieAlias(String alias);

  /// No description provided for @switchZombie.
  ///
  /// In en, this message translates to:
  /// **'Switch zombie'**
  String get switchZombie;

  /// No description provided for @customZombieAppearanceLocation.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get customZombieAppearanceLocation;

  /// No description provided for @customZombieNotUsed.
  ///
  /// In en, this message translates to:
  /// **'This custom zombie is currently not used by any wave or module.'**
  String get customZombieNotUsed;

  /// No description provided for @customZombieWaveItem.
  ///
  /// In en, this message translates to:
  /// **'Wave {n}'**
  String customZombieWaveItem(int n);

  /// No description provided for @customZombieDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this custom zombie entity and its property data.'**
  String get customZombieDeleteConfirm;

  /// No description provided for @customZombieOrphanDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase custom properties from level?'**
  String get customZombieOrphanDeleteTitle;

  /// No description provided for @customZombieOrphanDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{alias}\" will have no remaining uses in this level. Remove its zombie type and property objects from the level file? This cannot be undone.'**
  String customZombieOrphanDeleteMessage(String alias);

  /// No description provided for @customZombieOrphanDeleteKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep in level'**
  String get customZombieOrphanDeleteKeep;

  /// No description provided for @customZombieOrphanDeleteErase.
  ///
  /// In en, this message translates to:
  /// **'Erase from level'**
  String get customZombieOrphanDeleteErase;

  /// No description provided for @editCustomZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit custom zombie properties'**
  String get editCustomZombieProperties;

  /// No description provided for @makeZombieAsCustom.
  ///
  /// In en, this message translates to:
  /// **'Make zombie as custom'**
  String get makeZombieAsCustom;

  /// No description provided for @customLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLabel;

  /// No description provided for @moduleTitle_WaveManagerProperties.
  ///
  /// In en, this message translates to:
  /// **'Linked Wave Parameters (WaveManagerProps)'**
  String get moduleTitle_WaveManagerProperties;

  /// No description provided for @waveManagerPropsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current: {value}'**
  String waveManagerPropsCurrent(String value);

  /// No description provided for @waveManagerGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Parameters'**
  String get waveManagerGlobalParams;

  /// No description provided for @waveManagerGlobalSummary.
  ///
  /// In en, this message translates to:
  /// **'Flag interval: {interval}, Next wave health threshold: {minPercent}% - {maxPercent}%'**
  String waveManagerGlobalSummary(int interval, int minPercent, int maxPercent);

  /// No description provided for @waveEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No waves yet'**
  String get waveEmptyTitle;

  /// No description provided for @waveEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the first wave, or remove this empty container.'**
  String get waveEmptySubtitle;

  /// No description provided for @waveHeaderPreview.
  ///
  /// In en, this message translates to:
  /// **'Content & Points Preview'**
  String get waveHeaderPreview;

  /// No description provided for @waveTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String waveTotalLabel(int total);

  /// No description provided for @waveEmptyRowHint.
  ///
  /// In en, this message translates to:
  /// **'Empty wave (swipe left/right)'**
  String get waveEmptyRowHint;

  /// No description provided for @waveEmptyRowHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Empty wave (click to manage)'**
  String get waveEmptyRowHintDesktop;

  /// No description provided for @waveEmptyRowHintMobile.
  ///
  /// In en, this message translates to:
  /// **'Empty wave (swipe left/right)'**
  String get waveEmptyRowHintMobile;

  /// No description provided for @removeFromWave.
  ///
  /// In en, this message translates to:
  /// **'Remove from wave'**
  String get removeFromWave;

  /// No description provided for @deleteEventEntityTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event entity?'**
  String get deleteEventEntityTitle;

  /// No description provided for @deleteEventEntityBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the event object from the level.'**
  String get deleteEventEntityBody;

  /// No description provided for @waveEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} events'**
  String waveEventsTitle(int wave);

  /// No description provided for @waveManagerSettings.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Settings'**
  String get waveManagerSettings;

  /// No description provided for @flagInterval.
  ///
  /// In en, this message translates to:
  /// **'Flag interval'**
  String get flagInterval;

  /// No description provided for @waveManagerHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager'**
  String get waveManagerHelpTitle;

  /// No description provided for @waveManagerHelpOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get waveManagerHelpOverviewTitle;

  /// No description provided for @waveManagerHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'The wave event container organizes level events by wave order. Most levels use it to control zombie spawning. This page allows you to adjust its global settings.'**
  String get waveManagerHelpOverviewBody;

  /// No description provided for @waveManagerHelpFlagTitle.
  ///
  /// In en, this message translates to:
  /// **'Flag interval'**
  String get waveManagerHelpFlagTitle;

  /// No description provided for @waveManagerHelpFlagBody.
  ///
  /// In en, this message translates to:
  /// **'The flag interval determines how often a flag wave appears. The final wave is always a flag wave. Flag waves receive bonus points and have a separate spawn interval.'**
  String get waveManagerHelpFlagBody;

  /// No description provided for @waveManagerHelpTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get waveManagerHelpTimeTitle;

  /// No description provided for @waveManagerHelpTimeBody.
  ///
  /// In en, this message translates to:
  /// **'The delay before the first wave depends on whether the level uses a conveyor belt: 5 seconds with a conveyor, or 12 seconds without. Flag wave delay refers to the time between the red warning message and zombie spawn.'**
  String get waveManagerHelpTimeBody;

  /// No description provided for @waveManagerHelpMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Jam'**
  String get waveManagerHelpMusicTitle;

  /// No description provided for @waveManagerHelpMusicBody.
  ///
  /// In en, this message translates to:
  /// **'This setting applies only to the Modern Day world. It sets a fixed global background track that enables abilities for certain Neon Mixtape Tour zombies.'**
  String get waveManagerHelpMusicBody;

  /// No description provided for @waveManagerBasicParams.
  ///
  /// In en, this message translates to:
  /// **'Basic parameters'**
  String get waveManagerBasicParams;

  /// No description provided for @waveManagerMaxHealthThreshold.
  ///
  /// In en, this message translates to:
  /// **'Max next wave health threshold'**
  String get waveManagerMaxHealthThreshold;

  /// No description provided for @waveManagerMinHealthThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min next wave health threshold'**
  String get waveManagerMinHealthThreshold;

  /// No description provided for @waveManagerThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Threshold must be between 0 and 1. When the total remaining health of zombies in the current wave falls below this value, the next wave will spawn automatically.'**
  String get waveManagerThresholdHint;

  /// No description provided for @waveManagerTimeControl.
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get waveManagerTimeControl;

  /// No description provided for @waveManagerFirstWaveDelayConveyor.
  ///
  /// In en, this message translates to:
  /// **'First wave delay (conveyor)'**
  String get waveManagerFirstWaveDelayConveyor;

  /// No description provided for @waveManagerFirstWaveDelayNormal.
  ///
  /// In en, this message translates to:
  /// **'First wave delay (normal)'**
  String get waveManagerFirstWaveDelayNormal;

  /// No description provided for @waveManagerFlagWaveDelay.
  ///
  /// In en, this message translates to:
  /// **'Flag wave delay'**
  String get waveManagerFlagWaveDelay;

  /// No description provided for @waveManagerConveyorDetected.
  ///
  /// In en, this message translates to:
  /// **'Conveyor module detected; conveyor delay applied.'**
  String get waveManagerConveyorDetected;

  /// No description provided for @waveManagerConveyorNotDetected.
  ///
  /// In en, this message translates to:
  /// **'No conveyor module; normal delay applied.'**
  String get waveManagerConveyorNotDetected;

  /// No description provided for @waveManagerSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get waveManagerSpecial;

  /// No description provided for @waveManagerSuppressFlagZombieTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppress flag zombie'**
  String get waveManagerSuppressFlagZombieTitle;

  /// No description provided for @waveManagerSuppressFlagZombieField.
  ///
  /// In en, this message translates to:
  /// **'SuppressFlagZombie'**
  String get waveManagerSuppressFlagZombieField;

  /// No description provided for @waveManagerSuppressFlagZombieHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, flag waves won’t spawn a flag zombie.'**
  String get waveManagerSuppressFlagZombieHint;

  /// No description provided for @waveManagerLevelJam.
  ///
  /// In en, this message translates to:
  /// **'Level Jam'**
  String get waveManagerLevelJam;

  /// No description provided for @waveManagerLevelJamHint.
  ///
  /// In en, this message translates to:
  /// **'Only applies to Modern Day; provides fixed global background track.'**
  String get waveManagerLevelJamHint;

  /// No description provided for @jamNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get jamNone;

  /// No description provided for @jamPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get jamPop;

  /// No description provided for @jamRap.
  ///
  /// In en, this message translates to:
  /// **'Rap'**
  String get jamRap;

  /// No description provided for @jamMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get jamMetal;

  /// No description provided for @jamPunk.
  ///
  /// In en, this message translates to:
  /// **'Punk'**
  String get jamPunk;

  /// No description provided for @jam8Bit.
  ///
  /// In en, this message translates to:
  /// **'8-Bit'**
  String get jam8Bit;

  /// No description provided for @noWaves.
  ///
  /// In en, this message translates to:
  /// **'No waves'**
  String get noWaves;

  /// No description provided for @addFirstWave.
  ///
  /// In en, this message translates to:
  /// **'Add the first wave.'**
  String get addFirstWave;

  /// No description provided for @deleteWave.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWave;

  /// No description provided for @deleteWaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove this wave and its {count} events.'**
  String deleteWaveConfirm(int count);

  /// No description provided for @deleteWaveConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm permanent deletion of this wave'**
  String get deleteWaveConfirmCheckbox;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @emptyWave.
  ///
  /// In en, this message translates to:
  /// **'Empty wave'**
  String get emptyWave;

  /// No description provided for @addWave.
  ///
  /// In en, this message translates to:
  /// **'Add wave'**
  String get addWave;

  /// No description provided for @expectation.
  ///
  /// In en, this message translates to:
  /// **'Expectation'**
  String get expectation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit properties'**
  String get editProperties;

  /// No description provided for @deleteEntity.
  ///
  /// In en, this message translates to:
  /// **'Delete entity'**
  String get deleteEntity;

  /// No description provided for @deleteObjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete object?'**
  String get deleteObjectTitle;

  /// No description provided for @deleteObjectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this object from the level file? This action cannot be undone.'**
  String get deleteObjectConfirmMessage;

  /// No description provided for @objectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Object deleted'**
  String get objectDeleted;

  /// No description provided for @moduleEditorInProgress.
  ///
  /// In en, this message translates to:
  /// **'Module editor in development'**
  String get moduleEditorInProgress;

  /// No description provided for @dataEmpty.
  ///
  /// In en, this message translates to:
  /// **'Data is empty'**
  String get dataEmpty;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Save successful'**
  String get saveSuccess;

  /// No description provided for @saveFail.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFail;

  /// No description provided for @confirmRemoveRef.
  ///
  /// In en, this message translates to:
  /// **'Remove reference'**
  String get confirmRemoveRef;

  /// No description provided for @confirmRemoveRefMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this reference? The entity data will remain until all references are removed.'**
  String get confirmRemoveRefMessage;

  /// No description provided for @deleteEventConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand this action cannot be undone'**
  String get deleteEventConfirmCheckbox;

  /// No description provided for @noZombiesInLane.
  ///
  /// In en, this message translates to:
  /// **'No zombies in this lane'**
  String get noZombiesInLane;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Level name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Level description'**
  String get description;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level number'**
  String get levelNumber;

  /// No description provided for @startingSun.
  ///
  /// In en, this message translates to:
  /// **'Starting sun'**
  String get startingSun;

  /// No description provided for @stageModule.
  ///
  /// In en, this message translates to:
  /// **'Lawn module'**
  String get stageModule;

  /// No description provided for @musicType.
  ///
  /// In en, this message translates to:
  /// **'Music type'**
  String get musicType;

  /// No description provided for @loot.
  ///
  /// In en, this message translates to:
  /// **'Loot'**
  String get loot;

  /// No description provided for @victoryModule.
  ///
  /// In en, this message translates to:
  /// **'Victory module'**
  String get victoryModule;

  /// No description provided for @basicInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfoSection;

  /// No description provided for @sceneSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Scene Settings'**
  String get sceneSettingsSection;

  /// No description provided for @restrictionsSection.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictionsSection;

  /// No description provided for @victoryModuleWarning.
  ///
  /// In en, this message translates to:
  /// **'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.'**
  String get victoryModuleWarning;

  /// No description provided for @hintTextDisplay.
  ///
  /// In en, this message translates to:
  /// **'Text display (Description)'**
  String get hintTextDisplay;

  /// No description provided for @beatTheLevelDialogIntro.
  ///
  /// In en, this message translates to:
  /// **'Display hint text in a pop-up at the beginning of the level.'**
  String get beatTheLevelDialogIntro;

  /// No description provided for @beatTheLevelDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Supports Chinese; for multi-line text enter newlines directly, no need for \\n. Note: hints cannot be viewed in Creative Courtyard on iOS.'**
  String get beatTheLevelDialogHint;

  /// No description provided for @levelHintText.
  ///
  /// In en, this message translates to:
  /// **'Level hint text'**
  String get levelHintText;

  /// No description provided for @missingModules.
  ///
  /// In en, this message translates to:
  /// **'Missing modules'**
  String get missingModules;

  /// No description provided for @moduleConflict.
  ///
  /// In en, this message translates to:
  /// **'Module conflict'**
  String get moduleConflict;

  /// No description provided for @conflictTitle_ModuleLogic.
  ///
  /// In en, this message translates to:
  /// **'Module logic conflict'**
  String get conflictTitle_ModuleLogic;

  /// No description provided for @conflictDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'{module1} and {module2} conflict logically. It is recommended to keep only one.'**
  String conflictDefaultDescription(String module1, String module2);

  /// No description provided for @conflictDesc_SeedBankConveyor.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank and Conveyor modules interfere with each other\'s UI and may cause crashes. Ensure Seed Bank is in Preset mode.'**
  String get conflictDesc_SeedBankConveyor;

  /// No description provided for @conflictDesc_VaseBreakerIntro.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker mode does not need an opening intro.'**
  String get conflictDesc_VaseBreakerIntro;

  /// No description provided for @conflictDesc_LastStandIntro.
  ///
  /// In en, this message translates to:
  /// **'Last Stand mode does not need an opening intro.'**
  String get conflictDesc_LastStandIntro;

  /// No description provided for @conflictDesc_EvilDaveZombieDrop.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie mode cannot have Zombie Drop module.'**
  String get conflictDesc_EvilDaveZombieDrop;

  /// No description provided for @conflictDesc_EvilDaveVictory.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie mode cannot have Zombie Victory Condition.'**
  String get conflictDesc_EvilDaveVictory;

  /// No description provided for @conflictDesc_ZombossDeathDrop.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop in ZombossMech battle mode will prevent proper level completion.'**
  String get conflictDesc_ZombossDeathDrop;

  /// No description provided for @conflictDesc_ZombossBattleDeathDrop.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop in Zomboss battle mode will prevent proper level completion.'**
  String get conflictDesc_ZombossBattleDeathDrop;

  /// No description provided for @conflictDesc_WinConditionExclusive.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop and Bronze Matrix Loot Drop do not need to be used together. It is recommended to remove one of them.'**
  String get conflictDesc_WinConditionExclusive;

  /// No description provided for @conflictDesc_ZombossTwoIntros.
  ///
  /// In en, this message translates to:
  /// **'Two level opening intros cannot coexist, otherwise Zomboss health bar will not display correctly.'**
  String get conflictDesc_ZombossTwoIntros;

  /// No description provided for @conflictDesc_InitialPlantEntryRoof.
  ///
  /// In en, this message translates to:
  /// **'Pre-place plants on the roof will cause a crash.'**
  String get conflictDesc_InitialPlantEntryRoof;

  /// No description provided for @conflictDesc_InitialPlantRoof.
  ///
  /// In en, this message translates to:
  /// **'Legacy preset plants on the roof will cause a crash.'**
  String get conflictDesc_InitialPlantRoof;

  /// No description provided for @conflictDesc_ProtectPlantRoof.
  ///
  /// In en, this message translates to:
  /// **'Endangered plants on the roof will cause a crash.'**
  String get conflictDesc_ProtectPlantRoof;

  /// No description provided for @conflictDesc_LawnMowerYard.
  ///
  /// In en, this message translates to:
  /// **'Lawn mowers are ineffective when the Creative Courtyard module is enabled.'**
  String get conflictDesc_LawnMowerYard;

  /// No description provided for @conflictDesc_WaveGeneratorWaveManagerModule.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator and Wave Manager module cannot coexist — they are two different wave systems.'**
  String get conflictDesc_WaveGeneratorWaveManagerModule;

  /// No description provided for @conflictDesc_WaveGeneratorWaveManager.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator embeds waves directly and cannot be used with a separate Wave Manager container.'**
  String get conflictDesc_WaveGeneratorWaveManager;

  /// No description provided for @conflictDesc_WaveGeneratorRenai.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator is incompatible with the Renai module and will crash the level on load.'**
  String get conflictDesc_WaveGeneratorRenai;

  /// No description provided for @conflictDesc_WaveGeneratorWitch.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator is incompatible with the Witch module and will crash the level on load.'**
  String get conflictDesc_WaveGeneratorWitch;

  /// No description provided for @missingPlantModuleWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing module for parallel universe plants'**
  String get missingPlantModuleWarningTitle;

  /// No description provided for @editableModules.
  ///
  /// In en, this message translates to:
  /// **'Editable modules'**
  String get editableModules;

  /// No description provided for @parameterModules.
  ///
  /// In en, this message translates to:
  /// **'Parameter modules'**
  String get parameterModules;

  /// No description provided for @addNewModule.
  ///
  /// In en, this message translates to:
  /// **'Add new module'**
  String get addNewModule;

  /// No description provided for @selectStage.
  ///
  /// In en, this message translates to:
  /// **'Select lawn'**
  String get selectStage;

  /// No description provided for @searchStage.
  ///
  /// In en, this message translates to:
  /// **'Search by lawn name or codename'**
  String get searchStage;

  /// No description provided for @noStageFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn found'**
  String get noStageFound;

  /// No description provided for @stageTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get stageTypeAll;

  /// No description provided for @stageTypeMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get stageTypeMain;

  /// No description provided for @stageTypeExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get stageTypeExtra;

  /// No description provided for @stageTypeSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get stageTypeSeasons;

  /// No description provided for @stageTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get stageTypeSpecial;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @disablePeavine.
  ///
  /// In en, this message translates to:
  /// **'Disable Pea Vine\'s Pea Symbiosis'**
  String get disablePeavine;

  /// No description provided for @disableArtifact.
  ///
  /// In en, this message translates to:
  /// **'Disable Artifact (auto-applied when Creative Courtyard module is enabled)'**
  String get disableArtifact;

  /// No description provided for @selectPlant.
  ///
  /// In en, this message translates to:
  /// **'Select plant'**
  String get selectPlant;

  /// No description provided for @searchPlant.
  ///
  /// In en, this message translates to:
  /// **'Search plant'**
  String get searchPlant;

  /// No description provided for @noPlantFound.
  ///
  /// In en, this message translates to:
  /// **'No plant found'**
  String get noPlantFound;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(Object query);

  /// No description provided for @noModulesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No modules in this category'**
  String get noModulesInCategory;

  /// No description provided for @addEventForWave.
  ///
  /// In en, this message translates to:
  /// **'Add event for wave {wave}'**
  String addEventForWave(int wave);

  /// No description provided for @waveLabel.
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get waveLabel;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @wavePointsShort.
  ///
  /// In en, this message translates to:
  /// **'{points} pts.'**
  String wavePointsShort(int points);

  /// No description provided for @noDynamicZombies.
  ///
  /// In en, this message translates to:
  /// **'No dynamic zombies'**
  String get noDynamicZombies;

  /// No description provided for @moduleTitle_WaveManagerModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager'**
  String get moduleTitle_WaveManagerModuleProperties;

  /// No description provided for @moduleDesc_WaveManagerModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Manages overall wave event configuration for the level'**
  String get moduleDesc_WaveManagerModuleProperties;

  /// No description provided for @moduleTitle_WaveGeneratorProperties.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator'**
  String get moduleTitle_WaveGeneratorProperties;

  /// No description provided for @moduleDesc_WaveGeneratorProperties.
  ///
  /// In en, this message translates to:
  /// **'Legacy embedded wave definition (campaign-style levels). Mutually exclusive with Wave Manager.'**
  String get moduleDesc_WaveGeneratorProperties;

  /// No description provided for @moduleTitle_CustomLevelModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Creative Courtyard Module'**
  String get moduleTitle_CustomLevelModuleProperties;

  /// No description provided for @moduleDesc_CustomLevelModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables Creative Courtyard features (likes, rewards, costume feature disabling, etc.)'**
  String get moduleDesc_CustomLevelModuleProperties;

  /// No description provided for @powerTileModuleRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles module required'**
  String get powerTileModuleRequiredTitle;

  /// No description provided for @powerTileModuleRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Adding Power Tile tool packets requires the level to include the Power Tile module. Add the module and continue?'**
  String get powerTileModuleRequiredBody;

  /// No description provided for @conveyorPlantWearCostume.
  ///
  /// In en, this message translates to:
  /// **'Display costume (iAvatar)'**
  String get conveyorPlantWearCostume;

  /// No description provided for @conveyorPlantWearCostumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'When enabled, this plant’s packet on the conveyor belt will display its costume. This feature does not work when the Creative Courtyard module is enabled.'**
  String get conveyorPlantWearCostumeTooltip;

  /// No description provided for @modifyConveyorAddPoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Conveyor Pool'**
  String get modifyConveyorAddPoolTitle;

  /// No description provided for @modifyConveyorAddPoolEmpty.
  ///
  /// In en, this message translates to:
  /// **'The list is empty. Please add plants or tool packets.'**
  String get modifyConveyorAddPoolEmpty;

  /// No description provided for @modifyConveyorRemovePoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Conveyor Pool (doesn\'t work when Creative Courtyard module is enabled)'**
  String get modifyConveyorRemovePoolTitle;

  /// No description provided for @modifyConveyorEntryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit parameters'**
  String get modifyConveyorEntryEditTitle;

  /// No description provided for @moduleTitle_UnchartedModeNo42UniverseModule.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe Module'**
  String get moduleTitle_UnchartedModeNo42UniverseModule;

  /// No description provided for @moduleDesc_UnchartedModeNo42UniverseModule.
  ///
  /// In en, this message translates to:
  /// **'Enables Parallel Universe plants (No.41 & No.42)'**
  String get moduleDesc_UnchartedModeNo42UniverseModule;

  /// No description provided for @moduleTitle_PVZ2MausoleumModuleUnchartedMode.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Module'**
  String get moduleTitle_PVZ2MausoleumModuleUnchartedMode;

  /// No description provided for @moduleDesc_PVZ2MausoleumModuleUnchartedMode.
  ///
  /// In en, this message translates to:
  /// **'Enables plants featured in the Underground Palace realm'**
  String get moduleDesc_PVZ2MausoleumModuleUnchartedMode;

  /// No description provided for @plantModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'In order to select this plant, {moduleName} needs to be added.'**
  String plantModuleRequiredMessage(String moduleName);

  /// No description provided for @realmExclusivePlantChooserBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot select plant'**
  String get realmExclusivePlantChooserBlockedTitle;

  /// No description provided for @realmExclusivePlantChooserBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Realm-exclusive plants cannot be selected in Chooser Mode. To use them, please refer to other methods such as Preset Mode, Conveyor Belt, or Packet Drops.'**
  String get realmExclusivePlantChooserBlockedMessage;

  /// No description provided for @missingModuleForPlantsWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing module {moduleName} for plants: {plantList}'**
  String missingModuleForPlantsWarning(String moduleName, String plantList);

  /// No description provided for @moduleTitle_StandardLevelIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Intro Animation'**
  String get moduleTitle_StandardLevelIntroProperties;

  /// No description provided for @moduleDesc_StandardLevelIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Camera pan at the start of the level'**
  String get moduleDesc_StandardLevelIntroProperties;

  /// No description provided for @moduleTitle_ZombiesAteYourBrainsProperties.
  ///
  /// In en, this message translates to:
  /// **'Loss Condition'**
  String get moduleTitle_ZombiesAteYourBrainsProperties;

  /// No description provided for @moduleDesc_ZombiesAteYourBrainsProperties.
  ///
  /// In en, this message translates to:
  /// **'Position where zombies entering the house triggers defeat'**
  String get moduleDesc_ZombiesAteYourBrainsProperties;

  /// No description provided for @moduleTitle_ZombiesDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop'**
  String get moduleTitle_ZombiesDeadWinConProperties;

  /// No description provided for @moduleDesc_ZombiesDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Required module for level stability'**
  String get moduleDesc_ZombiesDeadWinConProperties;

  /// No description provided for @moduleTitle_BronzeDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Loot Drop'**
  String get moduleTitle_BronzeDeadWinConProperties;

  /// No description provided for @moduleDesc_BronzeDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Instantly eliminates all other zombies on the lawn once all bronze statues and gargantuar bronzes are defeated'**
  String get moduleDesc_BronzeDeadWinConProperties;

  /// No description provided for @moduleTitle_SpermWhaleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching'**
  String get moduleTitle_SpermWhaleModuleProperties;

  /// No description provided for @moduleDesc_SpermWhaleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures whale-related parameters for Underwater World levels, requires krill to be present on the lawn to take effect'**
  String get moduleDesc_SpermWhaleModuleProperties;

  /// No description provided for @spermWhaleModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching Settings'**
  String get spermWhaleModuleTitle;

  /// No description provided for @spermWhaleModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching'**
  String get spermWhaleModuleHelpTitle;

  /// No description provided for @spermWhaleModuleParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get spermWhaleModuleParameters;

  /// No description provided for @spermWhaleModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get spermWhaleModuleHelpOverview;

  /// No description provided for @spermWhaleModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure parameters related to the special marine creature \"Whale\", and is typically used in Underwater World levels. As krill begin appearing, the whale will circle above the lawn and trigger the corresponding red subtitle warning. Once at least 3 krill are present on the lawn, the whale will officially appear in the upper-left corner of the lawn. The whale will prioritize swallowing existing krill before continuously sucking up and swallowing plants on the lawn. The rotenone released by Puffy Derris can be inhaled by the whale; after the first inhalation, the whale’s swallowing speed will decrease. Once the number of inhalations reaches the configured rotenone trigger count, the whale will be forced to retreat. Note that the whale can only appear once per level.'**
  String get spermWhaleModuleHelpOverviewBody;

  /// No description provided for @spermWhaleModuleHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Overview'**
  String get spermWhaleModuleHelpFieldsTitle;

  /// No description provided for @spermWhaleModuleHelpFieldsBody.
  ///
  /// In en, this message translates to:
  /// **'Swallow Interval (SwallowInterval) refers to the interval between the whale’s swallowing actions under normal conditions.\nPoisoned Swallow Interval (PoisonSwallowInterval) refers to the interval between swallowing actions after the whale inhales rotenone once.\nSwallow Duration (SwallowDuration) refers to the total amount of time the whale remains on the lawn sucking up and swallowing plants.\nPoison Trigger Count (PoisonTriggerCount) refers to the number of rotenone inhalations required to force the whale to retreat.'**
  String get spermWhaleModuleHelpFieldsBody;

  /// No description provided for @spermWhaleModuleSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'Swallow Interval (SwallowInterval, unit: seconds)'**
  String get spermWhaleModuleSwallowInterval;

  /// No description provided for @spermWhaleModuleHelpSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'The interval between two swallowing actions under normal conditions.'**
  String get spermWhaleModuleHelpSwallowInterval;

  /// No description provided for @spermWhaleModulePoisonSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'Rotenone Swallow Interval (PoisonSwallowInterval, unit: seconds)'**
  String get spermWhaleModulePoisonSwallowInterval;

  /// No description provided for @spermWhaleModuleHelpPoisonSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'The interval between two swallowing actions after the whale inhales rotenone.'**
  String get spermWhaleModuleHelpPoisonSwallowInterval;

  /// No description provided for @spermWhaleModuleSwallowDuration.
  ///
  /// In en, this message translates to:
  /// **'Swallow Duration (SwallowDuration, unit: seconds)'**
  String get spermWhaleModuleSwallowDuration;

  /// No description provided for @spermWhaleModuleHelpSwallowDuration.
  ///
  /// In en, this message translates to:
  /// **'The total duration the whale remains on the lawn sucking up and swallowing plants.'**
  String get spermWhaleModuleHelpSwallowDuration;

  /// No description provided for @spermWhaleModulePoisonTriggerCount.
  ///
  /// In en, this message translates to:
  /// **'Rotenone trigger count (PoisonTriggerCount)'**
  String get spermWhaleModulePoisonTriggerCount;

  /// No description provided for @spermWhaleModuleHelpPoisonTriggerCount.
  ///
  /// In en, this message translates to:
  /// **'The cumulative number of rotenone inhalations required to force the whale to retreat.'**
  String get spermWhaleModuleHelpPoisonTriggerCount;

  /// No description provided for @spermWhaleModuleNotDeepSeaWarning.
  ///
  /// In en, this message translates to:
  /// **'This module is recommended for use in Underwater World lawns. The grid belows only reflects the current lawn configuration; using this module on non-20,000 Leagues Under the Sea/Atlantis lawns may cause compatibility issues.'**
  String get spermWhaleModuleNotDeepSeaWarning;

  /// No description provided for @spermWhaleModuleLawnPreview.
  ///
  /// In en, this message translates to:
  /// **'Lawn Preview'**
  String get spermWhaleModuleLawnPreview;

  /// No description provided for @spermWhaleModuleLawnPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Underwater World levels use a 6×10 lawn layout, while other levels use a 5×9 layout'**
  String get spermWhaleModuleLawnPreviewHint;

  /// No description provided for @moduleTitle_PennyClassroomModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Tier Definition'**
  String get moduleTitle_PennyClassroomModuleProperties;

  /// No description provided for @moduleDesc_PennyClassroomModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Globally defines plant tiers, overrides other modules'**
  String get moduleDesc_PennyClassroomModuleProperties;

  /// No description provided for @moduleTitle_SeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank'**
  String get moduleTitle_SeedBankProperties;

  /// No description provided for @moduleDesc_SeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Presets seed slots and seed selection mode'**
  String get moduleDesc_SeedBankProperties;

  /// No description provided for @moduleTitle_ConveyorSeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt'**
  String get moduleTitle_ConveyorSeedBankProperties;

  /// No description provided for @moduleDesc_ConveyorSeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Presets conveyor belt plant types and weights'**
  String get moduleDesc_ConveyorSeedBankProperties;

  /// No description provided for @moduleTitle_SunDropperProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun Dropper'**
  String get moduleTitle_SunDropperProperties;

  /// No description provided for @moduleDesc_SunDropperProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls falling sun frequency'**
  String get moduleDesc_SunDropperProperties;

  /// No description provided for @moduleTitle_LevelMutatorMaxSunProps.
  ///
  /// In en, this message translates to:
  /// **'Max Sun Limit'**
  String get moduleTitle_LevelMutatorMaxSunProps;

  /// No description provided for @moduleDesc_LevelMutatorMaxSunProps.
  ///
  /// In en, this message translates to:
  /// **'Overrides the maximum sun limit value'**
  String get moduleDesc_LevelMutatorMaxSunProps;

  /// No description provided for @moduleTitle_LevelMutatorStartingPlantfoodProps.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get moduleTitle_LevelMutatorStartingPlantfoodProps;

  /// No description provided for @moduleDesc_LevelMutatorStartingPlantfoodProps.
  ///
  /// In en, this message translates to:
  /// **'Overrides starting Plant Food amount'**
  String get moduleDesc_LevelMutatorStartingPlantfoodProps;

  /// No description provided for @moduleTitle_StarChallengeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module'**
  String get moduleTitle_StarChallengeModuleProperties;

  /// No description provided for @moduleDesc_StarChallengeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets level restrictions and objectives'**
  String get moduleDesc_StarChallengeModuleProperties;

  /// No description provided for @starChallengeNoConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get starChallengeNoConfigTitle;

  /// No description provided for @starChallengeNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.'**
  String get starChallengeNoConfigMessage;

  /// No description provided for @starChallengeSaveMowersTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose any lawn mowers'**
  String get starChallengeSaveMowersTitle;

  /// No description provided for @starChallengeSaveMowersNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.\n\nTo complete it, all lawn mowers must remain intact. Note that lawn mowers are not available by default when the Creative Courtyard module is enabled.'**
  String get starChallengeSaveMowersNoConfigMessage;

  /// No description provided for @starChallengePlantFoodNonuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use Plant Food'**
  String get starChallengePlantFoodNonuseTitle;

  /// No description provided for @starChallengePlantFoodNonuseNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.\n\nPlant Food cannot be used.'**
  String get starChallengePlantFoodNonuseNoConfigMessage;

  /// No description provided for @moduleTitle_LevelScoringModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Scoring Module'**
  String get moduleTitle_LevelScoringModuleProperties;

  /// No description provided for @moduleDesc_LevelScoringModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables scoring system based on zombie kills'**
  String get moduleDesc_LevelScoringModuleProperties;

  /// No description provided for @moduleTitle_BowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Bulb Bowling'**
  String get moduleTitle_BowlingMinigameProperties;

  /// No description provided for @moduleDesc_BowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets no-planting line and disable shovel'**
  String get moduleDesc_BowlingMinigameProperties;

  /// No description provided for @moduleTitle_NewBowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Wall-nut Bowling'**
  String get moduleTitle_NewBowlingMinigameProperties;

  /// No description provided for @moduleDesc_NewBowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Draws bowling warning line at a fixed position'**
  String get moduleDesc_NewBowlingMinigameProperties;

  /// No description provided for @moduleTitle_VaseBreakerPresetProperties.
  ///
  /// In en, this message translates to:
  /// **'Vase Layout'**
  String get moduleTitle_VaseBreakerPresetProperties;

  /// No description provided for @moduleDesc_VaseBreakerPresetProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures vase contents (requires 2 additional modules to function)'**
  String get moduleDesc_VaseBreakerPresetProperties;

  /// No description provided for @moduleTitle_VaseBreakerArcadeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker Mode'**
  String get moduleTitle_VaseBreakerArcadeModuleProperties;

  /// No description provided for @moduleDesc_VaseBreakerArcadeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable environment and UI for Vasebreaker'**
  String get moduleDesc_VaseBreakerArcadeModuleProperties;

  /// No description provided for @moduleTitle_VaseBreakerFlowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Vase Animation'**
  String get moduleTitle_VaseBreakerFlowModuleProperties;

  /// No description provided for @moduleDesc_VaseBreakerFlowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls the falling animation of vases at start'**
  String get moduleDesc_VaseBreakerFlowModuleProperties;

  /// No description provided for @moduleTitle_EvilDaveProperties.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie Mode'**
  String get moduleTitle_EvilDaveProperties;

  /// No description provided for @moduleDesc_EvilDaveProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable I, Zombie mode (requires zombie bank and preset plants)'**
  String get moduleDesc_EvilDaveProperties;

  /// No description provided for @moduleTitle_ZombossBattleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech Battle'**
  String get moduleTitle_ZombossBattleModuleProperties;

  /// No description provided for @moduleDesc_ZombossBattleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures ZombossMech parameters and types'**
  String get moduleDesc_ZombossBattleModuleProperties;

  /// No description provided for @moduleTitle_ZombossBattleIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech Intro'**
  String get moduleTitle_ZombossBattleIntroProperties;

  /// No description provided for @moduleDesc_ZombossBattleIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls ZombossMech cutscenes and health bar display'**
  String get moduleDesc_ZombossBattleIntroProperties;

  /// No description provided for @moduleTitle_ZombossLastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Battle'**
  String get moduleTitle_ZombossLastStandMinigameProperties;

  /// No description provided for @moduleDesc_ZombossLastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures non-mech Zomboss last-stand battles (Kongfu, Qin, etc.)'**
  String get moduleDesc_ZombossLastStandMinigameProperties;

  /// No description provided for @moduleTitle_SeedRainProperties.
  ///
  /// In en, this message translates to:
  /// **'It\'s Raining Seeds'**
  String get moduleTitle_SeedRainProperties;

  /// No description provided for @moduleDesc_SeedRainProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls plants, zombies or Plant Food falling from the sky'**
  String get moduleDesc_SeedRainProperties;

  /// No description provided for @moduleTitle_LastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Last Stand'**
  String get moduleTitle_LastStandMinigameProperties;

  /// No description provided for @moduleDesc_LastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets initial resources and enables setup phase'**
  String get moduleDesc_LastStandMinigameProperties;

  /// No description provided for @moduleTitle_PVZ1OverwhelmModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Column Like You See \'Em'**
  String get moduleTitle_PVZ1OverwhelmModuleProperties;

  /// No description provided for @moduleDesc_PVZ1OverwhelmModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Planting a seed packet fills its column (best used with conveyor belt)'**
  String get moduleDesc_PVZ1OverwhelmModuleProperties;

  /// No description provided for @moduleTitle_SunBombChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun Bombs'**
  String get moduleTitle_SunBombChallengeProperties;

  /// No description provided for @moduleDesc_SunBombChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures explosion range and damage of falling sun'**
  String get moduleDesc_SunBombChallengeProperties;

  /// No description provided for @moduleTitle_IncreasedCostModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get moduleTitle_IncreasedCostModuleProperties;

  /// No description provided for @moduleDesc_IncreasedCostModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun cost increases each time the same plant is planted'**
  String get moduleDesc_IncreasedCostModuleProperties;

  /// No description provided for @moduleTitle_DeathHoleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Death Craters'**
  String get moduleTitle_DeathHoleModuleProperties;

  /// No description provided for @moduleDesc_DeathHoleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Plants leave craters when destroyed'**
  String get moduleDesc_DeathHoleModuleProperties;

  /// No description provided for @moduleTitle_ZombieMoveFastModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fast Entry'**
  String get moduleTitle_ZombieMoveFastModuleProperties;

  /// No description provided for @moduleDesc_ZombieMoveFastModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Zombies move faster on entry'**
  String get moduleDesc_ZombieMoveFastModuleProperties;

  /// No description provided for @moduleTitle_InitialPlantProperties.
  ///
  /// In en, this message translates to:
  /// **'Legacy Preset Plants'**
  String get moduleTitle_InitialPlantProperties;

  /// No description provided for @moduleDesc_InitialPlantProperties.
  ///
  /// In en, this message translates to:
  /// **'The legacy method for preset plants, supports placing frozen plants'**
  String get moduleDesc_InitialPlantProperties;

  /// No description provided for @moduleTitle_InitialPlantEntryProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Plants'**
  String get moduleTitle_InitialPlantEntryProperties;

  /// No description provided for @moduleDesc_InitialPlantEntryProperties.
  ///
  /// In en, this message translates to:
  /// **'Plants existing on the lawn at the start'**
  String get moduleDesc_InitialPlantEntryProperties;

  /// No description provided for @frozenPlantPlacementTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Preset Plants'**
  String get frozenPlantPlacementTitle;

  /// No description provided for @frozenPlantPlacementLastStand.
  ///
  /// In en, this message translates to:
  /// **'Intensive Battle mode'**
  String get frozenPlantPlacementLastStand;

  /// No description provided for @frozenPlantPlacementSelectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get frozenPlantPlacementSelectedPosition;

  /// No description provided for @frozenPlantPlacementPlaceHere.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get frozenPlantPlacementPlaceHere;

  /// No description provided for @frozenPlantPlacementPlantList.
  ///
  /// In en, this message translates to:
  /// **'Plant(s) in selected tile'**
  String get frozenPlantPlacementPlantList;

  /// No description provided for @frozenPlantPlacementEditPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String frozenPlantPlacementEditPlant(Object name);

  /// No description provided for @frozenPlantPlacementLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get frozenPlantPlacementLevel;

  /// No description provided for @frozenPlantPlacementCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get frozenPlantPlacementCondition;

  /// No description provided for @frozenPlantPlacementConditionNull.
  ///
  /// In en, this message translates to:
  /// **'None (null)'**
  String get frozenPlantPlacementConditionNull;

  /// No description provided for @noConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions'**
  String get noConditions;

  /// No description provided for @frozenPlantPlacementHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Preset Plants'**
  String get frozenPlantPlacementHelpTitle;

  /// No description provided for @frozenPlantPlacementHelpOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get frozenPlantPlacementHelpOverviewTitle;

  /// No description provided for @frozenPlantPlacementHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module configures plant layout before the level starts. Similar to preset plant layout but with a different structure and special state support.'**
  String get frozenPlantPlacementHelpOverviewBody;

  /// No description provided for @frozenPlantPlacementHelpConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Special State'**
  String get frozenPlantPlacementHelpConditionTitle;

  /// No description provided for @frozenPlantPlacementHelpConditionBody.
  ///
  /// In en, this message translates to:
  /// **'Plants can be set to frozen state (icecubed), commonly used in Frostbite Caves levels.'**
  String get frozenPlantPlacementHelpConditionBody;

  /// No description provided for @frozenPlantPlacementHelpLastStandTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensive Battle Mode'**
  String get frozenPlantPlacementHelpLastStandTitle;

  /// No description provided for @frozenPlantPlacementHelpLastStandBody.
  ///
  /// In en, this message translates to:
  /// **'When Intensive Battle mode is enabled, initial plants will be incinerated after the game starts. Note that Chinese version does not have the burn animation.'**
  String get frozenPlantPlacementHelpLastStandBody;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @moduleTitle_InitialZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Zombies'**
  String get moduleTitle_InitialZombieProperties;

  /// No description provided for @moduleDesc_InitialZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Zombies existing on the lawn at the start'**
  String get moduleDesc_InitialZombieProperties;

  /// No description provided for @moduleTitle_InitialGridItemProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Grid Items'**
  String get moduleTitle_InitialGridItemProperties;

  /// No description provided for @moduleDesc_InitialGridItemProperties.
  ///
  /// In en, this message translates to:
  /// **'Grid items existing on the lawn at the start'**
  String get moduleDesc_InitialGridItemProperties;

  /// No description provided for @moduleTitle_ProtectThePlantChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Save Our Seeds'**
  String get moduleTitle_ProtectThePlantChallengeProperties;

  /// No description provided for @moduleDesc_ProtectThePlantChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets specific plants that must be protected'**
  String get moduleDesc_ProtectThePlantChallengeProperties;

  /// No description provided for @moduleTitle_ProtectTheGridItemChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items'**
  String get moduleTitle_ProtectTheGridItemChallengeProperties;

  /// No description provided for @moduleDesc_ProtectTheGridItemChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets grid items that must be protected from destruction'**
  String get moduleDesc_ProtectTheGridItemChallengeProperties;

  /// No description provided for @moduleTitle_ZombiePotionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Dark Alchemy'**
  String get moduleTitle_ZombiePotionModuleProperties;

  /// No description provided for @moduleDesc_ZombiePotionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages potion generation mechanics'**
  String get moduleDesc_ZombiePotionModuleProperties;

  /// No description provided for @moduleTitle_PiratePlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Pirate Planks'**
  String get moduleTitle_PiratePlankProperties;

  /// No description provided for @moduleDesc_PiratePlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures plank rows for Pirate Seas lawn'**
  String get moduleDesc_PiratePlankProperties;

  /// No description provided for @moduleTitle_RailcartProperties.
  ///
  /// In en, this message translates to:
  /// **'Minecart and Rail'**
  String get moduleTitle_RailcartProperties;

  /// No description provided for @moduleDesc_RailcartProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the initial layout of minecarts and rails'**
  String get moduleDesc_RailcartProperties;

  /// No description provided for @moduleTitle_MechanismPlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Connected Minecart'**
  String get moduleTitle_MechanismPlankProperties;

  /// No description provided for @moduleDesc_MechanismPlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the initial layout of Kongfu World minecarts and rails'**
  String get moduleDesc_MechanismPlankProperties;

  /// No description provided for @moduleTitle_PowerTileProperties.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles'**
  String get moduleTitle_PowerTileProperties;

  /// No description provided for @moduleDesc_PowerTileProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Plant Food link effects and tile layout'**
  String get moduleDesc_PowerTileProperties;

  /// No description provided for @moduleTitle_ManholePipelineModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Manhole Pipeline'**
  String get moduleTitle_ManholePipelineModuleProperties;

  /// No description provided for @moduleDesc_ManholePipelineModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Steam Ages transportation sewers'**
  String get moduleDesc_ManholePipelineModuleProperties;

  /// No description provided for @moduleTitle_SmokePollutionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Smoke Pollution'**
  String get moduleTitle_SmokePollutionModuleProperties;

  /// No description provided for @moduleDesc_SmokePollutionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures steam poison fog manholes on the lawn'**
  String get moduleDesc_SmokePollutionModuleProperties;

  /// No description provided for @moduleTitle_RoofProperties.
  ///
  /// In en, this message translates to:
  /// **'Roof Pots'**
  String get moduleTitle_RoofProperties;

  /// No description provided for @moduleDesc_RoofProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures preset Flower Pots for Roof levels'**
  String get moduleDesc_RoofProperties;

  /// No description provided for @moduleTitle_TideProperties.
  ///
  /// In en, this message translates to:
  /// **'Tide System'**
  String get moduleTitle_TideProperties;

  /// No description provided for @moduleDesc_TideProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable tide system (should be added last)'**
  String get moduleDesc_TideProperties;

  /// No description provided for @moduleTitle_BombProperties.
  ///
  /// In en, this message translates to:
  /// **'Powder Keg'**
  String get moduleTitle_BombProperties;

  /// No description provided for @moduleDesc_BombProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the fuse length and burn rate of Kongfu World powder kegs'**
  String get moduleDesc_BombProperties;

  /// No description provided for @moduleTitle_BronzeProperties.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Statues'**
  String get moduleTitle_BronzeProperties;

  /// No description provided for @moduleDesc_BronzeProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Kongfu World bronze statues'**
  String get moduleDesc_BronzeProperties;

  /// No description provided for @moduleTitle_ArmrackProperties.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands'**
  String get moduleTitle_ArmrackProperties;

  /// No description provided for @moduleDesc_ArmrackProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures weapon stand display on the lawn (wave 1 only)'**
  String get moduleDesc_ArmrackProperties;

  /// No description provided for @moduleTitle_EnergyGridProperties.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles'**
  String get moduleTitle_EnergyGridProperties;

  /// No description provided for @moduleDesc_EnergyGridProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Taiji Tile display on the lawn (wave 1 only)'**
  String get moduleDesc_EnergyGridProperties;

  /// No description provided for @bronzeModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Statues'**
  String get bronzeModuleTitle;

  /// No description provided for @bronzeModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Statues'**
  String get bronzeModuleHelpTitle;

  /// No description provided for @bronzeModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get bronzeModuleHelpOverview;

  /// No description provided for @bronzeModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to place bronze statue grid items on the lawn that exist at the start of the level, commonly used in the Kongfu World brain buster \"Bronze Matrix\". Bronze statues gradually lose their copper coating over time and will revive as gargantuar bronzes when the specified countdown ends. The HP of a bronze statue is the same as the corresponding Tier 1 Gargantuar Bronze.\nShake offset (shakeOffset) indicates the center offset of the revive animation’s shaking; adjusting this value has no practical effect.\nNote: This module itself does not include the effect of instantly eliminating remaining zombies after all bronze statues and gargantuar bronzes on the lawn are destroyed. To achieve that effect, the Bronze Matrix Loot Drop module must be added.'**
  String get bronzeModuleHelpOverviewBody;

  /// No description provided for @bronzeModuleHelpBatches.
  ///
  /// In en, this message translates to:
  /// **'Revival Logic'**
  String get bronzeModuleHelpBatches;

  /// No description provided for @bronzeModuleHelpBatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Each bronze statue added generates a corresponding entry in the level file. Revival timing is determined by the spawn time (spawnTime), in seconds, and is independent of waves. Bronze statues with the same spawn time will revive simultaneously.\nThe revival countdown for subsequent batches is offset from the first batch. For example, if the first batch is set to 30s, the second to 45s, and the third to 50s, then the second batch will revive 15s after the first, and the third batch 5s after the second.'**
  String get bronzeModuleHelpBatchesBody;

  /// No description provided for @bronzeModuleShakeOffset.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get bronzeModuleShakeOffset;

  /// No description provided for @bronzeModuleShakeOffsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Shake offset'**
  String get bronzeModuleShakeOffsetLabel;

  /// No description provided for @bronzeModuleInCell.
  ///
  /// In en, this message translates to:
  /// **'Bronze statue(s) in selected tile'**
  String get bronzeModuleInCell;

  /// No description provided for @bronzeModuleAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add bronze statue'**
  String get bronzeModuleAddTitle;

  /// No description provided for @bronzeKindStrength.
  ///
  /// In en, this message translates to:
  /// **'Han Bronze (strength)'**
  String get bronzeKindStrength;

  /// No description provided for @bronzeKindMage.
  ///
  /// In en, this message translates to:
  /// **'Qigong Bronze (mage)'**
  String get bronzeKindMage;

  /// No description provided for @bronzeKindAgile.
  ///
  /// In en, this message translates to:
  /// **'Xiake Bronze (agile)'**
  String get bronzeKindAgile;

  /// No description provided for @bronzeKindStrengthShort.
  ///
  /// In en, this message translates to:
  /// **'Han Bronze'**
  String get bronzeKindStrengthShort;

  /// No description provided for @bronzeKindMageShort.
  ///
  /// In en, this message translates to:
  /// **'Qigong Bronze'**
  String get bronzeKindMageShort;

  /// No description provided for @bronzeKindAgileShort.
  ///
  /// In en, this message translates to:
  /// **'Xiake Bronze'**
  String get bronzeKindAgileShort;

  /// No description provided for @bronzeModuleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bronzeModuleTypeLabel;

  /// No description provided for @bronzeModuleSpawnTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Revival time (seconds)'**
  String get bronzeModuleSpawnTimeLabel;

  /// No description provided for @moduleTitle_WarMistProperties.
  ///
  /// In en, this message translates to:
  /// **'Fog System'**
  String get moduleTitle_WarMistProperties;

  /// No description provided for @moduleDesc_WarMistProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Dark Ages fog coverage and interaction'**
  String get moduleDesc_WarMistProperties;

  /// No description provided for @moduleTitle_RainDarkProperties.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get moduleTitle_RainDarkProperties;

  /// No description provided for @moduleDesc_RainDarkProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets rain, snow, and lightning effects'**
  String get moduleDesc_RainDarkProperties;

  /// No description provided for @eventTitle_SpawnZombiesFromGroundSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Ground Spawner'**
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps;

  /// No description provided for @eventDesc_SpawnZombiesFromGroundSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from underground'**
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps;

  /// No description provided for @eventTitle_SpawnZombiesJitteredWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Basic Spawner'**
  String get eventTitle_SpawnZombiesJitteredWaveActionProps;

  /// No description provided for @eventDesc_SpawnZombiesJitteredWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Standard natural zombie spawning event'**
  String get eventDesc_SpawnZombiesJitteredWaveActionProps;

  /// No description provided for @eventTitle_FrostWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Freezing Wind'**
  String get eventTitle_FrostWindWaveActionProps;

  /// No description provided for @eventDesc_FrostWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Blows freezing wind on specific rows'**
  String get eventDesc_FrostWindWaveActionProps;

  /// No description provided for @eventTitle_BeachStageEventZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Low Tide'**
  String get eventTitle_BeachStageEventZombieSpawnerProps;

  /// No description provided for @eventDesc_BeachStageEventZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies emerge during low tide'**
  String get eventDesc_BeachStageEventZombieSpawnerProps;

  /// No description provided for @eventTitle_TidalChangeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Tide Change'**
  String get eventTitle_TidalChangeWaveActionProps;

  /// No description provided for @eventDesc_TidalChangeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Changes the tide position'**
  String get eventDesc_TidalChangeWaveActionProps;

  /// No description provided for @eventTitle_TideWaveWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Ocean Current'**
  String get eventTitle_TideWaveWaveActionProps;

  /// No description provided for @eventDesc_TideWaveWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Moves submarine and affects zombie movement speed'**
  String get eventDesc_TideWaveWaveActionProps;

  /// No description provided for @eventTitle_SpawnZombiesFishWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Underwater Spawner'**
  String get eventTitle_SpawnZombiesFishWaveActionProps;

  /// No description provided for @eventDesc_SpawnZombiesFishWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies or sea creatures from the left or right side of the lawn; can only be used in Underwater World'**
  String get eventDesc_SpawnZombiesFishWaveActionProps;

  /// No description provided for @eventTitle_ModifyConveyorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Change'**
  String get eventTitle_ModifyConveyorWaveActionProps;

  /// No description provided for @eventDesc_ModifyConveyorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dynamically adds or removes conveyor plants'**
  String get eventDesc_ModifyConveyorWaveActionProps;

  /// No description provided for @eventTitle_DinoWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Summon'**
  String get eventTitle_DinoWaveActionProps;

  /// No description provided for @eventDesc_DinoWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Summons a dinosaur to assist zombies'**
  String get eventDesc_DinoWaveActionProps;

  /// No description provided for @eventTitle_DinoTreadActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Stomp'**
  String get eventTitle_DinoTreadActionProps;

  /// No description provided for @eventDesc_DinoTreadActionProps.
  ///
  /// In en, this message translates to:
  /// **'Brachiosaurus stomps within a set area, dealing damage'**
  String get eventDesc_DinoTreadActionProps;

  /// No description provided for @eventTitle_DinoRunActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Stampede'**
  String get eventTitle_DinoRunActionProps;

  /// No description provided for @eventDesc_DinoRunActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dinosaurs charge down their lane, trampling plants and zombies'**
  String get eventDesc_DinoRunActionProps;

  /// No description provided for @eventTitle_SpawnModernPortalsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spacetime Portal'**
  String get eventTitle_SpawnModernPortalsWaveActionProps;

  /// No description provided for @eventDesc_SpawnModernPortalsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Summons spacetime portals at specific locations'**
  String get eventDesc_SpawnModernPortalsWaveActionProps;

  /// No description provided for @eventTitle_StormZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Storm Raid'**
  String get eventTitle_StormZombieSpawnerProps;

  /// No description provided for @eventDesc_StormZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Sandstorms or snowstorms bring in zombies'**
  String get eventDesc_StormZombieSpawnerProps;

  /// No description provided for @eventTitle_RaidingPartyZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Raiding Party'**
  String get eventTitle_RaidingPartyZombieSpawnerProps;

  /// No description provided for @eventDesc_RaidingPartyZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Summons multiple Swashbuckler Zombies'**
  String get eventDesc_RaidingPartyZombieSpawnerProps;

  /// No description provided for @eventTitle_ZombiePotionActionProps.
  ///
  /// In en, this message translates to:
  /// **'Potion Drop'**
  String get eventTitle_ZombiePotionActionProps;

  /// No description provided for @eventDesc_ZombiePotionActionProps.
  ///
  /// In en, this message translates to:
  /// **'Force spawns grid items at set positions'**
  String get eventDesc_ZombiePotionActionProps;

  /// No description provided for @eventTitle_ZombieAtlantisShellActionProps.
  ///
  /// In en, this message translates to:
  /// **'Seashell Spawn'**
  String get eventTitle_ZombieAtlantisShellActionProps;

  /// No description provided for @eventDesc_ZombieAtlantisShellActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns atlantis seashells at set positions'**
  String get eventDesc_ZombieAtlantisShellActionProps;

  /// No description provided for @eventTitle_PumpkinHouseActionProps.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin House Spawn'**
  String get eventTitle_PumpkinHouseActionProps;

  /// No description provided for @eventDesc_PumpkinHouseActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns pumpkin houses on the lawn at set positions'**
  String get eventDesc_PumpkinHouseActionProps;

  /// No description provided for @eventTitle_SpawnGravestonesWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Grid Item Spawn'**
  String get eventTitle_SpawnGravestonesWaveActionProps;

  /// No description provided for @eventDesc_SpawnGravestonesWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns grid items on empty tiles'**
  String get eventDesc_SpawnGravestonesWaveActionProps;

  /// No description provided for @eventTitle_SpawnZombiesFromGridItemSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Grid Item Spawner'**
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps;

  /// No description provided for @eventDesc_SpawnZombiesFromGridItemSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from specific grid items'**
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps;

  /// No description provided for @eventTitle_FairyTaleFogWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Magic Fog'**
  String get eventTitle_FairyTaleFogWaveActionProps;

  /// No description provided for @eventDesc_FairyTaleFogWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Creates fog that covers the lawn and grants shields to zombies'**
  String get eventDesc_FairyTaleFogWaveActionProps;

  /// No description provided for @eventTitle_FairyTaleWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Fairytale Breeze'**
  String get eventTitle_FairyTaleWindWaveActionProps;

  /// No description provided for @eventDesc_FairyTaleWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Blows away all Magic Fog on the lawn'**
  String get eventDesc_FairyTaleWindWaveActionProps;

  /// No description provided for @eventTitle_SpiderRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Imp Rain'**
  String get eventTitle_SpiderRainZombieSpawnerProps;

  /// No description provided for @eventDesc_SpiderRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Imps drop in from above'**
  String get eventDesc_SpiderRainZombieSpawnerProps;

  /// No description provided for @eventTitle_ParachuteRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Parachute Rain'**
  String get eventTitle_ParachuteRainZombieSpawnerProps;

  /// No description provided for @eventDesc_ParachuteRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop in by parachute'**
  String get eventDesc_ParachuteRainZombieSpawnerProps;

  /// No description provided for @eventTitle_BassRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Bass/Jetpack Rain'**
  String get eventTitle_BassRainZombieSpawnerProps;

  /// No description provided for @eventDesc_BassRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Jetpack or Bass Zombies drop in from above'**
  String get eventDesc_BassRainZombieSpawnerProps;

  /// No description provided for @eventTitle_BlackHoleWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Black Hole'**
  String get eventTitle_BlackHoleWaveActionProps;

  /// No description provided for @eventDesc_BlackHoleWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Generates a black hole to pull all plants'**
  String get eventDesc_BlackHoleWaveActionProps;

  /// No description provided for @eventTitle_BarrelWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Barrel Crisis'**
  String get eventTitle_BarrelWaveActionProps;

  /// No description provided for @eventDesc_BarrelWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns barrels with different abilities in set lanes'**
  String get eventDesc_BarrelWaveActionProps;

  /// No description provided for @eventTitle_SchoolBusWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream Van Spawn'**
  String get eventTitle_SchoolBusWaveActionProps;

  /// No description provided for @eventDesc_SchoolBusWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns an ice cream van in a lane and configures the zombies inside'**
  String get eventDesc_SchoolBusWaveActionProps;

  /// No description provided for @eventTitle_BungeeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Bungee Drop'**
  String get eventTitle_BungeeWaveActionProps;

  /// No description provided for @eventDesc_BungeeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Drops a zombie by bungee to the lawn'**
  String get eventDesc_BungeeWaveActionProps;

  /// No description provided for @eventTitle_ThunderWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Thundercloud Storm'**
  String get eventTitle_ThunderWaveActionProps;

  /// No description provided for @eventDesc_ThunderWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Lightning strikes, applying positive or negative charges to plants'**
  String get eventDesc_ThunderWaveActionProps;

  /// No description provided for @eventTitle_MagicMirrorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Magic Mirror'**
  String get eventTitle_MagicMirrorWaveActionProps;

  /// No description provided for @eventDesc_MagicMirrorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Generates paired teleportation mirrors'**
  String get eventDesc_MagicMirrorWaveActionProps;

  /// No description provided for @weatherOption_DefaultSnow_label.
  ///
  /// In en, this message translates to:
  /// **'Glacial Snowfall (DefaultSnow)'**
  String get weatherOption_DefaultSnow_label;

  /// No description provided for @weatherOption_DefaultSnow_desc.
  ///
  /// In en, this message translates to:
  /// **'Snowfall effect used in Frostbite Caves Resurgence'**
  String get weatherOption_DefaultSnow_desc;

  /// No description provided for @weatherOption_LightningRain_label.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm (LightningRain)'**
  String get weatherOption_LightningRain_label;

  /// No description provided for @weatherOption_LightningRain_desc.
  ///
  /// In en, this message translates to:
  /// **'Rain with lightning strikes that are purely visual'**
  String get weatherOption_LightningRain_desc;

  /// No description provided for @weatherOption_DefaultRainDark_label.
  ///
  /// In en, this message translates to:
  /// **'Dark Rain (DefaultRainDark)'**
  String get weatherOption_DefaultRainDark_label;

  /// No description provided for @weatherOption_DefaultRainDark_desc.
  ///
  /// In en, this message translates to:
  /// **'Briefly covers the lawn in darkness before returning to normal'**
  String get weatherOption_DefaultRainDark_desc;

  /// No description provided for @iZombiePlantReserveLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserved Plant Column (PlantDistance)'**
  String get iZombiePlantReserveLabel;

  /// No description provided for @column.
  ///
  /// In en, this message translates to:
  /// **'Column(s)'**
  String get column;

  /// No description provided for @iZombieInfoText.
  ///
  /// In en, this message translates to:
  /// **'In I, Zombie Mode, preset plants and zombies must be configured in the Preset Plants and Seed Bank modules respectively.'**
  String get iZombieInfoText;

  /// No description provided for @vaseRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase Spawn Range & Disabled Tiles'**
  String get vaseRangeTitle;

  /// No description provided for @startColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Col (Min)'**
  String get startColumnLabel;

  /// No description provided for @endColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'End Col (Max)'**
  String get endColumnLabel;

  /// No description provided for @toggleBlacklistHint.
  ///
  /// In en, this message translates to:
  /// **'Tap tiles to toggle disabled status (vases will not spawn on disabled tiles)'**
  String get toggleBlacklistHint;

  /// No description provided for @vaseCapacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase Capacity'**
  String get vaseCapacityTitle;

  /// No description provided for @vaseCapacitySummary.
  ///
  /// In en, this message translates to:
  /// **'Assigned: {current} / Total Slots: {total}'**
  String vaseCapacitySummary(Object current, Object total);

  /// No description provided for @vaseListTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase List'**
  String get vaseListTitle;

  /// No description provided for @addVaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Vase'**
  String get addVaseTitle;

  /// No description provided for @plantVaseOption.
  ///
  /// In en, this message translates to:
  /// **'Plant Vase (Green)'**
  String get plantVaseOption;

  /// No description provided for @zombieVaseOption.
  ///
  /// In en, this message translates to:
  /// **'Zombie Vase (Purple)'**
  String get zombieVaseOption;

  /// No description provided for @selectZombie.
  ///
  /// In en, this message translates to:
  /// **'Select zombie'**
  String get selectZombie;

  /// No description provided for @searchZombie.
  ///
  /// In en, this message translates to:
  /// **'Search zombie'**
  String get searchZombie;

  /// No description provided for @noZombieFound.
  ///
  /// In en, this message translates to:
  /// **'No zombie found'**
  String get noZombieFound;

  /// No description provided for @unknownVaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown Vase'**
  String get unknownVaseLabel;

  /// No description provided for @plantLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plantLabel;

  /// No description provided for @zombieLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie'**
  String get zombieLabel;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @railcartSettings.
  ///
  /// In en, this message translates to:
  /// **'Minecart and Rail Settings'**
  String get railcartSettings;

  /// No description provided for @railcartType.
  ///
  /// In en, this message translates to:
  /// **'Minecart type'**
  String get railcartType;

  /// No description provided for @layRails.
  ///
  /// In en, this message translates to:
  /// **'Lay rails'**
  String get layRails;

  /// No description provided for @placeCarts.
  ///
  /// In en, this message translates to:
  /// **'Place minecarts'**
  String get placeCarts;

  /// No description provided for @railSegments.
  ///
  /// In en, this message translates to:
  /// **'Rail segment'**
  String get railSegments;

  /// No description provided for @railcartCount.
  ///
  /// In en, this message translates to:
  /// **'Railcart count'**
  String get railcartCount;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @moduleCategoryBase.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get moduleCategoryBase;

  /// No description provided for @moduleCategoryMode.
  ///
  /// In en, this message translates to:
  /// **'Special Modes'**
  String get moduleCategoryMode;

  /// No description provided for @moduleCategoryScene.
  ///
  /// In en, this message translates to:
  /// **'Scene Config'**
  String get moduleCategoryScene;

  /// No description provided for @moduleCategoryGimmick.
  ///
  /// In en, this message translates to:
  /// **'Gimmick Config'**
  String get moduleCategoryGimmick;

  /// No description provided for @moduleTitle_RocketZombieFlickModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Rocket Flick'**
  String get moduleTitle_RocketZombieFlickModuleProperties;

  /// No description provided for @moduleDesc_RocketZombieFlickModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables swiping to knock Rocket Imps off their rockets'**
  String get moduleDesc_RocketZombieFlickModuleProperties;

  /// No description provided for @kongfuRocketFlickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'This Module Can Be Added'**
  String get kongfuRocketFlickDialogTitle;

  /// No description provided for @kongfuRocketFlickDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The \"Rocket Flick\" module lets you swipe rockets on the screen to knock Rocket Imps off them. Add this module?'**
  String get kongfuRocketFlickDialogMessage;

  /// No description provided for @customZombie.
  ///
  /// In en, this message translates to:
  /// **'Custom zombie'**
  String get customZombie;

  /// No description provided for @customZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom Zombie Properties'**
  String get customZombieProperties;

  /// No description provided for @zombieTypeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Zombie type object not found.'**
  String get zombieTypeNotFound;

  /// No description provided for @propertyObjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property object not found'**
  String get propertyObjectNotFound;

  /// No description provided for @propertyObjectNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'The custom zombie\'s property object ({alias}) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.'**
  String propertyObjectNotFoundHint(Object alias);

  /// No description provided for @baseStats.
  ///
  /// In en, this message translates to:
  /// **'Base stats'**
  String get baseStats;

  /// No description provided for @hitpoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get hitpoints;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Movement speed (Speed)'**
  String get speed;

  /// No description provided for @speedVariance.
  ///
  /// In en, this message translates to:
  /// **'Speed variance (Variance)'**
  String get speedVariance;

  /// No description provided for @eatDPS.
  ///
  /// In en, this message translates to:
  /// **'Bite damage per second (EatDPS)'**
  String get eatDPS;

  /// No description provided for @hitPosition.
  ///
  /// In en, this message translates to:
  /// **'Hit & Position'**
  String get hitPosition;

  /// No description provided for @hitRect.
  ///
  /// In en, this message translates to:
  /// **'Hitbox (HitRect)'**
  String get hitRect;

  /// No description provided for @editHitRect.
  ///
  /// In en, this message translates to:
  /// **'Edit Hitbox (HitRect)'**
  String get editHitRect;

  /// No description provided for @attackRect.
  ///
  /// In en, this message translates to:
  /// **'Eating Range (AttackRect)'**
  String get attackRect;

  /// No description provided for @editAttackRect.
  ///
  /// In en, this message translates to:
  /// **'Edit Eating Range (AttackRect)'**
  String get editAttackRect;

  /// No description provided for @artCenter.
  ///
  /// In en, this message translates to:
  /// **'Sprite Center (ArtCenter)'**
  String get artCenter;

  /// No description provided for @editArtCenter.
  ///
  /// In en, this message translates to:
  /// **'Edit Sprite Center (ArtCenter)'**
  String get editArtCenter;

  /// No description provided for @shadowOffset.
  ///
  /// In en, this message translates to:
  /// **'Shadow Offset (ShadowOffset)'**
  String get shadowOffset;

  /// No description provided for @editShadowOffset.
  ///
  /// In en, this message translates to:
  /// **'Edit Shadow Offset (ShadowOffset)'**
  String get editShadowOffset;

  /// No description provided for @groundTrackName.
  ///
  /// In en, this message translates to:
  /// **'Movement Track (GroundTrackName)'**
  String get groundTrackName;

  /// No description provided for @groundTrackNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal ground (ground_swatch)'**
  String get groundTrackNormal;

  /// No description provided for @groundTrackNone.
  ///
  /// In en, this message translates to:
  /// **'None (null)'**
  String get groundTrackNone;

  /// No description provided for @appearanceBehavior.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Behavior'**
  String get appearanceBehavior;

  /// No description provided for @sizeType.
  ///
  /// In en, this message translates to:
  /// **'Zombie Size (SizeType)'**
  String get sizeType;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select size'**
  String get selectSize;

  /// No description provided for @disableDropFractions.
  ///
  /// In en, this message translates to:
  /// **'Disable corpse HP (headDropFraction)'**
  String get disableDropFractions;

  /// No description provided for @immuneToKnockback.
  ///
  /// In en, this message translates to:
  /// **'Immune to knockback (CanBeLaunchedByPlants)'**
  String get immuneToKnockback;

  /// No description provided for @showHealthBarOnDamage.
  ///
  /// In en, this message translates to:
  /// **'Show health bar on damage (EnableShowHealthBar)'**
  String get showHealthBarOnDamage;

  /// No description provided for @drawHealthBarTime.
  ///
  /// In en, this message translates to:
  /// **'Health bar duration (DrawHealthBarTime)'**
  String get drawHealthBarTime;

  /// No description provided for @enableEliteScale.
  ///
  /// In en, this message translates to:
  /// **'Enable elite scaling (EnableEliteScale)'**
  String get enableEliteScale;

  /// No description provided for @eliteScale.
  ///
  /// In en, this message translates to:
  /// **'Scale (EliteScale)'**
  String get eliteScale;

  /// No description provided for @enableEliteImmunities.
  ///
  /// In en, this message translates to:
  /// **'Enable elite immunities (EnableEliteImmunities)'**
  String get enableEliteImmunities;

  /// No description provided for @canSpawnPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Can drop Plant Food (CanSpawnPlantFood)'**
  String get canSpawnPlantFood;

  /// No description provided for @canSurrender.
  ///
  /// In en, this message translates to:
  /// **'Can die immediately at the end if no other zombies remain (CanSurrender)'**
  String get canSurrender;

  /// No description provided for @canTriggerZombieWin.
  ///
  /// In en, this message translates to:
  /// **'Can trigger game over when reaching the house (CanTriggerZombieWin)'**
  String get canTriggerZombieWin;

  /// No description provided for @resilience.
  ///
  /// In en, this message translates to:
  /// **'Resistances (Resistences)'**
  String get resilience;

  /// No description provided for @resilienceArmor.
  ///
  /// In en, this message translates to:
  /// **'Resilience Bar'**
  String get resilienceArmor;

  /// No description provided for @enableResilience.
  ///
  /// In en, this message translates to:
  /// **'Enable resilience'**
  String get enableResilience;

  /// No description provided for @resilienceSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get resilienceSource;

  /// No description provided for @resiliencePreset.
  ///
  /// In en, this message translates to:
  /// **'Existing'**
  String get resiliencePreset;

  /// No description provided for @resilienceCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get resilienceCustom;

  /// No description provided for @resiliencePresetSelect.
  ///
  /// In en, this message translates to:
  /// **'Selected resilience shield'**
  String get resiliencePresetSelect;

  /// No description provided for @resilienceAmount.
  ///
  /// In en, this message translates to:
  /// **'Resilience value (Amount)'**
  String get resilienceAmount;

  /// No description provided for @resilienceWeakType.
  ///
  /// In en, this message translates to:
  /// **'Resilience type (WeakType)'**
  String get resilienceWeakType;

  /// No description provided for @resilienceRecoverSpeed.
  ///
  /// In en, this message translates to:
  /// **'Resilience bar recovery speed (RecoverSpeed)'**
  String get resilienceRecoverSpeed;

  /// No description provided for @resilienceDamageThresholdPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Zombie damage threshold per second (DamageThresholdPerSecond)'**
  String get resilienceDamageThresholdPerSecond;

  /// No description provided for @resilienceBaseDamageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Resilience base damage threshold (ResilienceBaseDamageThreshold)'**
  String get resilienceBaseDamageThreshold;

  /// No description provided for @resilienceExtraDamageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Resilience extra damage threshold (ResilienceExtraDamageThreshold)'**
  String get resilienceExtraDamageThreshold;

  /// No description provided for @resilienceCodename.
  ///
  /// In en, this message translates to:
  /// **'Resilience codename (aliases)'**
  String get resilienceCodename;

  /// No description provided for @resilienceCodenameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CustomResilience0'**
  String get resilienceCodenameHint;

  /// No description provided for @resistances.
  ///
  /// In en, this message translates to:
  /// **'Resistances'**
  String get resistances;

  /// No description provided for @zombieResilience.
  ///
  /// In en, this message translates to:
  /// **'Armor / Resilience'**
  String get zombieResilience;

  /// No description provided for @resilienceEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable armor'**
  String get resilienceEnable;

  /// No description provided for @weakTypeExplosive.
  ///
  /// In en, this message translates to:
  /// **'Explosive'**
  String get weakTypeExplosive;

  /// No description provided for @instantKillResistance.
  ///
  /// In en, this message translates to:
  /// **'Instant kill resistance (chance to ignore instant kill effects)'**
  String get instantKillResistance;

  /// No description provided for @resiliencePhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get resiliencePhysics;

  /// No description provided for @resiliencePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get resiliencePoison;

  /// No description provided for @resilienceElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get resilienceElectric;

  /// No description provided for @resilienceMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get resilienceMagic;

  /// No description provided for @resilienceIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get resilienceIce;

  /// No description provided for @resilienceFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get resilienceFire;

  /// No description provided for @resilienceHint.
  ///
  /// In en, this message translates to:
  /// **'Value range: 0.0–1.0 (0.0 = no resistance, 1.0 = full immunity)'**
  String get resilienceHint;

  /// No description provided for @resilienceSelectedShieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected Resilience Shield:'**
  String get resilienceSelectedShieldLabel;

  /// No description provided for @selectionFilterBySource.
  ///
  /// In en, this message translates to:
  /// **'By source'**
  String get selectionFilterBySource;

  /// No description provided for @selectionFilterByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get selectionFilterByType;

  /// No description provided for @selectionPreMade.
  ///
  /// In en, this message translates to:
  /// **'Pre-made'**
  String get selectionPreMade;

  /// No description provided for @selectionDefinedByUser.
  ///
  /// In en, this message translates to:
  /// **'Defined by user'**
  String get selectionDefinedByUser;

  /// No description provided for @aliasAlreadyTakenTitle.
  ///
  /// In en, this message translates to:
  /// **'Alias already taken'**
  String get aliasAlreadyTakenTitle;

  /// No description provided for @aliasRenameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename alias?'**
  String get aliasRenameConfirmTitle;

  /// No description provided for @aliasRenameConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Rename \"{oldAlias}\" to \"{newAlias}\"? All references in this level will be updated.'**
  String aliasRenameConfirmMessage(String oldAlias, String newAlias);

  /// No description provided for @resilienceSelectShield.
  ///
  /// In en, this message translates to:
  /// **'Select resilience shield'**
  String get resilienceSelectShield;

  /// No description provided for @resilienceCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'New custom shield'**
  String get resilienceCreateCustom;

  /// No description provided for @resilienceEditCustom.
  ///
  /// In en, this message translates to:
  /// **'Edit custom shield'**
  String get resilienceEditCustom;

  /// No description provided for @resilienceSourceResilienceConfig.
  ///
  /// In en, this message translates to:
  /// **'ResilienceConfig'**
  String get resilienceSourceResilienceConfig;

  /// No description provided for @resilienceSourceCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'CurrentLevel'**
  String get resilienceSourceCurrentLevel;

  /// No description provided for @resilienceTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get resilienceTypeAll;

  /// No description provided for @resilienceNoShieldsFound.
  ///
  /// In en, this message translates to:
  /// **'No resilience shields found'**
  String get resilienceNoShieldsFound;

  /// No description provided for @resilienceShieldInUseCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete — this shield is used by zombies in this level.'**
  String get resilienceShieldInUseCannotDelete;

  /// No description provided for @resilienceShieldDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete custom resilience shield?'**
  String get resilienceShieldDeleteTitle;

  /// No description provided for @resilienceShieldDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{alias}\" from this level?'**
  String resilienceShieldDeleteMessage(String alias);

  /// No description provided for @aliasAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Alias already exists in this level.'**
  String get aliasAlreadyExists;

  /// No description provided for @zombieTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie type: {type}'**
  String zombieTypeLabel(Object type);

  /// No description provided for @propertyAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Property alias: {alias}'**
  String propertyAliasLabel(Object alias);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @customZombieHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Brief introduction'**
  String get customZombieHelpIntro;

  /// No description provided for @customZombieHelpIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.'**
  String get customZombieHelpIntroBody;

  /// No description provided for @customZombieHelpBase.
  ///
  /// In en, this message translates to:
  /// **'Base properties'**
  String get customZombieHelpBase;

  /// No description provided for @customZombieHelpBaseBody.
  ///
  /// In en, this message translates to:
  /// **'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.'**
  String get customZombieHelpBaseBody;

  /// No description provided for @customZombieHelpHit.
  ///
  /// In en, this message translates to:
  /// **'Hit/position'**
  String get customZombieHelpHit;

  /// No description provided for @customZombieHelpHitBody.
  ///
  /// In en, this message translates to:
  /// **'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track as none lets the zombie walk in place.'**
  String get customZombieHelpHitBody;

  /// No description provided for @customZombieHelpManual.
  ///
  /// In en, this message translates to:
  /// **'Manual editing'**
  String get customZombieHelpManual;

  /// No description provided for @customZombieHelpManualBody.
  ///
  /// In en, this message translates to:
  /// **'Custom injection auto-fills all properties from game files. You can further edit the JSON file manually if needed.'**
  String get customZombieHelpManualBody;

  /// No description provided for @editAlias.
  ///
  /// In en, this message translates to:
  /// **'Edit {alias}'**
  String editAlias(Object alias);

  /// No description provided for @editNamedEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit {name} event'**
  String editNamedEvent(Object name);

  /// No description provided for @editNamedModule.
  ///
  /// In en, this message translates to:
  /// **'Edit {name} module'**
  String editNamedModule(Object name);

  /// No description provided for @addEventAliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEventAliasTitle;

  /// No description provided for @addModuleAliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Add module'**
  String get addModuleAliasTitle;

  /// No description provided for @aliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Alias'**
  String get aliasLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @maxCount.
  ///
  /// In en, this message translates to:
  /// **'Max count'**
  String get maxCount;

  /// No description provided for @startColumn.
  ///
  /// In en, this message translates to:
  /// **'Start column'**
  String get startColumn;

  /// No description provided for @endColumn.
  ///
  /// In en, this message translates to:
  /// **'End column'**
  String get endColumn;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeItemConfirm(Object name);

  /// No description provided for @groupN.
  ///
  /// In en, this message translates to:
  /// **'Group {n}'**
  String groupN(int n);

  /// No description provided for @rowN.
  ///
  /// In en, this message translates to:
  /// **'Row {n}'**
  String rowN(int n);

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @addWind.
  ///
  /// In en, this message translates to:
  /// **'Add wind'**
  String get addWind;

  /// No description provided for @addDropItem.
  ///
  /// In en, this message translates to:
  /// **'Add drop item'**
  String get addDropItem;

  /// No description provided for @addMirrorGroup.
  ///
  /// In en, this message translates to:
  /// **'Add a mirror group above'**
  String get addMirrorGroup;

  /// No description provided for @pipeN.
  ///
  /// In en, this message translates to:
  /// **'Pipe {n}'**
  String pipeN(int n);

  /// No description provided for @setStart.
  ///
  /// In en, this message translates to:
  /// **'Set entrance sewer'**
  String get setStart;

  /// No description provided for @setEnd.
  ///
  /// In en, this message translates to:
  /// **'Set exit sewer'**
  String get setEnd;

  /// No description provided for @collectable.
  ///
  /// In en, this message translates to:
  /// **'Collectible (Plant Food)'**
  String get collectable;

  /// No description provided for @selectGridItem.
  ///
  /// In en, this message translates to:
  /// **'Select grid item'**
  String get selectGridItem;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTitle;

  /// No description provided for @initialPlantLayout.
  ///
  /// In en, this message translates to:
  /// **'Initial plant layout'**
  String get initialPlantLayout;

  /// No description provided for @gridItemLayout.
  ///
  /// In en, this message translates to:
  /// **'Grid item layout'**
  String get gridItemLayout;

  /// No description provided for @zombieCount.
  ///
  /// In en, this message translates to:
  /// **'Total count (Total)'**
  String get zombieCount;

  /// No description provided for @groupSize.
  ///
  /// In en, this message translates to:
  /// **'Zombies per group (GroupSize)'**
  String get groupSize;

  /// No description provided for @timeBetweenGroups.
  ///
  /// In en, this message translates to:
  /// **'Group Interval (TimeBetweenGroups; seconds)'**
  String get timeBetweenGroups;

  /// No description provided for @timeBeforeSpawn.
  ///
  /// In en, this message translates to:
  /// **'Time before full spawn (seconds)'**
  String get timeBeforeSpawn;

  /// No description provided for @waterBoundaryColumn.
  ///
  /// In en, this message translates to:
  /// **'Column Offset (ChangeAmount)'**
  String get waterBoundaryColumn;

  /// No description provided for @columnsDragged.
  ///
  /// In en, this message translates to:
  /// **'Columns dragged (ColNumPlantIsDragged)'**
  String get columnsDragged;

  /// No description provided for @typeIndex.
  ///
  /// In en, this message translates to:
  /// **'Mirror Appearance (TypeIndex)'**
  String get typeIndex;

  /// No description provided for @noStyle.
  ///
  /// In en, this message translates to:
  /// **'No style'**
  String get noStyle;

  /// No description provided for @styleN.
  ///
  /// In en, this message translates to:
  /// **'Style {n}'**
  String styleN(int n);

  /// No description provided for @existDurationSec.
  ///
  /// In en, this message translates to:
  /// **'Exist duration (sec)'**
  String get existDurationSec;

  /// No description provided for @mirror1.
  ///
  /// In en, this message translates to:
  /// **'Mirror 1'**
  String get mirror1;

  /// No description provided for @mirror2.
  ///
  /// In en, this message translates to:
  /// **'Mirror 2'**
  String get mirror2;

  /// No description provided for @ignoreGravestone.
  ///
  /// In en, this message translates to:
  /// **'Ignore tombstone (IgnoreGraveStone)'**
  String get ignoreGravestone;

  /// No description provided for @zombiePreview.
  ///
  /// In en, this message translates to:
  /// **'{name} - Zombie preview'**
  String zombiePreview(Object name);

  /// No description provided for @weatherSettings.
  ///
  /// In en, this message translates to:
  /// **'Weather Settings'**
  String get weatherSettings;

  /// No description provided for @holeLifetimeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Crater duration (seconds)'**
  String get holeLifetimeSeconds;

  /// No description provided for @startingWaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Initial tide position (StartingWaveLocation)'**
  String get startingWaveLocation;

  /// No description provided for @rainIntervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'Drop interval (seconds)'**
  String get rainIntervalSeconds;

  /// No description provided for @startingPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get startingPlantFood;

  /// No description provided for @bowlingFoulLine.
  ///
  /// In en, this message translates to:
  /// **'No-planting line'**
  String get bowlingFoulLine;

  /// No description provided for @bowlingMinigameParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get bowlingMinigameParams;

  /// No description provided for @bowlingMinigameHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Sets the column index of the no-planting line for bulb bowling levels. Plants cannot be placed at or beyond this column.'**
  String get bowlingMinigameHelpOverview;

  /// No description provided for @bowlingMinigameHelpFoulLine.
  ///
  /// In en, this message translates to:
  /// **'BowlingFoulLine is a 0-based column index from the left edge of the lawn. Zombies and bowling bulbs interact with plants to the right of this line.'**
  String get bowlingMinigameHelpFoulLine;

  /// No description provided for @stopColumn.
  ///
  /// In en, this message translates to:
  /// **'Stop column (StopColumn, range: 0-9 or 0-10)'**
  String get stopColumn;

  /// No description provided for @speedUp.
  ///
  /// In en, this message translates to:
  /// **'Speed multiplier (SpeedUp)'**
  String get speedUp;

  /// No description provided for @baseCostIncreased.
  ///
  /// In en, this message translates to:
  /// **'Sun cost increase per planting (BaseCostIncreased)'**
  String get baseCostIncreased;

  /// No description provided for @maxIncreasedCount.
  ///
  /// In en, this message translates to:
  /// **'Max Cost Increase Count (MaxIncreasedCount)'**
  String get maxIncreasedCount;

  /// No description provided for @initialMistPositionX.
  ///
  /// In en, this message translates to:
  /// **'Initial fog column'**
  String get initialMistPositionX;

  /// No description provided for @normalValueX.
  ///
  /// In en, this message translates to:
  /// **'Extension distance to the right (1 tile = 64 units)'**
  String get normalValueX;

  /// No description provided for @bloverEffectInterval.
  ///
  /// In en, this message translates to:
  /// **'Blover effect interval (seconds)'**
  String get bloverEffectInterval;

  /// No description provided for @dinoType.
  ///
  /// In en, this message translates to:
  /// **'Dinosaur type'**
  String get dinoType;

  /// No description provided for @dinoRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get dinoRowTitle;

  /// No description provided for @dinoRow.
  ///
  /// In en, this message translates to:
  /// **'Row: {n}'**
  String dinoRow(int n);

  /// No description provided for @dinoWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'Stay duration (waves)'**
  String get dinoWaveDuration;

  /// No description provided for @eventHelpDinoType.
  ///
  /// In en, this message translates to:
  /// **'Which dinosaur enters the lawn. Each species has different behavior when assisting zombies.'**
  String get eventHelpDinoType;

  /// No description provided for @eventHelpDinoRow.
  ///
  /// In en, this message translates to:
  /// **'Row where the dinosaur appears, counted from the top (0-based). On deep-sea lawns, row 5 is also available.'**
  String get eventHelpDinoRow;

  /// No description provided for @eventHelpDinoWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'How many waves the dinosaur stays on the lawn before leaving.'**
  String get eventHelpDinoWaveDuration;

  /// No description provided for @unknownModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Module editor in development'**
  String get unknownModuleTitle;

  /// No description provided for @unknownModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown module'**
  String get unknownModuleHelpTitle;

  /// No description provided for @unknownModuleHelpBody.
  ///
  /// In en, this message translates to:
  /// **'This module is not registered in the level interpreter. It may be manually modified objclass.'**
  String get unknownModuleHelpBody;

  /// No description provided for @noEditorForModule.
  ///
  /// In en, this message translates to:
  /// **'No editor available for this module'**
  String get noEditorForModule;

  /// No description provided for @noEditorForModuleBody.
  ///
  /// In en, this message translates to:
  /// **'This module is not registered in the level interpreter, so no editor is available. It may also be due to the module\'s objclass being manually modified, preventing it from being read correctly.'**
  String get noEditorForModuleBody;

  /// No description provided for @invalidEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid event'**
  String get invalidEventTitle;

  /// No description provided for @invalidEventBody.
  ///
  /// In en, this message translates to:
  /// **'This event object could not be parsed.'**
  String get invalidEventBody;

  /// No description provided for @invalidReference.
  ///
  /// In en, this message translates to:
  /// **'Invalid reference'**
  String get invalidReference;

  /// No description provided for @aliasNotFound.
  ///
  /// In en, this message translates to:
  /// **'Alias \"{alias}\" not found'**
  String aliasNotFound(Object alias);

  /// No description provided for @invalidRefBody.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} references this event, but no corresponding entity definition was found in the level. This is usually caused by accidental deletion or manual renaming. Keeping it in the level may cause the game to crash.'**
  String invalidRefBody(int wave);

  /// No description provided for @removeInvalidRef.
  ///
  /// In en, this message translates to:
  /// **'Remove this invalid reference from the wave container'**
  String get removeInvalidRef;

  /// No description provided for @spawnCount.
  ///
  /// In en, this message translates to:
  /// **'Spawn count'**
  String get spawnCount;

  /// No description provided for @columnRangeTiming.
  ///
  /// In en, this message translates to:
  /// **'Column range & timing'**
  String get columnRangeTiming;

  /// No description provided for @waveStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Red warning message'**
  String get waveStartMessage;

  /// No description provided for @zombieTypeZombieName.
  ///
  /// In en, this message translates to:
  /// **'Zombie Settings'**
  String get zombieTypeZombieName;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Shown at the center when the event starts; Chinese input not supported'**
  String get optional;

  /// No description provided for @eventHelpBeachStageBody.
  ///
  /// In en, this message translates to:
  /// **'Zombies emerge from beneath the water. Commonly used for Snorkel Zombies in Big Wave Beach or for zombies that appear during low tide.\nSimilar to Parachute Rain, zombies will spawn in batches. You can specify the total number and spawn range.\nOnly one type of zombie can be used per event. To include multiple types, you need to add multiple events.'**
  String get eventHelpBeachStageBody;

  /// No description provided for @eventHelpTidalChangeBody.
  ///
  /// In en, this message translates to:
  /// **'This event is used to change the tide position during the selected wave. The range of tide changes cannot exceed the bounds of the lawn.'**
  String get eventHelpTidalChangeBody;

  /// No description provided for @eventTideWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Ocean Currents'**
  String get eventTideWave;

  /// No description provided for @eventHelpTideWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Creates ocean currents that push the submarine and grant speed boosts to zombies. Commonly used in Underwater World – 20,000 Leagues Under the Sea levels.'**
  String get eventHelpTideWaveBody;

  /// No description provided for @tideWaveHelpType.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get tideWaveHelpType;

  /// No description provided for @eventHelpTideWaveType.
  ///
  /// In en, this message translates to:
  /// **'Left: Currents come from the left, pushing the submarine right and speeding up zombies on the left side.\nRight: Currents come from the right, pushing the submarine left and speeding up zombies on the right side.'**
  String get eventHelpTideWaveType;

  /// No description provided for @tideWaveHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tideWaveHelpParams;

  /// No description provided for @eventHelpTideWaveParams.
  ///
  /// In en, this message translates to:
  /// **'Unless otherwise specified, the submarine returns to its original position after the duration ends. Plants cannot be planted on the submarine while it is moving.'**
  String get eventHelpTideWaveParams;

  /// No description provided for @tideWaveType.
  ///
  /// In en, this message translates to:
  /// **'Direction (Type)'**
  String get tideWaveType;

  /// No description provided for @tideWaveTypeLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get tideWaveTypeLeft;

  /// No description provided for @tideWaveTypeRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get tideWaveTypeRight;

  /// No description provided for @tideWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get tideWaveDuration;

  /// No description provided for @tideWaveSubmarineMovingDistance.
  ///
  /// In en, this message translates to:
  /// **'Submarine moving distance (columns)'**
  String get tideWaveSubmarineMovingDistance;

  /// No description provided for @tideWaveSpeedUpDuration.
  ///
  /// In en, this message translates to:
  /// **'Speed boost duration (seconds)'**
  String get tideWaveSpeedUpDuration;

  /// No description provided for @tideWaveSpeedUpIncreased.
  ///
  /// In en, this message translates to:
  /// **'Speed boost multiplier (tideWaveSpeedUpIncreased)'**
  String get tideWaveSpeedUpIncreased;

  /// No description provided for @tideWaveSubmarineMovingTime.
  ///
  /// In en, this message translates to:
  /// **'Submarine moving time (seconds)'**
  String get tideWaveSubmarineMovingTime;

  /// No description provided for @tideWaveZombieMovingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Zombie speed in current (tideWaveZombieMovingSpeed; 1 tile = 64 units)'**
  String get tideWaveZombieMovingSpeed;

  /// No description provided for @eventZombieFishWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Underwater Spawner'**
  String get eventZombieFishWave;

  /// No description provided for @eventHelpZombieFishWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Configures the zombies and sea creatures used in Two-Sided Attack, and can only be used in Underwater World levels. Coordinates are 0-based: row 1 = 0, column 10 = 9.'**
  String get eventHelpZombieFishWaveBody;

  /// No description provided for @eventHelpZombieFishWaveFish.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Add sea creature properties\" button to place sea creatures on the lawn. Size of the lawn varies by level: 6×10 in Underwater World, 5×9 in other levels. Rows correspond to Y, columns to X.'**
  String get eventHelpZombieFishWaveFish;

  /// No description provided for @eventHelpBatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Sets all zombies in this wave to the specified level. Elite zombies are unaffected and retain their default level.'**
  String get eventHelpBatchLevel;

  /// No description provided for @eventHelpDropConfig.
  ///
  /// In en, this message translates to:
  /// **'If the number of plants in the drop list equals the number of Plant Food drops, the drops will become seed packets.'**
  String get eventHelpDropConfig;

  /// No description provided for @fishPropertiesEntryHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a tile to select it, then add sea creatures. Tap \"+\" to add built-in sea creatures. Tap a creature\'s icon for more options such as duplicate, delete, or customize. Customized creatures are marked with a blue \"C\". A warning is shown if a creature is placed outside the lawn.'**
  String get fishPropertiesEntryHelp;

  /// No description provided for @fishAddCustom.
  ///
  /// In en, this message translates to:
  /// **'Add custom sea creature'**
  String get fishAddCustom;

  /// No description provided for @addFishLabel.
  ///
  /// In en, this message translates to:
  /// **'Add sea creature'**
  String get addFishLabel;

  /// No description provided for @addBuiltInFishLabel.
  ///
  /// In en, this message translates to:
  /// **'Add built-in sea creature'**
  String get addBuiltInFishLabel;

  /// No description provided for @makeFishAsCustom.
  ///
  /// In en, this message translates to:
  /// **'Make sea creature as custom'**
  String get makeFishAsCustom;

  /// No description provided for @switchCustomFish.
  ///
  /// In en, this message translates to:
  /// **'Switch custom sea creature'**
  String get switchCustomFish;

  /// No description provided for @selectCustomFish.
  ///
  /// In en, this message translates to:
  /// **'Select custom sea creature'**
  String get selectCustomFish;

  /// No description provided for @editCustomFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit custom sea creature properties'**
  String get editCustomFishProperties;

  /// No description provided for @fishPropertiesButton.
  ///
  /// In en, this message translates to:
  /// **'Sea creature properties'**
  String get fishPropertiesButton;

  /// No description provided for @addFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Add sea creature properties'**
  String get addFishProperties;

  /// No description provided for @editFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit sea creature properties'**
  String get editFishProperties;

  /// No description provided for @fishPropertiesGrid.
  ///
  /// In en, this message translates to:
  /// **'Sea Creature placement (row = Y, column = X)'**
  String get fishPropertiesGrid;

  /// No description provided for @fishSelectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected:'**
  String get fishSelectedPosition;

  /// No description provided for @fishRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get fishRow;

  /// No description provided for @fishColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get fishColumn;

  /// No description provided for @fishAtPosition.
  ///
  /// In en, this message translates to:
  /// **'Sea creature at position'**
  String get fishAtPosition;

  /// No description provided for @searchFish.
  ///
  /// In en, this message translates to:
  /// **'Search sea creature'**
  String get searchFish;

  /// No description provided for @noFishFound.
  ///
  /// In en, this message translates to:
  /// **'No sea creature found'**
  String get noFishFound;

  /// No description provided for @customFishManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature'**
  String get customFishManagerTitle;

  /// No description provided for @customFishAppearanceLocation.
  ///
  /// In en, this message translates to:
  /// **'Spawn location:'**
  String get customFishAppearanceLocation;

  /// No description provided for @customFishNotUsed.
  ///
  /// In en, this message translates to:
  /// **'This custom sea creature is not used by any wave.'**
  String get customFishNotUsed;

  /// No description provided for @customFishWaveItem.
  ///
  /// In en, this message translates to:
  /// **'Wave {n}'**
  String customFishWaveItem(int n);

  /// No description provided for @customFishDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this custom sea creature and its property data.'**
  String get customFishDeleteConfirm;

  /// No description provided for @customFish.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature'**
  String get customFish;

  /// No description provided for @customFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature properties'**
  String get customFishProperties;

  /// No description provided for @fishTypeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sea creature type object not found.'**
  String get fishTypeNotFound;

  /// No description provided for @fishTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sea creature type: {type}'**
  String fishTypeLabel(Object type);

  /// No description provided for @customFishHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get customFishHelpIntro;

  /// No description provided for @customFishHelpIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This screen allows you to edit custom sea creature parameters. Only common properties are supported; animation and special attributes require manual JSON editing.'**
  String get customFishHelpIntroBody;

  /// No description provided for @customFishHelpProps.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get customFishHelpProps;

  /// No description provided for @customFishHelpPropsBody.
  ///
  /// In en, this message translates to:
  /// **'HitRect, AttackRect, ScareRect define collision areas. Speed and ScareSpeed control movement. ArtCenter defines center of the sprite.'**
  String get customFishHelpPropsBody;

  /// No description provided for @noEditableFishProps.
  ///
  /// In en, this message translates to:
  /// **'No editable properties found.'**
  String get noEditableFishProps;

  /// No description provided for @fishPropSpeed.
  ///
  /// In en, this message translates to:
  /// **'Movement Speed (Speed)'**
  String get fishPropSpeed;

  /// No description provided for @fishPropScareSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed When Scared (ScareSpeed)'**
  String get fishPropScareSpeed;

  /// No description provided for @fishPropDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get fishPropDamage;

  /// No description provided for @fishPropHitpoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get fishPropHitpoints;

  /// No description provided for @fishPropHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get fishPropHitPoints;

  /// No description provided for @fishPropHitRect.
  ///
  /// In en, this message translates to:
  /// **'Hitbox (HitRect)'**
  String get fishPropHitRect;

  /// No description provided for @fishPropAttackRect.
  ///
  /// In en, this message translates to:
  /// **'Attack Range (AttackRect)'**
  String get fishPropAttackRect;

  /// No description provided for @fishPropScareRect.
  ///
  /// In en, this message translates to:
  /// **'Scare area (ScareRect)'**
  String get fishPropScareRect;

  /// No description provided for @fishPropScarerect.
  ///
  /// In en, this message translates to:
  /// **'Scare area (Sacrerect)'**
  String get fishPropScarerect;

  /// No description provided for @fishPropArtCenter.
  ///
  /// In en, this message translates to:
  /// **'Sprite Center (ArtCenter)'**
  String get fishPropArtCenter;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @eventHelpTidalChangePosition.
  ///
  /// In en, this message translates to:
  /// **'Sets the tide position after the change. The rightmost column is 0, and the leftmost is 9. Accepts integers, including negative values.'**
  String get eventHelpTidalChangePosition;

  /// No description provided for @eventHelpBlackHoleBody.
  ///
  /// In en, this message translates to:
  /// **'A event commonly seen in Kongfu World. A black hole will spawn and pull all plants to the right.'**
  String get eventHelpBlackHoleBody;

  /// No description provided for @eventHelpBlackHoleColumns.
  ///
  /// In en, this message translates to:
  /// **'You can specify how many columns plants are dragged, indicating how many tiles they will be pulled to the right by the black hole.'**
  String get eventHelpBlackHoleColumns;

  /// No description provided for @eventHelpMagicMirrorBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns paired mirrors on the lawn. Each pair consists of an entrance and an exit, both sharing the same appearance.'**
  String get eventHelpMagicMirrorBody;

  /// No description provided for @eventHelpMagicMirrorType.
  ///
  /// In en, this message translates to:
  /// **'You can change the mirror’s appearance to distinguish them. There are 3 different types of Magic Mirrors in this event.'**
  String get eventHelpMagicMirrorType;

  /// No description provided for @eventHelpParachuteRainBody.
  ///
  /// In en, this message translates to:
  /// **'Zombies will parachute in from above for a surprise attack. Commonly used for Bug Bot Imp, Lost Pilot Zombie, Bass Zombie, ZCorp Helpdesk, and more. Zombie levels follow the lawn’s level sequence.'**
  String get eventHelpParachuteRainBody;

  /// No description provided for @eventHelpParachuteRainLogic.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop in batches. You can control the total number and the interval between each batch. Zombies will land randomly within the selected columns. If the total pre-drop delay is reached, any remaining zombies will spawn immediately.\nA red warning message will appear before the event starts. Entering Chinese text in the message may result in garbled characters. You can leave the zombie type empty to use this event purely for message display.'**
  String get eventHelpParachuteRainLogic;

  /// No description provided for @eventHelpModernPortalsBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns a fixed type of spacetime portal on the lawn, commonly seen in Modern Day and Memory Lane.\nOnly one spacetime portal can be configured per event. To have multiple portals appear simultaneously, add multiple Spacetime Portal events within the wave.'**
  String get eventHelpModernPortalsBody;

  /// No description provided for @eventHelpModernPortalsType.
  ///
  /// In en, this message translates to:
  /// **'There are many types of spacetime portals in the game. You can select a specific type and preview the spawned zombies.'**
  String get eventHelpModernPortalsType;

  /// No description provided for @eventHelpModernPortalsIgnore.
  ///
  /// In en, this message translates to:
  /// **'When enabled, spacetime portals will still spawn even if blocked by grid items such as tombstones or surfboards.'**
  String get eventHelpModernPortalsIgnore;

  /// No description provided for @eventHelpFrostWindBody.
  ///
  /// In en, this message translates to:
  /// **'A common event in Frostbite Caves. Freezing wind is generated on specified rows, freezing plants into ice blocks.'**
  String get eventHelpFrostWindBody;

  /// No description provided for @eventHelpFrostWindDirection.
  ///
  /// In en, this message translates to:
  /// **'You can set the direction of the wind (from left or right). Note that there is an interval between each wind event. To make them occur simultaneously, try adding multiple Freezing Wind events.'**
  String get eventHelpFrostWindDirection;

  /// No description provided for @eventHelpModifyConveyorBody.
  ///
  /// In en, this message translates to:
  /// **'This event allows you to modify conveyor belt plants during gameplay. Parameters are similar to the conveyor belt module. Make sure the conveyor belt module is already included in the level.'**
  String get eventHelpModifyConveyorBody;

  /// No description provided for @eventHelpModifyConveyorAdd.
  ///
  /// In en, this message translates to:
  /// **'Adds new plants or tool packets to the conveyor belt. If the plant already exists, its previous data will be overwritten.'**
  String get eventHelpModifyConveyorAdd;

  /// No description provided for @eventHelpModifyConveyorRemove.
  ///
  /// In en, this message translates to:
  /// **'Removing does not work when the Creative Courtyard module is enabled. Instead, set the plant’s weight to 0 to achieve the same effect.'**
  String get eventHelpModifyConveyorRemove;

  /// No description provided for @eventHelpDinoBody.
  ///
  /// In en, this message translates to:
  /// **'A common event in Jurassic Marsh. Summons a specified dinosaur into a chosen row. The dinosaur will assist zombies in attacking.\nOnly one dinosaur can be configured per event. To have multiple dinosaurs appear simultaneously, add multiple Dino Summon events within the wave.'**
  String get eventHelpDinoBody;

  /// No description provided for @eventHelpDinoDuration.
  ///
  /// In en, this message translates to:
  /// **'The duration the dinosaur stays on the lawn, measured in waves. It will leave after the time expires or after interacting with enough zombies.'**
  String get eventHelpDinoDuration;

  /// No description provided for @eventDinoTread.
  ///
  /// In en, this message translates to:
  /// **'Event: Dino Stomp'**
  String get eventDinoTread;

  /// No description provided for @eventDinoRun.
  ///
  /// In en, this message translates to:
  /// **'Event: Dino Stampede'**
  String get eventDinoRun;

  /// No description provided for @eventHelpDinoTreadBody.
  ///
  /// In en, this message translates to:
  /// **'Brontosaurus moves its foot into the designated area and stomps after a few seconds, dealing damage to all plants and zombies within range. It leaves a footprint lasting about 7 seconds, during which planting is not allowed in that area.'**
  String get eventHelpDinoTreadBody;

  /// No description provided for @eventHelpDinoTreadRowCol.
  ///
  /// In en, this message translates to:
  /// **'GridY represents the row, and GridXMin/GridXMax represent the column range. Both rows and columns start counting from 0. In Underwater World, rows range from 0–5 and columns from 0–9.'**
  String get eventHelpDinoTreadRowCol;

  /// No description provided for @dinoTreadRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row (GridY)'**
  String get dinoTreadRowLabel;

  /// No description provided for @dinoTreadColMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Leftmost Column (GridXMin)'**
  String get dinoTreadColMinLabel;

  /// No description provided for @dinoTreadColMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Rightmost Column (GridXMax)'**
  String get dinoTreadColMaxLabel;

  /// No description provided for @dinoTreadTimeIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry Delay (TimeInterval)'**
  String get dinoTreadTimeIntervalLabel;

  /// No description provided for @columnStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Column (ColumnStart)'**
  String get columnStartLabel;

  /// No description provided for @columnEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End Column (ColumnEnd)'**
  String get columnEndLabel;

  /// No description provided for @eventHelpDinoRunBody.
  ///
  /// In en, this message translates to:
  /// **'When triggered, dinosaurs gather across 2–3 rows. They do not use their abilities, but instead charge into the lawn, trampling plants or zombies. The number of targets they can trample depends on the dinosaur type.'**
  String get eventHelpDinoRunBody;

  /// No description provided for @eventHelpDinoRunRow.
  ///
  /// In en, this message translates to:
  /// **'DinoRow defines the center row of the dino rush. Rows are 0-based. Underwater World supports up to 5.'**
  String get eventHelpDinoRunRow;

  /// No description provided for @positionAndArea.
  ///
  /// In en, this message translates to:
  /// **'Position & area'**
  String get positionAndArea;

  /// No description provided for @positionAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Position & timing'**
  String get positionAndDuration;

  /// No description provided for @rowCol0Index.
  ///
  /// In en, this message translates to:
  /// **'Row/column (0-based)'**
  String get rowCol0Index;

  /// No description provided for @timeInterval.
  ///
  /// In en, this message translates to:
  /// **'Time interval'**
  String get timeInterval;

  /// No description provided for @eventHelpZombiePotionBody.
  ///
  /// In en, this message translates to:
  /// **'Force-spawns potions on the lawn, ignoring plants. Can be used as an alternative to grid item spawn events.'**
  String get eventHelpZombiePotionBody;

  /// No description provided for @eventHelpZombiePotionUsage.
  ///
  /// In en, this message translates to:
  /// **'Unlike the preset pools used for grid item spawning, this event forces grid items to spawn on specific tiles and displaces plants. \nNote that on lawns without tombstone spawn effects, sun textures may appear incorrectly. Use with caution.'**
  String get eventHelpZombiePotionUsage;

  /// No description provided for @eventHelpShellBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns atlantis seashells at specified positions. Seashells start in a closed state. When a zombie steps on a seashell, it opens, launches the zombie forward, and closes again after 10 seconds. While open, seashells can be attacked by plants and block straight-shot projectiles. Each time a seashell opens, it generates a random item, including a Plant Food, a Cuttlefish, a plant seed packet, or a Relic Imp. After being triggered by zombies 3 times, the seashell will swim toward the seed bank and replace a random seed slot with a seashell seed packet. After the seashell has been planted 3 times, the seed slot will revert to its original plant.'**
  String get eventHelpShellBody;

  /// No description provided for @eventHelpShellUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a tile, then tap \"+\" to place a seashell. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get eventHelpShellUsage;

  /// No description provided for @eventHelpPumpkinHouseBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns pumpkin houses at specified positions. Zombies that pass through the Pumpkin House are transformed into Pumpkin House Ghosts. Pumpkin House Ghosts have a separate health pool and can only be damaged by lobbed plants. When their health is depleted, they revert to their original zombie form. The Pumpkin House itself also has its own health and can be destroyed by concentrated fire.'**
  String get eventHelpPumpkinHouseBody;

  /// No description provided for @eventHelpPumpkinHouseUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a tile, then tap \"+\" to place a pumpkin house. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get eventHelpPumpkinHouseUsage;

  /// No description provided for @eventHelpFairyFogBody.
  ///
  /// In en, this message translates to:
  /// **'Creates magic fog that covers the lawn and grants shields to zombies. Commonly used in Fairytale Forest levels. Can only be cleared by the Fairtyale Breeze event.\nHigher-tier fog grants stronger shields and increased control immunity to zombies. Tiers, from lowest to highest, are White, Blue, and Purple.'**
  String get eventHelpFairyFogBody;

  /// No description provided for @eventHelpFairyFogRange.
  ///
  /// In en, this message translates to:
  /// **'mX and mY define the center point. mWidth and mHeight define how far the area extends to the right and downward from the center.'**
  String get eventHelpFairyFogRange;

  /// No description provided for @eventHelpFairyWindBody.
  ///
  /// In en, this message translates to:
  /// **'Generates a continuous breeze that clears magical fog. Commonly used in Fairytale Forest levels.'**
  String get eventHelpFairyWindBody;

  /// No description provided for @eventHelpFairyWindVelocity.
  ///
  /// In en, this message translates to:
  /// **'This event affects projectile speed while active. 1.0 = normal speed; higher values increase projectile speed.'**
  String get eventHelpFairyWindVelocity;

  /// No description provided for @eventHelpRaidingPartyBody.
  ///
  /// In en, this message translates to:
  /// **'Commonly seen in Pirate Seas levels. Spawns groups of Swashbuckler Zombies in batches. TimeBetweenGroups defines the interval between each group.'**
  String get eventHelpRaidingPartyBody;

  /// No description provided for @eventHelpRaidingPartyGroup.
  ///
  /// In en, this message translates to:
  /// **'Zombies per group.'**
  String get eventHelpRaidingPartyGroup;

  /// No description provided for @eventHelpRaidingPartyCount.
  ///
  /// In en, this message translates to:
  /// **'Total Swashbuckler Zombies spawned.'**
  String get eventHelpRaidingPartyCount;

  /// No description provided for @eventHelpGravestoneBody.
  ///
  /// In en, this message translates to:
  /// **'Randomly spawns grid items during a wave (e.g., Dark Ages tombstones).'**
  String get eventHelpGravestoneBody;

  /// No description provided for @eventHelpGravestoneLogic.
  ///
  /// In en, this message translates to:
  /// **'Selects valid tiles from the pool above to spawn grid items. The total number of grid items cannot exceed the number of available tiles, or excess spawns will fail.'**
  String get eventHelpGravestoneLogic;

  /// No description provided for @eventHelpGravestoneMissingAssets.
  ///
  /// In en, this message translates to:
  /// **'Some lawns without tombstone spawn effects may show sun textures instead. Use with caution.'**
  String get eventHelpGravestoneMissingAssets;

  /// No description provided for @eventHelpBarrelWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns the three barrel types from the Memory Lane \"Barrel Crisis\" gimmick. Barrels roll in from the right and crush all plants in their path.'**
  String get eventHelpBarrelWaveBody;

  /// No description provided for @barrelWaveHelpTypes.
  ///
  /// In en, this message translates to:
  /// **'Barrel types'**
  String get barrelWaveHelpTypes;

  /// No description provided for @eventHelpBarrelWaveTypes.
  ///
  /// In en, this message translates to:
  /// **'Empty Barrel: Breaks with no effect.\nImp Barrel: Releases zombies (usually Imps) when destroyed.\nExplosive Barrel: Explodes on contact or when destroyed, damaging plants and zombies in a 3×3 area.'**
  String get eventHelpBarrelWaveTypes;

  /// No description provided for @barrelWaveHelpRows.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get barrelWaveHelpRows;

  /// No description provided for @eventHelpBarrelWaveRows.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.'**
  String get eventHelpBarrelWaveRows;

  /// No description provided for @eventHelpSchoolBusBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns an Ice Cream Van in the specified lane. Ice Cream Van slowly enters from the right side while carrying zombies, occupying 2 lanes. Any plants run over by the van are instantly crushed.\nIf the van is displayed with Bubble Gun Imps and Lollipop Zombies (i.e. the schoolbus_special variant), they will continuously use their respective abilities while the van is moving.\nPlants like Spikeweed and Spikerock can puncture the van\'s tires. After its tires are punctured, the Ice Cream Van gradually slows down and enters a gliding state. After a short period of time, it comes to a stop and breaks down.'**
  String get eventHelpSchoolBusBody;

  /// No description provided for @schoolBusHelpRows.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get schoolBusHelpRows;

  /// No description provided for @eventHelpSchoolBusRows.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.'**
  String get eventHelpSchoolBusRows;

  /// No description provided for @eventHelpSchoolBusType.
  ///
  /// In en, this message translates to:
  /// **'Type selects the ice cream van variant. Normal (schoolbus_normal) is the standard van. Special (schoolbus_special) shows Bubble Gun Imps and Lollipop Zombies on the van; they use their abilities while the van is moving.'**
  String get eventHelpSchoolBusType;

  /// No description provided for @schoolBusHelpZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombies'**
  String get schoolBusHelpZombies;

  /// No description provided for @eventHelpSchoolBusZombies.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream Van has its own health pool. Once destroyed, the zombies inside will exit the vehicle and continue advancing. Each zombie\'s level can be configured individually (Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard).'**
  String get eventHelpSchoolBusZombies;

  /// No description provided for @schoolBusRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get schoolBusRow;

  /// No description provided for @schoolBusType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get schoolBusType;

  /// No description provided for @schoolBusTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get schoolBusTypeNormal;

  /// No description provided for @schoolBusTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get schoolBusTypeSpecial;

  /// No description provided for @schoolBusHitPoints.
  ///
  /// In en, this message translates to:
  /// **' Van health (SchoolBusHitPoints)'**
  String get schoolBusHitPoints;

  /// No description provided for @schoolBusSpeed.
  ///
  /// In en, this message translates to:
  /// **'Van speed (SchoolBusSpeed)'**
  String get schoolBusSpeed;

  /// No description provided for @schoolBusZombies.
  ///
  /// In en, this message translates to:
  /// **'Contained zombies (Zombies)'**
  String get schoolBusZombies;

  /// No description provided for @schoolBusZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get schoolBusZombieLevel;

  /// No description provided for @schoolBusAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get schoolBusAddZombie;

  /// No description provided for @schoolBusRowsHint.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.'**
  String get schoolBusRowsHint;

  /// No description provided for @eventHelpThunderWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Lightning strikes during the wave, hitting plants adjacent to other plants. Commonly used in Sky City levels. Each strike applies either a positive or negative charge to plants.'**
  String get eventHelpThunderWaveBody;

  /// No description provided for @thunderWaveHelpTypes.
  ///
  /// In en, this message translates to:
  /// **'Charge effects'**
  String get thunderWaveHelpTypes;

  /// No description provided for @eventHelpThunderWaveTypes.
  ///
  /// In en, this message translates to:
  /// **'Two positive charges cause continuous percentage damage from an overhead energy orb.\nTwo negative charges paralyze the plant for a short duration.\nOne positive and one negative charge permanently slow the plant.\nPlants can still receive charges while affected, but no additional effects will be applied.'**
  String get eventHelpThunderWaveTypes;

  /// No description provided for @thunderWaveHelpKillRate.
  ///
  /// In en, this message translates to:
  /// **'Kill rate'**
  String get thunderWaveHelpKillRate;

  /// No description provided for @eventHelpThunderWaveKillRate.
  ///
  /// In en, this message translates to:
  /// **'The chance for lightning to instantly kill a plant on hit (0.0–1.0). Anthurium is unaffected. This applies to both positive and negative lightning.'**
  String get eventHelpThunderWaveKillRate;

  /// No description provided for @thunderWaveTypePositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get thunderWaveTypePositive;

  /// No description provided for @thunderWaveTypeNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get thunderWaveTypeNegative;

  /// No description provided for @thunderWaveKillRate.
  ///
  /// In en, this message translates to:
  /// **'Kill rate'**
  String get thunderWaveKillRate;

  /// No description provided for @thunderWaveKillRateHint.
  ///
  /// In en, this message translates to:
  /// **'Probability of killing plants on lightning strike (0.0–1.0), Anthurium is unaffected'**
  String get thunderWaveKillRateHint;

  /// No description provided for @thunderWaveThunders.
  ///
  /// In en, this message translates to:
  /// **'Lightnings'**
  String get thunderWaveThunders;

  /// No description provided for @thunderWaveAddThunder.
  ///
  /// In en, this message translates to:
  /// **'Add lightning'**
  String get thunderWaveAddThunder;

  /// No description provided for @thunderWaveThunder.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get thunderWaveThunder;

  /// No description provided for @barrelWaveTypeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty Barrel (barrelempty)'**
  String get barrelWaveTypeEmpty;

  /// No description provided for @barrelWaveTypeZombie.
  ///
  /// In en, this message translates to:
  /// **'Imp Barrel (barrelmoster)'**
  String get barrelWaveTypeZombie;

  /// No description provided for @barrelWaveTypeExplosive.
  ///
  /// In en, this message translates to:
  /// **'Explosive Barrel (barrelpowder)'**
  String get barrelWaveTypeExplosive;

  /// No description provided for @barrelWaveRowsHint.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.'**
  String get barrelWaveRowsHint;

  /// No description provided for @barrelWaveAddBarrel.
  ///
  /// In en, this message translates to:
  /// **'Add barrel'**
  String get barrelWaveAddBarrel;

  /// No description provided for @barrelWaveBarrel.
  ///
  /// In en, this message translates to:
  /// **'Barrel'**
  String get barrelWaveBarrel;

  /// No description provided for @barrelWaveRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get barrelWaveRow;

  /// No description provided for @barrelWaveType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get barrelWaveType;

  /// No description provided for @barrelWaveHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Barrel health (BarrelHitPoints)'**
  String get barrelWaveHitPoints;

  /// No description provided for @barrelWaveSpeed.
  ///
  /// In en, this message translates to:
  /// **'Barrel speed (BarrelSpeed)'**
  String get barrelWaveSpeed;

  /// No description provided for @barrelWaveZombies.
  ///
  /// In en, this message translates to:
  /// **'Contained zombies (Zombies)'**
  String get barrelWaveZombies;

  /// No description provided for @barrelWaveZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get barrelWaveZombieLevel;

  /// No description provided for @barrelWaveAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get barrelWaveAddZombie;

  /// No description provided for @barrelWaveExplosionDamage.
  ///
  /// In en, this message translates to:
  /// **'Explosion damage (BarrelBlowDamageAmount)'**
  String get barrelWaveExplosionDamage;

  /// No description provided for @barrelWaveDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete barrel'**
  String get barrelWaveDeleteTitle;

  /// No description provided for @barrelWaveDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this barrel?'**
  String get barrelWaveDeleteConfirm;

  /// No description provided for @barrelWaveDeleteLastHint.
  ///
  /// In en, this message translates to:
  /// **'This is the last barrel. Deleting it will leave this event without any barrels. Continue?'**
  String get barrelWaveDeleteLastHint;

  /// No description provided for @eventHelpGraveSpawnBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from specific grid item types. Commonly used for Dark Ages Necromancy ambushes.'**
  String get eventHelpGraveSpawnBody;

  /// No description provided for @eventHelpGraveSpawnWait.
  ///
  /// In en, this message translates to:
  /// **'Delay between wave start and zombie spawn. If the next wave begins before the timer ends, no zombies will spawn.'**
  String get eventHelpGraveSpawnWait;

  /// No description provided for @eventHelpStormBody.
  ///
  /// In en, this message translates to:
  /// **'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.'**
  String get eventHelpStormBody;

  /// No description provided for @eventHelpStormColumns.
  ///
  /// In en, this message translates to:
  /// **'The left boundary of the lawn is column 0, and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.'**
  String get eventHelpStormColumns;

  /// No description provided for @eventHelpStormLevels.
  ///
  /// In en, this message translates to:
  /// **'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.'**
  String get eventHelpStormLevels;

  /// No description provided for @eventHelpGroundSpawnBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies directly from the ground within the specified range. Configuration is similar to natural spawning. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\n By default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.'**
  String get eventHelpGroundSpawnBody;

  /// No description provided for @moduleHelpTideBody.
  ///
  /// In en, this message translates to:
  /// **'Enables the tide system for the level, allowing tide-related events to be used. Note that this module must be added last; otherwise, it may cause the level to crash.'**
  String get moduleHelpTideBody;

  /// No description provided for @moduleHelpTidePosition.
  ///
  /// In en, this message translates to:
  /// **'Sets the position of the tide at the start of the level, i.e., the position of the tide line within the level. The rightmost column is 0 and the leftmost is 9. Accepts integers, including negative values.'**
  String get moduleHelpTidePosition;

  /// No description provided for @initialTidePosition.
  ///
  /// In en, this message translates to:
  /// **'Tide line configuration'**
  String get initialTidePosition;

  /// No description provided for @moduleHelpManholeBody.
  ///
  /// In en, this message translates to:
  /// **'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.'**
  String get moduleHelpManholeBody;

  /// No description provided for @moduleHelpManholeEdit.
  ///
  /// In en, this message translates to:
  /// **'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.'**
  String get moduleHelpManholeEdit;

  /// No description provided for @moduleHelpWeatherBody.
  ///
  /// In en, this message translates to:
  /// **'Controls global environmental effects such as rain and snow.'**
  String get moduleHelpWeatherBody;

  /// No description provided for @moduleHelpWeatherRef.
  ///
  /// In en, this message translates to:
  /// **'These modules are typically referenced directly from LevelModules and do not require custom configuration.'**
  String get moduleHelpWeatherRef;

  /// No description provided for @moduleHelpZombiePotionBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns specified grid iems types (like potions) at random rows from right to left within a defined time interval. Stops spawning when the maximum number of grid items is reached.'**
  String get moduleHelpZombiePotionBody;

  /// No description provided for @moduleHelpZombiePotionTypes.
  ///
  /// In en, this message translates to:
  /// **'Potions are randomly selected from the specified types. To spawn multiple grid items at fixed intervals, add multiple instances of this module.'**
  String get moduleHelpZombiePotionTypes;

  /// No description provided for @moduleHelpUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'A level file consists of a root node and multiple modules, known as PVZ2Object. Each object has aliases, a type (objclass), and data (objdata). The root node has no aliases.'**
  String get moduleHelpUnknownBody;

  /// No description provided for @moduleHelpUnknownEvents.
  ///
  /// In en, this message translates to:
  /// **'This software determines module types by reading objclass. The objclass of the current module is not registered in the module list, so no matching editor is available. Support may be added in a future update.'**
  String get moduleHelpUnknownEvents;

  /// No description provided for @eventHelpInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'This event is referenced in the wave container, but the parser cannot find its entity definition in the level, leaving the RTID block unresolved.'**
  String get eventHelpInvalidBody;

  /// No description provided for @eventHelpInvalidImpact.
  ///
  /// In en, this message translates to:
  /// **'Keeping this invalid entry in the level will prevent it from being read correctly and may cause a crash. It should be removed manually.'**
  String get eventHelpInvalidImpact;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get position;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editing;

  /// No description provided for @logic.
  ///
  /// In en, this message translates to:
  /// **'Logic'**
  String get logic;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @referenceModules.
  ///
  /// In en, this message translates to:
  /// **'Reference modules'**
  String get referenceModules;

  /// No description provided for @portalType.
  ///
  /// In en, this message translates to:
  /// **'Portal type (PortalType)'**
  String get portalType;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @velocityScale.
  ///
  /// In en, this message translates to:
  /// **'Speed multiplier (VelocityScale)'**
  String get velocityScale;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @columnRange.
  ///
  /// In en, this message translates to:
  /// **'Column range'**
  String get columnRange;

  /// No description provided for @zombieLevels.
  ///
  /// In en, this message translates to:
  /// **'Zombie level'**
  String get zombieLevels;

  /// No description provided for @missingAssets.
  ///
  /// In en, this message translates to:
  /// **'Missing assets'**
  String get missingAssets;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @eventBlackHole.
  ///
  /// In en, this message translates to:
  /// **'Event: Black Hole'**
  String get eventBlackHole;

  /// No description provided for @attractionConfig.
  ///
  /// In en, this message translates to:
  /// **'Attraction config'**
  String get attractionConfig;

  /// No description provided for @selectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get selectedPosition;

  /// No description provided for @placePlant.
  ///
  /// In en, this message translates to:
  /// **'Place plant'**
  String get placePlant;

  /// No description provided for @plantList.
  ///
  /// In en, this message translates to:
  /// **'Plant(s) in selected tile'**
  String get plantList;

  /// No description provided for @firstCostume.
  ///
  /// In en, this message translates to:
  /// **'Wears primary costume (Avatar)'**
  String get firstCostume;

  /// No description provided for @costumeOn.
  ///
  /// In en, this message translates to:
  /// **'Costume: on'**
  String get costumeOn;

  /// No description provided for @costumeOff.
  ///
  /// In en, this message translates to:
  /// **'Costume: off'**
  String get costumeOff;

  /// No description provided for @outsideLawnItems.
  ///
  /// In en, this message translates to:
  /// **'Objects outside the lawn'**
  String get outsideLawnItems;

  /// No description provided for @zombieFromLeft.
  ///
  /// In en, this message translates to:
  /// **'From left'**
  String get zombieFromLeft;

  /// No description provided for @eventMagicMirror.
  ///
  /// In en, this message translates to:
  /// **'Event: Magic Mirror'**
  String get eventMagicMirror;

  /// No description provided for @eventParachuteRain.
  ///
  /// In en, this message translates to:
  /// **'Event: Parachute/Bass/Jetpack/Imp rain'**
  String get eventParachuteRain;

  /// No description provided for @manholePipeline.
  ///
  /// In en, this message translates to:
  /// **'Manhole Pipeline module'**
  String get manholePipeline;

  /// No description provided for @manholePipelines.
  ///
  /// In en, this message translates to:
  /// **'Manhole pipelines'**
  String get manholePipelines;

  /// No description provided for @manholePipelineHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.'**
  String get manholePipelineHelpOverview;

  /// No description provided for @manholePipelineHelpEditing.
  ///
  /// In en, this message translates to:
  /// **'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.'**
  String get manholePipelineHelpEditing;

  /// No description provided for @smokePollutionModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Smoke pollution module'**
  String get smokePollutionModuleTitle;

  /// No description provided for @smokePollutionModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Smoke pollution module help'**
  String get smokePollutionModuleHelpTitle;

  /// No description provided for @smokePollutionModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get smokePollutionModuleHelpOverview;

  /// No description provided for @smokePollutionModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Places smoke manholes on the lawn that erupt after a delay, releasing poison fog. Commonly used in Steam Ages levels.'**
  String get smokePollutionModuleHelpOverviewBody;

  /// No description provided for @smokePollutionModuleHelpManholes.
  ///
  /// In en, this message translates to:
  /// **'Manholes'**
  String get smokePollutionModuleHelpManholes;

  /// No description provided for @smokePollutionModuleHelpManholesBody.
  ///
  /// In en, this message translates to:
  /// **'Select a tile on the grid, then add manholes at that position. Each manhole has a Start Time — seconds from level start until it erupts and releases poison fog.'**
  String get smokePollutionModuleHelpManholesBody;

  /// No description provided for @smokePollutionModuleStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time (s)'**
  String get smokePollutionModuleStartTimeLabel;

  /// No description provided for @manholePipelineStartEndFormat.
  ///
  /// In en, this message translates to:
  /// **'Start: ({sx}, {sy})  End: ({ex}, {ey})'**
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey);

  /// No description provided for @piratePlank.
  ///
  /// In en, this message translates to:
  /// **'Pirate Plank module'**
  String get piratePlank;

  /// No description provided for @weatherModule.
  ///
  /// In en, this message translates to:
  /// **'Environmental Weather module'**
  String get weatherModule;

  /// No description provided for @zombiePotion.
  ///
  /// In en, this message translates to:
  /// **'Dark Alchemy module'**
  String get zombiePotion;

  /// No description provided for @eventTimeRift.
  ///
  /// In en, this message translates to:
  /// **'Event: Spacetime Portal'**
  String get eventTimeRift;

  /// No description provided for @deathHole.
  ///
  /// In en, this message translates to:
  /// **'Death Crater module'**
  String get deathHole;

  /// No description provided for @seedRain.
  ///
  /// In en, this message translates to:
  /// **'It\'s Raining Seeds module'**
  String get seedRain;

  /// No description provided for @eventFrostWind.
  ///
  /// In en, this message translates to:
  /// **'Event: Freezing Wind'**
  String get eventFrostWind;

  /// No description provided for @lastStandSettings.
  ///
  /// In en, this message translates to:
  /// **'Last Stand Settings'**
  String get lastStandSettings;

  /// No description provided for @roofFlowerPot.
  ///
  /// In en, this message translates to:
  /// **'Roof Pots module'**
  String get roofFlowerPot;

  /// No description provided for @eventConveyorModify.
  ///
  /// In en, this message translates to:
  /// **'Event: Conveyor Change'**
  String get eventConveyorModify;

  /// No description provided for @bowlingMinigame.
  ///
  /// In en, this message translates to:
  /// **'Bulb Bowling module'**
  String get bowlingMinigame;

  /// No description provided for @zombieMoveFast.
  ///
  /// In en, this message translates to:
  /// **'Fast Entry module'**
  String get zombieMoveFast;

  /// No description provided for @eventPotionDrop.
  ///
  /// In en, this message translates to:
  /// **'Event: Potion Drop'**
  String get eventPotionDrop;

  /// No description provided for @eventShellSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Seashell Spawn'**
  String get eventShellSpawn;

  /// No description provided for @eventPumpkinHouseSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Pumpkin House Spawn'**
  String get eventPumpkinHouseSpawn;

  /// No description provided for @eventSchoolBusSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Ice cream Van spawn'**
  String get eventSchoolBusSpawn;

  /// No description provided for @warMist.
  ///
  /// In en, this message translates to:
  /// **'Fog System module'**
  String get warMist;

  /// No description provided for @eventDino.
  ///
  /// In en, this message translates to:
  /// **'Event: Dino Spawn'**
  String get eventDino;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @sunDropper.
  ///
  /// In en, this message translates to:
  /// **'Sun Dropper module'**
  String get sunDropper;

  /// No description provided for @eventFairyWind.
  ///
  /// In en, this message translates to:
  /// **'Event: Fairytale Breeze'**
  String get eventFairyWind;

  /// No description provided for @eventFairyFog.
  ///
  /// In en, this message translates to:
  /// **'Event: Magic Fog'**
  String get eventFairyFog;

  /// No description provided for @eventRaidingParty.
  ///
  /// In en, this message translates to:
  /// **'Event: Raiding Party'**
  String get eventRaidingParty;

  /// No description provided for @swashbucklerCount.
  ///
  /// In en, this message translates to:
  /// **'Swashbuckler count'**
  String get swashbucklerCount;

  /// No description provided for @sunBomb.
  ///
  /// In en, this message translates to:
  /// **'Sun Bombs module'**
  String get sunBomb;

  /// No description provided for @eventSpawnGravestones.
  ///
  /// In en, this message translates to:
  /// **'Event: Grid Item Spawn'**
  String get eventSpawnGravestones;

  /// No description provided for @eventBarrelWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Barrel Crisis'**
  String get eventBarrelWave;

  /// No description provided for @eventThunderWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Thundercloud Storm'**
  String get eventThunderWave;

  /// No description provided for @eventGraveSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Grid Item Spawner'**
  String get eventGraveSpawn;

  /// No description provided for @zombieSpawnWait.
  ///
  /// In en, this message translates to:
  /// **'Zombie spawn delay'**
  String get zombieSpawnWait;

  /// No description provided for @selectCustomZombie.
  ///
  /// In en, this message translates to:
  /// **'Select custom zombie'**
  String get selectCustomZombie;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @autoLevel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Set level'**
  String get autoLevel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyBatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Apply batch level?'**
  String get applyBatchLevel;

  /// No description provided for @conveyorBelt.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt Module Settings'**
  String get conveyorBelt;

  /// No description provided for @starChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module Settings'**
  String get starChallenges;

  /// No description provided for @addChallenge.
  ///
  /// In en, this message translates to:
  /// **'Add challenge'**
  String get addChallenge;

  /// No description provided for @unknownChallengeType.
  ///
  /// In en, this message translates to:
  /// **'Unknown challenge type'**
  String get unknownChallengeType;

  /// No description provided for @protectedPlants.
  ///
  /// In en, this message translates to:
  /// **'Endangered plants'**
  String get protectedPlants;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @protectedGridItems.
  ///
  /// In en, this message translates to:
  /// **'Grid items to protect'**
  String get protectedGridItems;

  /// No description provided for @addGridItem.
  ///
  /// In en, this message translates to:
  /// **'Add grid item'**
  String get addGridItem;

  /// No description provided for @spawnTimer.
  ///
  /// In en, this message translates to:
  /// **'Spawn Interval (PotionSpawnTimer)'**
  String get spawnTimer;

  /// No description provided for @plantLevels.
  ///
  /// In en, this message translates to:
  /// **'Plant levels'**
  String get plantLevels;

  /// No description provided for @globalPlantLevels.
  ///
  /// In en, this message translates to:
  /// **'Global plant levels'**
  String get globalPlantLevels;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @applyBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch apply'**
  String get applyBatch;

  /// No description provided for @addPlants.
  ///
  /// In en, this message translates to:
  /// **'Add plants to the list'**
  String get addPlants;

  /// No description provided for @noPlantsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No plants configured. Please add plants to the list.'**
  String get noPlantsConfigured;

  /// No description provided for @batchLevelFormat.
  ///
  /// In en, this message translates to:
  /// **'Batch level: {level}'**
  String batchLevelFormat(int level);

  /// No description provided for @protectPlants.
  ///
  /// In en, this message translates to:
  /// **'Save Our Seeds'**
  String get protectPlants;

  /// No description provided for @autoCount.
  ///
  /// In en, this message translates to:
  /// **'Auto count'**
  String get autoCount;

  /// No description provided for @overrideStartingPlantfood.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food settings'**
  String get overrideStartingPlantfood;

  /// No description provided for @startingPlantfoodOverride.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food (StartingPlantfoodOverride)'**
  String get startingPlantfoodOverride;

  /// No description provided for @iconText.
  ///
  /// In en, this message translates to:
  /// **'Icon Text'**
  String get iconText;

  /// No description provided for @iconImage.
  ///
  /// In en, this message translates to:
  /// **'Icon Image'**
  String get iconImage;

  /// No description provided for @overrideMaxSun.
  ///
  /// In en, this message translates to:
  /// **'Max Sun Limit Settings'**
  String get overrideMaxSun;

  /// No description provided for @maxSunOverride.
  ///
  /// In en, this message translates to:
  /// **'Max sun limit (MaxSunOverride)'**
  String get maxSunOverride;

  /// No description provided for @maxSunHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Sun Limit'**
  String get maxSunHelpTitle;

  /// No description provided for @maxSunHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Originally used for Penny’s Pursuit difficulty settings. This module overrides the maximum amount of sun that can be stored in a level.'**
  String get maxSunHelpOverview;

  /// No description provided for @startingPlantfoodHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get startingPlantfoodHelpTitle;

  /// No description provided for @startingPlantfoodHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Originally used for Penny’s Pursuit difficulty settings. This module overrides the amount of Plant Food available at the start of a level.'**
  String get startingPlantfoodHelpOverview;

  /// No description provided for @starChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module'**
  String get starChallengeHelpTitle;

  /// No description provided for @starChallengeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Select the challenge modules to apply to the level. Multiple challenges can be enabled at once, and the same challenge can be applied multiple times.'**
  String get starChallengeHelpOverview;

  /// No description provided for @starChallengeHelpSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get starChallengeHelpSuggestionTitle;

  /// No description provided for @starChallengeHelpSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Some challenges display progress using an on-screen tracker. If too many challenges are enabled, the tracker may be overlapped.'**
  String get starChallengeHelpSuggestion;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plant;

  /// No description provided for @zombie.
  ///
  /// In en, this message translates to:
  /// **'Zombie'**
  String get zombie;

  /// No description provided for @initialZombieLayout.
  ///
  /// In en, this message translates to:
  /// **'Initial zombie layout'**
  String get initialZombieLayout;

  /// No description provided for @placeZombie.
  ///
  /// In en, this message translates to:
  /// **'Place zombie'**
  String get placeZombie;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get manualInput;

  /// No description provided for @waveManagerModule.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Module'**
  String get waveManagerModule;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @eventStorm.
  ///
  /// In en, this message translates to:
  /// **'Event: Storm Raid'**
  String get eventStorm;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// No description provided for @addType.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addType;

  /// No description provided for @plantFunExperimental.
  ///
  /// In en, this message translates to:
  /// **'Plant (work in progress)'**
  String get plantFunExperimental;

  /// No description provided for @availableZombies.
  ///
  /// In en, this message translates to:
  /// **'Available zombies'**
  String get availableZombies;

  /// No description provided for @presetPlants.
  ///
  /// In en, this message translates to:
  /// **'Preset plants (PresetPlantList)'**
  String get presetPlants;

  /// No description provided for @whiteList.
  ///
  /// In en, this message translates to:
  /// **'White list (WhiteList)'**
  String get whiteList;

  /// No description provided for @blackList.
  ///
  /// In en, this message translates to:
  /// **'Black list (BlackList)'**
  String get blackList;

  /// No description provided for @chooser.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Seeds (Chooser)'**
  String get chooser;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Locked and Loaded (Preset)'**
  String get preset;

  /// No description provided for @seedBankHelp.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank'**
  String get seedBankHelp;

  /// No description provided for @conveyorBeltHelp.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt'**
  String get conveyorBeltHelp;

  /// No description provided for @dropDelayConditions.
  ///
  /// In en, this message translates to:
  /// **'Seed packets delay (DropDelayConditions)'**
  String get dropDelayConditions;

  /// No description provided for @unitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Unit: seconds'**
  String get unitSeconds;

  /// No description provided for @speedConditions.
  ///
  /// In en, this message translates to:
  /// **'Conveyor speed (SpeedConditions)'**
  String get speedConditions;

  /// No description provided for @speedConditionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default is 100; higher values increase speed'**
  String get speedConditionsSubtitle;

  /// No description provided for @addPlantConveyor.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlantConveyor;

  /// No description provided for @addTool.
  ///
  /// In en, this message translates to:
  /// **'Add tool packet'**
  String get addTool;

  /// No description provided for @increasedCost.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get increasedCost;

  /// No description provided for @powerTile.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles'**
  String get powerTile;

  /// No description provided for @powerTileGridSection.
  ///
  /// In en, this message translates to:
  /// **'Current lawn'**
  String get powerTileGridSection;

  /// No description provided for @powerTileGridHelpPrimary.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to place a tile, and tap again to remove it. Placing a tile on an occupied cell will replace the existing one. Tiles from other groups are shown dimmed to indicate they are not in the selected group.'**
  String get powerTileGridHelpPrimary;

  /// No description provided for @powerTileGridHelpSecondaryMobile.
  ///
  /// In en, this message translates to:
  /// **'Long press a cell to quickly set a group or adjust the propagation delay.'**
  String get powerTileGridHelpSecondaryMobile;

  /// No description provided for @powerTileGridHelpSecondaryDesktop.
  ///
  /// In en, this message translates to:
  /// **'Right-click a cell to quickly set a group or adjust its propagation delay.'**
  String get powerTileGridHelpSecondaryDesktop;

  /// No description provided for @powerTileLinkedTilesSection.
  ///
  /// In en, this message translates to:
  /// **'Tile list'**
  String get powerTileLinkedTilesSection;

  /// No description provided for @powerTilePropagationDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Propagation delay (seconds)'**
  String get powerTilePropagationDelayLabel;

  /// No description provided for @powerTilePropagationDelayTooltip.
  ///
  /// In en, this message translates to:
  /// **'The delay before power begins to propagate to other tiles (0–5 seconds). This does not include the transmission time itself. The default propagation delay is 1.5 seconds.'**
  String get powerTilePropagationDelayTooltip;

  /// No description provided for @powerTileDialogEditCell.
  ///
  /// In en, this message translates to:
  /// **'Edit cell'**
  String get powerTileDialogEditCell;

  /// No description provided for @powerTileDialogTileGroup.
  ///
  /// In en, this message translates to:
  /// **'Tile group'**
  String get powerTileDialogTileGroup;

  /// No description provided for @powerTileDialogNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get powerTileDialogNone;

  /// No description provided for @powerTileDialogPropagationDelay.
  ///
  /// In en, this message translates to:
  /// **'Propagation delay (seconds)'**
  String get powerTileDialogPropagationDelay;

  /// No description provided for @powerTileHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles are divided into five groups. When a plant on a tile activates its Plant Food effect, power is propagated to other tiles in the same group, causing those plants to activate their Plant Food effect as well. The initial delay before propagation can be configured. '**
  String get powerTileHelpOverview;

  /// No description provided for @powerTileHelpGridSize.
  ///
  /// In en, this message translates to:
  /// **'Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get powerTileHelpGridSize;

  /// No description provided for @powerTileHelpQuickEdit.
  ///
  /// In en, this message translates to:
  /// **'Quick edit: {interaction}'**
  String powerTileHelpQuickEdit(String interaction);

  /// No description provided for @eventStandardSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Basic Spawner'**
  String get eventStandardSpawn;

  /// No description provided for @eventGroundSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Ground Spawner'**
  String get eventGroundSpawn;

  /// No description provided for @eventEditorInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Event editor in development'**
  String get eventEditorInDevelopment;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @missingTideModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Tide System module'**
  String get missingTideModule;

  /// No description provided for @levelHasNoTideProperties.
  ///
  /// In en, this message translates to:
  /// **'This level has no Tide System module (TideProperties). This event may not function correctly and could cause a crash.'**
  String get levelHasNoTideProperties;

  /// No description provided for @changePosition.
  ///
  /// In en, this message translates to:
  /// **'Tide adjustment'**
  String get changePosition;

  /// No description provided for @changePositionChangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Column Offset (ChangeAmount)'**
  String get changePositionChangeAmount;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Tide preview'**
  String get preview;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @groupConfigN.
  ///
  /// In en, this message translates to:
  /// **'Group {n} config'**
  String groupConfigN(int n);

  /// No description provided for @globalParameters.
  ///
  /// In en, this message translates to:
  /// **'Global parameters'**
  String get globalParameters;

  /// No description provided for @timePerGrid.
  ///
  /// In en, this message translates to:
  /// **'Transfer time (seconds per tile)'**
  String get timePerGrid;

  /// No description provided for @damagePerSecond.
  ///
  /// In en, this message translates to:
  /// **'Damage per second'**
  String get damagePerSecond;

  /// No description provided for @pipe.
  ///
  /// In en, this message translates to:
  /// **'Pipe'**
  String get pipe;

  /// No description provided for @stageMismatch.
  ///
  /// In en, this message translates to:
  /// **'Lawn mismatch'**
  String get stageMismatch;

  /// No description provided for @currentStageNotPirate.
  ///
  /// In en, this message translates to:
  /// **'The current lawn is not Pirate Seas. This module may not work correctly and could cause a crash.'**
  String get currentStageNotPirate;

  /// No description provided for @plankRows.
  ///
  /// In en, this message translates to:
  /// **'Plank rows'**
  String get plankRows;

  /// No description provided for @plankRowsDeepSea.
  ///
  /// In en, this message translates to:
  /// **'Plank rows (Underwater World)'**
  String get plankRowsDeepSea;

  /// No description provided for @selectedRows.
  ///
  /// In en, this message translates to:
  /// **'Rows selected:'**
  String get selectedRows;

  /// No description provided for @selectedRowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected rows:'**
  String get selectedRowsLabel;

  /// No description provided for @indexLabel.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get indexLabel;

  /// No description provided for @selectWeatherType.
  ///
  /// In en, this message translates to:
  /// **'Select weather type'**
  String get selectWeatherType;

  /// No description provided for @counts.
  ///
  /// In en, this message translates to:
  /// **'Count Settings'**
  String get counts;

  /// No description provided for @initial.
  ///
  /// In en, this message translates to:
  /// **'Initial count (InitialPotionCount)'**
  String get initial;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max count (MaxPotionCount)'**
  String get max;

  /// No description provided for @spawnTimerShort.
  ///
  /// In en, this message translates to:
  /// **'Spawn Interval (PotionSpawnTimer)'**
  String get spawnTimerShort;

  /// No description provided for @minSec.
  ///
  /// In en, this message translates to:
  /// **'Min (seconds)'**
  String get minSec;

  /// No description provided for @maxSec.
  ///
  /// In en, this message translates to:
  /// **'Max (seconds)'**
  String get maxSec;

  /// No description provided for @potionTypes.
  ///
  /// In en, this message translates to:
  /// **'Potion Types (PotionTypes)'**
  String get potionTypes;

  /// No description provided for @noPotionTypes.
  ///
  /// In en, this message translates to:
  /// **'No potion types configured; add one to continue'**
  String get noPotionTypes;

  /// No description provided for @ignoreGravestoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable to spawn regardless of grid items'**
  String get ignoreGravestoneSubtitle;

  /// No description provided for @thisPortalSpawns.
  ///
  /// In en, this message translates to:
  /// **'This portal can spawn:'**
  String get thisPortalSpawns;

  /// No description provided for @startEndFormat.
  ///
  /// In en, this message translates to:
  /// **'Start: ({sx}, {sy})  End: ({ex}, {ey})'**
  String startEndFormat(int sx, int sy, int ex, int ey);

  /// No description provided for @indexN.
  ///
  /// In en, this message translates to:
  /// **'Index: {n}'**
  String indexN(int n);

  /// No description provided for @noItemsAddHint.
  ///
  /// In en, this message translates to:
  /// **'No items. Add plants, zombies, or collectibles.'**
  String get noItemsAddHint;

  /// No description provided for @zombieTypeSpiderZombieName.
  ///
  /// In en, this message translates to:
  /// **'Zombie type (SpiderZombieName)'**
  String get zombieTypeSpiderZombieName;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @totalSpiderCount.
  ///
  /// In en, this message translates to:
  /// **'Total count (SpiderCount)'**
  String get totalSpiderCount;

  /// No description provided for @perBatchGroupSize.
  ///
  /// In en, this message translates to:
  /// **'Per batch count (GroupSize)'**
  String get perBatchGroupSize;

  /// No description provided for @fallTime.
  ///
  /// In en, this message translates to:
  /// **'Fall time (ZombieFallTime; seconds)'**
  String get fallTime;

  /// No description provided for @waveStartMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Red warning message (WaveStartMessage)'**
  String get waveStartMessageLabel;

  /// No description provided for @optionalWarningText.
  ///
  /// In en, this message translates to:
  /// **'Optional warning text shown at the center of the screen when the drop begins; Chinese is not supported'**
  String get optionalWarningText;

  /// No description provided for @rowNShort.
  ///
  /// In en, this message translates to:
  /// **'Row {n}'**
  String rowNShort(int n);

  /// No description provided for @weightMaxFormat.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight}, Max: {max}'**
  String weightMaxFormat(int weight, int max);

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @noChallengesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No challenges configured'**
  String get noChallengesConfigured;

  /// No description provided for @whiteListBlackListHint.
  ///
  /// In en, this message translates to:
  /// **'If the whitelist is empty, no restrictions are applied.\nParallel Universe plants are ignored by the whitelist unless the corresponding module is enabled.\nThe blacklist explicitly disables plants and takes priority over the whitelist.'**
  String get whiteListBlackListHint;

  /// No description provided for @conveyorBeltHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Conveyor-belt delivers seed packets randomly based on configured weights. Requires a plant pool and drop delay settings.'**
  String get conveyorBeltHelpIntro;

  /// No description provided for @conveyorBeltHelpPool.
  ///
  /// In en, this message translates to:
  /// **'Plant pool & weight: Probability = weight / total weight. Use thresholds to adjust dynamically.'**
  String get conveyorBeltHelpPool;

  /// No description provided for @conveyorBeltHelpDropDelay.
  ///
  /// In en, this message translates to:
  /// **'Seed packets delay: Controls the interval between seed packet generation. The interval can scale based on the number of queued plants: more backlog usually results in slower generation.'**
  String get conveyorBeltHelpDropDelay;

  /// No description provided for @conveyorBeltHelpSpeed.
  ///
  /// In en, this message translates to:
  /// **'Conveyor speed: Controls the movement speed of cards on the conveyor belt. Default speed is 100. Speed can scale dynamically based on backlog size.'**
  String get conveyorBeltHelpSpeed;

  /// No description provided for @cannotAddEliteZombies.
  ///
  /// In en, this message translates to:
  /// **'Cannot add elite zombies'**
  String get cannotAddEliteZombies;

  /// No description provided for @eliteZombiesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Elite zombies are not allowed here'**
  String get eliteZombiesNotAllowed;

  /// No description provided for @yetiZombiesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Yetis are not allowed here'**
  String get yetiZombiesNotAllowed;

  /// No description provided for @fixToAlias.
  ///
  /// In en, this message translates to:
  /// **'Fix to {alias}'**
  String fixToAlias(Object alias);

  /// No description provided for @editPresetZombie.
  ///
  /// In en, this message translates to:
  /// **'Edit preset zombie: {name}'**
  String editPresetZombie(Object name);

  /// No description provided for @missingZombossMechModule.
  ///
  /// In en, this message translates to:
  /// **'Missing ZombossMech battle module (ZombossBattleModuleProperties)'**
  String get missingZombossMechModule;

  /// No description provided for @missingZombossBattleModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Zomboss battle module (ZombossLastStandMinigameProperties)'**
  String get missingZombossBattleModule;

  /// No description provided for @challengeNoConfig.
  ///
  /// In en, this message translates to:
  /// **'This challenge doesn\'t support configuration.'**
  String get challengeNoConfig;

  /// No description provided for @maxPotionCount.
  ///
  /// In en, this message translates to:
  /// **'Max Potion Count'**
  String get maxPotionCount;

  /// No description provided for @potionTypesConfigured.
  ///
  /// In en, this message translates to:
  /// **'Potion types: {count} configured'**
  String potionTypesConfigured(int count);

  /// No description provided for @pipelinesCount.
  ///
  /// In en, this message translates to:
  /// **'Pipelines: {count}'**
  String pipelinesCount(int count);

  /// No description provided for @windN.
  ///
  /// In en, this message translates to:
  /// **'Freezing Wind #{n}'**
  String windN(int n);

  /// No description provided for @zombieList.
  ///
  /// In en, this message translates to:
  /// **'Zombie list'**
  String get zombieList;

  /// No description provided for @positionPoolSpawnPositions.
  ///
  /// In en, this message translates to:
  /// **'Position pool (SpawnPositionsPool)'**
  String get positionPoolSpawnPositions;

  /// No description provided for @tapCellsSelectDeselect.
  ///
  /// In en, this message translates to:
  /// **'Tap tiles to select/deselect spawn positions'**
  String get tapCellsSelectDeselect;

  /// No description provided for @gravestonePool.
  ///
  /// In en, this message translates to:
  /// **'Item pool (GravestonePool)'**
  String get gravestonePool;

  /// No description provided for @removePlants.
  ///
  /// In en, this message translates to:
  /// **'Remove plants'**
  String get removePlants;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @eliteZombiesUseDefaultLevel.
  ///
  /// In en, this message translates to:
  /// **'Elite zombies use default level.'**
  String get eliteZombiesUseDefaultLevel;

  /// No description provided for @basicParameters.
  ///
  /// In en, this message translates to:
  /// **'Basic parameters'**
  String get basicParameters;

  /// No description provided for @zombieSpawnWaitSec.
  ///
  /// In en, this message translates to:
  /// **'Spawn delay (seconds) '**
  String get zombieSpawnWaitSec;

  /// No description provided for @gridTypes.
  ///
  /// In en, this message translates to:
  /// **'Grid item types'**
  String get gridTypes;

  /// No description provided for @zombiesCount.
  ///
  /// In en, this message translates to:
  /// **'Zombies ({count})'**
  String zombiesCount(int count);

  /// No description provided for @eventGraveSpawnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Event: Grave Item Spawner'**
  String get eventGraveSpawnSubtitle;

  /// No description provided for @eventStormSpawnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Event: Storm Raid'**
  String get eventStormSpawnSubtitle;

  /// No description provided for @eventHelpGraveSpawnZombieWait.
  ///
  /// In en, this message translates to:
  /// **'Delay between wave start and zombie spawn. Zombies won\'t spawn if the next wave has already begun.'**
  String get eventHelpGraveSpawnZombieWait;

  /// No description provided for @eventHelpStormOverview.
  ///
  /// In en, this message translates to:
  /// **'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.'**
  String get eventHelpStormOverview;

  /// No description provided for @eventHelpStormColumnRange.
  ///
  /// In en, this message translates to:
  /// **'The left boundary is column 0 and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.'**
  String get eventHelpStormColumnRange;

  /// No description provided for @eventHelpStormZombieLevels.
  ///
  /// In en, this message translates to:
  /// **'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.'**
  String get eventHelpStormZombieLevels;

  /// No description provided for @spawnParameters.
  ///
  /// In en, this message translates to:
  /// **'Spawn parameters'**
  String get spawnParameters;

  /// No description provided for @sandstorm.
  ///
  /// In en, this message translates to:
  /// **'Sandstorm'**
  String get sandstorm;

  /// No description provided for @snowstorm.
  ///
  /// In en, this message translates to:
  /// **'Snowstorm'**
  String get snowstorm;

  /// No description provided for @excoldStorm.
  ///
  /// In en, this message translates to:
  /// **'Freezing Storm'**
  String get excoldStorm;

  /// No description provided for @columnStart.
  ///
  /// In en, this message translates to:
  /// **'Start column (ColumnStart)'**
  String get columnStart;

  /// No description provided for @columnEnd.
  ///
  /// In en, this message translates to:
  /// **'End column (ColumnEnd)'**
  String get columnEnd;

  /// No description provided for @applyBatchLevelContent.
  ///
  /// In en, this message translates to:
  /// **'Set all zombies in this wave to level {level} (elite zombies unaffected)'**
  String applyBatchLevelContent(int level);

  /// No description provided for @randomRow.
  ///
  /// In en, this message translates to:
  /// **'Random row'**
  String get randomRow;

  /// No description provided for @levelFormat.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelFormat(int level);

  /// No description provided for @levelAccount.
  ///
  /// In en, this message translates to:
  /// **'Level: account'**
  String get levelAccount;

  /// No description provided for @levelDisplay.
  ///
  /// In en, this message translates to:
  /// **'Level: {value}'**
  String levelDisplay(Object value);

  /// No description provided for @eventStandardSpawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Spawner'**
  String get eventStandardSpawnTitle;

  /// No description provided for @eventGroundSpawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Ground Spawner'**
  String get eventGroundSpawnTitle;

  /// No description provided for @eventHelpStandardOverview.
  ///
  /// In en, this message translates to:
  /// **'Basic event for spawning zombies. Allows configuring the level and row for each zombie. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\nBy default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.'**
  String get eventHelpStandardOverview;

  /// No description provided for @eventHelpStandardRow.
  ///
  /// In en, this message translates to:
  /// **'Zombies can spawn in any row from 1–5, or in a random row.'**
  String get eventHelpStandardRow;

  /// No description provided for @eventHelpStandardRowDeepSea.
  ///
  /// In en, this message translates to:
  /// **'Zombies can spawn in any row from 1–6, or in a random row.'**
  String get eventHelpStandardRowDeepSea;

  /// No description provided for @warningStageSwitchedTo5Rows.
  ///
  /// In en, this message translates to:
  /// **'The lawn only has 5 rows, but some data references row 6. These objects may not appear correctly in-game.'**
  String get warningStageSwitchedTo5Rows;

  /// No description provided for @warningObjectsOutsideArea.
  ///
  /// In en, this message translates to:
  /// **'Some objects are placed outside the lawn ({rows} rows × {cols} cols).'**
  String warningObjectsOutsideArea(int rows, int cols);

  /// No description provided for @izombieModeTitle.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie Mode'**
  String get izombieModeTitle;

  /// No description provided for @izombieModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switches to zombie placement gameplay. Seed selection will be locked.'**
  String get izombieModeSubtitle;

  /// No description provided for @reverseZombieFactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Invert Zombie Faction'**
  String get reverseZombieFactionTitle;

  /// No description provided for @reverseZombieFactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Placed zombies will belong to the plant faction. Useful for Plant Wars (ZvZ) mini-game.'**
  String get reverseZombieFactionSubtitle;

  /// No description provided for @initialWeight.
  ///
  /// In en, this message translates to:
  /// **'Initial weight'**
  String get initialWeight;

  /// No description provided for @plantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level'**
  String get plantLevelLabel;

  /// No description provided for @missingIntroModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Intro Module'**
  String get missingIntroModule;

  /// No description provided for @missingIntroModuleHint.
  ///
  /// In en, this message translates to:
  /// **'Level is missing ZombossMech intro module (ZombossBattleIntroProperties). The level may not function correctly. Please add the module and reselect the ZombossMech.'**
  String get missingIntroModuleHint;

  /// No description provided for @zombossMechType.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech type'**
  String get zombossMechType;

  /// No description provided for @unknownZombossMech.
  ///
  /// In en, this message translates to:
  /// **'Unknown ZombossMech'**
  String get unknownZombossMech;

  /// No description provided for @zombossMechSelection.
  ///
  /// In en, this message translates to:
  /// **'ZombossMech selection'**
  String get zombossMechSelection;

  /// No description provided for @zombossMechBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Base ZombossMech'**
  String get zombossMechBaseLabel;

  /// No description provided for @zombossMechBaseHint.
  ///
  /// In en, this message translates to:
  /// **'Mech boss family (Egypt, Future, Memory Lane robot, etc.). Changing this updates the available variations below.'**
  String get zombossMechBaseHint;

  /// No description provided for @zombossMechSelectBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select base ZombossMech'**
  String get zombossMechSelectBaseTitle;

  /// No description provided for @zombossMechChangeBase.
  ///
  /// In en, this message translates to:
  /// **'Change base ZombossMech'**
  String get zombossMechChangeBase;

  /// No description provided for @zombossMechUsedProperties.
  ///
  /// In en, this message translates to:
  /// **'Used properties'**
  String get zombossMechUsedProperties;

  /// No description provided for @zombossMechVariationLabel.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get zombossMechVariationLabel;

  /// No description provided for @zombossMechVariationHint.
  ///
  /// In en, this message translates to:
  /// **'Specific mech type used in-game (ZombossMechType). Options depend on the base ZombossMech selected above. Phase count and spawn position sync automatically.'**
  String get zombossMechVariationHint;

  /// No description provided for @zombossBattleSelection.
  ///
  /// In en, this message translates to:
  /// **'Zomboss selection'**
  String get zombossBattleSelection;

  /// No description provided for @zombossBattleSelectBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select base Zomboss'**
  String get zombossBattleSelectBaseTitle;

  /// No description provided for @zombossBattleChangeBase.
  ///
  /// In en, this message translates to:
  /// **'Change base Zomboss'**
  String get zombossBattleChangeBase;

  /// No description provided for @zombossBattleBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Base zomboss'**
  String get zombossBattleBaseLabel;

  /// No description provided for @zombossBattleBaseHint.
  ///
  /// In en, this message translates to:
  /// **'Boss family (Kongfu blade, Qin Shi Huang, etc.). Changing this updates bundled resource groups automatically.'**
  String get zombossBattleBaseHint;

  /// No description provided for @zombossBattleVariationLabel.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get zombossBattleVariationLabel;

  /// No description provided for @zombossBattleVariationHint.
  ///
  /// In en, this message translates to:
  /// **'Specific Zomboss type used in-game (ZombossTypeName). Options depend on the base zomboss selected above.'**
  String get zombossBattleVariationHint;

  /// No description provided for @zombossBattleStartingSunLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting sun (StartingSun)'**
  String get zombossBattleStartingSunLabel;

  /// No description provided for @zombossBattleStartingSunHint.
  ///
  /// In en, this message translates to:
  /// **'Sun available when the battle begins.'**
  String get zombossBattleStartingSunHint;

  /// No description provided for @zombossBattleStartingPlantfoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting plant food (StartingPlantfood)'**
  String get zombossBattleStartingPlantfoodLabel;

  /// No description provided for @zombossBattleStartingPlantfoodHint.
  ///
  /// In en, this message translates to:
  /// **'Plant Food available when the battle begins.'**
  String get zombossBattleStartingPlantfoodHint;

  /// No description provided for @zombossBattleInitialGridColLabel.
  ///
  /// In en, this message translates to:
  /// **'Spawn column (ZombossInitialGridCol)'**
  String get zombossBattleInitialGridColLabel;

  /// No description provided for @zombossBattleInitialGridColHint.
  ///
  /// In en, this message translates to:
  /// **'Grid column where the Zomboss appears.'**
  String get zombossBattleInitialGridColHint;

  /// No description provided for @zombossBattleInitialGridRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Spawn row (ZombossInitialGridRow)'**
  String get zombossBattleInitialGridRowLabel;

  /// No description provided for @zombossBattleInitialGridRowHint.
  ///
  /// In en, this message translates to:
  /// **'Grid row where the Zomboss appears.'**
  String get zombossBattleInitialGridRowHint;

  /// No description provided for @zombossBattleStartStageIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Start stage (ZombossStartStageIndex)'**
  String get zombossBattleStartStageIndexLabel;

  /// No description provided for @zombossBattleStartStageIndexHint.
  ///
  /// In en, this message translates to:
  /// **'Which boss phase index the fight begins at (0 = first phase).'**
  String get zombossBattleStartStageIndexHint;

  /// No description provided for @zombossBattleSkipPlantingLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip planting phase (SkipPlanting)'**
  String get zombossBattleSkipPlantingLabel;

  /// No description provided for @zombossBattleSkipPlantingHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the level skips the setup/planting phase before the boss fight.'**
  String get zombossBattleSkipPlantingHint;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @reservedColumnCount.
  ///
  /// In en, this message translates to:
  /// **'Reserved Columns (ReservedColumnCount)'**
  String get reservedColumnCount;

  /// No description provided for @reservedColumnCountHint.
  ///
  /// In en, this message translates to:
  /// **'Number of columns reserved on the right where planting is disabled. Typically 2 or more columns are reserved.'**
  String get reservedColumnCountHint;

  /// No description provided for @protectedList.
  ///
  /// In en, this message translates to:
  /// **'Protected Targets'**
  String get protectedList;

  /// No description provided for @plantLevelsFollowGlobal.
  ///
  /// In en, this message translates to:
  /// **'Plants in this module follow their respective tiers from the player’s account. You can standardize their levels using the Tier Definition module.'**
  String get plantLevelsFollowGlobal;

  /// No description provided for @protectPlantsOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines plants that must be protected. The level fails if any of them are eaten or destroyed.'**
  String get protectPlantsOverview;

  /// No description provided for @protectPlantsAutoCount.
  ///
  /// In en, this message translates to:
  /// **'The required count updates automatically based on the number of plants added.'**
  String get protectPlantsAutoCount;

  /// No description provided for @protectItemsOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines grid items that must be protected. The level fails if any of them are destroyed.'**
  String get protectItemsOverview;

  /// No description provided for @protectItemsAutoCount.
  ///
  /// In en, this message translates to:
  /// **'The required count updates automatically based on the number of grid items added.'**
  String get protectItemsAutoCount;

  /// No description provided for @positionsCount.
  ///
  /// In en, this message translates to:
  /// **'Positions: {count}'**
  String positionsCount(int count);

  /// No description provided for @totalItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Total items to be spawned: {count}'**
  String totalItemsCount(int count);

  /// No description provided for @itemCountExceedsPositionsWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Total grid items exceed available positions. Some grid items will not spawn!'**
  String get itemCountExceedsPositionsWarning;

  /// No description provided for @gravestoneBlockedInfo.
  ///
  /// In en, this message translates to:
  /// **'Grid items like tombstones cannot spawn if blocked by plants. Use other methods to force spawn them, such as the Potion Drop event.'**
  String get gravestoneBlockedInfo;

  /// No description provided for @enterConditionValue.
  ///
  /// In en, this message translates to:
  /// **'Enter condition value'**
  String get enterConditionValue;

  /// No description provided for @customInputHint.
  ///
  /// In en, this message translates to:
  /// **'Custom input must be accurate'**
  String get customInputHint;

  /// No description provided for @presetConditions.
  ///
  /// In en, this message translates to:
  /// **'Preset conditions'**
  String get presetConditions;

  /// No description provided for @selectFromPresetHint.
  ///
  /// In en, this message translates to:
  /// **'Select from preset condition list'**
  String get selectFromPresetHint;

  /// No description provided for @conveyorCardPool.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Pool'**
  String get conveyorCardPool;

  /// No description provided for @toolCardsUseFixedLevel.
  ///
  /// In en, this message translates to:
  /// **'Tool packets use a fixed level by default and do not need to be modified.'**
  String get toolCardsUseFixedLevel;

  /// No description provided for @maxLimits.
  ///
  /// In en, this message translates to:
  /// **'Max limits'**
  String get maxLimits;

  /// No description provided for @maxCountThreshold.
  ///
  /// In en, this message translates to:
  /// **'Max count threshold'**
  String get maxCountThreshold;

  /// No description provided for @weightFactor.
  ///
  /// In en, this message translates to:
  /// **'Post-threshold weight multiplier'**
  String get weightFactor;

  /// No description provided for @minLimits.
  ///
  /// In en, this message translates to:
  /// **'Min limits'**
  String get minLimits;

  /// No description provided for @minCountThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min count threshold'**
  String get minCountThreshold;

  /// No description provided for @followAccountLevel.
  ///
  /// In en, this message translates to:
  /// **'Level 0 plants use their corresponding tier from the player\'s account.'**
  String get followAccountLevel;

  /// No description provided for @enablePointSpawning.
  ///
  /// In en, this message translates to:
  /// **'Enable Point-Based Spawning'**
  String get enablePointSpawning;

  /// No description provided for @pointSpawningEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enabled (uses points to spawn extra zombies)'**
  String get pointSpawningEnabledDesc;

  /// No description provided for @pointSpawningDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Disabled (event-based spawning only)'**
  String get pointSpawningDisabledDesc;

  /// No description provided for @pointSettings.
  ///
  /// In en, this message translates to:
  /// **'Point settings'**
  String get pointSettings;

  /// No description provided for @startingWave.
  ///
  /// In en, this message translates to:
  /// **'Starting wave'**
  String get startingWave;

  /// No description provided for @startingPoints.
  ///
  /// In en, this message translates to:
  /// **'Starting points'**
  String get startingPoints;

  /// No description provided for @pointIncrement.
  ///
  /// In en, this message translates to:
  /// **'Point increase per wave'**
  String get pointIncrement;

  /// No description provided for @zombiePool.
  ///
  /// In en, this message translates to:
  /// **'Zombie pool'**
  String get zombiePool;

  /// No description provided for @plantLevelsCount.
  ///
  /// In en, this message translates to:
  /// **'Plant levels: {count}'**
  String plantLevelsCount(int count);

  /// No description provided for @lvN.
  ///
  /// In en, this message translates to:
  /// **'Level {n}'**
  String lvN(int n);

  /// No description provided for @pennyClassroom.
  ///
  /// In en, this message translates to:
  /// **'Penny Classroom module'**
  String get pennyClassroom;

  /// No description provided for @protectGridItems.
  ///
  /// In en, this message translates to:
  /// **'Event: Save Our Items'**
  String get protectGridItems;

  /// No description provided for @waveManagerHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager defines the wave event container. Wave editing is only available after adding this module.'**
  String get waveManagerHelpOverview;

  /// No description provided for @waveManagerHelpPoints.
  ///
  /// In en, this message translates to:
  /// **'Point-based spawning generates additional zombies during valid waves based on point cost.\nNormal waves have a cap of 60,000 points, while flag waves use a 2.5× multiplier.\nWhen points are positive, zombies are selected from the zombie pool. Expected spawn values for each zombie can be viewed in the wave event container.\nWhen points are negative, zombies with equivalent point value are removed from natural spawns.\nDo not include Elite Zombies, Yetis, or custom zombies in the point-based spawning pool.'**
  String get waveManagerHelpPoints;

  /// No description provided for @pointsSection.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsSection;

  /// No description provided for @globalPlantLevelsOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines plant levels globally within the level. This setting overrides seed packet levels and allows individual customization for specific plants.'**
  String get globalPlantLevelsOverview;

  /// No description provided for @globalPlantLevelsScope.
  ///
  /// In en, this message translates to:
  /// **'Applies to all instances of the plant used in the level, including endangered plants and packet drops.'**
  String get globalPlantLevelsScope;

  /// No description provided for @mustProtectCountFormat.
  ///
  /// In en, this message translates to:
  /// **'Required to protect: {count}'**
  String mustProtectCountFormat(int count);

  /// No description provided for @noWaveManagerPropsFound.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager module (WaveManagerProperties) not found.'**
  String get noWaveManagerPropsFound;

  /// No description provided for @itemsSortedByRow.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get itemsSortedByRow;

  /// No description provided for @eventStormSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Storm Raid'**
  String get eventStormSpawn;

  /// No description provided for @stormEvent.
  ///
  /// In en, this message translates to:
  /// **'Storm Raid'**
  String get stormEvent;

  /// No description provided for @makeCustom.
  ///
  /// In en, this message translates to:
  /// **'Set as custom'**
  String get makeCustom;

  /// No description provided for @zombieLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.'**
  String get zombieLevelsBody;

  /// No description provided for @batchLevel.
  ///
  /// In en, this message translates to:
  /// **'Batch level'**
  String get batchLevel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @backgroundMusicLevelJam.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour music switch (LevelJam)'**
  String get backgroundMusicLevelJam;

  /// No description provided for @onlyAppliesRockEra.
  ///
  /// In en, this message translates to:
  /// **'Switches the background music when triggered. Only applies to Neon Mixtape Tour levels.'**
  String get onlyAppliesRockEra;

  /// No description provided for @appliesToAllNonElite.
  ///
  /// In en, this message translates to:
  /// **'Sets all zombies in this wave to the specified level (elite zombies are unaffected and retain their default level)'**
  String get appliesToAllNonElite;

  /// No description provided for @dropConfigPlants.
  ///
  /// In en, this message translates to:
  /// **'Drop Configuration (seed packets)'**
  String get dropConfigPlants;

  /// No description provided for @dropConfigPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Drop config (Plant Food)'**
  String get dropConfigPlantFood;

  /// No description provided for @zombiesCarryingPlants.
  ///
  /// In en, this message translates to:
  /// **'Zombies carrying seed packets'**
  String get zombiesCarryingPlants;

  /// No description provided for @zombiesCarryingPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Zombies carrying Plant Food'**
  String get zombiesCarryingPlantFood;

  /// No description provided for @descriptiveName.
  ///
  /// In en, this message translates to:
  /// **'Descriptive Name'**
  String get descriptiveName;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @targetDistance.
  ///
  /// In en, this message translates to:
  /// **'Flowerbed Distance (TargetDistance) — Distance from the left edge (in columns); higher values are closer to the house; supports decimals'**
  String get targetDistance;

  /// No description provided for @targetSun.
  ///
  /// In en, this message translates to:
  /// **'Target Sun'**
  String get targetSun;

  /// No description provided for @maximumSun.
  ///
  /// In en, this message translates to:
  /// **'Sun Cap (MaximumSun)'**
  String get maximumSun;

  /// No description provided for @holdoutSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration (HoldoutSeconds)'**
  String get holdoutSeconds;

  /// No description provided for @zombiesToKill.
  ///
  /// In en, this message translates to:
  /// **'Zombies to Kill (ZombiesToKill)'**
  String get zombiesToKill;

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time Limit (seconds)'**
  String get timeSeconds;

  /// No description provided for @speedModifier.
  ///
  /// In en, this message translates to:
  /// **'Speed Multiplier (SpeedModifier) — e.g. 0.5 = +50% zombie speed'**
  String get speedModifier;

  /// No description provided for @sunModifier.
  ///
  /// In en, this message translates to:
  /// **'Sun Reduction (SunModifier) — e.g. 0.2 = −20% sun gain'**
  String get sunModifier;

  /// No description provided for @maximumPlantsLost.
  ///
  /// In en, this message translates to:
  /// **'Maximum Plants Lost'**
  String get maximumPlantsLost;

  /// No description provided for @maximumPlants.
  ///
  /// In en, this message translates to:
  /// **'Maximum Plants on the Lawn'**
  String get maximumPlants;

  /// No description provided for @targetScore.
  ///
  /// In en, this message translates to:
  /// **'Target Score'**
  String get targetScore;

  /// No description provided for @plantBombRadius.
  ///
  /// In en, this message translates to:
  /// **'Plant explosion radius'**
  String get plantBombRadius;

  /// No description provided for @plantType.
  ///
  /// In en, this message translates to:
  /// **'Plant Type'**
  String get plantType;

  /// No description provided for @gridX.
  ///
  /// In en, this message translates to:
  /// **'Grid X'**
  String get gridX;

  /// No description provided for @gridY.
  ///
  /// In en, this message translates to:
  /// **'Grid Y'**
  String get gridY;

  /// No description provided for @noCardsYetAddPlants.
  ///
  /// In en, this message translates to:
  /// **'No seed packets yet. Add plants or tool packets.'**
  String get noCardsYetAddPlants;

  /// No description provided for @mustProtectCountAll.
  ///
  /// In en, this message translates to:
  /// **'Required to Protect (0 = protect all)'**
  String get mustProtectCountAll;

  /// No description provided for @mustProtectCount.
  ///
  /// In en, this message translates to:
  /// **'Current protected target count: {count}'**
  String mustProtectCount(int count);

  /// No description provided for @gridItemType.
  ///
  /// In en, this message translates to:
  /// **'Grid item type'**
  String get gridItemType;

  /// No description provided for @zombieBombRadius.
  ///
  /// In en, this message translates to:
  /// **'Zombie explosion radius'**
  String get zombieBombRadius;

  /// No description provided for @plantDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage to plants'**
  String get plantDamage;

  /// No description provided for @zombieDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage to zombies'**
  String get zombieDamage;

  /// No description provided for @initialPotionCount.
  ///
  /// In en, this message translates to:
  /// **'Initial count (InitialPotionCount)'**
  String get initialPotionCount;

  /// No description provided for @operationTimePerGrid.
  ///
  /// In en, this message translates to:
  /// **'Transfer time (seconds per tile)'**
  String get operationTimePerGrid;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level: '**
  String get levelLabel;

  /// No description provided for @mistParameters.
  ///
  /// In en, this message translates to:
  /// **'Fog parameters'**
  String get mistParameters;

  /// No description provided for @sunDropParameters.
  ///
  /// In en, this message translates to:
  /// **'Sun drop parameters'**
  String get sunDropParameters;

  /// No description provided for @initialDropDelay.
  ///
  /// In en, this message translates to:
  /// **'Initial drop delay (InitialSunDropDelay)'**
  String get initialDropDelay;

  /// No description provided for @baseCountdown.
  ///
  /// In en, this message translates to:
  /// **'Base drop interval (SunCountdownBase)'**
  String get baseCountdown;

  /// No description provided for @maxCountdown.
  ///
  /// In en, this message translates to:
  /// **'Max drop interval (SunCountdownMax)'**
  String get maxCountdown;

  /// No description provided for @countdownRange.
  ///
  /// In en, this message translates to:
  /// **'Interval variation range (SunCountdownRange)'**
  String get countdownRange;

  /// No description provided for @increasePerSun.
  ///
  /// In en, this message translates to:
  /// **'Increase per sun (SunCountdownIncreasePerSun)'**
  String get increasePerSun;

  /// No description provided for @inflationParams.
  ///
  /// In en, this message translates to:
  /// **'Inflation parameters'**
  String get inflationParams;

  /// No description provided for @baseCostIncreaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost increase per planting (BaseCostIncreased)'**
  String get baseCostIncreaseLabel;

  /// No description provided for @maxIncreaseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Increase Count (MaxIncreasedCount) — Capped at 10 in-game, value changes have no effect'**
  String get maxIncreaseCountLabel;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroup;

  /// No description provided for @gridTapAddRemove.
  ///
  /// In en, this message translates to:
  /// **'Tile (tap to add/change, long-press to remove)'**
  String get gridTapAddRemove;

  /// No description provided for @sunBombHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get sunBombHelpOverview;

  /// No description provided for @sunBombHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Required for the Far Future brain buster \"Sun Bomb\". When enabled, falling sun will turn into purple, detonatable Sun Bombs. Damage dealt by Sun Bombs can be configured separately for different factions.'**
  String get sunBombHelpBody;

  /// No description provided for @bombProperties.
  ///
  /// In en, this message translates to:
  /// **'Powder Keg module'**
  String get bombProperties;

  /// No description provided for @bombPropertiesHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Required for configuring the Kongfu World brain buster \"Powder Keg\". When enabled, Powder Kegs will appear at lawn mower positions and spawn a fuse that can be ignited. If a flame travels along the fuse and reaches the Powder Keg, it will explode, destroying plants within a 3×3 area centered on itself.'**
  String get bombPropertiesHelpBody;

  /// No description provided for @bombPropertiesHelpFuse.
  ///
  /// In en, this message translates to:
  /// **'Fuse lengths'**
  String get bombPropertiesHelpFuse;

  /// No description provided for @bombPropertiesHelpFuseBody.
  ///
  /// In en, this message translates to:
  /// **'Fuse length is configured per row, starting from row 1 (top to bottom). Each row corresponds to a value in the array, representing how many tiles the fuse extends to the right. Standard lawns have 5 rows, while Underwater World lawns have 6. The array length will automatically adjust based on the current lawn when opening this panel.'**
  String get bombPropertiesHelpFuseBody;

  /// No description provided for @bombPropertiesFlameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Fuse Burn Speed (FlameSpeed)'**
  String get bombPropertiesFlameSpeed;

  /// No description provided for @bombPropertiesFuseLengths.
  ///
  /// In en, this message translates to:
  /// **'Fuse Lengths (FuseLengths)'**
  String get bombPropertiesFuseLengths;

  /// No description provided for @bombPropertiesFuseLengthsHint.
  ///
  /// In en, this message translates to:
  /// **'Set how many tiles the fuse extends to the right for each row (one value per row)'**
  String get bombPropertiesFuseLengthsHint;

  /// No description provided for @bombPropertiesFuseLength.
  ///
  /// In en, this message translates to:
  /// **'Fuse Length'**
  String get bombPropertiesFuseLength;

  /// No description provided for @damage.
  ///
  /// In en, this message translates to:
  /// **'Explosion Damage'**
  String get damage;

  /// No description provided for @explosionRadius.
  ///
  /// In en, this message translates to:
  /// **'Explosion Radius'**
  String get explosionRadius;

  /// No description provided for @plantRadius.
  ///
  /// In en, this message translates to:
  /// **'Plant explosion radius'**
  String get plantRadius;

  /// No description provided for @zombieRadius.
  ///
  /// In en, this message translates to:
  /// **'Zombie explosion radius'**
  String get zombieRadius;

  /// No description provided for @radiusPixelsHint.
  ///
  /// In en, this message translates to:
  /// **'Explosion radius is measured in pixels (1 tile ≈ 60 pixels).'**
  String get radiusPixelsHint;

  /// No description provided for @enterMaxSunHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the level’s maximum sun cap (e.g. 9900)'**
  String get enterMaxSunHint;

  /// No description provided for @optionalLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Optional label'**
  String get optionalLabelHint;

  /// No description provided for @imageResourceIdHint.
  ///
  /// In en, this message translates to:
  /// **'IMAGE_... resource id'**
  String get imageResourceIdHint;

  /// No description provided for @enterStartingPlantfoodHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the starting Plant Food amount (0 or more)'**
  String get enterStartingPlantfoodHint;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get threshold;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @seedBankLetsPlayersChoose.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank lets players choose from available plants. In Creative Courtyard, it supports setting a global tier and enables access to all plants. When selection mode is set to Preset, placing the Seed Bank before the Conveyor Belt makes conveyor plants cost sun, while placing it after allows preset plants to be planted without sun cost.'**
  String get seedBankLetsPlayersChoose;

  /// No description provided for @iZombieModePresetHint.
  ///
  /// In en, this message translates to:
  /// **'When I, Zombie Mode is enabled, available zombies must be preset. Selection mode will be forced to Preset. If both plant and zombie seed packets are used, they must be locked to the same level.'**
  String get iZombieModePresetHint;

  /// No description provided for @invalidIdsHint.
  ///
  /// In en, this message translates to:
  /// **'Invalid IDs will appear as empty slots in the Seed Bank. In I, Zombie Mode, plant IDs are invalid, and vice versa. This can be used to create two Seed Banks in one level and combine both modes. Make sure the Zombie Seed Bank is placed first.'**
  String get invalidIdsHint;

  /// No description provided for @seedBankIZombie.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank (I, Zombie Mode)'**
  String get seedBankIZombie;

  /// No description provided for @basicRules.
  ///
  /// In en, this message translates to:
  /// **'Basic Rules'**
  String get basicRules;

  /// No description provided for @selectionMethod.
  ///
  /// In en, this message translates to:
  /// **'Selection Mode'**
  String get selectionMethod;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'The list is empty'**
  String get emptyList;

  /// No description provided for @plantsAvailableAtStart.
  ///
  /// In en, this message translates to:
  /// **'Plants pre-selected at the start'**
  String get plantsAvailableAtStart;

  /// No description provided for @presetPlantListReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press the ⋮⋮ handle and drag to reorder.'**
  String get presetPlantListReorderHint;

  /// No description provided for @presetPlantListReorderHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Drag the ⋮⋮ handle to reorder.'**
  String get presetPlantListReorderHintDesktop;

  /// No description provided for @whiteListDescription.
  ///
  /// In en, this message translates to:
  /// **'Only these plants can be selected (no restriction if empty)'**
  String get whiteListDescription;

  /// No description provided for @blackListDescription.
  ///
  /// In en, this message translates to:
  /// **'These plants cannot be selected'**
  String get blackListDescription;

  /// No description provided for @availableZombiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Zombies available for I, Zombie Mode'**
  String get availableZombiesDescription;

  /// No description provided for @izombieCardSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Only certain zombies have dedicate seed packets and sun costs in I, Zombie (IZ) Mode. These zombies can be found under the \"Other\" category in the zombie selection screen.'**
  String get izombieCardSlotsHint;

  /// No description provided for @seedBankPresetModeHint.
  ///
  /// In en, this message translates to:
  /// **'Preset mode enters game immediately regardless of card count.'**
  String get seedBankPresetModeHint;

  /// No description provided for @seedBankPlantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level (0-5)'**
  String get seedBankPlantLevelLabel;

  /// No description provided for @seedBankSlotCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot count (0-9)'**
  String get seedBankSlotCountLabel;

  /// No description provided for @seedBankCourtyardSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Courtyard mode ignores slot count. Chooser locks 8 slots.'**
  String get seedBankCourtyardSlotsHint;

  /// No description provided for @seedBankAddGridItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add grid items'**
  String get seedBankAddGridItemsTitle;

  /// No description provided for @seedBankAddGridItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Append grid items to PresetPlantList. Duplicates are allowed.'**
  String get seedBankAddGridItemsSubtitle;

  /// No description provided for @seedBankGridItemCount.
  ///
  /// In en, this message translates to:
  /// **'In preset list: {count}'**
  String seedBankGridItemCount(int count);

  /// No description provided for @starChallengeSelectConditions.
  ///
  /// In en, this message translates to:
  /// **'Select conditions'**
  String get starChallengeSelectConditions;

  /// No description provided for @starChallengeEditConditions.
  ///
  /// In en, this message translates to:
  /// **'Edit conditions'**
  String get starChallengeEditConditions;

  /// No description provided for @selectToolCard.
  ///
  /// In en, this message translates to:
  /// **'Select tool packets'**
  String get selectToolCard;

  /// No description provided for @searchGridItems.
  ///
  /// In en, this message translates to:
  /// **'Search grid items'**
  String get searchGridItems;

  /// No description provided for @searchStatues.
  ///
  /// In en, this message translates to:
  /// **'Search renaissance statues or marble mounds'**
  String get searchStatues;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @selectedCountTapToSearch.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}, tap to search'**
  String selectedCountTapToSearch(int count);

  /// No description provided for @noFavoritesLongPress.
  ///
  /// In en, this message translates to:
  /// **'No favorites. Long-press to favorite.'**
  String get noFavoritesLongPress;

  /// No description provided for @gridItemCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get gridItemCategoryAll;

  /// No description provided for @gridItemCategoryScene.
  ///
  /// In en, this message translates to:
  /// **'Scenery'**
  String get gridItemCategoryScene;

  /// No description provided for @gridItemCategoryTrap.
  ///
  /// In en, this message translates to:
  /// **'Interactive Traps'**
  String get gridItemCategoryTrap;

  /// No description provided for @gridItemCategorySpawnableObjects.
  ///
  /// In en, this message translates to:
  /// **'Spawnable Objects'**
  String get gridItemCategorySpawnableObjects;

  /// No description provided for @sunDropperConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Sun Drop Settings'**
  String get sunDropperConfigTitle;

  /// No description provided for @customLocalParams.
  ///
  /// In en, this message translates to:
  /// **'Custom local parameters'**
  String get customLocalParams;

  /// No description provided for @currentModeLocal.
  ///
  /// In en, this message translates to:
  /// **'Current: local (@CurrentLevel)'**
  String get currentModeLocal;

  /// No description provided for @currentModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Current: system default (@LevelModules)'**
  String get currentModeSystem;

  /// No description provided for @paramAdjust.
  ///
  /// In en, this message translates to:
  /// **'Parameter adjustment'**
  String get paramAdjust;

  /// No description provided for @firstDropDelay.
  ///
  /// In en, this message translates to:
  /// **'Initial drop delay (InitialSunDropDelay)'**
  String get firstDropDelay;

  /// No description provided for @initialDropInterval.
  ///
  /// In en, this message translates to:
  /// **'Initial drop interval (SunCountdownBase)'**
  String get initialDropInterval;

  /// No description provided for @maxDropInterval.
  ///
  /// In en, this message translates to:
  /// **'Max drop interval (SunCountdownMax)'**
  String get maxDropInterval;

  /// No description provided for @intervalFloatRange.
  ///
  /// In en, this message translates to:
  /// **'Interval variation range (SunCountdownRange)'**
  String get intervalFloatRange;

  /// No description provided for @sunDropperHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sun Dropper'**
  String get sunDropperHelpTitle;

  /// No description provided for @sunDropperHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Configures falling sun in a level. For night lawns, this module is usually not needed.'**
  String get sunDropperHelpIntro;

  /// No description provided for @sunDropperHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameter configuration'**
  String get sunDropperHelpParams;

  /// No description provided for @sunDropperHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'By default, this module uses the game’s built-in values. You can enable custom settings to edit detailed parameters.'**
  String get sunDropperHelpParamsBody;

  /// No description provided for @noZombossMechFound.
  ///
  /// In en, this message translates to:
  /// **'No ZombossMech found'**
  String get noZombossMechFound;

  /// No description provided for @noZombossBattleFound.
  ///
  /// In en, this message translates to:
  /// **'No zomboss definitions found'**
  String get noZombossBattleFound;

  /// No description provided for @searchChallengeNameOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search by challenge name or codename'**
  String get searchChallengeNameOrCode;

  /// No description provided for @deleteChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete challenge?'**
  String get deleteChallengeTitle;

  /// No description provided for @deleteChallengeConfirmLocal.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This will permanently delete the local challenge data.'**
  String deleteChallengeConfirmLocal(String name);

  /// No description provided for @deleteChallengeConfirmRef.
  ///
  /// In en, this message translates to:
  /// **'Remove reference to \"{name}\"? The challenge will remain in LevelModules.'**
  String deleteChallengeConfirmRef(String name);

  /// No description provided for @missingModulesRecommended.
  ///
  /// In en, this message translates to:
  /// **'The level might not function correctly. Recommended to add the following modules:'**
  String get missingModulesRecommended;

  /// No description provided for @recommendedTunnelDefendTitle.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathways module strongly recommended'**
  String get recommendedTunnelDefendTitle;

  /// No description provided for @recommendedTunnelDefendBody.
  ///
  /// In en, this message translates to:
  /// **'The tiles in Underground Palace Secret Realm lawns must be placed through the \"Underground Palace Pathways\" module. If this module is not added, the lawns may appear overly empty in-game.'**
  String get recommendedTunnelDefendBody;

  /// No description provided for @itemListRowFirst.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get itemListRowFirst;

  /// No description provided for @railcartCowboy.
  ///
  /// In en, this message translates to:
  /// **'Wild West mine cart'**
  String get railcartCowboy;

  /// No description provided for @railcartFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future mine cart'**
  String get railcartFuture;

  /// No description provided for @railcartEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt mine cart'**
  String get railcartEgypt;

  /// No description provided for @railcartPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas mine cart'**
  String get railcartPirate;

  /// No description provided for @railcartWorldcup.
  ///
  /// In en, this message translates to:
  /// **'Ice Hockey mine cart'**
  String get railcartWorldcup;

  /// No description provided for @clearUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear unused objects?'**
  String get clearUnusedTitle;

  /// No description provided for @clearUnusedMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?'**
  String get clearUnusedMessage;

  /// No description provided for @clearUnusedNone.
  ///
  /// In en, this message translates to:
  /// **'No unused objects found.'**
  String get clearUnusedNone;

  /// No description provided for @clearUnusedDone.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} unused object(s).'**
  String clearUnusedDone(int count);

  /// No description provided for @lawnMowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Lawn Mowers'**
  String get lawnMowerTitle;

  /// No description provided for @lawnMowerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lawnMowerNotes;

  /// No description provided for @lawnMowerHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Controls the appearance of lawn mowers in a level. This module does not work when the Creative Courtyard module is enabled.'**
  String get lawnMowerHelpOverview;

  /// No description provided for @lawnMowerHelpNotes.
  ///
  /// In en, this message translates to:
  /// **'This module is typically referenced from LevelModules and does not require custom configuration within the level.'**
  String get lawnMowerHelpNotes;

  /// No description provided for @lawnMowerSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select mower type'**
  String get lawnMowerSelectType;

  /// No description provided for @zombieRushTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Timer module'**
  String get zombieRushTitle;

  /// No description provided for @zombieRushHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'A countdown module from Zombie Elimination Initiative. The level ends and results are calculated when the timer reaches zero.'**
  String get zombieRushHelpOverview;

  /// No description provided for @zombieRushHelpNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get zombieRushHelpNotes;

  /// No description provided for @zombieRushHelpIncompat.
  ///
  /// In en, this message translates to:
  /// **'Penny’s Pursuit timer module is incompatible with Creative Courtyard and may cause crashes. It is recommended to use the Zombie Elimination Initiative timer module instead.'**
  String get zombieRushHelpIncompat;

  /// No description provided for @zombieRushTimeSettings.
  ///
  /// In en, this message translates to:
  /// **'Time Settings'**
  String get zombieRushTimeSettings;

  /// No description provided for @levelCountdown.
  ///
  /// In en, this message translates to:
  /// **'Level countdown (seconds)'**
  String get levelCountdown;

  /// No description provided for @tunnelDefendTitle.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathway Settings'**
  String get tunnelDefendTitle;

  /// No description provided for @tunnelDefendHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Use this module to add pathways from the Underground Palace secret realm to the level. Certain zombies have their interactions with plants affected by pathways.'**
  String get tunnelDefendHelpOverview;

  /// No description provided for @tunnelDefendHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get tunnelDefendHelpUsage;

  /// No description provided for @tunnelDefendHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Select a pathway component from the list below, then click on the grid above to place it. Tapping an existing component of the same type removes it, while selecting a different component will replace it directly.'**
  String get tunnelDefendHelpUsageBody;

  /// No description provided for @tunnelDefendSelectComponent.
  ///
  /// In en, this message translates to:
  /// **'Select component'**
  String get tunnelDefendSelectComponent;

  /// No description provided for @tunnelDefendPlacedCount.
  ///
  /// In en, this message translates to:
  /// **'Placed components'**
  String get tunnelDefendPlacedCount;

  /// No description provided for @tunnelDefendClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get tunnelDefendClearAll;

  /// No description provided for @tunnelDefendClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all pathway components?'**
  String get tunnelDefendClearConfirmTitle;

  /// No description provided for @tunnelDefendClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all placed pathway components from the lawn. This action cannot be undone.'**
  String get tunnelDefendClearConfirmMessage;

  /// No description provided for @tunnelDefendPathOutsideLawn.
  ///
  /// In en, this message translates to:
  /// **'Pathway components outside the lawn: '**
  String get tunnelDefendPathOutsideLawn;

  /// No description provided for @tunnelDefendDeleteOutside.
  ///
  /// In en, this message translates to:
  /// **'Remove pathway components outside the lawn'**
  String get tunnelDefendDeleteOutside;

  /// No description provided for @tunnelDefendDeleteOutsideConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove pathway components outside the lawn?'**
  String get tunnelDefendDeleteOutsideConfirmTitle;

  /// No description provided for @tunnelDefendDeleteOutsideConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all pathway components outside the 5×9 lawn. This action cannot be undone.'**
  String get tunnelDefendDeleteOutsideConfirmMessage;

  /// No description provided for @tunnelDefendTileStylePreset.
  ///
  /// In en, this message translates to:
  /// **'Tile style preset'**
  String get tunnelDefendTileStylePreset;

  /// No description provided for @tunnelDefendTileStylePart1.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Ruins (Chapter 1)'**
  String get tunnelDefendTileStylePart1;

  /// No description provided for @tunnelDefendTileStylePart2.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Spirit Supression (Chapter 2)'**
  String get tunnelDefendTileStylePart2;

  /// No description provided for @tunnelDefendSequenceInterval.
  ///
  /// In en, this message translates to:
  /// **'Tunnel sequence interval (TunnelSequenceInterval, seconds)'**
  String get tunnelDefendSequenceInterval;

  /// No description provided for @tunnelDefendHelpSequenceInterval.
  ///
  /// In en, this message translates to:
  /// **'Sequence interval'**
  String get tunnelDefendHelpSequenceInterval;

  /// No description provided for @tunnelDefendHelpSequenceIntervalBody.
  ///
  /// In en, this message translates to:
  /// **'Delay between tunnel sequence steps. Lower values make pathways appear faster.'**
  String get tunnelDefendHelpSequenceIntervalBody;

  /// No description provided for @moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Final stage time limit'**
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties;

  /// No description provided for @moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables the final zomboss desperation timer. Add or remove only — the timer value comes from the zomboss property sheet (e.g. ZombossFinalStageTimeLimited on Qin Shi Huang props), not from module parameters.'**
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties;

  /// No description provided for @finalStageTimeLimitedChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Final stage time limit'**
  String get finalStageTimeLimitedChallengeTitle;

  /// No description provided for @finalStageTimeLimitedChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Final stage time limit challenge'**
  String get finalStageTimeLimitedChallengeHelpTitle;

  /// No description provided for @finalStageTimeLimitedChallengeHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Adds a timed kill challenge during the final zomboss stage (commonly used in Qin Shi Huang boss fights). The actual timer is read from the zomboss property sheet (ZombossFinalStageTimeLimited), not from this module\'s ZombossTimeLimit field.'**
  String get finalStageTimeLimitedChallengeHelpIntro;

  /// No description provided for @finalStageTimeLimitedChallengeHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameter configuration'**
  String get finalStageTimeLimitedChallengeHelpParams;

  /// No description provided for @finalStageTimeLimitedChallengeHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'This editor screen is currently unwired. Levels should reference RTID(FinalStageTimeLimitedChallenge@LevelModules) only. Custom @CurrentLevel overrides are not supported until the game reads them correctly.'**
  String get finalStageTimeLimitedChallengeHelpParamsBody;

  /// No description provided for @finalStageTimeLimitedChallengeTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Zomboss time limit (ZombossTimeLimit, seconds)'**
  String get finalStageTimeLimitedChallengeTimeLimit;

  /// No description provided for @moduleTitle_LawnMowerProperties.
  ///
  /// In en, this message translates to:
  /// **'Lawn Mowers'**
  String get moduleTitle_LawnMowerProperties;

  /// No description provided for @moduleDesc_LawnMowerProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets mower styles (may not work in custom lawns)'**
  String get moduleDesc_LawnMowerProperties;

  /// No description provided for @moduleTitle_TunnelDefendModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathways'**
  String get moduleTitle_TunnelDefendModuleProperties;

  /// No description provided for @moduleDesc_TunnelDefendModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures pathways and tile styles for Underground Palace secret realm levels'**
  String get moduleDesc_TunnelDefendModuleProperties;

  /// No description provided for @moduleTitle_WitchModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch'**
  String get moduleTitle_WitchModuleProperties;

  /// No description provided for @moduleDesc_WitchModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fright Witches periodically sweep across the lawn, scattering magical potions'**
  String get moduleDesc_WitchModuleProperties;

  /// No description provided for @moduleTitle_InitialGridItemGulliverTunnelProperties.
  ///
  /// In en, this message translates to:
  /// **'Gulliver Tunnels'**
  String get moduleTitle_InitialGridItemGulliverTunnelProperties;

  /// No description provided for @moduleDesc_InitialGridItemGulliverTunnelProperties.
  ///
  /// In en, this message translates to:
  /// **'Places pre-set Gulliver tunnels on the lawn'**
  String get moduleDesc_InitialGridItemGulliverTunnelProperties;

  /// No description provided for @witchModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch Settings'**
  String get witchModuleTitle;

  /// No description provided for @witchModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch module'**
  String get witchModuleHelpTitle;

  /// No description provided for @witchModuleHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Enabling this module adds 2 Fright Witches to the level. After the level begins, Fright Witch will periodically enter from either the left or right side of the lawn, randomly choosing a lane and flying across it on a magic broomstick while scattering magical potions along the way. After a period of time, she returns and repeats the process.\nDifferent potions have different effects: Orange Explosion Potions deal percentage-based damage in a 3×3 area around the landing point; Green Transmutation Potions transform single-tile plants into a sheep, frog, or chicken, and may also turn them into Tall-nut seed packets; Blue Necromancy Potions continuously revive zombies that die within a 3×3 area around the landing point for a duration; Red Berserk Potions grant zombies increased health and movement speed.\nFright Witch cannot be targeted by plants. Planting a Tall-nut in her path will knock her off the lawn; if the Tall-nut has previously used Plant Food, it will shatter the witch permanently, preventing her from returning.'**
  String get witchModuleHelpIntro;

  /// No description provided for @witchModuleHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameter configuration'**
  String get witchModuleHelpParams;

  /// No description provided for @witchModuleHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'By default, this module uses the values defined in the game files. Alternatively, you may enable custom local parameters and modify the interval between witch appearances'**
  String get witchModuleHelpParamsBody;

  /// No description provided for @witchModuleSpawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Witch spawn interval (WitchSpawnInterval, seconds)'**
  String get witchModuleSpawnInterval;

  /// No description provided for @gulliverTunnelTitle.
  ///
  /// In en, this message translates to:
  /// **'Gulliver Tunnels'**
  String get gulliverTunnelTitle;

  /// No description provided for @gulliverTunnelHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module is used to place Gulliver Tunnels on the lawn before the level begins. Depending on their orientation, Gulliver Tunnels come in two forms: a small opening on the right and a large opening on the left, or a small opening on the left and a large opening on the right.\nImps entering through the small opening become Giant Imps with increased health. Regular zombies entering through the large opening become Mini Zombies, gaining increased movement speed and the ability to avoid some higher-flying straight projectiles.\nStraight-flying plant projectiles can also enter through the large opening and emerge from the small opening after being shrunk, dealing reduced damage. Lobbed projectiles can pass over the tunnel and attack zombies normally.'**
  String get gulliverTunnelHelpOverview;

  /// No description provided for @gulliverTunnelHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get gulliverTunnelHelpUsage;

  /// No description provided for @gulliverTunnelHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Select a tunnel orientation below, then click a tile to place it. Clicking a tile containing an existing tunnel removes it. Selecting a different orientation and clicking an existing tunnel replaces its orientation.'**
  String get gulliverTunnelHelpUsageBody;

  /// No description provided for @gulliverTunnelOrientationBigOnLeft.
  ///
  /// In en, this message translates to:
  /// **'Small Opening on Right, Large Opening on Left'**
  String get gulliverTunnelOrientationBigOnLeft;

  /// No description provided for @gulliverTunnelOrientationBigOnRight.
  ///
  /// In en, this message translates to:
  /// **'Small Opening on Left, Large Opening on Right'**
  String get gulliverTunnelOrientationBigOnRight;

  /// No description provided for @gulliverTunnelPlacedCount.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get gulliverTunnelPlacedCount;

  /// No description provided for @gulliverTunnelClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get gulliverTunnelClearAll;

  /// No description provided for @gulliverTunnelClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all Gulliver Tunnels?'**
  String get gulliverTunnelClearConfirmTitle;

  /// No description provided for @gulliverTunnelClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will removbe all placed Gulliver Tunnels from the lawn. This action cannot be undone.'**
  String get gulliverTunnelClearConfirmMessage;

  /// No description provided for @gulliverTunnelSelectOrientation.
  ///
  /// In en, this message translates to:
  /// **'Select orientation'**
  String get gulliverTunnelSelectOrientation;

  /// No description provided for @gulliverTunnelOutsideLawn.
  ///
  /// In en, this message translates to:
  /// **'Tunnels outside the lawn: '**
  String get gulliverTunnelOutsideLawn;

  /// No description provided for @gulliverTunnelDeleteOutside.
  ///
  /// In en, this message translates to:
  /// **'Remove Gulliver Tunnels outside the lawn'**
  String get gulliverTunnelDeleteOutside;

  /// No description provided for @gulliverTunnelDeleteOutsideConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Gulliver Tunnels outside the lawn?'**
  String get gulliverTunnelDeleteOutsideConfirmTitle;

  /// No description provided for @gulliverTunnelDeleteOutsideConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all Gulliver Tunnels outside the 5×9 lawn. This action cannot be undone.'**
  String get gulliverTunnelDeleteOutsideConfirmMessage;

  /// No description provided for @moduleTitle_RiftThemeDemoModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Theme Configuration'**
  String get moduleTitle_RiftThemeDemoModuleProperties;

  /// No description provided for @moduleDesc_RiftThemeDemoModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Adds theme effects from Penny\'s Pursuit, Memory Lane, and other game modes to the level'**
  String get moduleDesc_RiftThemeDemoModuleProperties;

  /// No description provided for @riftThemeModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Configuration'**
  String get riftThemeModuleTitle;

  /// No description provided for @riftThemeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Configuration module'**
  String get riftThemeHelpTitle;

  /// No description provided for @riftThemeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module defines a list of themes for the level. Themes are global conditions found in modes such as Penny\'s Pursuit, Memory Lane, and Secret Realm. Each theme provides unique effects. For detailed descriptions of individual themes, please refer to the wiki.gg pages covering those themes.'**
  String get riftThemeHelpOverview;

  /// No description provided for @riftThemeHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get riftThemeHelpUsage;

  /// No description provided for @riftThemeHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Click the button in the lower-right corner to open the theme selection screen. Themes can be added to or removed from the theme list by clicking them. Once all settings are complete, click the button again to confirm. Themes take effect in the order they appear in the list.'**
  String get riftThemeHelpUsageBody;

  /// No description provided for @riftThemeHelpUnique.
  ///
  /// In en, this message translates to:
  /// **'Addition Rules'**
  String get riftThemeHelpUnique;

  /// No description provided for @riftThemeHelpUniqueBody.
  ///
  /// In en, this message translates to:
  /// **'Each theme can only appear once in the list. Adding an excessive number of themes may cause the level to crash.'**
  String get riftThemeHelpUniqueBody;

  /// No description provided for @riftThemeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No themes selected. Tap the button in the lower-right corner to choose themes.'**
  String get riftThemeEmpty;

  /// No description provided for @riftThemeAddTheme.
  ///
  /// In en, this message translates to:
  /// **'Add theme'**
  String get riftThemeAddTheme;

  /// No description provided for @riftThemeSelectThemes.
  ///
  /// In en, this message translates to:
  /// **'Select themes'**
  String get riftThemeSelectThemes;

  /// No description provided for @riftThemeSelectTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get riftThemeSelectTheme;

  /// No description provided for @riftThemeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search theme name or codename'**
  String get riftThemeSearchPlaceholder;

  /// No description provided for @riftThemeAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get riftThemeAlreadyAdded;

  /// No description provided for @riftThemeNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching themes'**
  String get riftThemeNoSearchResults;

  /// No description provided for @riftThemeAllUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'All themes added'**
  String get riftThemeAllUsedTitle;

  /// No description provided for @riftThemeAllUsedMessage.
  ///
  /// In en, this message translates to:
  /// **'All available themes have already been added. Each theme can only be added once.'**
  String get riftThemeAllUsedMessage;

  /// No description provided for @moduleTitle_ZombieRushModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Level Timer'**
  String get moduleTitle_ZombieRushModuleProperties;

  /// No description provided for @moduleDesc_ZombieRushModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Level ends when the timer reaches zero'**
  String get moduleDesc_ZombieRushModuleProperties;

  /// No description provided for @moduleTitle_PVZ1PassageModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Portal Combat'**
  String get moduleTitle_PVZ1PassageModuleProperties;

  /// No description provided for @moduleDesc_PVZ1PassageModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the spawning of PvZ1-style portals'**
  String get moduleDesc_PVZ1PassageModuleProperties;

  /// No description provided for @moduleTitle_PVZ1CopycatsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Guess Who I Am'**
  String get moduleTitle_PVZ1CopycatsModuleProperties;

  /// No description provided for @moduleDesc_PVZ1CopycatsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Magic Hat summons, enables Magic Hat selection'**
  String get moduleDesc_PVZ1CopycatsModuleProperties;

  /// No description provided for @pvz1CopycatsModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Guess Who I Am'**
  String get pvz1CopycatsModuleTitle;

  /// No description provided for @pvz1CopycatsSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get pvz1CopycatsSectionParams;

  /// No description provided for @pvz1CopycatsFieldZombieWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie weight (ZombieWeight)'**
  String get pvz1CopycatsFieldZombieWeightLabel;

  /// No description provided for @pvz1CopycatsHelpZombieWeight.
  ///
  /// In en, this message translates to:
  /// **'The probability of summoning a zombie per attempt (0–1). The probability of summoning a plant is 1 minus this value.'**
  String get pvz1CopycatsHelpZombieWeight;

  /// No description provided for @pvz1CopycatsFieldSpawnPlantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level (SpawnPlantLevel)'**
  String get pvz1CopycatsFieldSpawnPlantLevelLabel;

  /// No description provided for @pvz1CopycatsHelpSpawnPlantLevel.
  ///
  /// In en, this message translates to:
  /// **'The level of plants summoned by the Magic Hat.'**
  String get pvz1CopycatsHelpSpawnPlantLevel;

  /// No description provided for @pvz1CopycatsSectionPlantBlackList.
  ///
  /// In en, this message translates to:
  /// **'Plant blacklist (PlantBlackList)'**
  String get pvz1CopycatsSectionPlantBlackList;

  /// No description provided for @pvz1CopycatsHelpPlantBlackList.
  ///
  /// In en, this message translates to:
  /// **'Each type of Magic Hat has its own plant pool. This pool is not affected by the blacklist, so modifying the blacklist has no effect.'**
  String get pvz1CopycatsHelpPlantBlackList;

  /// No description provided for @pvz1CopycatsSectionZombieWhiteList.
  ///
  /// In en, this message translates to:
  /// **'Zombie whitelist (ZombieWhiteList)'**
  String get pvz1CopycatsSectionZombieWhiteList;

  /// No description provided for @pvz1CopycatsHelpZombieWhiteList.
  ///
  /// In en, this message translates to:
  /// **'Only zombies in the whitelist can be summoned by the Magic Hat.'**
  String get pvz1CopycatsHelpZombieWhiteList;

  /// No description provided for @pvz1CopycatsHelpTip.
  ///
  /// In en, this message translates to:
  /// **'After adding this module, remember to pre-select Magic Hats in the Seed Bank or Conveyor Belt module. Long press or right-click the Magic Hat in the plant selection screen to preview the plants it can summon.'**
  String get pvz1CopycatsHelpTip;

  /// No description provided for @pvz1CopycatsHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module configures the summon behavior of Magic Hats that can be planted in the seed slots, commonly used in the Memory Lane mini-game \"Guess Who I Am\". Without this module, Magic Hats will not function properly. Different types of Magic Hat vary in sun cost and cooldown time. After being planted, a Magic Hat will transform into a random plant or zombie. Plants are selected from the Magic Hat’s own plant pool, while zombies are selected only from the whitelist. The weights of individual entries in the plant or zombie pools cannot be adjusted.'**
  String get pvz1CopycatsHelpOverview;

  /// No description provided for @pvz1CopycatsHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter details'**
  String get pvz1CopycatsHelpFieldsTitle;

  /// No description provided for @pvz1CopycatsPlantListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Blacklist is empty'**
  String get pvz1CopycatsPlantListEmpty;

  /// No description provided for @pvz1CopycatsZombieListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Whitelist is empty'**
  String get pvz1CopycatsZombieListEmpty;

  /// No description provided for @pvz1CopycatsAddPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant to blacklist'**
  String get pvz1CopycatsAddPlant;

  /// No description provided for @pvz1CopycatsAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie to whitelist'**
  String get pvz1CopycatsAddZombie;

  /// No description provided for @magicHatSpawnPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible plants from Magic Hat'**
  String get magicHatSpawnPreviewTitle;

  /// No description provided for @magicHatSpawnPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plants match this blacklist.'**
  String get magicHatSpawnPreviewEmpty;

  /// No description provided for @pvz1PassageModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Portal Combat'**
  String get pvz1PassageModuleTitle;

  /// No description provided for @pvz1PassageSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Portal parameters'**
  String get pvz1PassageSectionParams;

  /// No description provided for @pvz1PassageHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module configures PvZ1-style portals, commonly used in the Memory Lane mini-game \"Portal Combat\". Portals appear in groups and affect the movement paths of plant projectiles and zombies, and will periodically change positions. Note that portals do not affect plant targeting. Plants will not attack zombies on the other end of a portal ahead of them, and will only attack if there are zombies in their lane.'**
  String get pvz1PassageHelpOverview;

  /// No description provided for @pvz1PassageHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Overview'**
  String get pvz1PassageHelpFieldsTitle;

  /// No description provided for @pvz1PassageFieldGroupAmount.
  ///
  /// In en, this message translates to:
  /// **'Portal types (GroupAmount)'**
  String get pvz1PassageFieldGroupAmount;

  /// No description provided for @pvz1PassageHelpGroupAmount.
  ///
  /// In en, this message translates to:
  /// **'The number of portal types that appear in the level. PvZ1-style portals have two types: square and circular. If set to 1, only square portals will appear. If set to 2, both square and circular portals will appear. If set to 3 or higher, the extra portal types will display as sun textures; these portals do not change position, but can still teleport zombies.'**
  String get pvz1PassageHelpGroupAmount;

  /// No description provided for @pvz1PassageFieldPassageAmount.
  ///
  /// In en, this message translates to:
  /// **'Portals per type (PassageAmount)'**
  String get pvz1PassageFieldPassageAmount;

  /// No description provided for @pvz1PassageHelpPassageAmount.
  ///
  /// In en, this message translates to:
  /// **'The number of portals within each type. For example, if set to 2, each type will have 2 portals. The total number of portals cannot exceed the number of tiles in the spawn area. If multiple valid destination portals exist within the same type, zombies will always teleport to the designated one.'**
  String get pvz1PassageHelpPassageAmount;

  /// No description provided for @pvz1PassageFieldGridXMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum spawn column (GridXMin)'**
  String get pvz1PassageFieldGridXMin;

  /// No description provided for @pvz1PassageHelpGridXMin.
  ///
  /// In en, this message translates to:
  /// **'The leftmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column {maxIndex}. This value must be less than the maximum column value.'**
  String pvz1PassageHelpGridXMin(int maxIndex);

  /// No description provided for @pvz1PassageFieldGridXMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum spawn column (GridXMax)'**
  String get pvz1PassageFieldGridXMax;

  /// No description provided for @pvz1PassageHelpGridXMax.
  ///
  /// In en, this message translates to:
  /// **'The rightmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column {maxIndex}. This value must be greater than the minimum column value.'**
  String pvz1PassageHelpGridXMax(int maxIndex);

  /// No description provided for @pvz1PassageGridColumnRange.
  ///
  /// In en, this message translates to:
  /// **'0–{maxIndex}'**
  String pvz1PassageGridColumnRange(int maxIndex);

  /// No description provided for @pvz1PassageFieldTransferCooldown.
  ///
  /// In en, this message translates to:
  /// **'Same-zombie teleport cooldown (transferCooldown, unit: seconds)'**
  String get pvz1PassageFieldTransferCooldown;

  /// No description provided for @pvz1PassageHelpTransferCooldown.
  ///
  /// In en, this message translates to:
  /// **'The minimum time between two teleports of the same zombie. If set too low, a zombie that fails to leave the portal tile within the interval may be teleported back to the original portal again once the cooldown ends.'**
  String get pvz1PassageHelpTransferCooldown;

  /// No description provided for @pvz1PassageFieldRefreshTime.
  ///
  /// In en, this message translates to:
  /// **'Portal reposition interval (refreshTime, unit: seconds)'**
  String get pvz1PassageFieldRefreshTime;

  /// No description provided for @pvz1PassageHelpRefreshTime.
  ///
  /// In en, this message translates to:
  /// **'The interval at which portal positions are regenerated. Portals are refreshed one at a time, meaning each refresh only changes the position of one portal within the same type.'**
  String get pvz1PassageHelpRefreshTime;

  /// No description provided for @pvz1PassagePortalSpawnPreview.
  ///
  /// In en, this message translates to:
  /// **'Portal spawn column preview'**
  String get pvz1PassagePortalSpawnPreview;

  /// No description provided for @pvz1PassageHelpPreview.
  ///
  /// In en, this message translates to:
  /// **'Spawn Range Preview'**
  String get pvz1PassageHelpPreview;

  /// No description provided for @pvz1PassageHelpPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'The orange highlighted area indicates which columns portals may appear in. The column range of the current lawn is 0–{maxIndex} (including both lawn boundaries). This module cannot restrict the row range where portals spawn.'**
  String pvz1PassageHelpPreviewBody(int maxIndex);

  /// No description provided for @moduleWaveIndexZeroBasedHint.
  ///
  /// In en, this message translates to:
  /// **'0 = Wave 1, 1 = Wave 2, ...'**
  String get moduleWaveIndexZeroBasedHint;

  /// No description provided for @moduleWaveFieldZeroBased.
  ///
  /// In en, this message translates to:
  /// **'Wave (0 = Wave 1, 1 = Wave 2, ...)'**
  String get moduleWaveFieldZeroBased;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @airDropShipGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get airDropShipGroupLabel;

  /// No description provided for @moduleTitle_RenaiModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Module'**
  String get moduleTitle_RenaiModuleProperties;

  /// No description provided for @moduleDesc_RenaiModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables the Vitruvian Wheel and day–night cycle, configures Renaissance Statues and Marble Mounds'**
  String get moduleDesc_RenaiModuleProperties;

  /// No description provided for @renaiModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Module Settings'**
  String get renaiModuleTitle;

  /// No description provided for @renaiModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Module'**
  String get renaiModuleHelpTitle;

  /// No description provided for @renaiModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get renaiModuleHelpOverview;

  /// No description provided for @renaiModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to make the Vitruvian Wheel respond to Floor-de-Lis tiles; configure day–night cycle waves; and, at night, revive Renaissance Statues and Marble Mounds, and spawn grid items based on settings. Typically used in Renaissance Ages levels.'**
  String get renaiModuleHelpOverviewBody;

  /// No description provided for @renaiModuleHelpStatues.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get renaiModuleHelpStatues;

  /// No description provided for @renaiModuleHelpStatuesBody.
  ///
  /// In en, this message translates to:
  /// **'Initial grid items refer to statues and Marble Mounds present at the start of the level, which revive into zombies at specified waves. Night grid items are generated after night begins; if a plant occupies the target tile, they will not spawn. Night start wave uses a 0-based index (e.g., 0 = first wave, 1 = second wave).'**
  String get renaiModuleHelpStatuesBody;

  /// No description provided for @renaiModuleEnableNight.
  ///
  /// In en, this message translates to:
  /// **'Enable Day–Night Cycle'**
  String get renaiModuleEnableNight;

  /// No description provided for @renaiModuleEnableNightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allows setting the wave when night begins and configuring night grid items'**
  String get renaiModuleEnableNightSubtitle;

  /// No description provided for @renaiModuleNightStart.
  ///
  /// In en, this message translates to:
  /// **'Night Start Wave'**
  String get renaiModuleNightStart;

  /// No description provided for @renaiModuleDayStatues.
  ///
  /// In en, this message translates to:
  /// **'Initial grid items'**
  String get renaiModuleDayStatues;

  /// No description provided for @renaiModuleNightStatues.
  ///
  /// In en, this message translates to:
  /// **'Night grid items'**
  String get renaiModuleNightStatues;

  /// No description provided for @renaiModuleNightStatuesDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Please enable the day–night cycle first'**
  String get renaiModuleNightStatuesDisabledHint;

  /// No description provided for @renaiModuleAddStatue.
  ///
  /// In en, this message translates to:
  /// **'Add statue'**
  String get renaiModuleAddStatue;

  /// No description provided for @renaiModuleCarveWave.
  ///
  /// In en, this message translates to:
  /// **'Statue revival wave'**
  String get renaiModuleCarveWave;

  /// No description provided for @renaiModuleStatuesInCell.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get renaiModuleStatuesInCell;

  /// No description provided for @renaiModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Renaissance event preview'**
  String get renaiModuleExpectationLabel;

  /// No description provided for @renaiModuleNightStarts.
  ///
  /// In en, this message translates to:
  /// **'Night begins'**
  String get renaiModuleNightStarts;

  /// No description provided for @renaiModulePreviewNightStatues.
  ///
  /// In en, this message translates to:
  /// **'Night grid items to be spawned this wave:'**
  String get renaiModulePreviewNightStatues;

  /// No description provided for @renaiModulePreviewRevivingStatues.
  ///
  /// In en, this message translates to:
  /// **'Statues to be revived this wave:'**
  String get renaiModulePreviewRevivingStatues;

  /// No description provided for @renaiModuleStatueCarve.
  ///
  /// In en, this message translates to:
  /// **'Statue revival'**
  String get renaiModuleStatueCarve;

  /// No description provided for @moduleTitle_DropShipProperties.
  ///
  /// In en, this message translates to:
  /// **'Transport Boat Assault'**
  String get moduleTitle_DropShipProperties;

  /// No description provided for @moduleDesc_DropShipProperties.
  ///
  /// In en, this message translates to:
  /// **'Airdrops Flying Imp Zombies onto the lawn'**
  String get moduleDesc_DropShipProperties;

  /// No description provided for @airDropShipModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport Boat Assault'**
  String get airDropShipModuleTitle;

  /// No description provided for @airDropShipModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport Boat Assault module'**
  String get airDropShipModuleHelpTitle;

  /// No description provided for @airDropShipModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get airDropShipModuleHelpOverview;

  /// No description provided for @airDropShipModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure Transport Boats that appear during waves in a level, commonly seen in Sky City levels. Transport Boats cannot be damaged. A set number of Flying Imp Zombies will drop sequentially into the designated drop area.'**
  String get airDropShipModuleHelpOverviewBody;

  /// No description provided for @airDropShipModuleHelpImps.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get airDropShipModuleHelpImps;

  /// No description provided for @airDropShipModuleHelpImpsBody.
  ///
  /// In en, this message translates to:
  /// **'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Each Transport Boat drops at least one Flying Imp Zombie. The extra imp count specifies how many additional imps are dropped on top of the initial one for that wave.'**
  String get airDropShipModuleHelpImpsBody;

  /// No description provided for @airDropShipModuleAppearWaves.
  ///
  /// In en, this message translates to:
  /// **'Appear waves (Wave; starts from 0)'**
  String get airDropShipModuleAppearWaves;

  /// No description provided for @airDropShipModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Assault Groups'**
  String get airDropShipModuleAppearances;

  /// No description provided for @airDropShipModuleExtraImpCount.
  ///
  /// In en, this message translates to:
  /// **'Extra imp count (Imp)'**
  String get airDropShipModuleExtraImpCount;

  /// No description provided for @airDropShipModuleDropArea.
  ///
  /// In en, this message translates to:
  /// **'Drop area'**
  String get airDropShipModuleDropArea;

  /// No description provided for @airDropShipModuleDropAreaPreview.
  ///
  /// In en, this message translates to:
  /// **'Drop area preview'**
  String get airDropShipModuleDropAreaPreview;

  /// No description provided for @airDropShipModuleAreaDropPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Area drop preview:'**
  String get airDropShipModuleAreaDropPreviewLabel;

  /// No description provided for @airDropShipModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Airdropped Imps'**
  String get airDropShipModuleExpectationLabel;

  /// No description provided for @airDropShipModuleImpLevel.
  ///
  /// In en, this message translates to:
  /// **'Imp level (ImpLv)'**
  String get airDropShipModuleImpLevel;

  /// No description provided for @airDropShipModuleRowMin.
  ///
  /// In en, this message translates to:
  /// **'Start row'**
  String get airDropShipModuleRowMin;

  /// No description provided for @airDropShipModuleRowMax.
  ///
  /// In en, this message translates to:
  /// **'End row'**
  String get airDropShipModuleRowMax;

  /// No description provided for @airDropShipModuleColMin.
  ///
  /// In en, this message translates to:
  /// **'Start column'**
  String get airDropShipModuleColMin;

  /// No description provided for @airDropShipModuleColMax.
  ///
  /// In en, this message translates to:
  /// **'End column'**
  String get airDropShipModuleColMax;

  /// No description provided for @openModuleSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Module Settings'**
  String get openModuleSettings;

  /// No description provided for @moduleTitle_GlacierModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Glacier Spawn'**
  String get moduleTitle_GlacierModuleProperties;

  /// No description provided for @moduleDesc_GlacierModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Zombie spawn weights for Ice Age Zomboss glacier blocks (6 columns from the left)'**
  String get moduleDesc_GlacierModuleProperties;

  /// No description provided for @glacierModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Glacier module'**
  String get glacierModuleTitle;

  /// No description provided for @glacierModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Glacier module'**
  String get glacierModuleHelpTitle;

  /// No description provided for @glacierModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Configures which zombies can emerge from glacier blocks when the Ice Age Zomboss destroys them. Place this module at the start of the level Modules list. Without it, glacier blocks will not spawn zombies.'**
  String get glacierModuleHelpOverviewBody;

  /// No description provided for @glacierModuleHelpColumnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Columns and entries'**
  String get glacierModuleHelpColumnsTitle;

  /// No description provided for @glacierModuleHelpColumnsBody.
  ///
  /// In en, this message translates to:
  /// **'ZombieSpawnData always has exactly six elements, one per column counting from the left edge of the lawn. Each column holds a weighted list of zombie types (TypeName), spawn weight (Weight), and level (Level, 0–10).'**
  String get glacierModuleHelpColumnsBody;

  /// No description provided for @glacierModuleHelpRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get glacierModuleHelpRequirementsTitle;

  /// No description provided for @glacierModuleHelpRequirementsBody.
  ///
  /// In en, this message translates to:
  /// **'Only takes effect together with the Zomboss Battle module when the selected Zomboss Mech is an Ice Age variant (zombossmech_iceage and its variations).'**
  String get glacierModuleHelpRequirementsBody;

  /// No description provided for @glacierModuleCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'This module only works with the Zomboss Battle module and an Ice Age Zomboss Mech (zombossmech_iceage). Add or fix those settings so glacier blocks can spawn zombies.'**
  String get glacierModuleCompatibilityWarning;

  /// No description provided for @glacierModuleColumn.
  ///
  /// In en, this message translates to:
  /// **'Column {columnIndex} (from left)'**
  String glacierModuleColumn(int columnIndex);

  /// No description provided for @glacierModuleEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 entry} other{{count} entries}}'**
  String glacierModuleEntryCount(int count);

  /// No description provided for @glacierModuleEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry {index}'**
  String glacierModuleEntryLabel(int index);

  /// No description provided for @glacierModuleNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No zombie entries for this column.'**
  String get glacierModuleNoEntries;

  /// No description provided for @glacierModuleAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add zombie entry'**
  String get glacierModuleAddEntry;

  /// No description provided for @glacierModuleSelectZombie.
  ///
  /// In en, this message translates to:
  /// **'Select zombie'**
  String get glacierModuleSelectZombie;

  /// No description provided for @glacierModuleEmptyType.
  ///
  /// In en, this message translates to:
  /// **'No zombie selected'**
  String get glacierModuleEmptyType;

  /// No description provided for @glacierModuleWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get glacierModuleWeight;

  /// No description provided for @glacierModuleWeightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Relative spawn weight for this zombie in this column.'**
  String get glacierModuleWeightTooltip;

  /// No description provided for @glacierModuleLevel.
  ///
  /// In en, this message translates to:
  /// **'Level (0–10)'**
  String get glacierModuleLevel;

  /// No description provided for @glacierModuleLevelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zombie level from 0 to 10.'**
  String get glacierModuleLevelTooltip;

  /// No description provided for @moduleTitle_HeianWindModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind'**
  String get moduleTitle_HeianWindModuleProperties;

  /// No description provided for @moduleDesc_HeianWindModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Wind that pushes zombies and knocks plants into the air'**
  String get moduleDesc_HeianWindModuleProperties;

  /// No description provided for @heianWindModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind Settings'**
  String get heianWindModuleTitle;

  /// No description provided for @heianWindModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind module'**
  String get heianWindModuleHelpTitle;

  /// No description provided for @heianWindModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get heianWindModuleHelpOverview;

  /// No description provided for @heianWindModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to summon Divine Wind at specified waves, commonly seen in Heian Ages levels. The wind pushes a set number of small and medium zombies within its range horizontally. After all winds in a wave finish, rows affected by single-row winds will generate a whirlwind (one per row). The whirlwind carries zombies forward and knocks plants into the air on contact before disappearing.'**
  String get heianWindModuleHelpOverviewBody;

  /// No description provided for @heianWindModuleHelpDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get heianWindModuleHelpDistance;

  /// No description provided for @heianWindModuleHelpDistanceBody.
  ///
  /// In en, this message translates to:
  /// **'1 tile = 50 distance units. Negative values push zombies to the left, while positive values push them to the right.'**
  String get heianWindModuleHelpDistanceBody;

  /// No description provided for @heianWindModuleHelpRow.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get heianWindModuleHelpRow;

  /// No description provided for @heianWindModuleHelpRowBody.
  ///
  /// In en, this message translates to:
  /// **'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Target rows are also indexed from 0. You can specify a single row or set it to -1 to affect all rows; in this case, no whirlwind will be generated.'**
  String get heianWindModuleHelpRowBody;

  /// No description provided for @heianWindModuleWaves.
  ///
  /// In en, this message translates to:
  /// **'Appear waves (WaveNumber)'**
  String get heianWindModuleWaves;

  /// No description provided for @heianWindModuleWavesHint.
  ///
  /// In en, this message translates to:
  /// **'starts from 0'**
  String get heianWindModuleWavesHint;

  /// No description provided for @heianWindModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Summon Batches'**
  String get heianWindModuleAppearances;

  /// No description provided for @heianWindModuleWindDelay.
  ///
  /// In en, this message translates to:
  /// **'Time between wind spawns (WindDelay)'**
  String get heianWindModuleWindDelay;

  /// No description provided for @heianWindModuleWindDelayHint.
  ///
  /// In en, this message translates to:
  /// **'unit: seconds'**
  String get heianWindModuleWindDelayHint;

  /// No description provided for @heianWindModuleWindEntries.
  ///
  /// In en, this message translates to:
  /// **'Wind configurations'**
  String get heianWindModuleWindEntries;

  /// No description provided for @heianWindModuleAddWind.
  ///
  /// In en, this message translates to:
  /// **'Add wind'**
  String get heianWindModuleAddWind;

  /// No description provided for @heianWindModuleRow.
  ///
  /// In en, this message translates to:
  /// **'Affected row (Row)'**
  String get heianWindModuleRow;

  /// No description provided for @heianWindModuleAllRows.
  ///
  /// In en, this message translates to:
  /// **'All rows (-1)'**
  String get heianWindModuleAllRows;

  /// No description provided for @heianWindModuleAffectZombies.
  ///
  /// In en, this message translates to:
  /// **'Affected zombie count (AffectZombies)'**
  String get heianWindModuleAffectZombies;

  /// No description provided for @heianWindModuleDistance.
  ///
  /// In en, this message translates to:
  /// **'Push Distance (Distance)'**
  String get heianWindModuleDistance;

  /// No description provided for @heianWindModuleDistanceHint.
  ///
  /// In en, this message translates to:
  /// **'1 tile = 50 units'**
  String get heianWindModuleDistanceHint;

  /// No description provided for @heianWindModuleMoveTime.
  ///
  /// In en, this message translates to:
  /// **'Move Duration (MoveTime)'**
  String get heianWindModuleMoveTime;

  /// No description provided for @heianWindModuleMoveTimeHint.
  ///
  /// In en, this message translates to:
  /// **'unit: seconds'**
  String get heianWindModuleMoveTimeHint;

  /// No description provided for @heianWindModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Divine Wind Settings'**
  String get heianWindModuleExpectationLabel;

  /// No description provided for @jsonViewerModeReading.
  ///
  /// In en, this message translates to:
  /// **'(plain text view)'**
  String get jsonViewerModeReading;

  /// No description provided for @jsonViewerModeObjectReading.
  ///
  /// In en, this message translates to:
  /// **'(structured view)'**
  String get jsonViewerModeObjectReading;

  /// No description provided for @jsonViewerModeEdit.
  ///
  /// In en, this message translates to:
  /// **'(edit mode)'**
  String get jsonViewerModeEdit;

  /// No description provided for @jsonViewerFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get jsonViewerFontSize;

  /// No description provided for @jsonViewerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get jsonViewerSearchHint;

  /// No description provided for @jsonViewerReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get jsonViewerReplaceHint;

  /// No description provided for @jsonViewerSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get jsonViewerSearchHistory;

  /// No description provided for @jsonViewerReplaceHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent replacements'**
  String get jsonViewerReplaceHistory;

  /// No description provided for @jsonViewerInsertNewline.
  ///
  /// In en, this message translates to:
  /// **'Insert newline'**
  String get jsonViewerInsertNewline;

  /// No description provided for @jsonViewerMatchCase.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get jsonViewerMatchCase;

  /// No description provided for @jsonViewerWholeWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get jsonViewerWholeWords;

  /// No description provided for @jsonViewerRegex.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get jsonViewerRegex;

  /// No description provided for @jsonViewerPreviousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get jsonViewerPreviousMatch;

  /// No description provided for @jsonViewerNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get jsonViewerNextMatch;

  /// No description provided for @jsonViewerReplaceOne.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get jsonViewerReplaceOne;

  /// No description provided for @jsonViewerReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get jsonViewerReplaceAll;

  /// No description provided for @jsonViewerMatchCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String jsonViewerMatchCounter(int current, int total);

  /// No description provided for @tooltipAboutModule.
  ///
  /// In en, this message translates to:
  /// **'About this module'**
  String get tooltipAboutModule;

  /// No description provided for @tooltipAboutEvent.
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get tooltipAboutEvent;

  /// No description provided for @tooltipSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipSave;

  /// No description provided for @tooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @tooltipToggleObjectView.
  ///
  /// In en, this message translates to:
  /// **'Toggle plain text / structured view'**
  String get tooltipToggleObjectView;

  /// No description provided for @tooltipClearUnused.
  ///
  /// In en, this message translates to:
  /// **'Clear unused objects'**
  String get tooltipClearUnused;

  /// No description provided for @tooltipJsonViewer.
  ///
  /// In en, this message translates to:
  /// **'View/edit JSON'**
  String get tooltipJsonViewer;

  /// No description provided for @tooltipAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tooltipAdd;

  /// No description provided for @tooltipDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get tooltipDecrease;

  /// No description provided for @tooltipIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get tooltipIncrease;

  /// No description provided for @bungeeWaveEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Bungee Drop Settings'**
  String get bungeeWaveEventTitle;

  /// No description provided for @bungeeWaveEventHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Bungee Drop'**
  String get bungeeWaveEventHelpTitle;

  /// No description provided for @bungeeWaveEventHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Configures the zombie type and drop position for Bungee Zombie deployment. Each event can drop only one zombie.'**
  String get bungeeWaveEventHelpOverview;

  /// No description provided for @bungeeWaveEventHelpGrid.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get bungeeWaveEventHelpGrid;

  /// No description provided for @bungeeWaveEventHelpGridBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell in the grid to set where the Bungee Zombie will land.'**
  String get bungeeWaveEventHelpGridBody;

  /// No description provided for @bungeeWaveCurrentTarget.
  ///
  /// In en, this message translates to:
  /// **'Current target'**
  String get bungeeWaveCurrentTarget;

  /// No description provided for @bungeeWaveCol.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get bungeeWaveCol;

  /// No description provided for @bungeeWaveRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get bungeeWaveRow;

  /// No description provided for @bungeeWavePropertiesConfig.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get bungeeWavePropertiesConfig;

  /// No description provided for @bungeeWaveZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get bungeeWaveZombieLevel;

  /// No description provided for @bungeeWaveRoofWarning.
  ///
  /// In en, this message translates to:
  /// **'In Roof levels, if a Bungee Zombie spawned by this event is blocked by Umbrella Leaf, it may immediately trigger a loss. Use with caution.'**
  String get bungeeWaveRoofWarning;

  /// No description provided for @moduleTitle_LevelMutatorRiftTimedSunProps.
  ///
  /// In en, this message translates to:
  /// **'Zombie Sun Drop'**
  String get moduleTitle_LevelMutatorRiftTimedSunProps;

  /// No description provided for @moduleDesc_LevelMutatorRiftTimedSunProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop sun when defeated'**
  String get moduleDesc_LevelMutatorRiftTimedSunProps;

  /// No description provided for @zombieSunDropTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Sun Drop Settings'**
  String get zombieSunDropTitle;

  /// No description provided for @zombieSunDropHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Sun Drop module'**
  String get zombieSunDropHelpTitle;

  /// No description provided for @zombieSunDropHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure how much sun specific zombies drop in a level, mainly for Penny\'s Pursuit Level 5. As a side effect, the Sun Shovel becomes ineffective.'**
  String get zombieSunDropHelpOverview;

  /// No description provided for @zombieSunDropHelpValues.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get zombieSunDropHelpValues;

  /// No description provided for @zombieSunDropHelpValuesBody.
  ///
  /// In en, this message translates to:
  /// **'10 integer values correspond to sun dropped at levels 1–10. For levels above 6, the value for level 1 will be used.'**
  String get zombieSunDropHelpValuesBody;

  /// No description provided for @zombieSunDropEmpty.
  ///
  /// In en, this message translates to:
  /// **'No configuration yet. Tap the \"+\" button in the bottom right to add.'**
  String get zombieSunDropEmpty;

  /// No description provided for @zombieSunDropDefaultDrop.
  ///
  /// In en, this message translates to:
  /// **'Default drop'**
  String get zombieSunDropDefaultDrop;

  /// No description provided for @zombieSunDropSun.
  ///
  /// In en, this message translates to:
  /// **'sun'**
  String get zombieSunDropSun;

  /// No description provided for @zombieSunDropEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit values'**
  String get zombieSunDropEditTitle;

  /// No description provided for @zombieSunDropEditHint.
  ///
  /// In en, this message translates to:
  /// **'Configure the amount of sun dropped by this zombie at different levels; for levels above 6, the level 1 value will be used'**
  String get zombieSunDropEditHint;

  /// No description provided for @zombieSunDropTier.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get zombieSunDropTier;

  /// No description provided for @moduleTitle_PickupCollectableTutorialProperties.
  ///
  /// In en, this message translates to:
  /// **'Pickup Collectible Tutorial'**
  String get moduleTitle_PickupCollectableTutorialProperties;

  /// No description provided for @moduleDesc_PickupCollectableTutorialProperties.
  ///
  /// In en, this message translates to:
  /// **'Shows tutorial dialog boxes when specific zombies are defeated'**
  String get moduleDesc_PickupCollectableTutorialProperties;

  /// No description provided for @pickupCollectableTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup Collectible Tutorial Settings'**
  String get pickupCollectableTutorialTitle;

  /// No description provided for @pickupCollectableTutorialHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup Collectible Tutorial module'**
  String get pickupCollectableTutorialHelpTitle;

  /// No description provided for @pickupCollectableTutorialHelpBasic.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get pickupCollectableTutorialHelpBasic;

  /// No description provided for @pickupCollectableTutorialHelpBasicBody.
  ///
  /// In en, this message translates to:
  /// **'Configures zombies that drop specific items and the guidance text shown before and after picking them up. A dialog box will appear when this type of zombie (including custom zombies) is defeated for the first time in the level.'**
  String get pickupCollectableTutorialHelpBasicBody;

  /// No description provided for @pickupCollectableTutorialHelpDialogs.
  ///
  /// In en, this message translates to:
  /// **'Dialogs'**
  String get pickupCollectableTutorialHelpDialogs;

  /// No description provided for @pickupCollectableTutorialHelpDialogsBody.
  ///
  /// In en, this message translates to:
  /// **'Dialogs will appear before and after picking up the item. These dialogs pause level progression and delay the next wave.'**
  String get pickupCollectableTutorialHelpDialogsBody;

  /// No description provided for @pickupCollectableTutorialCoreConfig.
  ///
  /// In en, this message translates to:
  /// **'Core configuration'**
  String get pickupCollectableTutorialCoreConfig;

  /// No description provided for @pickupCollectableTutorialZombieLabel.
  ///
  /// In en, this message translates to:
  /// **'Item-carrying zombie'**
  String get pickupCollectableTutorialZombieLabel;

  /// No description provided for @pickupCollectableTutorialLootType.
  ///
  /// In en, this message translates to:
  /// **'Item type'**
  String get pickupCollectableTutorialLootType;

  /// No description provided for @pickupCollectableTutorialGuideText.
  ///
  /// In en, this message translates to:
  /// **'Guidance text'**
  String get pickupCollectableTutorialGuideText;

  /// No description provided for @pickupCollectableTutorialPickupAdvice.
  ///
  /// In en, this message translates to:
  /// **'Pre-pickup dialog (PickupAdvice)'**
  String get pickupCollectableTutorialPickupAdvice;

  /// No description provided for @pickupCollectableTutorialPostPickupAdvice.
  ///
  /// In en, this message translates to:
  /// **'Post-pickup dialog (PostPickupAdvice)'**
  String get pickupCollectableTutorialPostPickupAdvice;

  /// No description provided for @pickupCollectableTutorialNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get pickupCollectableTutorialNotSet;

  /// No description provided for @pickupCollectableLootGoldCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get pickupCollectableLootGoldCoin;

  /// No description provided for @invalidRtonMagic.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON file: magic must be \"RTON\".'**
  String get invalidRtonMagic;

  /// No description provided for @invalidRtonVersion.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON version (expected 1).'**
  String get invalidRtonVersion;

  /// No description provided for @invalidRtonEnd.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON file: must end with \"DONE\".'**
  String get invalidRtonEnd;

  /// No description provided for @invalidRtonArrayEnd.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON array delimiter.'**
  String get invalidRtonArrayEnd;

  /// No description provided for @invalidRtid.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTID value.'**
  String get invalidRtid;

  /// No description provided for @invalidValueType.
  ///
  /// In en, this message translates to:
  /// **'Invalid value type for RTON.'**
  String get invalidValueType;

  /// No description provided for @musicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Music settings'**
  String get musicSuffix;

  /// No description provided for @ambientAudioSuffix.
  ///
  /// In en, this message translates to:
  /// **'Ambient audio settings'**
  String get ambientAudioSuffix;

  /// No description provided for @selectMusicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Select music settings'**
  String get selectMusicSuffix;

  /// No description provided for @searchMusicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Search by name or codename'**
  String get searchMusicSuffix;

  /// No description provided for @noMusicSuffixFound.
  ///
  /// In en, this message translates to:
  /// **'No music settings found'**
  String get noMusicSuffixFound;

  /// No description provided for @jsonViewerLineContinuation.
  ///
  /// In en, this message translates to:
  /// **'↳'**
  String get jsonViewerLineContinuation;

  /// No description provided for @zombossMechCustomVariation.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get zombossMechCustomVariation;

  /// No description provided for @editCustomZombossMech.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editCustomZombossMech;

  /// No description provided for @customZombossMechProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom ZombossMech properties'**
  String get customZombossMechProperties;

  /// No description provided for @customZombossMechScalars.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get customZombossMechScalars;

  /// No description provided for @customZombossMechStages.
  ///
  /// In en, this message translates to:
  /// **'Battle phases'**
  String get customZombossMechStages;

  /// No description provided for @customZombossMechEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit level-local property sheet for the memo (custom) mech variation.'**
  String get customZombossMechEditHint;

  /// No description provided for @zombossMechMinColumn.
  ///
  /// In en, this message translates to:
  /// **'Min column'**
  String get zombossMechMinColumn;

  /// No description provided for @zombossMechMaxColumn.
  ///
  /// In en, this message translates to:
  /// **'Max column'**
  String get zombossMechMaxColumn;

  /// No description provided for @zombossMechStageActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get zombossMechStageActions;

  /// No description provided for @zombossMechActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get zombossMechActions;

  /// No description provided for @zombossMechPropertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get zombossMechPropertiesLabel;

  /// No description provided for @zombossMechAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Alias'**
  String get zombossMechAliasLabel;

  /// No description provided for @zombossMechDeletePhase.
  ///
  /// In en, this message translates to:
  /// **'Delete phase'**
  String get zombossMechDeletePhase;

  /// No description provided for @zombossMechDeletePhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete phase {number}?'**
  String zombossMechDeletePhaseTitle(int number);

  /// No description provided for @zombossMechDeletePhaseMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the phase and its action list. This cannot be undone.'**
  String get zombossMechDeletePhaseMessage;

  /// No description provided for @zombossMechOrphanActionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove custom action data?'**
  String get zombossMechOrphanActionDeleteTitle;

  /// No description provided for @zombossMechOrphanActionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{alias}\" is no longer used in this level. Remove its action object from the level file?'**
  String zombossMechOrphanActionDeleteMessage(String alias);

  /// No description provided for @zombossMechPhasesHelp.
  ///
  /// In en, this message translates to:
  /// **'Each phase has hit points, an ordered action list (executed top to bottom), and optionally a retreat action when the mech supports it.'**
  String get zombossMechPhasesHelp;

  /// No description provided for @zombossMechAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get zombossMechAddAction;

  /// No description provided for @zombossMechNoStageActions.
  ///
  /// In en, this message translates to:
  /// **'No actions yet'**
  String get zombossMechNoStageActions;

  /// No description provided for @zombossMechSelectAction.
  ///
  /// In en, this message translates to:
  /// **'Select action'**
  String get zombossMechSelectAction;

  /// No description provided for @zombossMechSelectRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Select retreat action'**
  String get zombossMechSelectRetreatAction;

  /// No description provided for @zombossMechCreateCustomAction.
  ///
  /// In en, this message translates to:
  /// **'New custom action'**
  String get zombossMechCreateCustomAction;

  /// No description provided for @zombossMechEditCustomAction.
  ///
  /// In en, this message translates to:
  /// **'Edit custom action'**
  String get zombossMechEditCustomAction;

  /// No description provided for @zombossMechActionCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get zombossMechActionCategoryAll;

  /// No description provided for @zombossMechActionCategoryMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get zombossMechActionCategoryMovement;

  /// No description provided for @zombossMechActionCategoryAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get zombossMechActionCategoryAttack;

  /// No description provided for @zombossMechActionCategorySpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get zombossMechActionCategorySpecial;

  /// No description provided for @zombossMechActionCategorySpawn.
  ///
  /// In en, this message translates to:
  /// **'Spawn'**
  String get zombossMechActionCategorySpawn;

  /// No description provided for @zombossMechActionCategoryRetreat.
  ///
  /// In en, this message translates to:
  /// **'Retreat'**
  String get zombossMechActionCategoryRetreat;

  /// No description provided for @zombossMechNoActionsFound.
  ///
  /// In en, this message translates to:
  /// **'No actions found'**
  String get zombossMechNoActionsFound;

  /// No description provided for @zombossMechCustomActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom (CurrentLevel)'**
  String get zombossMechCustomActionLabel;

  /// No description provided for @zombossMechActionAliasHint.
  ///
  /// In en, this message translates to:
  /// **'Codename used in RTID(alias@CurrentLevel). You can change it later; references in this property sheet update automatically.'**
  String get zombossMechActionAliasHint;

  /// No description provided for @zombossMechActionBaseObjclass.
  ///
  /// In en, this message translates to:
  /// **'Base objclass'**
  String get zombossMechActionBaseObjclass;

  /// No description provided for @zombossMechEditRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Choose retreat action'**
  String get zombossMechEditRetreatAction;

  /// No description provided for @zombossMechAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get zombossMechAddZombie;

  /// No description provided for @zombossMechPickZombie.
  ///
  /// In en, this message translates to:
  /// **'Pick zombie'**
  String get zombossMechPickZombie;

  /// No description provided for @zombossMechNoZombiesInList.
  ///
  /// In en, this message translates to:
  /// **'No zombies in list'**
  String get zombossMechNoZombiesInList;

  /// No description provided for @zombossMechCatalogActionReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Built-in actions cannot be edited here. Create a custom action to change zombie lists.'**
  String get zombossMechCatalogActionReadOnly;

  /// No description provided for @zombossMechRetreatDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get zombossMechRetreatDisabled;

  /// No description provided for @zombossMechOpenGlacierModule.
  ///
  /// In en, this message translates to:
  /// **'Open glacier module settings'**
  String get zombossMechOpenGlacierModule;

  /// No description provided for @zombossMechRobotSpawnRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get zombossMechRobotSpawnRow;

  /// No description provided for @zombossMechRobotSpawnRowRandom.
  ///
  /// In en, this message translates to:
  /// **'Random (-1)'**
  String get zombossMechRobotSpawnRowRandom;

  /// No description provided for @zombossMechRobotSpawnLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get zombossMechRobotSpawnLevel;

  /// No description provided for @zombossMechRobotSpawnWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get zombossMechRobotSpawnWeight;

  /// No description provided for @zombossMechRobotSpawnPlantfood.
  ///
  /// In en, this message translates to:
  /// **'Plant food'**
  String get zombossMechRobotSpawnPlantfood;

  /// No description provided for @zombossMechRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Retreat action'**
  String get zombossMechRetreatAction;

  /// No description provided for @zombossMechPhaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Phase {number}'**
  String zombossMechPhaseNumber(int number);

  /// No description provided for @zombossMechAddPhase.
  ///
  /// In en, this message translates to:
  /// **'Add phase'**
  String get zombossMechAddPhase;

  /// No description provided for @zombossMechRemovePhase.
  ///
  /// In en, this message translates to:
  /// **'Remove phase'**
  String get zombossMechRemovePhase;

  /// No description provided for @zombossMechHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Hit points'**
  String get zombossMechHitPoints;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @armrackModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands'**
  String get armrackModuleTitle;

  /// No description provided for @armrackModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands module'**
  String get armrackModuleHelpTitle;

  /// No description provided for @armrackModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get armrackModuleHelpOverview;

  /// No description provided for @armrackModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Places weapon stands on the lawn. Wave 1 is the initial preset (before the level starts); later wave groups spawn during wave-generator waves using the N−1 rule.'**
  String get armrackModuleHelpOverviewBody;

  /// No description provided for @armrackModuleHelpPlacement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get armrackModuleHelpPlacement;

  /// No description provided for @armrackModuleHelpPlacementBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a stand type, then tap a tile to place it (one per tile). Right-click or long-press a tile to remove its stand.'**
  String get armrackModuleHelpPlacementBody;

  /// No description provided for @armrackModuleHelpWaveLimit.
  ///
  /// In en, this message translates to:
  /// **'Wave limit'**
  String get armrackModuleHelpWaveLimit;

  /// No description provided for @armrackModuleHelpWaveLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Due to a game limitation, only wave 1 entries take effect in-game. Other wave groups can still be edited here and are saved to the level file, but only wave 1 appears in the wave timeline tab.'**
  String get armrackModuleHelpWaveLimitBody;

  /// No description provided for @armrackModuleTypePalette.
  ///
  /// In en, this message translates to:
  /// **'Stand type'**
  String get armrackModuleTypePalette;

  /// No description provided for @armrackModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Weapon stands'**
  String get armrackModuleExpectationLabel;

  /// No description provided for @armrackModuleIgnoredWaveOverridesWarning.
  ///
  /// In en, this message translates to:
  /// **'This level contains weapon stand overrides for waves other than wave 1. They are saved but not shown in the wave timeline because the game only applies wave 1.'**
  String get armrackModuleIgnoredWaveOverridesWarning;

  /// No description provided for @armrackModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'For weapon stands to display properly without showing sun textures, {moduleName} needs to be added.'**
  String armrackModuleRequiredMessage(String moduleName);

  /// No description provided for @energyGridModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles'**
  String get energyGridModuleTitle;

  /// No description provided for @energyGridModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles module'**
  String get energyGridModuleHelpTitle;

  /// No description provided for @energyGridModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get energyGridModuleHelpOverview;

  /// No description provided for @energyGridModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Places Taiji Tiles on the lawn. Wave 1 is the initial preset (before the level starts); later wave groups spawn during wave-generator waves using the N−1 rule.'**
  String get energyGridModuleHelpOverviewBody;

  /// No description provided for @energyGridModuleHelpPlacement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get energyGridModuleHelpPlacement;

  /// No description provided for @energyGridModuleHelpPlacementBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty tile to place a Taiji Tile (one per tile). Right-click or long-press a tile to remove it.'**
  String get energyGridModuleHelpPlacementBody;

  /// No description provided for @energyGridModuleHelpWaveLimit.
  ///
  /// In en, this message translates to:
  /// **'Wave limit'**
  String get energyGridModuleHelpWaveLimit;

  /// No description provided for @energyGridModuleHelpWaveLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Due to a game limitation, only wave 1 entries take effect in-game. Other wave groups can still be edited here and are saved to the level file, but only wave 1 appears in the wave timeline tab.'**
  String get energyGridModuleHelpWaveLimitBody;

  /// No description provided for @energyGridModuleTapToPlace.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty tile to place a Taiji Tile.'**
  String get energyGridModuleTapToPlace;

  /// No description provided for @energyGridModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Taiji tiles'**
  String get energyGridModuleExpectationLabel;

  /// No description provided for @energyGridModuleIgnoredWaveOverridesWarning.
  ///
  /// In en, this message translates to:
  /// **'This level contains Taiji Tile overrides for waves other than wave 1. They are saved but not shown in the wave timeline because the game only applies wave 1.'**
  String get energyGridModuleIgnoredWaveOverridesWarning;

  /// No description provided for @energyGridModuleWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Due to a game-side issue, generated Taiji Tiles may appear as purple X markers. This does not affect their actual functionality. If you want them to display properly, restarting the game is recommended.'**
  String get energyGridModuleWarningMessage;

  /// No description provided for @gridOverrideModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Wave groups'**
  String get gridOverrideModuleAppearances;

  /// No description provided for @gridOverrideModuleWaveFieldOneBased.
  ///
  /// In en, this message translates to:
  /// **'Wave index'**
  String get gridOverrideModuleWaveFieldOneBased;

  /// No description provided for @gridOverrideModuleTimelineNote.
  ///
  /// In en, this message translates to:
  /// **'Only wave 1 entries appear in the wave timeline tab.'**
  String get gridOverrideModuleTimelineNote;

  /// No description provided for @gridOverrideModuleInitialWaveNote.
  ///
  /// In en, this message translates to:
  /// **'This wave is used for preset grid items. Added grid items will appear on the lawn before the level starts.'**
  String get gridOverrideModuleInitialWaveNote;

  /// No description provided for @gridOverrideModuleWaveSpawnNote.
  ///
  /// In en, this message translates to:
  /// **'Grid items in this wave will spawn when Wave Generator wave {waveGeneratorWave} begins.'**
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave);

  /// No description provided for @gridOverrideModuleWaveSpawnTimelineNote.
  ///
  /// In en, this message translates to:
  /// **'Due to incompatibilities between the old and new implementations, Wave Manager cannot spawn Grid Items by wave using this module. Please use events such as Grid Item Spawn instead.'**
  String get gridOverrideModuleWaveSpawnTimelineNote;

  /// No description provided for @gridOverrideModuleHelpWaveNumbering.
  ///
  /// In en, this message translates to:
  /// **'Wave index'**
  String get gridOverrideModuleHelpWaveNumbering;

  /// No description provided for @gridOverrideModuleHelpWaveNumberingBody.
  ///
  /// In en, this message translates to:
  /// **'Wave index 1 is used for preset grid items, and added grid items will appear on the lawn before the level starts. Starting from wave index 2, the numbering corresponds directly to Wave Generator waves. For example, wave number 2 corresponds to Wave Generator wave 1, and wave index 3 corresponds to Wave Generator wave 2.'**
  String get gridOverrideModuleHelpWaveNumberingBody;

  /// No description provided for @gridOverridePreviewArmrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon stand layout preview'**
  String get gridOverridePreviewArmrackTitle;

  /// No description provided for @gridOverridePreviewEnergyGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiji tile layout preview'**
  String get gridOverridePreviewEnergyGridTitle;

  /// No description provided for @waveGeneratorInitialGridOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial Kongfu World Grid Items Management'**
  String get waveGeneratorInitialGridOverridesTitle;

  /// No description provided for @waveGeneratorPreviewInitialArmrack.
  ///
  /// In en, this message translates to:
  /// **'Initial Weapon Stands'**
  String get waveGeneratorPreviewInitialArmrack;

  /// No description provided for @waveGeneratorPreviewInitialEnergyGrid.
  ///
  /// In en, this message translates to:
  /// **'Initial Taiji Tiles'**
  String get waveGeneratorPreviewInitialEnergyGrid;

  /// No description provided for @waveGeneratorGridOverrideWavePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} - {label}'**
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label);

  /// No description provided for @waveGeneratorInitialPoolWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to initial zombie pool?'**
  String get waveGeneratorInitialPoolWarningTitle;

  /// No description provided for @waveGeneratorInitialPoolWarningContent.
  ///
  /// In en, this message translates to:
  /// **'Zombies added here are not included in the editor random spawn expectation preview and will not take effect in-game. Continue?'**
  String get waveGeneratorInitialPoolWarningContent;

  /// No description provided for @mechanismPlankSettings.
  ///
  /// In en, this message translates to:
  /// **'Connected Minecart settings'**
  String get mechanismPlankSettings;

  /// No description provided for @mechanismPlankStartColumn.
  ///
  /// In en, this message translates to:
  /// **'Starting column (mx)'**
  String get mechanismPlankStartColumn;

  /// No description provided for @mechanismPlankTrackLength.
  ///
  /// In en, this message translates to:
  /// **'Track length (mWidth)'**
  String get mechanismPlankTrackLength;

  /// No description provided for @mechanismPlankEditNotice.
  ///
  /// In en, this message translates to:
  /// **'This interface only supports editing the starting column and track length. All other parameters use preset values, as modifying them may cause Connected Minecarts to malfunction. For further customization, please edit the JSON file manually.\nAdditionally, Connected Minecarts are not recommended outside of Kongfu World, as they are more likely to appear as purple X markers. This does not affect their actual functionality, but it may impact the level\'s visual presentation.'**
  String get mechanismPlankEditNotice;

  /// No description provided for @mechanismPlankOutOfAreaWarning.
  ///
  /// In en, this message translates to:
  /// **'The current rail range may go outside the lawn.'**
  String get mechanismPlankOutOfAreaWarning;

  /// No description provided for @portalTypeEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt'**
  String get portalTypeEgypt;

  /// No description provided for @portalTypeEgypt2.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt 2'**
  String get portalTypeEgypt2;

  /// No description provided for @portalTypePirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas'**
  String get portalTypePirate;

  /// No description provided for @portalTypeWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West'**
  String get portalTypeWest;

  /// No description provided for @portalTypeFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future'**
  String get portalTypeFuture;

  /// No description provided for @portalTypeFuture2.
  ///
  /// In en, this message translates to:
  /// **'Far Future 2'**
  String get portalTypeFuture2;

  /// No description provided for @portalTypeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages'**
  String get portalTypeDark;

  /// No description provided for @portalTypeBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach'**
  String get portalTypeBeach;

  /// No description provided for @portalTypeIceAge.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves'**
  String get portalTypeIceAge;

  /// No description provided for @portalTypeLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City'**
  String get portalTypeLostCity;

  /// No description provided for @portalTypeEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour'**
  String get portalTypeEighties;

  /// No description provided for @portalTypeDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh'**
  String get portalTypeDino;

  /// No description provided for @portalTypeEndlessEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt (Endless)'**
  String get portalTypeEndlessEgypt;

  /// No description provided for @portalTypeEndlessPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas (Endless)'**
  String get portalTypeEndlessPirate;

  /// No description provided for @portalTypeEndlessWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West (Endless)'**
  String get portalTypeEndlessWest;

  /// No description provided for @portalTypeEndlessKongfu.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World (Endless)'**
  String get portalTypeEndlessKongfu;

  /// No description provided for @portalTypeEndlessFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future (Endless)'**
  String get portalTypeEndlessFuture;

  /// No description provided for @portalTypeEndlessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages (Endless)'**
  String get portalTypeEndlessDark;

  /// No description provided for @portalTypeEndlessBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach (Endless)'**
  String get portalTypeEndlessBeach;

  /// No description provided for @portalTypeEndlessIceAge.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves (Endless)'**
  String get portalTypeEndlessIceAge;

  /// No description provided for @portalTypeEndlessSkyCity.
  ///
  /// In en, this message translates to:
  /// **'Sky City (Endless)'**
  String get portalTypeEndlessSkyCity;

  /// No description provided for @portalTypeEndlessLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City (Endless)'**
  String get portalTypeEndlessLostCity;

  /// No description provided for @portalTypeEndlessEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour (Endless)'**
  String get portalTypeEndlessEighties;

  /// No description provided for @portalTypeEndlessDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh (Endless)'**
  String get portalTypeEndlessDino;

  /// No description provided for @portalTypeEndlessModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Day (Endless)'**
  String get portalTypeEndlessModern;

  /// No description provided for @portalTypeMemoryLane1.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 1'**
  String get portalTypeMemoryLane1;

  /// No description provided for @portalTypeMemoryLane2.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 2'**
  String get portalTypeMemoryLane2;

  /// No description provided for @portalTypeMemoryLane3.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 3'**
  String get portalTypeMemoryLane3;

  /// No description provided for @portalTypeShieldGenerator.
  ///
  /// In en, this message translates to:
  /// **'Shield Generator'**
  String get portalTypeShieldGenerator;

  /// No description provided for @portalTypeGlacialNianSkill.
  ///
  /// In en, this message translates to:
  /// **'Glacial Nian Skill'**
  String get portalTypeGlacialNianSkill;

  /// No description provided for @portalTypeZombotany.
  ///
  /// In en, this message translates to:
  /// **'Zombotany'**
  String get portalTypeZombotany;

  /// No description provided for @portalTypeSlimeZombies.
  ///
  /// In en, this message translates to:
  /// **'Zom-Blob'**
  String get portalTypeSlimeZombies;

  /// No description provided for @portalTypeUniverse42.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe No. 42'**
  String get portalTypeUniverse42;

  /// No description provided for @portalTypeUniverse41.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe No. 41'**
  String get portalTypeUniverse41;

  /// No description provided for @portalTypeEliteHealerNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Healer (Normal)'**
  String get portalTypeEliteHealerNormal;

  /// No description provided for @portalTypeEliteElectricNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Lightning Gun (Normal)'**
  String get portalTypeEliteElectricNormal;

  /// No description provided for @portalTypeEliteBallistaNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Zcorpion (Normal)'**
  String get portalTypeEliteBallistaNormal;

  /// No description provided for @portalTypeEliteOnmyojiNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Onmyoji (Normal)'**
  String get portalTypeEliteOnmyojiNormal;

  /// No description provided for @portalTypeEliteHealerHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Healer (Hard)'**
  String get portalTypeEliteHealerHard;

  /// No description provided for @portalTypeEliteElectricHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Lightning Gun (Hard)'**
  String get portalTypeEliteElectricHard;

  /// No description provided for @portalTypeEliteBallistaHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Zcorpion (Hard)'**
  String get portalTypeEliteBallistaHard;

  /// No description provided for @portalTypeEliteOnmyojiHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Onmyoji (Hard)'**
  String get portalTypeEliteOnmyojiHard;

  /// No description provided for @portalTypeRomeoHard.
  ///
  /// In en, this message translates to:
  /// **'Romeo (Memory Lane)'**
  String get portalTypeRomeoHard;

  /// No description provided for @portalTypeRomeoHard2.
  ///
  /// In en, this message translates to:
  /// **'Romeo 2 (Memory Lane)'**
  String get portalTypeRomeoHard2;

  /// No description provided for @portalTypeJulietHard.
  ///
  /// In en, this message translates to:
  /// **'Juliet (Memory Lane)'**
  String get portalTypeJulietHard;

  /// No description provided for @portalTypeJulietHard2.
  ///
  /// In en, this message translates to:
  /// **'Juliet 2 (Memory Lane)'**
  String get portalTypeJulietHard2;

  /// No description provided for @portalTypeSherlockHard.
  ///
  /// In en, this message translates to:
  /// **'Sherlock (Memory Lane)'**
  String get portalTypeSherlockHard;

  /// No description provided for @portalTypeEliteHunter.
  ///
  /// In en, this message translates to:
  /// **'Elite Hunter'**
  String get portalTypeEliteHunter;

  /// No description provided for @portalTypeEliteChief.
  ///
  /// In en, this message translates to:
  /// **'Elite Chief'**
  String get portalTypeEliteChief;

  /// No description provided for @portalTypeEliteWeasel.
  ///
  /// In en, this message translates to:
  /// **'Elite Weasel Hoarder'**
  String get portalTypeEliteWeasel;

  /// No description provided for @portalTypeEliteBumperCar.
  ///
  /// In en, this message translates to:
  /// **'Elite Bumper Car'**
  String get portalTypeEliteBumperCar;

  /// No description provided for @portalTypeGlacialNian.
  ///
  /// In en, this message translates to:
  /// **'Glacial Nian'**
  String get portalTypeGlacialNian;

  /// No description provided for @portalTypeEliteWizard.
  ///
  /// In en, this message translates to:
  /// **'Elite Wizard'**
  String get portalTypeEliteWizard;

  /// No description provided for @portalTypeEliteKing.
  ///
  /// In en, this message translates to:
  /// **'Elite King'**
  String get portalTypeEliteKing;

  /// No description provided for @portalTypeEliteMirrorQueen.
  ///
  /// In en, this message translates to:
  /// **'Elite Mirror Queen'**
  String get portalTypeEliteMirrorQueen;

  /// No description provided for @waveGeneratorTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get waveGeneratorTabLabel;

  /// No description provided for @waveGeneratorModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator'**
  String get waveGeneratorModuleTitle;

  /// No description provided for @waveGeneratorModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator module'**
  String get waveGeneratorModuleHelpTitle;

  /// No description provided for @waveGeneratorModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get waveGeneratorModuleHelpOverview;

  /// No description provided for @waveGeneratorModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Legacy embedded wave system used in campaign-style levels such as Kongfu. Waves are stored inside this module — there are no separate wave events. Edit individual waves on the Waves tab.'**
  String get waveGeneratorModuleHelpOverviewBody;

  /// No description provided for @waveGeneratorModuleHelpSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending points'**
  String get waveGeneratorModuleHelpSpending;

  /// No description provided for @waveGeneratorModuleHelpSpendingBody.
  ///
  /// In en, this message translates to:
  /// **'WaveSpendingPoints must be less than or equal to WaveSpendingPointIncrement. If WaveSpendingPoints is higher, the level crashes on load.'**
  String get waveGeneratorModuleHelpSpendingBody;

  /// No description provided for @waveGeneratorModuleHelpPool.
  ///
  /// In en, this message translates to:
  /// **'Zombie pool'**
  String get waveGeneratorModuleHelpPool;

  /// No description provided for @waveGeneratorModuleHelpPoolBody.
  ///
  /// In en, this message translates to:
  /// **'AddToZombiePool extends the random-spawn zombie pool from the given wave onward. Only built-in zombie types (ZombieTypes RTIDs) are supported — custom zombies crash the game.'**
  String get waveGeneratorModuleHelpPoolBody;

  /// No description provided for @waveGeneratorModuleHelpIncompat.
  ///
  /// In en, this message translates to:
  /// **'Incompatibilities'**
  String get waveGeneratorModuleHelpIncompat;

  /// No description provided for @waveGeneratorModuleHelpIncompatBody.
  ///
  /// In en, this message translates to:
  /// **'Cannot coexist with Wave Manager modules, Renai module, or Witch module.'**
  String get waveGeneratorModuleHelpIncompatBody;

  /// No description provided for @waveGeneratorModuleHelpRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get waveGeneratorModuleHelpRow;

  /// No description provided for @waveGeneratorModuleHelpRowBody.
  ///
  /// In en, this message translates to:
  /// **'Row values are 1-based strings in JSON (\"?\" = random).'**
  String get waveGeneratorModuleHelpRowBody;

  /// No description provided for @waveGeneratorModuleGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Global parameters'**
  String get waveGeneratorModuleGlobalParams;

  /// No description provided for @waveGeneratorGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator Parameters'**
  String get waveGeneratorGlobalParams;

  /// No description provided for @waveGeneratorFlagIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'Final wave is always a flag wave.'**
  String get waveGeneratorFlagIntervalHint;

  /// No description provided for @flagWaveInterval.
  ///
  /// In en, this message translates to:
  /// **'Flag wave interval (FlagWaveInterval)'**
  String get flagWaveInterval;

  /// No description provided for @waveGeneratorSpendingPoints.
  ///
  /// In en, this message translates to:
  /// **'Spending points (WaveSpendingPoints)'**
  String get waveGeneratorSpendingPoints;

  /// No description provided for @waveGeneratorSpendingPointIncrement.
  ///
  /// In en, this message translates to:
  /// **'Point increment (WaveSpendingPointIncrement)'**
  String get waveGeneratorSpendingPointIncrement;

  /// No description provided for @waveGeneratorWaveCountSummary.
  ///
  /// In en, this message translates to:
  /// **'Waves: {count} (edit on Waves tab)'**
  String waveGeneratorWaveCountSummary(int count);

  /// No description provided for @waveGeneratorInitialPool.
  ///
  /// In en, this message translates to:
  /// **'Initial zombie pool (AddToZombiePool)'**
  String get waveGeneratorInitialPool;

  /// No description provided for @waveGeneratorEmptyPool.
  ///
  /// In en, this message translates to:
  /// **'No zombies in the initial pool.'**
  String get waveGeneratorEmptyPool;

  /// No description provided for @waveGeneratorCustomZombieBlocked.
  ///
  /// In en, this message translates to:
  /// **'Custom zombies are not supported in wave generator levels.'**
  String get waveGeneratorCustomZombieBlocked;

  /// No description provided for @waveGeneratorTabMissingModule.
  ///
  /// In en, this message translates to:
  /// **'Add Wave Generator module to edit waves.'**
  String get waveGeneratorTabMissingModule;

  /// No description provided for @waveGeneratorTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Flag interval: {interval}, Spending: {points} + {increment}/wave'**
  String waveGeneratorTabSummary(int interval, int points, int increment);

  /// No description provided for @waveGeneratorNoWaves.
  ///
  /// In en, this message translates to:
  /// **'No waves defined.'**
  String get waveGeneratorNoWaves;

  /// No description provided for @waveGeneratorEmptyWaveRow.
  ///
  /// In en, this message translates to:
  /// **'No scripted zombies (tap to edit)'**
  String get waveGeneratorEmptyWaveRow;

  /// No description provided for @waveGeneratorRandomSpawnsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Random spawns enabled'**
  String get waveGeneratorRandomSpawnsEnabled;

  /// No description provided for @waveGeneratorRandomZombiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Random zombies:'**
  String get waveGeneratorRandomZombiesLabel;

  /// No description provided for @waveGeneratorWavePoolDisabled.
  ///
  /// In en, this message translates to:
  /// **'Random spawns are disabled — you cannot add zombies to the pool on this wave.'**
  String get waveGeneratorWavePoolDisabled;

  /// No description provided for @waveGeneratorDisableRandomSpawns.
  ///
  /// In en, this message translates to:
  /// **'Disable random spawns (DisableRandomSpawns)'**
  String get waveGeneratorDisableRandomSpawns;

  /// No description provided for @waveGeneratorDisableRandomSpawnsHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, only scripted zombies spawn on this wave.'**
  String get waveGeneratorDisableRandomSpawnsHint;

  /// No description provided for @waveGeneratorWaitUntilAllDie.
  ///
  /// In en, this message translates to:
  /// **'Spawn this wave only after all zombies from the previous wave have been defeated (WaitUntilAllZombiesDie)'**
  String get waveGeneratorWaitUntilAllDie;

  /// No description provided for @waveGeneratorNoScriptedZombies.
  ///
  /// In en, this message translates to:
  /// **'No scripted zombies on this wave.'**
  String get waveGeneratorNoScriptedZombies;

  /// No description provided for @waveGeneratorSpawnPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Plant food drops (SpawnPlantFoodCount)'**
  String get waveGeneratorSpawnPlantFood;

  /// No description provided for @waveGeneratorWavePointStart.
  ///
  /// In en, this message translates to:
  /// **'Wave point start (WavePointStart)'**
  String get waveGeneratorWavePointStart;

  /// No description provided for @waveGeneratorWavePointIncrement.
  ///
  /// In en, this message translates to:
  /// **'Wave point increment (WavePointIncrement)'**
  String get waveGeneratorWavePointIncrement;

  /// No description provided for @waveGeneratorBlackHoleFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of columns to summon a black hole at the end of this wave, pulling all plants to the right.\nNote: Black hole can only be summoned if this wave is not the final wave of the level and \"Spawn this wave only after all zombies from the previous wave have been defeated\" is enabled.'**
  String get waveGeneratorBlackHoleFieldHint;

  /// No description provided for @waveGeneratorBlackHoleWaveHint.
  ///
  /// In en, this message translates to:
  /// **'A black hole appears at the end of this wave and pulls plants {cols} columns to the right'**
  String waveGeneratorBlackHoleWaveHint(int cols);

  /// No description provided for @waveGeneratorWavePoolAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to pool this wave (AddToZombiePool)'**
  String get waveGeneratorWavePoolAdd;

  /// No description provided for @waveGeneratorWaveScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wave generator wave'**
  String get waveGeneratorWaveScreenSubtitle;

  /// No description provided for @waveGeneratorWaveScreenHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave editor'**
  String get waveGeneratorWaveScreenHelpTitle;

  /// No description provided for @waveGeneratorWaveScreenHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Edit scripted spawns and wave-specific options. Random spawns use the cumulative zombie pool and spending points.'**
  String get waveGeneratorWaveScreenHelpBody;

  /// No description provided for @waveGeneratorExpectationTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view random spawn expectation'**
  String get waveGeneratorExpectationTapHint;

  /// No description provided for @waveGeneratorExpectationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No eligible pool zombies for random spawns on this wave.'**
  String get waveGeneratorExpectationEmpty;

  /// No description provided for @waveGeneratorExpectationPoolNote.
  ///
  /// In en, this message translates to:
  /// **'Expectations are based on the cumulative AddToZombiePool. Other zombies may still appear if points are high enough.'**
  String get waveGeneratorExpectationPoolNote;

  /// No description provided for @protectItems.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items'**
  String get protectItems;

  /// No description provided for @protectGridItemChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items module'**
  String get protectGridItemChallengeHelpTitle;

  /// No description provided for @briefOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get briefOverview;

  /// No description provided for @automaticCount.
  ///
  /// In en, this message translates to:
  /// **'Automatic Count'**
  String get automaticCount;

  /// No description provided for @operationGuide.
  ///
  /// In en, this message translates to:
  /// **'Operation Guide'**
  String get operationGuide;

  /// No description provided for @protectGridItemChallengeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Specify the grid items that must be protected in the level. The level will immediately fail if any of them are destroyed.'**
  String get protectGridItemChallengeHelpOverview;

  /// No description provided for @protectGridItemChallengeHelpAutoCountBody.
  ///
  /// In en, this message translates to:
  /// **'The editor will automatically update the number of grid items that need to be protected based on the number of items you add.'**
  String get protectGridItemChallengeHelpAutoCountBody;

  /// No description provided for @protectGridItemChallengeHelpOperationGuide.
  ///
  /// In en, this message translates to:
  /// **'Click a position in the grid above, then click the \"Add item\" button to select the type of item to protect.'**
  String get protectGridItemChallengeHelpOperationGuide;

  /// No description provided for @customStageProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom stage properties'**
  String get customStageProperties;

  /// No description provided for @customStageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Custom stage object not found.'**
  String get customStageNotFound;

  /// No description provided for @customStageSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get customStageSectionGeneral;

  /// No description provided for @customStageSectionZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombie Types'**
  String get customStageSectionZombies;

  /// No description provided for @customStageSectionResourceGroups.
  ///
  /// In en, this message translates to:
  /// **'Resource Groups'**
  String get customStageSectionResourceGroups;

  /// No description provided for @customStageSectionMusicAndOther.
  ///
  /// In en, this message translates to:
  /// **'Basic Elements'**
  String get customStageSectionMusicAndOther;

  /// No description provided for @customStageSectionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get customStageSectionAdvanced;

  /// No description provided for @customStageAlias.
  ///
  /// In en, this message translates to:
  /// **'Stage alias (English only)'**
  String get customStageAlias;

  /// No description provided for @customStageNoResourceGroups.
  ///
  /// In en, this message translates to:
  /// **'No resource groups in list'**
  String get customStageNoResourceGroups;

  /// No description provided for @customStageMissingBackgroundWarning.
  ///
  /// In en, this message translates to:
  /// **'Import at least one DelayLoad_Background group listed in the stage helper, or the lawn may appear completely black.'**
  String get customStageMissingBackgroundWarning;

  /// No description provided for @customStageEnableAmbient.
  ///
  /// In en, this message translates to:
  /// **'Enable ambient audio'**
  String get customStageEnableAmbient;

  /// No description provided for @customStageDisabledCellsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Leave empty'**
  String get customStageDisabledCellsEmpty;

  /// No description provided for @customStageDisabledCellsDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get customStageDisabledCellsDefault;

  /// No description provided for @customStageEnableSubmarine.
  ///
  /// In en, this message translates to:
  /// **'Enable submarine'**
  String get customStageEnableSubmarine;

  /// No description provided for @customStageSubmarineHitpoints.
  ///
  /// In en, this message translates to:
  /// **'Submarine health'**
  String get customStageSubmarineHitpoints;

  /// No description provided for @customStageBeachMinigame.
  ///
  /// In en, this message translates to:
  /// **'Use minigame version'**
  String get customStageBeachMinigame;

  /// No description provided for @customStageOnePerLevelLimit.
  ///
  /// In en, this message translates to:
  /// **'This level already has a custom lawn. Delete it before adding another.'**
  String get customStageOnePerLevelLimit;

  /// No description provided for @selectStageBackground.
  ///
  /// In en, this message translates to:
  /// **'Select lawn appearance'**
  String get selectStageBackground;

  /// No description provided for @searchStageBackground.
  ///
  /// In en, this message translates to:
  /// **'Search lawn'**
  String get searchStageBackground;

  /// No description provided for @noStageBackgroundFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn appearance found'**
  String get noStageBackgroundFound;

  /// No description provided for @stageBackgroundNeedMorePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Need another lawn appearance?'**
  String get stageBackgroundNeedMorePromptTitle;

  /// No description provided for @stageBackgroundNeedMorePromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Import resource groups from another stage to unlock more lawn appearances here.'**
  String get stageBackgroundNeedMorePromptMessage;

  /// No description provided for @stageBackgroundAddFromStage.
  ///
  /// In en, this message translates to:
  /// **'Add another lawn appearance'**
  String get stageBackgroundAddFromStage;

  /// No description provided for @customStageNameSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Custom)'**
  String get customStageNameSuffix;

  /// No description provided for @customStageLawnAppearance.
  ///
  /// In en, this message translates to:
  /// **'Lawn appearance'**
  String get customStageLawnAppearance;

  /// No description provided for @customStageBaseStage.
  ///
  /// In en, this message translates to:
  /// **'Base stage'**
  String get customStageBaseStage;

  /// No description provided for @selectCustomStageBase.
  ///
  /// In en, this message translates to:
  /// **'Select base lawn'**
  String get selectCustomStageBase;

  /// No description provided for @noStageBaseFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn found'**
  String get noStageBaseFound;

  /// No description provided for @importResourceGroup.
  ///
  /// In en, this message translates to:
  /// **'Import resource group'**
  String get importResourceGroup;

  /// No description provided for @importResourceGroupGlobal.
  ///
  /// In en, this message translates to:
  /// **'From global list'**
  String get importResourceGroupGlobal;

  /// No description provided for @importResourceGroupFromStage.
  ///
  /// In en, this message translates to:
  /// **'From stage'**
  String get importResourceGroupFromStage;

  /// No description provided for @importResourceGroupSourceStage.
  ///
  /// In en, this message translates to:
  /// **'Source stage'**
  String get importResourceGroupSourceStage;

  /// No description provided for @searchResourceGroup.
  ///
  /// In en, this message translates to:
  /// **'Search resource group'**
  String get searchResourceGroup;

  /// No description provided for @noResourceGroupFound.
  ///
  /// In en, this message translates to:
  /// **'No resource group found'**
  String get noResourceGroupFound;

  /// No description provided for @importResourceGroupsFromStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add resource groups from stage?'**
  String get importResourceGroupsFromStageTitle;

  /// No description provided for @importResourceGroupsFromStageMessage.
  ///
  /// In en, this message translates to:
  /// **'The following resource groups from {stageName} will be added:'**
  String importResourceGroupsFromStageMessage(String stageName);

  /// No description provided for @importResourceGroupsFromStageSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} resource group(s) already in this level will be skipped.'**
  String importResourceGroupsFromStageSkipped(int count);

  /// No description provided for @importResourceGroupsFromStageAllPresent.
  ///
  /// In en, this message translates to:
  /// **'All resource groups from this stage are already in this level.'**
  String get importResourceGroupsFromStageAllPresent;

  /// No description provided for @importResourceGroupsApplySourceLawnAppearance.
  ///
  /// In en, this message translates to:
  /// **'Also use this stage\'s lawn appearance'**
  String get importResourceGroupsApplySourceLawnAppearance;

  /// No description provided for @createCustomStage.
  ///
  /// In en, this message translates to:
  /// **'Create custom lawn'**
  String get createCustomStage;

  /// No description provided for @createCustomStageHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a base lawn appearance and edit it locally in this level.'**
  String get createCustomStageHint;

  /// No description provided for @customStageAliasPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom stage alias'**
  String get customStageAliasPromptTitle;

  /// No description provided for @customStageAliasTaken.
  ///
  /// In en, this message translates to:
  /// **'That alias is already used in this level.'**
  String get customStageAliasTaken;

  /// No description provided for @stageSelectionTabBuiltin.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get stageSelectionTabBuiltin;

  /// No description provided for @stageSelectionTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get stageSelectionTabCustom;

  /// No description provided for @customStageSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom lawn in this level yet.'**
  String get customStageSelectionEmpty;

  /// No description provided for @customStageSelectionInLevel.
  ///
  /// In en, this message translates to:
  /// **'Custom lawns in this level'**
  String get customStageSelectionInLevel;

  /// No description provided for @customStageSwitchToBuiltinTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to built-in lawn?'**
  String get customStageSwitchToBuiltinTitle;

  /// No description provided for @customStageSwitchToBuiltinMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the custom stage data from this level. This cannot be undone.'**
  String get customStageSwitchToBuiltinMessage;

  /// No description provided for @customStageDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete custom lawn?'**
  String get customStageDeleteTitle;

  /// No description provided for @customStageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the custom stage data from this level. If it is the active lawn, the level will switch to the default built-in lawn.'**
  String get customStageDeleteMessage;

  /// No description provided for @customStagePresetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preset custom lawns'**
  String get customStagePresetSectionTitle;

  /// No description provided for @editCustomStage.
  ///
  /// In en, this message translates to:
  /// **'Edit custom lawn'**
  String get editCustomStage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
