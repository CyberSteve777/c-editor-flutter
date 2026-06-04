// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Level Library';

  @override
  String get about => 'About';

  @override
  String get back => 'Back';

  @override
  String get refresh => 'Refresh';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get switchFolder => 'Switch folder';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get uiSize => 'UI size';

  @override
  String get aboutSoftware => 'About';

  @override
  String get selectFolder => 'Select folder';

  @override
  String get storagePermissionHint =>
      'Storage permission required. Enable \"Allow access to manage all files\" in Settings to open level files.';

  @override
  String get storagePermissionDialogTitle => 'Storage Permission Required';

  @override
  String get storagePermissionDialogMessage =>
      'This app requires external storage access to open and save level files. Please turn on \"Allow access to manage all files\" in Settings.';

  @override
  String get storagePermissionGoToSettings => 'Go to settings';

  @override
  String get storagePermissionDeny => 'Deny';

  @override
  String get initSetup => 'Initial setup';

  @override
  String get selectFolderPrompt =>
      'Please select a folder as the level storage directory.';

  @override
  String get selectFolderButton => 'Select folder';

  @override
  String get emptyFolder => 'Folder is empty';

  @override
  String get newFolder => 'New folder';

  @override
  String get newLevel => 'New level';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get copy => 'Copy';

  @override
  String get move => 'Move';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get convert => 'Convert';

  @override
  String get convertHelpTooltip => 'Convert';

  @override
  String get create => 'Create';

  @override
  String get newName => 'New name';

  @override
  String get folderName => 'Folder name';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String confirmDeleteMessage(Object detail, Object name) {
    return 'Are you sure you want to delete \"$name\"? $detail';
  }

  @override
  String get folderDeleteDetail =>
      'If it is a folder, its contents will also be deleted.';

  @override
  String get levelDeleteDetail => 'This action cannot be undone.';

  @override
  String get confirmDeleteCheckbox => 'I confirm permanent deletion';

  @override
  String get renameSuccess => 'Successfully renamed';

  @override
  String get renameFail => 'Rename failed, file already exists';

  @override
  String get uploadLevel => 'Upload to Creative Courtyard';

  @override
  String get uploadLevelConfirm =>
      'You are about to leave the editor and open the official Advanced Creation Courtyard Creator Hub website. After signing in with your email account, you can upload JSON level files from the editor to the in-game Creative Courtyard for other players to enjoy. Do you want to continue?';

  @override
  String get proceed => 'Continue';

  @override
  String get copyReferenceOrDeep => 'Copy reference or make a deep copy?';

  @override
  String get copyReference => 'Copy reference';

  @override
  String get deepCopy => 'Deep copy';

  @override
  String get copyEventTarget => 'Target wave';

  @override
  String get targetWaveIndex => 'Target wave number';

  @override
  String get moveToWaveIndex => 'Move to wave number';

  @override
  String get invalidWaveIndex => 'Invalid wave number';

  @override
  String get renamingFailed => 'Renaming failed';

  @override
  String get deleted => 'Deleted';

  @override
  String get copyLevel => 'Copy level';

  @override
  String get newFileName => 'New file name';

  @override
  String get copySuccess => 'Copy successful';

  @override
  String get copyFail => 'Copy failed';

  @override
  String moving(Object name) {
    return 'Moving: $name';
  }

  @override
  String get movePrompt => 'Navigate to target folder, then tap Paste';

  @override
  String get paste => 'Paste';

  @override
  String get movingSuccess => 'Moved successfully';

  @override
  String get movingFail => 'Move failed';

  @override
  String get moveSameFolder => 'Source and destination folders are the same';

  @override
  String get moveFileExistsTitle => 'File already exists';

  @override
  String get moveFileExistsMessage =>
      'A file with this name already exists in the destination folder.';

  @override
  String get moveOverwrite => 'Overwrite';

  @override
  String fileOverwritten(Object name) {
    return 'File was overwritten: $name';
  }

  @override
  String get moveSaveAsCopy => 'Save as copy';

  @override
  String get moveCancelled => 'Operation cancelled';

  @override
  String movedAs(Object name) {
    return 'Moved and saved as $name';
  }

  @override
  String get folderCreated => 'Folder created';

  @override
  String get createFail => 'Create failed';

  @override
  String get noTemplates => 'No templates found';

  @override
  String get newLevelTemplate => 'New level - Select template';

  @override
  String get nameLevel => 'Name level';

  @override
  String get levelCreated => 'Level created';

  @override
  String get levelCreateFail => 'Create failed, file already exists';

  @override
  String get adjustUiSize => 'Adjust UI size';

  @override
  String currentScale(Object percent) {
    return 'Current scale: $percent%';
  }

  @override
  String get small => 'Small';

  @override
  String get standard => 'Standard';

  @override
  String get large => 'Large';

  @override
  String get done => 'Done';

  @override
  String get reset => 'Reset';

  @override
  String cacheCleared(Object count) {
    return 'Cleared $count cached files';
  }

  @override
  String get returnUp => 'Back';

  @override
  String get jsonFile => 'JSON file';

  @override
  String get convertToJson => 'Convert to JSON';

  @override
  String get convertToHotUpdateJson => 'Convert to hot update json';

  @override
  String get convertToEncryptedRton => 'Convert to encrypted rton';

  @override
  String get conversionRequiredTitle => 'Conversion required';

  @override
  String get conversionRequiredMessage =>
      'This file must be converted to JSON before it can be opened in the editor.';

  @override
  String get convertAction => 'Convert';

  @override
  String get conversionFailed => 'Conversion failed';

  @override
  String convertedMessage(Object name) {
    return 'Converted: $name';
  }

  @override
  String get softwareIntro => 'Software intro';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'PVZ2 Visual Level Editor';

  @override
  String get introSection => 'Introduction';

  @override
  String get introText =>
      'C-Editor is a visual level editing tool designed for Plants vs. Zombies 2 Chinese Edition. It aims to simplify editing level JSON files with an intuitive interface.';

  @override
  String get featuresSection => 'Core features';

  @override
  String get feature1 => 'Modular editing: Manage level modules and events.';

  @override
  String get feature2 =>
      'Multi-mode: I, Zombie, Vasebreaker, Last Stand, ZombossMech battle, and more.';

  @override
  String get feature3 =>
      'Custom zombies: Inject and edit custom zombie properties.';

  @override
  String get feature4 =>
      'Validation: Detect missing modules, broken references, and other issues.';

  @override
  String get usageSection => 'Usage';

  @override
  String get usageText =>
      '1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Tap a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Tap save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Once your level is complete, click the \"Upload to Creative Courtyard\" button in the bottom navigation bar of the main page to go to the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. Sign in with your email account to upload the level to the in-game Creative Courtyard.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.';

  @override
  String get usageTextDesktop =>
      '1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Click a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Click save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Once your level is complete, click the \"Upload to Creative Courtyard\" button in the bottom navigation bar of the main page to go to the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. Sign in with your email account to upload the level to the in-game Creative Courtyard.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.';

  @override
  String get usageTextMobile =>
      '1. Directory Setup: Tap the folder icon to select a folder for level JSON files.\n2. Open/Create: Tap a level to edit or use \"+\" to create from template.\n3. Modules: Add modules in the editor.\n4. Save: Tap save to write back to the JSON file.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON or encrypted RTON, after which the files can be imported into the game using other tools for testing (remember to manually change the file extension from .hujson back to .json before importing).\n6. Once your level is complete, tap the \"Upload to Creative Courtyard\" button in the bottom navigation bar of the main page to go to the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. Sign in with your email account to upload the level to the in-game Creative Courtyard.\n7. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n8. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.';

  @override
  String get usageRecommendedLevelsLabel =>
      'Creative Courtyard · Recommended Levels Showcase:';

  @override
  String get discordInviteLabel => 'Discord server invite link:';

  @override
  String get creditsSection => 'Credits';

  @override
  String get authorLabel => 'Author:';

  @override
  String get authorName => 'CyberSteve777';

  @override
  String get thanksLabel => 'Special thanks:';

  @override
  String get thanksNames =>
      'Devourdoom, Evilhack28, Chara, KL12, Haruma, nineteendo, vi_i_guess';

  @override
  String get sourceLabel => 'Source:';

  @override
  String get issuesLabel => 'Report Issues:';

  @override
  String get zEditorAcknowledgment =>
      'Creating this tool would be impossible without the creators of Z-Editor.';

  @override
  String get zEditorCreditsSubsection => 'Z-Editor credits';

  @override
  String get zEditorAuthorLabel => 'Author:';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => 'Special thanks:';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ group:';

  @override
  String get zEditorQqGroupNumber => '960722092';

  @override
  String get tagline => 'Create infinite possibilities';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => 'Blank level';

  @override
  String get templateCardPickExample => 'Regular level template';

  @override
  String get templateConveyorExample => 'Conveyor-belt level template';

  @override
  String get templateLastStandExample => 'Last Stand level template';

  @override
  String get templateIZombieExample => 'I, Zombie level template';

  @override
  String get templateVaseBreakerExample => 'Vasebreaker level template';

  @override
  String get templateZombossMechExample => 'ZombossMech battle level template';

  @override
  String get templateZombossBattleExample => 'Zomboss battle level template';

  @override
  String get templateCustomZombieExample => 'Custom zombie level template';

  @override
  String get templateIPlantExample => 'I, Plant level template';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get saveBeforeLeaving => 'Save before leaving?';

  @override
  String get discard => 'Discard';

  @override
  String get stayInEditor => 'Stay';

  @override
  String get saved => 'Saved';

  @override
  String get failedToLoadLevel => 'Failed to load level';

  @override
  String get noLevelDefinition => 'No level definition';

  @override
  String get noLevelDefinitionHint =>
      'Level definition module (LevelDefinition) was not found. This is the base node of the level file. Try adding it manually.';

  @override
  String get levelBasicInfo => 'Basic Information';

  @override
  String get levelBasicInfoSubtitle => 'Name, Index, Description, Lawn';

  @override
  String get removeModule => 'Remove module';

  @override
  String get zombieCategoryMain => 'By World';

  @override
  String get zombieCategorySize => 'By Size';

  @override
  String get zombieCategoryOther => 'Other';

  @override
  String get zombieCategoryCollection => 'My Collection';

  @override
  String get zombieTagAll => 'All Zombies';

  @override
  String get zombieTagEgyptPirate => 'Ancient Egypt / Pirate Seas';

  @override
  String get zombieTagWestFuture => 'Wild West / Far Future';

  @override
  String get zombieTagDarkBeach => 'Dark Ages / Big Wave Beach';

  @override
  String get zombieTagIceageLostcity => 'Frostbite Caves / Lost City';

  @override
  String get zombieTagKongfuSkycity => 'Kongfu World / Sky City';

  @override
  String get zombieTagEightiesDino => 'Neon Mixtape Tour / Jurassic Marsh';

  @override
  String get zombieTagModernPvz1 => 'Modern Day / PvZ1';

  @override
  String get zombieTagSteamRenai => 'Steam Ages / Renaissance Ages';

  @override
  String get zombieTagHenaiAtlantis => 'Heian Ages / Underwater World';

  @override
  String get zombieTagTaleZCorp => 'Fairytale Forest / ZCorp Takeover';

  @override
  String get zombieTagParkourSpeed => 'Parkour Party / Speed Racing';

  @override
  String get zombieTagTothewest => 'Journey to the West / Underground Palace';

  @override
  String get zombieTagMemory => 'Memory Lane';

  @override
  String get zombieTagUniverse => 'Parallel Universe';

  @override
  String get zombieTagFestival1 => 'Festival 1';

  @override
  String get zombieTagFestival2 => 'Festival 2';

  @override
  String get zombieTagRoman => 'Ancient Rome';

  @override
  String get zombieTagCustom => 'Memory Lane Variants';

  @override
  String get zombieTagPet => 'Pet';

  @override
  String get zombieTagImp => 'Imp';

  @override
  String get zombieTagBasic => 'Basic';

  @override
  String get zombieTagFat => 'Fat';

  @override
  String get zombieTagStrong => 'Bully';

  @override
  String get zombieTagGargantuar => 'Gargantuar';

  @override
  String get zombieTagElite => 'Elite';

  @override
  String get zombieTagEvildave => 'Compatible with IZ';

  @override
  String get plantCategoryQuality => 'By Quality';

  @override
  String get plantCategoryRole => 'By Role';

  @override
  String get plantCategoryAttribute => 'By Attribute';

  @override
  String get plantCategoryOther => 'Other';

  @override
  String get plantCategoryCollection => 'My Favorites';

  @override
  String get plantTagAll => 'All Plants';

  @override
  String get plantTagWhite => 'White Quality';

  @override
  String get plantTagGreen => 'Green Quality';

  @override
  String get plantTagBlue => 'Blue Quality';

  @override
  String get plantTagPurple => 'Purple Quality';

  @override
  String get plantTagOrange => 'Orange Quality';

  @override
  String get plantTagRed => 'Red Quality';

  @override
  String get plantTagSupport => 'Support';

  @override
  String get plantTagRanger => 'Ranged';

  @override
  String get plantTagSunProducer => 'Sun';

  @override
  String get plantTagDefence => 'Tough';

  @override
  String get plantTagVanguard => 'Vanguard';

  @override
  String get plantTagTrapper => 'Special';

  @override
  String get plantTagFire => 'Fire';

  @override
  String get plantTagIce => 'Ice';

  @override
  String get plantTagMagic => 'Magic';

  @override
  String get plantTagPoison => 'Poison';

  @override
  String get plantTagElectric => 'Electric';

  @override
  String get plantTagPhysical => 'Physical';

  @override
  String get plantTagOriginal => 'PvZ1 Plants';

  @override
  String get plantTagParallel => 'Parallel Universe';

  @override
  String get plantTagSpecial => 'Magic Hats';

  @override
  String get removeModuleConfirm =>
      'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.';

  @override
  String get confirmRemove => 'Remove';

  @override
  String get addModule => 'Add module';

  @override
  String get settings => 'Settings';

  @override
  String get timeline => 'Wave Timeline';

  @override
  String get iZombie => 'I, Zombie';

  @override
  String get vaseBreaker => 'Vasebreaker';

  @override
  String get zombossMech => 'ZombossMech Battle';

  @override
  String get zombossBattle => 'Zomboss Battle';

  @override
  String get moveSourceSameAsDest => 'Source and target folder are the same';

  @override
  String get moveSuccess => 'Moved successfully';

  @override
  String get moveFail => 'Move failed';

  @override
  String get rootFolder => 'Root';

  @override
  String get createEmptyWave => 'Create empty wave';

  @override
  String get createEmptyWaveContainer => 'Create empty wave container';

  @override
  String get deleteEmptyContainer => 'Delete empty container';

  @override
  String get deleteWaveContainerTitle => 'Delete wave container';

  @override
  String get deleteWaveContainerConfirm =>
      'Are you sure you want to delete the empty wave container? You can create a new one later.';

  @override
  String get noWaveManager => 'Wave Container Not Found';

  @override
  String get noWaveManagerHint =>
      'Wave management is enabled, but the entity object (WaveManagerProperties) is missing. Please create an empty wave container.';

  @override
  String get waveTimelineHint =>
      'Tap an event to edit it, or tap \"+\" to add a new one.';

  @override
  String get waveTimelineHintDetail => 'Swipe left on a wave to delete it.';

  @override
  String get waveTimelineGuideTitle => 'Operation Guide';

  @override
  String get waveTimelineGuideBody =>
      'Swipe right: Manage wave events\nSwipe left: Delete a wave\nTap pt: View spawn expectations';

  @override
  String get waveTimelineGuideBodyDesktop =>
      'Left-click a wave: Manage wave events\nClick delete: Remove a wave\nClick pt: View spawn expectations';

  @override
  String get waveTimelineGuideBodyMobile =>
      'Swipe right: Manage wave events\nSwipe left: Delete a wave\nTap pt: View spawn expectations';

  @override
  String get waveDeadLinksTitle => 'Broken References';

  @override
  String get waveDeadLinksClear => 'Clear dead links';

  @override
  String get customZombieManagerTitle => 'Custom Zombie Management';

  @override
  String get customZombieEmpty => 'No custom zombie data';

  @override
  String get switchCustomZombie => 'Switch custom zombie';

  @override
  String get switchZombie => 'Switch zombie';

  @override
  String get customZombieAppearanceLocation => 'Location:';

  @override
  String get customZombieNotUsed =>
      'This custom zombie is currently not used by any wave or module.';

  @override
  String customZombieWaveItem(int n) {
    return 'Wave $n';
  }

  @override
  String get customZombieDeleteConfirm =>
      'Remove this custom zombie entity and its property data.';

  @override
  String get editCustomZombieProperties => 'Edit custom zombie properties';

  @override
  String get makeZombieAsCustom => 'Make zombie as custom';

  @override
  String get customLabel => 'Custom';

  @override
  String get waveManagerGlobalParams => 'Wave Manager Parameters';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return 'Flag interval: $interval, Next wave health threshold: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => 'No waves yet';

  @override
  String get waveEmptySubtitle =>
      'Add the first wave, or remove this empty container.';

  @override
  String get waveHeaderPreview => 'Content & Points Preview';

  @override
  String waveTotalLabel(int total) {
    return 'Total: $total';
  }

  @override
  String get waveEmptyRowHint => 'Empty wave (swipe left/right)';

  @override
  String get waveEmptyRowHintDesktop => 'Empty wave (click to manage)';

  @override
  String get waveEmptyRowHintMobile => 'Empty wave (swipe left/right)';

  @override
  String get removeFromWave => 'Remove from wave';

  @override
  String get deleteEventEntityTitle => 'Delete event entity?';

  @override
  String get deleteEventEntityBody =>
      'This will remove the event object from the level.';

  @override
  String waveEventsTitle(int wave) {
    return 'Wave $wave events';
  }

  @override
  String get waveManagerSettings => 'Wave Manager Settings';

  @override
  String get flagInterval => 'Flag interval';

  @override
  String get waveManagerHelpTitle => 'Wave Manager';

  @override
  String get waveManagerHelpOverviewTitle => 'Overview';

  @override
  String get waveManagerHelpOverviewBody =>
      'The wave event container organizes level events by wave order. Most levels use it to control zombie spawning. This page allows you to adjust its global settings.';

  @override
  String get waveManagerHelpFlagTitle => 'Flag interval';

  @override
  String get waveManagerHelpFlagBody =>
      'The flag interval determines how often a flag wave appears. The final wave is always a flag wave. Flag waves receive bonus points and have a separate spawn interval.';

  @override
  String get waveManagerHelpTimeTitle => 'Time control';

  @override
  String get waveManagerHelpTimeBody =>
      'The delay before the first wave depends on whether the level uses a conveyor belt: 5 seconds with a conveyor, or 12 seconds without. Flag wave delay refers to the time between the red warning message and zombie spawn.';

  @override
  String get waveManagerHelpMusicTitle => 'Level Jam';

  @override
  String get waveManagerHelpMusicBody =>
      'This setting applies only to the Modern Day world. It sets a fixed global background track that enables abilities for certain Neon Mixtape Tour zombies.';

  @override
  String get waveManagerBasicParams => 'Basic parameters';

  @override
  String get waveManagerMaxHealthThreshold => 'Max next wave health threshold';

  @override
  String get waveManagerMinHealthThreshold => 'Min next wave health threshold';

  @override
  String get waveManagerThresholdHint =>
      'Threshold must be between 0 and 1. When the total remaining health of zombies in the current wave falls below this value, the next wave will spawn automatically.';

  @override
  String get waveManagerTimeControl => 'Time control';

  @override
  String get waveManagerFirstWaveDelayConveyor => 'First wave delay (conveyor)';

  @override
  String get waveManagerFirstWaveDelayNormal => 'First wave delay (normal)';

  @override
  String get waveManagerFlagWaveDelay => 'Flag wave delay';

  @override
  String get waveManagerConveyorDetected =>
      'Conveyor module detected; conveyor delay applied.';

  @override
  String get waveManagerConveyorNotDetected =>
      'No conveyor module; normal delay applied.';

  @override
  String get waveManagerSpecial => 'Special';

  @override
  String get waveManagerSuppressFlagZombieTitle => 'Suppress flag zombie';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint =>
      'When enabled, flag waves won’t spawn a flag zombie.';

  @override
  String get waveManagerLevelJam => 'Level Jam';

  @override
  String get waveManagerLevelJamHint =>
      'Only applies to Modern Day; provides fixed global background track.';

  @override
  String get jamNone => 'None';

  @override
  String get jamPop => 'Pop';

  @override
  String get jamRap => 'Rap';

  @override
  String get jamMetal => 'Metal';

  @override
  String get jamPunk => 'Punk';

  @override
  String get jam8Bit => '8-Bit';

  @override
  String get noWaves => 'No waves';

  @override
  String get addFirstWave => 'Add the first wave.';

  @override
  String get deleteWave => 'Delete';

  @override
  String deleteWaveConfirm(int count) {
    return 'This will remove this wave and its $count events.';
  }

  @override
  String get deleteWaveConfirmCheckbox =>
      'I confirm permanent deletion of this wave';

  @override
  String get addEvent => 'Add event';

  @override
  String get emptyWave => 'Empty wave';

  @override
  String get addWave => 'Add wave';

  @override
  String get expectation => 'Expectation';

  @override
  String get close => 'Close';

  @override
  String get editProperties => 'Edit properties';

  @override
  String get deleteEntity => 'Delete entity';

  @override
  String get deleteObjectTitle => 'Delete object?';

  @override
  String get deleteObjectConfirmMessage =>
      'Remove this object from the level file? This action cannot be undone.';

  @override
  String get objectDeleted => 'Object deleted';

  @override
  String get moduleEditorInProgress => 'Module editor in development';

  @override
  String get dataEmpty => 'Data is empty';

  @override
  String get saveSuccess => 'Save successful';

  @override
  String get saveFail => 'Save failed';

  @override
  String get confirmRemoveRef => 'Remove reference';

  @override
  String get confirmRemoveRefMessage =>
      'Remove this reference? The entity data will remain until all references are removed.';

  @override
  String get deleteEventConfirmCheckbox =>
      'I understand this action cannot be undone';

  @override
  String get noZombiesInLane => 'No zombies in this lane';

  @override
  String get code => 'Code';

  @override
  String get name => 'Level name';

  @override
  String get description =>
      'Level description (supports Chinese; press Enter for line breaks, no escape sequences needed. Note: not visible in Creative Courtyard on iOS)';

  @override
  String get levelNumber => 'Level number';

  @override
  String get startingSun => 'Starting sun';

  @override
  String get stageModule => 'Stage module';

  @override
  String get musicType => 'Music type';

  @override
  String get loot => 'Loot';

  @override
  String get victoryModule => 'Victory module';

  @override
  String get basicInfoSection => 'Basic info';

  @override
  String get sceneSettingsSection => 'Scene Settings';

  @override
  String get restrictionsSection => 'Restrictions';

  @override
  String get victoryModuleWarning =>
      'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.';

  @override
  String get hintTextDisplay => 'Text display (Description)';

  @override
  String get beatTheLevelDialogIntro =>
      'Display hint text in a pop-up at the beginning of the level.';

  @override
  String get beatTheLevelDialogHint =>
      'Supports Chinese; for multi-line text enter newlines directly, no need for \\n. Note: hints cannot be viewed in Creative Courtyard on iOS.';

  @override
  String get levelHintText => 'Level hint text';

  @override
  String get missingModules => 'Missing modules';

  @override
  String get moduleConflict => 'Module conflict';

  @override
  String get conflictTitle_ModuleLogic => 'Module logic conflict';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '$module1 and $module2 conflict logically. It is recommended to keep only one.';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      'Seed Bank and Conveyor modules interfere with each other\'s UI and may cause crashes. Ensure Seed Bank is in Preset mode.';

  @override
  String get conflictDesc_VaseBreakerIntro =>
      'Vasebreaker mode does not need an opening intro.';

  @override
  String get conflictDesc_LastStandIntro =>
      'Last Stand mode does not need an opening intro.';

  @override
  String get conflictDesc_EvilDaveZombieDrop =>
      'I, Zombie mode cannot have Zombie Drop module.';

  @override
  String get conflictDesc_EvilDaveVictory =>
      'I, Zombie mode cannot have Zombie Victory Condition.';

  @override
  String get conflictDesc_ZombossDeathDrop =>
      'Loot Drop in ZombossMech battle mode will prevent proper level completion.';

  @override
  String get conflictDesc_ZombossBattleDeathDrop =>
      'Loot Drop in Zomboss battle mode will prevent proper level completion.';

  @override
  String get conflictDesc_WinConditionExclusive =>
      'Loot Drop and Bronze Matrix Loot Drop do not need to be used together. It is recommended to remove one of them.';

  @override
  String get conflictDesc_ZombossTwoIntros =>
      'Two level opening intros cannot coexist, otherwise Zomboss health bar will not display correctly.';

  @override
  String get conflictDesc_InitialPlantEntryRoof =>
      'Pre-place plants on the roof will cause a crash.';

  @override
  String get conflictDesc_InitialPlantRoof =>
      'Legacy preset plants on the roof will cause a crash.';

  @override
  String get conflictDesc_ProtectPlantRoof =>
      'Endangered plants on the roof will cause a crash.';

  @override
  String get conflictDesc_LawnMowerYard =>
      'Lawn mowers are ineffective when the Creative Courtyard module is enabled.';

  @override
  String get missingPlantModuleWarningTitle =>
      'Missing module for parallel universe plants';

  @override
  String get editableModules => 'Editable modules';

  @override
  String get parameterModules => 'Parameter modules';

  @override
  String get addNewModule => 'Add new module';

  @override
  String get selectStage => 'Select lawn';

  @override
  String get searchStage => 'Search by lawn name or codename';

  @override
  String get noStageFound => 'No lawn found';

  @override
  String get stageTypeAll => 'All';

  @override
  String get stageTypeMain => 'Main';

  @override
  String get stageTypeExtra => 'Extra';

  @override
  String get stageTypeSeasons => 'Seasons';

  @override
  String get stageTypeSpecial => 'Special';

  @override
  String get search => 'Search';

  @override
  String get disablePeavine => 'Disable Pea Vine\'s Pea Symbiosis';

  @override
  String get disableArtifact =>
      'Disable Artifact (auto-applied when Creative Courtyard module is enabled)';

  @override
  String get selectPlant => 'Select plant';

  @override
  String get searchPlant => 'Search plant';

  @override
  String get noPlantFound => 'No plant found';

  @override
  String noResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noModulesInCategory => 'No modules in this category';

  @override
  String addEventForWave(int wave) {
    return 'Add event for wave $wave';
  }

  @override
  String get waveLabel => 'Wave';

  @override
  String get pointsLabel => 'Points';

  @override
  String get noDynamicZombies => 'No dynamic zombies';

  @override
  String get moduleTitle_WaveManagerModuleProperties => 'Wave Manager';

  @override
  String get moduleDesc_WaveManagerModuleProperties =>
      'Manages overall wave event configuration for the level';

  @override
  String get moduleTitle_CustomLevelModuleProperties =>
      'Creative Courtyard Module';

  @override
  String get moduleDesc_CustomLevelModuleProperties =>
      'Enables Creative Courtyard features (likes, rewards, costume feature disabling, etc.)';

  @override
  String get powerTileModuleRequiredTitle => 'Power Tiles module required';

  @override
  String get powerTileModuleRequiredBody =>
      'Adding Power Tile tool packets requires the level to include the Power Tile module. Add the module and continue?';

  @override
  String get conveyorPlantWearCostume => 'Display costume (iAvatar)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      'When enabled, this plant’s packet on the conveyor belt will display its costume. This feature does not work when the Creative Courtyard module is enabled.';

  @override
  String get modifyConveyorAddPoolTitle => 'Add to Conveyor Pool';

  @override
  String get modifyConveyorAddPoolEmpty =>
      'The list is empty. Please add plants or tool packets.';

  @override
  String get modifyConveyorRemovePoolTitle =>
      'Remove from Conveyor Pool (doesn\'t work when Creative Courtyard module is enabled)';

  @override
  String get modifyConveyorEntryEditTitle => 'Edit parameters';

  @override
  String get moduleTitle_UnchartedModeNo42UniverseModule =>
      'Parallel Universe Module';

  @override
  String get moduleDesc_UnchartedModeNo42UniverseModule =>
      'Enables Parallel Universe plants (No.41 & No.42)';

  @override
  String get moduleTitle_PVZ2MausoleumModuleUnchartedMode =>
      'Underground Palace Module';

  @override
  String get moduleDesc_PVZ2MausoleumModuleUnchartedMode =>
      'Enables plants featured in the Underground Palace realm';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return 'In order to select this plant, $moduleName needs to be added.';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle => 'Cannot select plant';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      'Realm-exclusive plants cannot be selected in Chooser Mode. To use them, please refer to other methods such as Preset Mode, Conveyor Belt, or Packet Drops.';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return 'Missing module $moduleName for plants: $plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => 'Intro Animation';

  @override
  String get moduleDesc_StandardLevelIntroProperties =>
      'Camera pan at the start of the level';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => 'Loss Condition';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties =>
      'Position where zombies entering the house triggers defeat';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => 'Loot Drop';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties =>
      'Required module for level stability';

  @override
  String get moduleTitle_BronzeDeadWinConProperties =>
      'Bronze Matrix Loot Drop';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      'Instantly eliminates all other zombies on the lawn once all bronze statues and gargantuar bronzes are defeated';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => 'Whale Approaching';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      'Configures whale-related parameters for Underwater World levels, requires krill to be present on the lawn to take effect';

  @override
  String get spermWhaleModuleTitle => 'Whale Approaching Settings';

  @override
  String get spermWhaleModuleHelpTitle => 'Whale Approaching';

  @override
  String get spermWhaleModuleParameters => 'Parameters';

  @override
  String get spermWhaleModuleHelpOverview => 'Overview';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      'This module is used to configure parameters related to the special marine creature \"Whale\", and is typically used in Underwater World levels. As krill begin appearing, the whale will circle above the lawn and trigger the corresponding red subtitle warning. Once at least 3 krill are present on the lawn, the whale will officially appear in the upper-left corner of the lawn. The whale will prioritize swallowing existing krill before continuously sucking up and swallowing plants on the lawn. The rotenone released by Puffy Derris can be inhaled by the whale; after the first inhalation, the whale’s swallowing speed will decrease. Once the number of inhalations reaches the configured rotenone trigger count, the whale will be forced to retreat. Note that the whale can only appear once per level.';

  @override
  String get spermWhaleModuleHelpFieldsTitle => 'Parameter Overview';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      'Swallow Interval (SwallowInterval) refers to the interval between the whale’s swallowing actions under normal conditions.\nPoisoned Swallow Interval (PoisonSwallowInterval) refers to the interval between swallowing actions after the whale inhales rotenone once.\nSwallow Duration (SwallowDuration) refers to the total amount of time the whale remains on the lawn sucking up and swallowing plants.\nPoison Trigger Count (PoisonTriggerCount) refers to the number of rotenone inhalations required to force the whale to retreat.';

  @override
  String get spermWhaleModuleSwallowInterval =>
      'Swallow Interval (SwallowInterval, unit: seconds)';

  @override
  String get spermWhaleModuleHelpSwallowInterval =>
      'The interval between two swallowing actions under normal conditions.';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      'Rotenone Swallow Interval (PoisonSwallowInterval, unit: seconds)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval =>
      'The interval between two swallowing actions after the whale inhales rotenone.';

  @override
  String get spermWhaleModuleSwallowDuration =>
      'Swallow Duration (SwallowDuration, unit: seconds)';

  @override
  String get spermWhaleModuleHelpSwallowDuration =>
      'The total duration the whale remains on the lawn sucking up and swallowing plants.';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      'Rotenone trigger count (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      'The cumulative number of rotenone inhalations required to force the whale to retreat.';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      'This module is recommended for use in Underwater World lawns. The grid belows only reflects the current lawn configuration; using this module on non-20,000 Leagues Under the Sea/Atlantis lawns may cause compatibility issues.';

  @override
  String get spermWhaleModuleLawnPreview => 'Lawn Preview';

  @override
  String get spermWhaleModuleLawnPreviewHint =>
      'Underwater World levels use a 6×10 lawn layout, while other levels use a 5×9 layout';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => 'Tier Definition';

  @override
  String get moduleDesc_PennyClassroomModuleProperties =>
      'Globally defines plant tiers, overrides other modules';

  @override
  String get moduleTitle_SeedBankProperties => 'Seed Bank';

  @override
  String get moduleDesc_SeedBankProperties =>
      'Presets seed slots and seed selection mode';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => 'Conveyor Belt';

  @override
  String get moduleDesc_ConveyorSeedBankProperties =>
      'Presets conveyor belt plant types and weights';

  @override
  String get moduleTitle_SunDropperProperties => 'Sun Dropper';

  @override
  String get moduleDesc_SunDropperProperties =>
      'Controls falling sun frequency';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => 'Max Sun Limit';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps =>
      'Overrides the maximum sun limit value';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps =>
      'Starting Plant Food';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps =>
      'Overrides starting Plant Food amount';

  @override
  String get moduleTitle_StarChallengeModuleProperties => 'Challenge Module';

  @override
  String get moduleDesc_StarChallengeModuleProperties =>
      'Sets level restrictions and objectives';

  @override
  String get starChallengeNoConfigTitle => 'Challenge';

  @override
  String get starChallengeNoConfigMessage =>
      'This challenge has no configurable parameters.';

  @override
  String get starChallengeSaveMowersTitle => 'Don\'t lose any lawn mowers';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      'This challenge has no configurable parameters.\n\nTo complete it, all lawn mowers must remain intact. Note that lawn mowers are not available by default when the Creative Courtyard module is enabled.';

  @override
  String get starChallengePlantFoodNonuseTitle => 'Don\'t use Plant Food';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      'This challenge has no configurable parameters.\n\nPlant Food cannot be used.';

  @override
  String get moduleTitle_LevelScoringModuleProperties => 'Scoring Module';

  @override
  String get moduleDesc_LevelScoringModuleProperties =>
      'Enables scoring system based on zombie kills';

  @override
  String get moduleTitle_BowlingMinigameProperties => 'Bulb Bowling';

  @override
  String get moduleDesc_BowlingMinigameProperties =>
      'Sets no-planting line and disable shovel';

  @override
  String get moduleTitle_NewBowlingMinigameProperties => 'Wall-nut Bowling';

  @override
  String get moduleDesc_NewBowlingMinigameProperties =>
      'Draws bowling warning line at a fixed position';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => 'Vase Layout';

  @override
  String get moduleDesc_VaseBreakerPresetProperties =>
      'Configures vase contents (requires 2 additional modules to function)';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties =>
      'Vasebreaker Mode';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      'Enable environment and UI for Vasebreaker';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => 'Vase Animation';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties =>
      'Controls the falling animation of vases at start';

  @override
  String get moduleTitle_EvilDaveProperties => 'I, Zombie Mode';

  @override
  String get moduleDesc_EvilDaveProperties =>
      'Enable I, Zombie mode (requires zombie bank and preset plants)';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => 'ZombossMech Battle';

  @override
  String get moduleDesc_ZombossBattleModuleProperties =>
      'Configures ZombossMech parameters and types';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => 'ZombossMech Intro';

  @override
  String get moduleDesc_ZombossBattleIntroProperties =>
      'Controls ZombossMech cutscenes and health bar display';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties => 'Zomboss Battle';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      'Configures non-mech Zomboss last-stand battles (Kongfu, Qin, etc.)';

  @override
  String get moduleTitle_SeedRainProperties => 'It\'s Raining Seeds';

  @override
  String get moduleDesc_SeedRainProperties =>
      'Controls plants, zombies or Plant Food falling from the sky';

  @override
  String get moduleTitle_LastStandMinigameProperties => 'Last Stand';

  @override
  String get moduleDesc_LastStandMinigameProperties =>
      'Sets initial resources and enables setup phase';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties =>
      'Column Like You See \'Em';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties =>
      'Planting a seed packet fills its column (best used with conveyor belt)';

  @override
  String get moduleTitle_SunBombChallengeProperties => 'Sun Bombs';

  @override
  String get moduleDesc_SunBombChallengeProperties =>
      'Configures explosion range and damage of falling sun';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => 'Inflation';

  @override
  String get moduleDesc_IncreasedCostModuleProperties =>
      'Sun cost increases each time the same plant is planted';

  @override
  String get moduleTitle_DeathHoleModuleProperties => 'Death Craters';

  @override
  String get moduleDesc_DeathHoleModuleProperties =>
      'Plants leave craters when destroyed';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => 'Fast Entry';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties =>
      'Zombies move faster on entry';

  @override
  String get moduleTitle_InitialPlantProperties => 'Legacy Preset Plants';

  @override
  String get moduleDesc_InitialPlantProperties =>
      'The legacy method for preset plants, supports placing frozen plants';

  @override
  String get moduleTitle_InitialPlantEntryProperties => 'Preset Plants';

  @override
  String get moduleDesc_InitialPlantEntryProperties =>
      'Plants existing on the lawn at the start';

  @override
  String get frozenPlantPlacementTitle => 'Legacy Preset Plants';

  @override
  String get frozenPlantPlacementLastStand => 'Intensive Battle mode';

  @override
  String get frozenPlantPlacementSelectedPosition => 'Selected position';

  @override
  String get frozenPlantPlacementPlaceHere => 'Add plant';

  @override
  String get frozenPlantPlacementPlantList => 'Plant(s) in selected tile';

  @override
  String frozenPlantPlacementEditPlant(Object name) {
    return 'Edit $name';
  }

  @override
  String get frozenPlantPlacementLevel => 'Level';

  @override
  String get frozenPlantPlacementCondition => 'Condition';

  @override
  String get frozenPlantPlacementConditionNull => 'None (null)';

  @override
  String get noConditions => 'No conditions';

  @override
  String get frozenPlantPlacementHelpTitle => 'Legacy Preset Plants';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => 'Overview';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      'This module configures plant layout before the level starts. Similar to preset plant layout but with a different structure and special state support.';

  @override
  String get frozenPlantPlacementHelpConditionTitle => 'Special State';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      'Plants can be set to frozen state (icecubed), commonly used in Frostbite Caves levels.';

  @override
  String get frozenPlantPlacementHelpLastStandTitle => 'Intensive Battle Mode';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      'When Intensive Battle mode is enabled, initial plants will be incinerated after the game starts. Note that Chinese version does not have the burn animation.';

  @override
  String get save => 'Save';

  @override
  String get moduleTitle_InitialZombieProperties => 'Preset Zombies';

  @override
  String get moduleDesc_InitialZombieProperties =>
      'Zombies existing on the lawn at the start';

  @override
  String get moduleTitle_InitialGridItemProperties => 'Preset Grid Items';

  @override
  String get moduleDesc_InitialGridItemProperties =>
      'Grid items existing on the lawn at the start';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties => 'Save Our Seeds';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties =>
      'Sets specific plants that must be protected';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties =>
      'Save Our Items';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      'Sets grid items that must be protected from destruction';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => 'Dark Alchemy';

  @override
  String get moduleDesc_ZombiePotionModuleProperties =>
      'Dark Ages potion generation mechanics';

  @override
  String get moduleTitle_PiratePlankProperties => 'Pirate Planks';

  @override
  String get moduleDesc_PiratePlankProperties =>
      'Configures plank rows for Pirate Seas lawn';

  @override
  String get moduleTitle_RailcartProperties => 'Minecart and Rail';

  @override
  String get moduleDesc_RailcartProperties =>
      'Configures the initial layout of minecarts and rails';

  @override
  String get moduleTitle_PowerTileProperties => 'Power Tiles';

  @override
  String get moduleDesc_PowerTileProperties =>
      'Configures Plant Food link effects and tile layout';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => 'Manhole Pipeline';

  @override
  String get moduleDesc_ManholePipelineModuleProperties =>
      'Configures Steam Ages transportation sewers';

  @override
  String get moduleTitle_RoofProperties => 'Roof Pots';

  @override
  String get moduleDesc_RoofProperties =>
      'Configures preset Flower Pots for Roof levels';

  @override
  String get moduleTitle_TideProperties => 'Tide System';

  @override
  String get moduleDesc_TideProperties =>
      'Enable tide system (should be added last)';

  @override
  String get moduleTitle_BombProperties => 'Powder Keg';

  @override
  String get moduleDesc_BombProperties =>
      'Configures the fuse length and burn rate of Kongfu World powder kegs';

  @override
  String get moduleTitle_BronzeProperties => 'Bronze Matrix Statues';

  @override
  String get moduleDesc_BronzeProperties =>
      'Configures Kongfu World bronze statues';

  @override
  String get bronzeModuleTitle => 'Bronze Matrix Statues';

  @override
  String get bronzeModuleHelpTitle => 'Bronze Matrix Statues';

  @override
  String get bronzeModuleHelpOverview => 'Overview';

  @override
  String get bronzeModuleHelpOverviewBody =>
      'This module is used to place bronze statue grid items on the lawn that exist at the start of the level, commonly used in the Kongfu World brain buster \"Bronze Matrix\". Bronze statues gradually lose their copper coating over time and will revive as gargantuar bronzes when the specified countdown ends. The HP of a bronze statue is the same as the corresponding Tier 1 Gargantuar Bronze.\nShake offset (shakeOffset) indicates the center offset of the revive animation’s shaking; adjusting this value has no practical effect.\nNote: This module itself does not include the effect of instantly eliminating remaining zombies after all bronze statues and gargantuar bronzes on the lawn are destroyed. To achieve that effect, the Bronze Matrix Loot Drop module must be added.';

  @override
  String get bronzeModuleHelpBatches => 'Revival Logic';

  @override
  String get bronzeModuleHelpBatchesBody =>
      'Each bronze statue added generates a corresponding entry in the level file. Revival timing is determined by the spawn time (spawnTime), in seconds, and is independent of waves. Bronze statues with the same spawn time will revive simultaneously.\nThe revival countdown for subsequent batches is offset from the first batch. For example, if the first batch is set to 30s, the second to 45s, and the third to 50s, then the second batch will revive 15s after the first, and the third batch 5s after the second.';

  @override
  String get bronzeModuleShakeOffset => 'Animation';

  @override
  String get bronzeModuleShakeOffsetLabel => 'Shake offset';

  @override
  String get bronzeModuleInCell => 'Bronze statue(s) in selected tile';

  @override
  String get bronzeModuleAddTitle => 'Add bronze statue';

  @override
  String get bronzeKindStrength => 'Han Bronze (strength)';

  @override
  String get bronzeKindMage => 'Qigong Bronze (mage)';

  @override
  String get bronzeKindAgile => 'Xiake Bronze (agile)';

  @override
  String get bronzeKindStrengthShort => 'Han Bronze';

  @override
  String get bronzeKindMageShort => 'Qigong Bronze';

  @override
  String get bronzeKindAgileShort => 'Xiake Bronze';

  @override
  String get bronzeModuleTypeLabel => 'Type';

  @override
  String get bronzeModuleSpawnTimeLabel => 'Revival time (seconds)';

  @override
  String get moduleTitle_WarMistProperties => 'Fog System';

  @override
  String get moduleDesc_WarMistProperties =>
      'Configures Dark Ages fog coverage and interaction';

  @override
  String get moduleTitle_RainDarkProperties => 'Weather';

  @override
  String get moduleDesc_RainDarkProperties =>
      'Sets rain, snow, and lightning effects';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps => 'Ground Spawner';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps =>
      'Spawns zombies from underground';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => 'Basic Spawner';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps =>
      'Standard natural zombie spawning event';

  @override
  String get eventTitle_FrostWindWaveActionProps => 'Freezing Wind';

  @override
  String get eventDesc_FrostWindWaveActionProps =>
      'Blows freezing wind on specific rows';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps => 'Low Tide';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps =>
      'Zombies emerge during low tide';

  @override
  String get eventTitle_TidalChangeWaveActionProps => 'Tide Change';

  @override
  String get eventDesc_TidalChangeWaveActionProps =>
      'Changes the tide position';

  @override
  String get eventTitle_TideWaveWaveActionProps => 'Ocean Current';

  @override
  String get eventDesc_TideWaveWaveActionProps =>
      'Moves submarine and affects zombie movement speed';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => 'Underwater Spawner';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      'Spawns zombies or sea creatures from the left or right side of the lawn; can only be used in Underwater World';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => 'Conveyor Change';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps =>
      'Dynamically adds or removes conveyor plants';

  @override
  String get eventTitle_DinoWaveActionProps => 'Dino Summon';

  @override
  String get eventDesc_DinoWaveActionProps =>
      'Summons a dinosaur to assist zombies';

  @override
  String get eventTitle_DinoTreadActionProps => 'Dino Stomp';

  @override
  String get eventDesc_DinoTreadActionProps =>
      'Brachiosaurus stomps within a set area, dealing damage';

  @override
  String get eventTitle_DinoRunActionProps => 'Dino Stampede';

  @override
  String get eventDesc_DinoRunActionProps =>
      'Dinosaurs charge down their lane, trampling plants and zombies';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps => 'Spacetime Portal';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps =>
      'Summons spacetime portals at specific locations';

  @override
  String get eventTitle_StormZombieSpawnerProps => 'Storm Raid';

  @override
  String get eventDesc_StormZombieSpawnerProps =>
      'Sandstorms or snowstorms bring in zombies';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => 'Raiding Party';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps =>
      'Summons multiple Swashbuckler Zombies';

  @override
  String get eventTitle_ZombiePotionActionProps => 'Potion Drop';

  @override
  String get eventDesc_ZombiePotionActionProps =>
      'Force spawns grid items at set positions';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => 'Seashell Spawn';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps =>
      'Spawns atlantis seashells at set positions';

  @override
  String get eventTitle_PumpkinHouseActionProps => 'Pumpkin House Spawn';

  @override
  String get eventDesc_PumpkinHouseActionProps =>
      'Spawns pumpkin houses on the lawn at set positions';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => 'Grid Item Spawn';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps =>
      'Spawns grid items on empty tiles';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps =>
      'Grid Item Spawner';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps =>
      'Spawns zombies from specific grid items';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => 'Magic Fog';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps =>
      'Creates fog that covers the lawn and grants shields to zombies';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => 'Fairytale Breeze';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps =>
      'Blows away all Magic Fog on the lawn';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps => 'Imp Rain';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps =>
      'Imps drop in from above';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => 'Parachute Rain';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps =>
      'Zombies drop in by parachute';

  @override
  String get eventTitle_BassRainZombieSpawnerProps => 'Bass/Jetpack Rain';

  @override
  String get eventDesc_BassRainZombieSpawnerProps =>
      'Jetpack or Bass Zombies drop in from above';

  @override
  String get eventTitle_BlackHoleWaveActionProps => 'Black Hole';

  @override
  String get eventDesc_BlackHoleWaveActionProps =>
      'Generates a black hole to pull all plants';

  @override
  String get eventTitle_BarrelWaveActionProps => 'Barrel Crisis';

  @override
  String get eventDesc_BarrelWaveActionProps =>
      'Spawns barrels with different abilities in set lanes';

  @override
  String get eventTitle_SchoolBusWaveActionProps => 'Ice Cream Van Spawn';

  @override
  String get eventDesc_SchoolBusWaveActionProps =>
      'Spawns an ice cream van in a lane and configures the zombies inside';

  @override
  String get eventTitle_BungeeWaveActionProps => 'Bungee Drop';

  @override
  String get eventDesc_BungeeWaveActionProps =>
      'Drops a zombie by bungee to the lawn';

  @override
  String get eventTitle_ThunderWaveActionProps => 'Thundercloud Storm';

  @override
  String get eventDesc_ThunderWaveActionProps =>
      'Lightning strikes, applying positive or negative charges to plants';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => 'Magic Mirror';

  @override
  String get eventDesc_MagicMirrorWaveActionProps =>
      'Generates paired teleportation mirrors';

  @override
  String get weatherOption_DefaultSnow_label =>
      'Glacial Snowfall (DefaultSnow)';

  @override
  String get weatherOption_DefaultSnow_desc =>
      'Snowfall effect used in Frostbite Caves Resurgence';

  @override
  String get weatherOption_LightningRain_label =>
      'Thunderstorm (LightningRain)';

  @override
  String get weatherOption_LightningRain_desc =>
      'Rain with lightning strikes that are purely visual';

  @override
  String get weatherOption_DefaultRainDark_label =>
      'Dark Rain (DefaultRainDark)';

  @override
  String get weatherOption_DefaultRainDark_desc =>
      'Briefly covers the lawn in darkness before returning to normal';

  @override
  String get iZombiePlantReserveLabel =>
      'Reserved Plant Column (PlantDistance)';

  @override
  String get column => 'Column(s)';

  @override
  String get iZombieInfoText =>
      'In I, Zombie Mode, preset plants and zombies must be configured in the Preset Plants and Seed Bank modules respectively.';

  @override
  String get vaseRangeTitle => 'Vase Spawn Range & Disabled Tiles';

  @override
  String get startColumnLabel => 'Start Col (Min)';

  @override
  String get endColumnLabel => 'End Col (Max)';

  @override
  String get toggleBlacklistHint =>
      'Tap tiles to toggle disabled status (vases will not spawn on disabled tiles)';

  @override
  String get vaseCapacityTitle => 'Vase Capacity';

  @override
  String vaseCapacitySummary(Object current, Object total) {
    return 'Assigned: $current / Total Slots: $total';
  }

  @override
  String get vaseListTitle => 'Vase List';

  @override
  String get addVaseTitle => 'Add Vase';

  @override
  String get plantVaseOption => 'Plant Vase (Green)';

  @override
  String get zombieVaseOption => 'Zombie Vase (Purple)';

  @override
  String get selectZombie => 'Select zombie';

  @override
  String get searchZombie => 'Search zombie';

  @override
  String get noZombieFound => 'No zombie found';

  @override
  String get unknownVaseLabel => 'Unknown Vase';

  @override
  String get plantLabel => 'Plant';

  @override
  String get zombieLabel => 'Zombie';

  @override
  String get itemLabel => 'Item';

  @override
  String get railcartSettings => 'Minecart and Rail Settings';

  @override
  String get railcartType => 'Minecart type';

  @override
  String get layRails => 'Lay rails';

  @override
  String get placeCarts => 'Place minecarts';

  @override
  String get railSegments => 'Rail segment';

  @override
  String get railcartCount => 'Railcart count';

  @override
  String get clearAll => 'Clear all';

  @override
  String get moduleCategoryBase => 'Basic';

  @override
  String get moduleCategoryMode => 'Special Modes';

  @override
  String get moduleCategoryScene => 'Scene Config';

  @override
  String get moduleCategoryGimmick => 'Gimmick Config';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties => 'Rocket Flick';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      'Enables swiping to knock Rocket Imps off their rockets';

  @override
  String get kongfuRocketFlickDialogTitle => 'This Module Can Be Added';

  @override
  String get kongfuRocketFlickDialogMessage =>
      'The \"Rocket Flick\" module lets you swipe rockets on the screen to knock Rocket Imps off them. Add this module?';

  @override
  String get customZombie => 'Custom zombie';

  @override
  String get customZombieProperties => 'Custom Zombie Properties';

  @override
  String get zombieTypeNotFound => 'Zombie type object not found.';

  @override
  String get propertyObjectNotFound => 'Property object not found';

  @override
  String propertyObjectNotFoundHint(Object alias) {
    return 'The custom zombie\'s property object ($alias) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.';
  }

  @override
  String get baseStats => 'Base stats';

  @override
  String get hitpoints => 'Health (Hitpoints)';

  @override
  String get speed => 'Movement speed (Speed)';

  @override
  String get speedVariance => 'Speed variance (Variance)';

  @override
  String get eatDPS => 'Bite damage per second (EatDPS)';

  @override
  String get hitPosition => 'Hit & Position';

  @override
  String get hitRect => 'Hitbox (HitRect)';

  @override
  String get editHitRect => 'Edit Hitbox (HitRect)';

  @override
  String get attackRect => 'Eating Range (AttackRect)';

  @override
  String get editAttackRect => 'Edit Eating Range (AttackRect)';

  @override
  String get artCenter => 'Sprite Center (ArtCenter)';

  @override
  String get editArtCenter => 'Edit Sprite Center (ArtCenter)';

  @override
  String get shadowOffset => 'Shadow Offset (ShadowOffset)';

  @override
  String get editShadowOffset => 'Edit Shadow Offset (ShadowOffset)';

  @override
  String get groundTrackName => 'Movement Track (GroundTrackName)';

  @override
  String get groundTrackNormal => 'Normal ground (ground_swatch)';

  @override
  String get groundTrackNone => 'None (null)';

  @override
  String get appearanceBehavior => 'Appearance & Behavior';

  @override
  String get sizeType => 'Zombie Size (SizeType)';

  @override
  String get selectSize => 'Select size';

  @override
  String get disableDropFractions => 'Disable corpse HP (headDropFraction)';

  @override
  String get immuneToKnockback => 'Immune to knockback (CanBeLaunchedByPlants)';

  @override
  String get showHealthBarOnDamage =>
      'Show health bar on damage (EnableShowHealthBar)';

  @override
  String get drawHealthBarTime => 'Health bar duration (DrawHealthBarTime)';

  @override
  String get enableEliteScale => 'Enable elite scaling (EnableEliteScale)';

  @override
  String get eliteScale => 'Scale (EliteScale)';

  @override
  String get enableEliteImmunities =>
      'Enable elite immunities (EnableEliteImmunities)';

  @override
  String get canSpawnPlantFood => 'Can drop Plant Food (CanSpawnPlantFood)';

  @override
  String get canSurrender =>
      'Can die immediately at the end if no other zombies remain (CanSurrender)';

  @override
  String get canTriggerZombieWin =>
      'Triggers game over when reaching the house (CanTriggerZombieWin)';

  @override
  String get resilience => 'Resistances (Resistences)';

  @override
  String get resilienceArmor => 'Resilience Bar';

  @override
  String get enableResilience => 'Enable resilience';

  @override
  String get resilienceSource => 'Source';

  @override
  String get resiliencePreset => 'Preset';

  @override
  String get resilienceCustom => 'Custom';

  @override
  String get resiliencePresetSelect => 'Selected resilience preset';

  @override
  String get resilienceAmount => 'Resilience value (Amount)';

  @override
  String get resilienceWeakType => 'Resilience type (WeakType)';

  @override
  String get resilienceRecoverSpeed =>
      'Resilience bar recovery speed (RecoverSpeed)';

  @override
  String get resilienceDamageThresholdPerSecond =>
      'Zombie damage threshold per second (DamageThresholdPerSecond)';

  @override
  String get resilienceBaseDamageThreshold =>
      'Resilience base damage threshold (ResilienceBaseDamageThreshold)';

  @override
  String get resilienceExtraDamageThreshold =>
      'Resilience extra damage threshold (ResilienceExtraDamageThreshold)';

  @override
  String get resilienceCodename => 'Resilience codename (aliases)';

  @override
  String get resilienceCodenameHint => 'e.g. CustomResilience0';

  @override
  String get resistances => 'Resistances';

  @override
  String get zombieResilience => 'Armor / Resilience';

  @override
  String get resilienceEnable => 'Enable armor';

  @override
  String get weakTypeExplosive => 'Explosive';

  @override
  String get instantKillResistance =>
      'Instant kill resistance (chance to ignore instant kill effects)';

  @override
  String get resiliencePhysics => 'Physics';

  @override
  String get resiliencePoison => 'Poison';

  @override
  String get resilienceElectric => 'Electric';

  @override
  String get resilienceMagic => 'Magic';

  @override
  String get resilienceIce => 'Ice';

  @override
  String get resilienceFire => 'Fire';

  @override
  String get resilienceHint =>
      'Value range: 0.0–1.0 (0.0 = no resistance, 1.0 = full immunity)';

  @override
  String zombieTypeLabel(Object type) {
    return 'Zombie type: $type';
  }

  @override
  String propertyAliasLabel(Object alias) {
    return 'Property alias: $alias';
  }

  @override
  String get ok => 'OK';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get customZombieHelpIntro => 'Brief introduction';

  @override
  String get customZombieHelpIntroBody =>
      'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.';

  @override
  String get customZombieHelpBase => 'Base properties';

  @override
  String get customZombieHelpBaseBody =>
      'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.';

  @override
  String get customZombieHelpHit => 'Hit/position';

  @override
  String get customZombieHelpHitBody =>
      'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track as none lets the zombie walk in place.';

  @override
  String get customZombieHelpManual => 'Manual editing';

  @override
  String get customZombieHelpManualBody =>
      'Custom injection auto-fills all properties from game files. You can further edit the JSON file manually if needed.';

  @override
  String editAlias(Object alias) {
    return 'Edit $alias';
  }

  @override
  String get aliasLabel => 'Alias';

  @override
  String get add => 'Add';

  @override
  String get overview => 'Overview';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get weight => 'Weight';

  @override
  String get maxCount => 'Max count';

  @override
  String get startColumn => 'Start column';

  @override
  String get endColumn => 'End column';

  @override
  String get removeItem => 'Remove item';

  @override
  String removeItemConfirm(Object name) {
    return 'Remove $name?';
  }

  @override
  String groupN(int n) {
    return 'Group $n';
  }

  @override
  String rowN(int n) {
    return 'Row $n';
  }

  @override
  String get addItem => 'Add item';

  @override
  String get addWind => 'Add wind';

  @override
  String get addDropItem => 'Add drop item';

  @override
  String get addMirrorGroup => 'Add a mirror group above';

  @override
  String pipeN(int n) {
    return 'Pipe $n';
  }

  @override
  String get setStart => 'Set entrance sewer';

  @override
  String get setEnd => 'Set exit sewer';

  @override
  String get collectable => 'Collectible (Plant Food)';

  @override
  String get selectGridItem => 'Select grid item';

  @override
  String get addItemTitle => 'Add item';

  @override
  String get initialPlantLayout => 'Initial plant layout';

  @override
  String get gridItemLayout => 'Grid item layout';

  @override
  String get zombieCount => 'Total count (Total)';

  @override
  String get groupSize => 'Zombies per group (GroupSize)';

  @override
  String get timeBetweenGroups => 'Group Interval (TimeBetweenGroups; seconds)';

  @override
  String get timeBeforeSpawn => 'Time before full spawn (seconds)';

  @override
  String get waterBoundaryColumn => 'Column Offset (ChangeAmount)';

  @override
  String get columnsDragged => 'Columns dragged (ColNumPlantIsDragged)';

  @override
  String get typeIndex => 'Mirror Appearance (TypeIndex)';

  @override
  String get noStyle => 'No style';

  @override
  String styleN(int n) {
    return 'Style $n';
  }

  @override
  String get existDurationSec => 'Exist duration (sec)';

  @override
  String get mirror1 => 'Mirror 1';

  @override
  String get mirror2 => 'Mirror 2';

  @override
  String get ignoreGravestone => 'Ignore tombstone (IgnoreGraveStone)';

  @override
  String zombiePreview(Object name) {
    return '$name - Zombie preview';
  }

  @override
  String get weatherSettings => 'Weather Settings';

  @override
  String get holeLifetimeSeconds => 'Crater duration (seconds)';

  @override
  String get startingWaveLocation =>
      'Initial tide position (StartingWaveLocation)';

  @override
  String get rainIntervalSeconds => 'Drop interval (seconds)';

  @override
  String get startingPlantFood => 'Starting Plant Food';

  @override
  String get bowlingFoulLine => 'No-planting line';

  @override
  String get bowlingMinigameParams => 'Parameters';

  @override
  String get bowlingMinigameHelpOverview =>
      'Sets the column index of the no-planting line for bulb bowling levels. Plants cannot be placed at or beyond this column.';

  @override
  String get bowlingMinigameHelpFoulLine =>
      'BowlingFoulLine is a 0-based column index from the left edge of the lawn. Zombies and bowling bulbs interact with plants to the right of this line.';

  @override
  String get stopColumn => 'Stop column (StopColumn, range: 0-9 or 0-10)';

  @override
  String get speedUp => 'Speed multiplier (SpeedUp)';

  @override
  String get baseCostIncreased =>
      'Sun cost increase per planting (BaseCostIncreased)';

  @override
  String get maxIncreasedCount => 'Max Cost Increase Count (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => 'Initial fog column';

  @override
  String get normalValueX =>
      'Extension distance to the right (1 tile = 64 units)';

  @override
  String get bloverEffectInterval => 'Blover effect interval (seconds)';

  @override
  String get dinoType => 'Dinosaur type';

  @override
  String get dinoRowTitle => 'Row';

  @override
  String dinoRow(int n) {
    return 'Row: $n';
  }

  @override
  String get dinoWaveDuration => 'Stay duration (waves)';

  @override
  String get eventHelpDinoType =>
      'Which dinosaur enters the lawn. Each species has different behavior when assisting zombies.';

  @override
  String get eventHelpDinoRow =>
      'Row where the dinosaur appears, counted from the top (0-based). On deep-sea lawns, row 5 is also available.';

  @override
  String get eventHelpDinoWaveDuration =>
      'How many waves the dinosaur stays on the lawn before leaving.';

  @override
  String get unknownModuleTitle => 'Module editor in development';

  @override
  String get unknownModuleHelpTitle => 'Unknown module';

  @override
  String get unknownModuleHelpBody =>
      'This module is not registered in the level interpreter. It may be manually modified objclass.';

  @override
  String get noEditorForModule => 'No editor available for this module';

  @override
  String get noEditorForModuleBody =>
      'This module is not registered in the level interpreter, so no editor is available. It may also be due to the module\'s objclass being manually modified, preventing it from being read correctly.';

  @override
  String get invalidEventTitle => 'Invalid event';

  @override
  String get invalidEventBody => 'This event object could not be parsed.';

  @override
  String get invalidReference => 'Invalid reference';

  @override
  String aliasNotFound(Object alias) {
    return 'Alias \"$alias\" not found';
  }

  @override
  String invalidRefBody(int wave) {
    return 'Wave $wave references this event, but no corresponding entity definition was found in the level. This is usually caused by accidental deletion or manual renaming. Keeping it in the level may cause the game to crash.';
  }

  @override
  String get removeInvalidRef =>
      'Remove this invalid reference from the wave container';

  @override
  String get spawnCount => 'Spawn count';

  @override
  String get columnRangeTiming => 'Column range & timing';

  @override
  String get waveStartMessage => 'Red warning message';

  @override
  String get zombieTypeZombieName => 'Zombie Settings';

  @override
  String get optional =>
      'Shown at the center when the event starts; Chinese input not supported';

  @override
  String get eventHelpBeachStageBody =>
      'Zombies emerge from beneath the water. Commonly used for Snorkel Zombies in Big Wave Beach or for zombies that appear during low tide.\nSimilar to Parachute Rain, zombies will spawn in batches. You can specify the total number and spawn range.\nOnly one type of zombie can be used per event. To include multiple types, you need to add multiple events.';

  @override
  String get eventHelpTidalChangeBody =>
      'This event is used to change the tide position during the selected wave. The range of tide changes cannot exceed the bounds of the lawn.';

  @override
  String get eventTideWave => 'Event: Ocean Currents';

  @override
  String get eventHelpTideWaveBody =>
      'Creates ocean currents that push the submarine and grant speed boosts to zombies. Commonly used in Underwater World – 20,000 Leagues Under the Sea levels.';

  @override
  String get tideWaveHelpType => 'Direction';

  @override
  String get eventHelpTideWaveType =>
      'Left: Currents come from the left, pushing the submarine right and speeding up zombies on the left side.\nRight: Currents come from the right, pushing the submarine left and speeding up zombies on the right side.';

  @override
  String get tideWaveHelpParams => 'Notes';

  @override
  String get eventHelpTideWaveParams =>
      'Unless otherwise specified, the submarine returns to its original position after the duration ends. Plants cannot be planted on the submarine while it is moving.';

  @override
  String get tideWaveType => 'Direction (Type)';

  @override
  String get tideWaveTypeLeft => 'Left';

  @override
  String get tideWaveTypeRight => 'Right';

  @override
  String get tideWaveDuration => 'Duration';

  @override
  String get tideWaveSubmarineMovingDistance =>
      'Submarine moving distance (columns)';

  @override
  String get tideWaveSpeedUpDuration => 'Speed boost duration (seconds)';

  @override
  String get tideWaveSpeedUpIncreased =>
      'Speed boost multiplier (tideWaveSpeedUpIncreased)';

  @override
  String get tideWaveSubmarineMovingTime => 'Submarine moving time (seconds)';

  @override
  String get tideWaveZombieMovingSpeed =>
      'Zombie speed in current (tideWaveZombieMovingSpeed; 1 tile = 64 units)';

  @override
  String get eventZombieFishWave => 'Event: Underwater Spawner';

  @override
  String get eventHelpZombieFishWaveBody =>
      'Configures the zombies and sea creatures used in Two-Sided Attack, and can only be used in Underwater World levels. Coordinates are 0-based: row 1 = 0, column 10 = 9.';

  @override
  String get eventHelpZombieFishWaveFish =>
      'Use the \"Add sea creature properties\" button to place sea creatures on the lawn. Size of the lawn varies by level: 6×10 in Underwater World, 5×9 in other levels. Rows correspond to Y, columns to X.';

  @override
  String get eventHelpBatchLevel =>
      'Sets all zombies in this wave to the specified level. Elite zombies are unaffected and retain their default level.';

  @override
  String get eventHelpDropConfig =>
      'If the number of plants in the drop list equals the number of Plant Food drops, the drops will become seed packets.';

  @override
  String get fishPropertiesEntryHelp =>
      'Tap a tile to select it, then add sea creatures. Tap \"+\" to add built-in sea creatures. Tap a creature\'s icon for more options such as duplicate, delete, or customize. Customized creatures are marked with a blue \"C\". A warning is shown if a creature is placed outside the lawn.';

  @override
  String get fishAddCustom => 'Add custom sea creature';

  @override
  String get addFishLabel => 'Add sea creature';

  @override
  String get addBuiltInFishLabel => 'Add built-in sea creature';

  @override
  String get makeFishAsCustom => 'Make sea creature as custom';

  @override
  String get switchCustomFish => 'Switch custom sea creature';

  @override
  String get selectCustomFish => 'Select custom sea creature';

  @override
  String get editCustomFishProperties => 'Edit custom sea creature properties';

  @override
  String get fishPropertiesButton => 'Sea creature properties';

  @override
  String get addFishProperties => 'Add sea creature properties';

  @override
  String get editFishProperties => 'Edit sea creature properties';

  @override
  String get fishPropertiesGrid =>
      'Sea Creature placement (row = Y, column = X)';

  @override
  String get fishSelectedPosition => 'Selected:';

  @override
  String get fishRow => 'Row';

  @override
  String get fishColumn => 'Column';

  @override
  String get fishAtPosition => 'Sea creature at position';

  @override
  String get searchFish => 'Search sea creature';

  @override
  String get noFishFound => 'No sea creature found';

  @override
  String get customFishManagerTitle => 'Custom sea creature';

  @override
  String get customFishAppearanceLocation => 'Spawn location:';

  @override
  String get customFishNotUsed =>
      'This custom sea creature is not used by any wave.';

  @override
  String customFishWaveItem(int n) {
    return 'Wave $n';
  }

  @override
  String get customFishDeleteConfirm =>
      'Remove this custom sea creature and its property data.';

  @override
  String get customFish => 'Custom sea creature';

  @override
  String get customFishProperties => 'Custom sea creature properties';

  @override
  String get fishTypeNotFound => 'Sea creature type object not found.';

  @override
  String fishTypeLabel(Object type) {
    return 'Sea creature type: $type';
  }

  @override
  String get customFishHelpIntro => 'Overview';

  @override
  String get customFishHelpIntroBody =>
      'This screen allows you to edit custom sea creature parameters. Only common properties are supported; animation and special attributes require manual JSON editing.';

  @override
  String get customFishHelpProps => 'Properties';

  @override
  String get customFishHelpPropsBody =>
      'HitRect, AttackRect, ScareRect define collision areas. Speed and ScareSpeed control movement. ArtCenter defines center of the sprite.';

  @override
  String get noEditableFishProps => 'No editable properties found.';

  @override
  String get fishPropSpeed => 'Movement Speed (Speed)';

  @override
  String get fishPropScareSpeed => 'Speed When Scared (ScareSpeed)';

  @override
  String get fishPropDamage => 'Damage';

  @override
  String get fishPropHitpoints => 'Health (Hitpoints)';

  @override
  String get fishPropHitPoints => 'Health (Hitpoints)';

  @override
  String get fishPropHitRect => 'Hitbox (HitRect)';

  @override
  String get fishPropAttackRect => 'Attack Range (AttackRect)';

  @override
  String get fishPropScareRect => 'Scare area (ScareRect)';

  @override
  String get fishPropScarerect => 'Scare area (Sacrerect)';

  @override
  String get fishPropArtCenter => 'Sprite Center (ArtCenter)';

  @override
  String get edit => 'Edit';

  @override
  String get eventHelpTidalChangePosition =>
      'Sets the tide position after the change. The rightmost column is 0, and the leftmost is 9. Accepts integers, including negative values.';

  @override
  String get eventHelpBlackHoleBody =>
      'A event commonly seen in Kongfu World. A black hole will spawn and pull all plants to the right.';

  @override
  String get eventHelpBlackHoleColumns =>
      'You can specify how many columns plants are dragged, indicating how many tiles they will be pulled to the right by the black hole.';

  @override
  String get eventHelpMagicMirrorBody =>
      'Spawns paired mirrors on the lawn. Each pair consists of an entrance and an exit, both sharing the same appearance.';

  @override
  String get eventHelpMagicMirrorType =>
      'You can change the mirror’s appearance to distinguish them. There are 3 different types of Magic Mirrors in this event.';

  @override
  String get eventHelpParachuteRainBody =>
      'Zombies will parachute in from above for a surprise attack. Commonly used for Bug Bot Imp, Lost Pilot Zombie, Bass Zombie, ZCorp Helpdesk, and more. Zombie levels follow the lawn’s level sequence.';

  @override
  String get eventHelpParachuteRainLogic =>
      'Zombies drop in batches. You can control the total number and the interval between each batch. Zombies will land randomly within the selected columns. If the total pre-drop delay is reached, any remaining zombies will spawn immediately.\nA red warning message will appear before the event starts. Entering Chinese text in the message may result in garbled characters. You can leave the zombie type empty to use this event purely for message display.';

  @override
  String get eventHelpModernPortalsBody =>
      'Spawns fixed types of spacetime portals on the lawn, commonly seen in Modern Day and Memory Lane';

  @override
  String get eventHelpModernPortalsType =>
      'There are many types of spacetime portals in the game. You can select a specific type and preview the spawned zombies.';

  @override
  String get eventHelpModernPortalsIgnore =>
      'When enabled, spacetime portals will still spawn even if blocked by grid items such as tombstones or surfboards.';

  @override
  String get eventHelpFrostWindBody =>
      'A common event in Frostbite Caves. Freezing wind is generated on specified rows, freezing plants into ice blocks.';

  @override
  String get eventHelpFrostWindDirection =>
      'You can set the direction of the wind (from left or right). Note that there is an interval between each wind event. To make them occur simultaneously, try adding multiple Freezing Wind events.';

  @override
  String get eventHelpModifyConveyorBody =>
      'This event allows you to modify conveyor belt plants during gameplay. Parameters are similar to the conveyor belt module. Make sure the conveyor belt module is already included in the level.';

  @override
  String get eventHelpModifyConveyorAdd =>
      'Adds new plants or tool packets to the conveyor belt. If the plant already exists, its previous data will be overwritten.';

  @override
  String get eventHelpModifyConveyorRemove =>
      'Removing does not work when the Creative Courtyard module is enabled. Instead, set the plant’s weight to 0 to achieve the same effect.';

  @override
  String get eventHelpDinoBody =>
      'A common event in Jurassic Marsh. Summons a specified dinosaur into a chosen row. The dinosaur will assist zombies in attacking.\nOnly one dinosaur can be configured per event. To have multiple dinosaurs appear simultaneously, add multiple Dino Summon events within the wave.';

  @override
  String get eventHelpDinoDuration =>
      'The duration the dinosaur stays on the lawn, measured in waves. It will leave after the time expires or after interacting with enough zombies.';

  @override
  String get eventDinoTread => 'Event: Dino Stomp';

  @override
  String get eventDinoRun => 'Event: Dino Stampede';

  @override
  String get eventHelpDinoTreadBody =>
      'Brontosaurus moves its foot into the designated area and stomps after a few seconds, dealing damage to all plants and zombies within range. It leaves a footprint lasting about 7 seconds, during which planting is not allowed in that area.';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY represents the row, and GridXMin/GridXMax represent the column range. Both rows and columns start counting from 0. In Underwater World, rows range from 0–5 and columns from 0–9.';

  @override
  String get dinoTreadRowLabel => 'Row (GridY)';

  @override
  String get dinoTreadColMinLabel => 'Leftmost Column (GridXMin)';

  @override
  String get dinoTreadColMaxLabel => 'Rightmost Column (GridXMax)';

  @override
  String get dinoTreadTimeIntervalLabel => 'Entry Delay (TimeInterval)';

  @override
  String get columnStartLabel => 'Start Column (ColumnStart)';

  @override
  String get columnEndLabel => 'End Column (ColumnEnd)';

  @override
  String get eventHelpDinoRunBody =>
      'When triggered, dinosaurs gather across 2–3 rows. They do not use their abilities, but instead charge into the lawn, trampling plants or zombies. The number of targets they can trample depends on the dinosaur type.';

  @override
  String get eventHelpDinoRunRow =>
      'DinoRow defines the center row of the dino rush. Rows are 0-based. Underwater World supports up to 5.';

  @override
  String get positionAndArea => 'Position & area';

  @override
  String get positionAndDuration => 'Position & timing';

  @override
  String get rowCol0Index => 'Row/column (0-based)';

  @override
  String get timeInterval => 'Time interval';

  @override
  String get eventHelpZombiePotionBody =>
      'Force-spawns potions on the lawn, ignoring plants. Can be used as an alternative to grid item spawn events.';

  @override
  String get eventHelpZombiePotionUsage =>
      'Unlike the preset pools used for grid item spawning, this event forces grid items to spawn on specific tiles and displaces plants. \nNote that on lawns without tombstone spawn effects, sun textures may appear incorrectly. Use with caution.';

  @override
  String get eventHelpShellBody =>
      'Spawns atlantis seashells at specified positions. Seashells start in a closed state. When a zombie steps on a seashell, it opens, launches the zombie forward, and closes again after 10 seconds. While open, seashells can be attacked by plants and block straight-shot projectiles. Each time a seashell opens, it generates a random item, including a Plant Food, a Cuttlefish, a plant seed packet, or a Relic Imp. After being triggered by zombies 3 times, the seashell will swim toward the seed bank and replace a random seed slot with a seashell seed packet. After the seashell has been planted 3 times, the seed slot will revert to its original plant.';

  @override
  String get eventHelpShellUsage =>
      'Select a tile, then tap \"+\" to place a seashell. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String get eventHelpPumpkinHouseBody =>
      'Spawns pumpkin houses at specified positions. Zombies that pass through the Pumpkin House are transformed into Pumpkin House Ghosts. Pumpkin House Ghosts have a separate health pool and can only be damaged by lobbed plants. When their health is depleted, they revert to their original zombie form. The Pumpkin House itself also has its own health and can be destroyed by concentrated fire.';

  @override
  String get eventHelpPumpkinHouseUsage =>
      'Select a tile, then tap \"+\" to place a pumpkin house. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String get eventHelpFairyFogBody =>
      'Creates magic fog that covers the lawn and grants shields to zombies. Commonly used in Fairytale Forest levels. Can only be cleared by the Fairtyale Breeze event.\nHigher-tier fog grants stronger shields and increased control immunity to zombies. Tiers, from lowest to highest, are White, Blue, and Purple.';

  @override
  String get eventHelpFairyFogRange =>
      'mX and mY define the center point. mWidth and mHeight define how far the area extends to the right and downward from the center.';

  @override
  String get eventHelpFairyWindBody =>
      'Generates a continuous breeze that clears magical fog. Commonly used in Fairytale Forest levels.';

  @override
  String get eventHelpFairyWindVelocity =>
      'This event affects projectile speed while active. 1.0 = normal speed; higher values increase projectile speed.';

  @override
  String get eventHelpRaidingPartyBody =>
      'Commonly seen in Pirate Seas levels. Spawns groups of Swashbuckler Zombies in batches. TimeBetweenGroups defines the interval between each group.';

  @override
  String get eventHelpRaidingPartyGroup => 'Zombies per group.';

  @override
  String get eventHelpRaidingPartyCount =>
      'Total Swashbuckler Zombies spawned.';

  @override
  String get eventHelpGravestoneBody =>
      'Randomly spawns grid items during a wave (e.g., Dark Ages tombstones).';

  @override
  String get eventHelpGravestoneLogic =>
      'Selects valid tiles from the pool above to spawn grid items. The total number of grid items cannot exceed the number of available tiles, or excess spawns will fail.';

  @override
  String get eventHelpGravestoneMissingAssets =>
      'Some lawns without tombstone spawn effects may show sun textures instead. Use with caution.';

  @override
  String get eventHelpBarrelWaveBody =>
      'Spawns the three barrel types from the Memory Lane \"Barrel Crisis\" gimmick. Barrels roll in from the right and crush all plants in their path.';

  @override
  String get barrelWaveHelpTypes => 'Barrel types';

  @override
  String get eventHelpBarrelWaveTypes =>
      'Empty Barrel: Breaks with no effect.\nImp Barrel: Releases zombies (usually Imps) when destroyed.\nExplosive Barrel: Explodes on contact or when destroyed, damaging plants and zombies in a 3×3 area.';

  @override
  String get barrelWaveHelpRows => 'Row';

  @override
  String get eventHelpBarrelWaveRows =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.';

  @override
  String get eventHelpSchoolBusBody =>
      'Spawns an Ice Cream Van in the specified lane. Ice Cream Van slowly enters from the right side while carrying zombies, occupying 2 lanes. Any plants run over by the van are instantly crushed.\nIf the van is displayed with Bubble Gun Imps and Lollipop Zombies (i.e. the schoolbus_special variant), they will continuously use their respective abilities while the van is moving.\nPlants like Spikeweed and Spikerock can puncture the van\'s tires. After its tires are punctured, the Ice Cream Van gradually slows down and enters a gliding state. After a short period of time, it comes to a stop and breaks down.';

  @override
  String get schoolBusHelpRows => 'Row';

  @override
  String get eventHelpSchoolBusRows =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.';

  @override
  String get eventHelpSchoolBusType =>
      'Type selects the ice cream van variant. Normal (schoolbus_normal) is the standard van. Special (schoolbus_special) shows Bubble Gun Imps and Lollipop Zombies on the van; they use their abilities while the van is moving.';

  @override
  String get schoolBusHelpZombies => 'Zombies';

  @override
  String get eventHelpSchoolBusZombies =>
      'Ice Cream Van has its own health pool. Once destroyed, the zombies inside will exit the vehicle and continue advancing. Each zombie\'s level can be configured individually (Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard).';

  @override
  String get schoolBusRow => 'Row';

  @override
  String get schoolBusType => 'Type';

  @override
  String get schoolBusTypeNormal => 'Normal';

  @override
  String get schoolBusTypeSpecial => 'Special';

  @override
  String get schoolBusHitPoints => ' Van health (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => 'Van speed (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => 'Contained zombies (Zombies)';

  @override
  String get schoolBusZombieLevel => 'Zombie level (Level)';

  @override
  String get schoolBusAddZombie => 'Add zombie';

  @override
  String get schoolBusRowsHint =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.';

  @override
  String get eventHelpThunderWaveBody =>
      'Lightning strikes during the wave, hitting plants adjacent to other plants. Commonly used in Sky City levels. Each strike applies either a positive or negative charge to plants.';

  @override
  String get thunderWaveHelpTypes => 'Charge effects';

  @override
  String get eventHelpThunderWaveTypes =>
      'Two positive charges cause continuous percentage damage from an overhead energy orb.\nTwo negative charges paralyze the plant for a short duration.\nOne positive and one negative charge permanently slow the plant.\nPlants can still receive charges while affected, but no additional effects will be applied.';

  @override
  String get thunderWaveHelpKillRate => 'Kill rate';

  @override
  String get eventHelpThunderWaveKillRate =>
      'The chance for lightning to instantly kill a plant on hit (0.0–1.0). Anthurium is unaffected. This applies to both positive and negative lightning.';

  @override
  String get thunderWaveTypePositive => 'Positive';

  @override
  String get thunderWaveTypeNegative => 'Negative';

  @override
  String get thunderWaveKillRate => 'Kill rate';

  @override
  String get thunderWaveKillRateHint =>
      'Probability of killing plants on lightning strike (0.0–1.0), Anthurium is unaffected';

  @override
  String get thunderWaveThunders => 'Lightnings';

  @override
  String get thunderWaveAddThunder => 'Add lightning';

  @override
  String get thunderWaveThunder => 'Lightning';

  @override
  String get barrelWaveTypeEmpty => 'Empty Barrel (barrelempty)';

  @override
  String get barrelWaveTypeZombie => 'Imp Barrel (barrelmoster)';

  @override
  String get barrelWaveTypeExplosive => 'Explosive Barrel (barrelpowder)';

  @override
  String get barrelWaveRowsHint =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.';

  @override
  String get barrelWaveAddBarrel => 'Add barrel';

  @override
  String get barrelWaveBarrel => 'Barrel';

  @override
  String get barrelWaveRow => 'Row';

  @override
  String get barrelWaveType => 'Type';

  @override
  String get barrelWaveHitPoints => 'Barrel health (BarrelHitPoints)';

  @override
  String get barrelWaveSpeed => 'Barrel speed (BarrelSpeed)';

  @override
  String get barrelWaveZombies => 'Contained zombies (Zombies)';

  @override
  String get barrelWaveZombieLevel => 'Zombie level (Level)';

  @override
  String get barrelWaveAddZombie => 'Add zombie';

  @override
  String get barrelWaveExplosionDamage =>
      'Explosion damage (BarrelBlowDamageAmount)';

  @override
  String get barrelWaveDeleteTitle => 'Delete barrel';

  @override
  String get barrelWaveDeleteConfirm => 'Delete this barrel?';

  @override
  String get barrelWaveDeleteLastHint =>
      'This is the last barrel. Deleting it will leave this event without any barrels. Continue?';

  @override
  String get eventHelpGraveSpawnBody =>
      'Spawns zombies from specific grid item types. Commonly used for Dark Ages Necromancy ambushes.';

  @override
  String get eventHelpGraveSpawnWait =>
      'Delay between wave start and zombie spawn. If the next wave begins before the timer ends, no zombies will spawn.';

  @override
  String get eventHelpStormBody =>
      'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.';

  @override
  String get eventHelpStormColumns =>
      'The left boundary of the lawn is column 0, and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.';

  @override
  String get eventHelpStormLevels =>
      'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.';

  @override
  String get eventHelpGroundSpawnBody =>
      'Spawns zombies directly from the ground within the specified range. Configuration is similar to natural spawning. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\n By default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.';

  @override
  String get moduleHelpTideBody =>
      'Enables the tide system for the level, allowing tide-related events to be used. Note that this module must be added last; otherwise, it may cause the level to crash.';

  @override
  String get moduleHelpTidePosition =>
      'Sets the position of the tide at the start of the level, i.e., the position of the tide line within the level. The rightmost column is 0 and the leftmost is 9. Accepts integers, including negative values.';

  @override
  String get initialTidePosition => 'Tide line configuration';

  @override
  String get moduleHelpManholeBody =>
      'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.';

  @override
  String get moduleHelpManholeEdit =>
      'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.';

  @override
  String get moduleHelpWeatherBody =>
      'Controls global environmental effects such as rain and snow.';

  @override
  String get moduleHelpWeatherRef =>
      'These modules are typically referenced directly from LevelModules and do not require custom configuration.';

  @override
  String get moduleHelpZombiePotionBody =>
      'Spawns specified grid iems types (like potions) at random rows from right to left within a defined time interval. Stops spawning when the maximum number of grid items is reached.';

  @override
  String get moduleHelpZombiePotionTypes =>
      'Potions are randomly selected from the specified types. To spawn multiple grid items at fixed intervals, add multiple instances of this module.';

  @override
  String get moduleHelpUnknownBody =>
      'A level file consists of a root node and multiple modules, known as PVZ2Object. Each object has aliases, a type (objclass), and data (objdata). The root node has no aliases.';

  @override
  String get moduleHelpUnknownEvents =>
      'This software determines module types by reading objclass. The objclass of the current module is not registered in the module list, so no matching editor is available. Support may be added in a future update.';

  @override
  String get eventHelpInvalidBody =>
      'This event is referenced in the wave container, but the parser cannot find its entity definition in the level, leaving the RTID block unresolved.';

  @override
  String get eventHelpInvalidImpact =>
      'Keeping this invalid entry in the level will prevent it from being read correctly and may cause a crash. It should be removed manually.';

  @override
  String get position => 'Initial tide position';

  @override
  String get editing => 'Editing';

  @override
  String get logic => 'Logic';

  @override
  String get impact => 'Impact';

  @override
  String get events => 'Events';

  @override
  String get referenceModules => 'Reference modules';

  @override
  String get portalType => 'Portal type (PortalType)';

  @override
  String get direction => 'Direction';

  @override
  String get velocityScale => 'Speed multiplier (VelocityScale)';

  @override
  String get range => 'Range';

  @override
  String get columnRange => 'Column range';

  @override
  String get zombieLevels => 'Zombie level';

  @override
  String get missingAssets => 'Missing assets';

  @override
  String get usage => 'Usage';

  @override
  String get types => 'Types';

  @override
  String get eventBlackHole => 'Event: Black Hole';

  @override
  String get attractionConfig => 'Attraction config';

  @override
  String get selectedPosition => 'Selected position';

  @override
  String get placePlant => 'Place plant';

  @override
  String get plantList => 'Plant(s) in selected tile';

  @override
  String get firstCostume => 'Wears primary costume (Avatar)';

  @override
  String get costumeOn => 'Costume: on';

  @override
  String get costumeOff => 'Costume: off';

  @override
  String get outsideLawnItems => 'Objects outside the lawn';

  @override
  String get zombieFromLeft => 'From left';

  @override
  String get eventMagicMirror => 'Event: Magic Mirror';

  @override
  String get eventParachuteRain => 'Event: Parachute/Bass/Jetpack/Imp rain';

  @override
  String get manholePipeline => 'Manhole Pipeline module';

  @override
  String get manholePipelines => 'Manhole pipelines';

  @override
  String get manholePipelineHelpOverview =>
      'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.';

  @override
  String get manholePipelineHelpEditing =>
      'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return 'Start: ($sx, $sy)  End: ($ex, $ey)';
  }

  @override
  String get piratePlank => 'Pirate Plank module';

  @override
  String get weatherModule => 'Environmental Weather module';

  @override
  String get zombiePotion => 'Dark Alchemy module';

  @override
  String get eventTimeRift => 'Event: Spacetime Portal';

  @override
  String get deathHole => 'Death Crater module';

  @override
  String get seedRain => 'It\'s Raining Seeds module';

  @override
  String get eventFrostWind => 'Event: Freezing Wind';

  @override
  String get lastStandSettings => 'Last Stand Settings';

  @override
  String get roofFlowerPot => 'Roof Pots module';

  @override
  String get eventConveyorModify => 'Event: Conveyor Change';

  @override
  String get bowlingMinigame => 'Bulb Bowling module';

  @override
  String get zombieMoveFast => 'Fast Entry module';

  @override
  String get eventPotionDrop => 'Event: Potion Drop';

  @override
  String get eventShellSpawn => 'Event: Seashell Spawn';

  @override
  String get eventPumpkinHouseSpawn => 'Event: Pumpkin House Spawn';

  @override
  String get eventSchoolBusSpawn => 'Event: Ice cream Van spawn';

  @override
  String get warMist => 'Fog System module';

  @override
  String get eventDino => 'Event: Dino Spawn';

  @override
  String get duration => 'Duration';

  @override
  String get sunDropper => 'Sun Dropper module';

  @override
  String get eventFairyWind => 'Event: Fairytale Breeze';

  @override
  String get eventFairyFog => 'Event: Magic Fog';

  @override
  String get eventRaidingParty => 'Event: Raiding Party';

  @override
  String get swashbucklerCount => 'Swashbuckler count';

  @override
  String get sunBomb => 'Sun Bombs module';

  @override
  String get eventSpawnGravestones => 'Event: Grid Item Spawn';

  @override
  String get eventBarrelWave => 'Event: Barrel Crisis';

  @override
  String get eventThunderWave => 'Event: Thundercloud Storm';

  @override
  String get eventGraveSpawn => 'Event: Grid Item Spawner';

  @override
  String get zombieSpawnWait => 'Zombie spawn delay';

  @override
  String get selectCustomZombie => 'Select custom zombie';

  @override
  String get change => 'Change';

  @override
  String get autoLevel => 'Auto-Set level';

  @override
  String get apply => 'Apply';

  @override
  String get applyBatchLevel => 'Apply batch level?';

  @override
  String get conveyorBelt => 'Conveyor Belt Module Settings';

  @override
  String get starChallenges => 'Challenge Module Settings';

  @override
  String get addChallenge => 'Add challenge';

  @override
  String get unknownChallengeType => 'Unknown challenge type';

  @override
  String get protectedPlants => 'Endangered plants';

  @override
  String get addPlant => 'Add plant';

  @override
  String get protectedGridItems => 'Grid items to protect';

  @override
  String get addGridItem => 'Add grid item';

  @override
  String get spawnTimer => 'Spawn Interval (PotionSpawnTimer)';

  @override
  String get plantLevels => 'Plant levels';

  @override
  String get globalPlantLevels => 'Global plant levels';

  @override
  String get scope => 'Scope';

  @override
  String get applyBatch => 'Batch apply';

  @override
  String get addPlants => 'Add plants to the list';

  @override
  String get noPlantsConfigured =>
      'No plants configured. Please add plants to the list.';

  @override
  String batchLevelFormat(int level) {
    return 'Batch level: $level';
  }

  @override
  String get protectPlants => 'Protect plants';

  @override
  String get protectItems => 'Protect items';

  @override
  String get autoCount => 'Auto count';

  @override
  String get overrideStartingPlantfood => 'Starting Plant Food settings';

  @override
  String get startingPlantfoodOverride =>
      'Starting Plant Food (StartingPlantfoodOverride)';

  @override
  String get iconText => 'Icon Text';

  @override
  String get iconImage => 'Icon Image';

  @override
  String get overrideMaxSun => 'Max Sun Limit Settings';

  @override
  String get maxSunOverride => 'Max sun limit (MaxSunOverride)';

  @override
  String get maxSunHelpTitle => 'Max Sun Limit';

  @override
  String get maxSunHelpOverview =>
      'Originally used for Penny’s Pursuit difficulty settings. This module overrides the maximum amount of sun that can be stored in a level.';

  @override
  String get startingPlantfoodHelpTitle => 'Starting Plant Food';

  @override
  String get startingPlantfoodHelpOverview =>
      'Originally used for Penny’s Pursuit difficulty settings. This module overrides the amount of Plant Food available at the start of a level.';

  @override
  String get starChallengeHelpTitle => 'Challenge Module';

  @override
  String get starChallengeHelpOverview =>
      'Select the challenge modules to apply to the level. Multiple challenges can be enabled at once, and the same challenge can be applied multiple times.';

  @override
  String get starChallengeHelpSuggestionTitle => 'Tips';

  @override
  String get starChallengeHelpSuggestion =>
      'Some challenges display progress using an on-screen tracker. If too many challenges are enabled, the tracker may be overlapped.';

  @override
  String get remove => 'Remove';

  @override
  String get plant => 'Plant';

  @override
  String get zombie => 'Zombie';

  @override
  String get initialZombieLayout => 'Initial zombie layout';

  @override
  String get placeZombie => 'Place zombie';

  @override
  String get manualInput => 'Manual input';

  @override
  String get waveManagerModule => 'Wave Manager Module';

  @override
  String get points => 'Points';

  @override
  String get eventStorm => 'Event: Storm Raid';

  @override
  String get row => 'Row';

  @override
  String get addType => 'Add type';

  @override
  String get plantFunExperimental => 'Plant (work in progress)';

  @override
  String get availableZombies => 'Available zombies';

  @override
  String get presetPlants => 'Preset plants (PresetPlantList)';

  @override
  String get whiteList => 'White list (WhiteList)';

  @override
  String get blackList => 'Black list (BlackList)';

  @override
  String get chooser => 'Choose Your Seeds (Chooser)';

  @override
  String get preset => 'Locked and Loaded (Preset)';

  @override
  String get seedBankHelp => 'Seed Bank';

  @override
  String get conveyorBeltHelp => 'Conveyor Belt';

  @override
  String get dropDelayConditions => 'Seed packets delay (DropDelayConditions)';

  @override
  String get unitSeconds => 'Unit: seconds';

  @override
  String get speedConditions => 'Conveyor speed (SpeedConditions)';

  @override
  String get speedConditionsSubtitle =>
      'Default is 100; higher values increase speed';

  @override
  String get addPlantConveyor => 'Add plant';

  @override
  String get addTool => 'Add tool packet';

  @override
  String get increasedCost => 'Inflation';

  @override
  String get powerTile => 'Power Tiles';

  @override
  String get powerTileGridSection => 'Current lawn';

  @override
  String get powerTileGridHelpPrimary =>
      'Tap a cell to place a tile, and tap again to remove it. Placing a tile on an occupied cell will replace the existing one. Tiles from other groups are shown dimmed to indicate they are not in the selected group.';

  @override
  String get powerTileGridHelpSecondaryMobile =>
      'Long press a cell to quickly set a group or adjust the propagation delay.';

  @override
  String get powerTileGridHelpSecondaryDesktop =>
      'Right-click a cell to quickly set a group or adjust its propagation delay.';

  @override
  String get powerTileLinkedTilesSection => 'Tile list';

  @override
  String get powerTilePropagationDelayLabel => 'Propagation delay (seconds)';

  @override
  String get powerTilePropagationDelayTooltip =>
      'The delay before power begins to propagate to other tiles (0–5 seconds). This does not include the transmission time itself. The default propagation delay is 1.5 seconds.';

  @override
  String get powerTileDialogEditCell => 'Edit cell';

  @override
  String get powerTileDialogTileGroup => 'Tile group';

  @override
  String get powerTileDialogNone => 'None';

  @override
  String get powerTileDialogPropagationDelay => 'Propagation delay (seconds)';

  @override
  String get powerTileHelpOverview =>
      'Power Tiles are divided into five groups. When a plant on a tile activates its Plant Food effect, power is propagated to other tiles in the same group, causing those plants to activate their Plant Food effect as well. The initial delay before propagation can be configured. ';

  @override
  String get powerTileHelpGridSize =>
      'Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return 'Quick edit: $interaction';
  }

  @override
  String get eventStandardSpawn => 'Event: Basic Spawner';

  @override
  String get eventGroundSpawn => 'Event: Ground Spawner';

  @override
  String get eventEditorInDevelopment => 'Event editor in development';

  @override
  String get level => 'Level';

  @override
  String get missingTideModule => 'Missing Tide System module';

  @override
  String get levelHasNoTideProperties =>
      'This level has no Tide System module (TideProperties). This event may not function correctly and could cause a crash.';

  @override
  String get changePosition => 'Tide adjustment';

  @override
  String get changePositionChangeAmount => 'Column Offset (ChangeAmount)';

  @override
  String get preview => 'Tide preview';

  @override
  String get water => 'Water';

  @override
  String get land => 'Land';

  @override
  String groupConfigN(int n) {
    return 'Group $n config';
  }

  @override
  String get globalParameters => 'Global parameters';

  @override
  String get timePerGrid => 'Transfer time (seconds per tile)';

  @override
  String get damagePerSecond => 'Damage per second';

  @override
  String get pipe => 'Pipe';

  @override
  String get stageMismatch => 'Lawn mismatch';

  @override
  String get currentStageNotPirate =>
      'The current lawn is not Pirate Seas. This module may not work correctly and could cause a crash.';

  @override
  String get plankRows => 'Plank rows';

  @override
  String get plankRowsDeepSea => 'Plank rows (Underwater World)';

  @override
  String get selectedRows => 'Rows selected:';

  @override
  String get selectedRowsLabel => 'Selected rows:';

  @override
  String get indexLabel => 'Index';

  @override
  String get selectWeatherType => 'Select weather type';

  @override
  String get counts => 'Count Settings';

  @override
  String get initial => 'Initial count (InitialPotionCount)';

  @override
  String get max => 'Max count (MaxPotionCount)';

  @override
  String get spawnTimerShort => 'Spawn Interval (PotionSpawnTimer)';

  @override
  String get minSec => 'Min (seconds)';

  @override
  String get maxSec => 'Max (seconds)';

  @override
  String get potionTypes => 'Potion Types (PotionTypes)';

  @override
  String get noPotionTypes => 'No potion types configured; add one to continue';

  @override
  String get ignoreGravestoneSubtitle =>
      'Enable to spawn regardless of grid items';

  @override
  String get thisPortalSpawns => 'This portal spawns:';

  @override
  String startEndFormat(int sx, int sy, int ex, int ey) {
    return 'Start: ($sx, $sy)  End: ($ex, $ey)';
  }

  @override
  String indexN(int n) {
    return 'Index: $n';
  }

  @override
  String get noItemsAddHint =>
      'No items. Add plants, zombies, or collectibles.';

  @override
  String get zombieTypeSpiderZombieName => 'Zombie type (SpiderZombieName)';

  @override
  String get noneSelected => 'None selected';

  @override
  String get totalSpiderCount => 'Total count (SpiderCount)';

  @override
  String get perBatchGroupSize => 'Per batch count (GroupSize)';

  @override
  String get fallTime => 'Fall time (ZombieFallTime; seconds)';

  @override
  String get waveStartMessageLabel => 'Red warning message (WaveStartMessage)';

  @override
  String get optionalWarningText =>
      'Optional warning text shown at the center of the screen when the drop begins; Chinese is not supported';

  @override
  String rowNShort(int n) {
    return 'Row $n';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return 'Weight: $weight, Max: $max';
  }

  @override
  String get random => 'Random';

  @override
  String get noChallengesConfigured => 'No challenges configured';

  @override
  String get whiteListBlackListHint =>
      'If the whitelist is empty, no restrictions are applied.\nParallel Universe plants are ignored by the whitelist unless the corresponding module is enabled.\nThe blacklist explicitly disables plants and takes priority over the whitelist.';

  @override
  String get conveyorBeltHelpIntro =>
      'Conveyor-belt delivers seed packets randomly based on configured weights. Requires a plant pool and drop delay settings.';

  @override
  String get conveyorBeltHelpPool =>
      'Plant pool & weight: Probability = weight / total weight. Use thresholds to adjust dynamically.';

  @override
  String get conveyorBeltHelpDropDelay =>
      'Seed packets delay: Controls the interval between seed packet generation. The interval can scale based on the number of queued plants: more backlog usually results in slower generation.';

  @override
  String get conveyorBeltHelpSpeed =>
      'Conveyor speed: Controls the movement speed of cards on the conveyor belt. Default speed is 100. Speed can scale dynamically based on backlog size.';

  @override
  String get cannotAddEliteZombies => 'Cannot add elite zombies';

  @override
  String get eliteZombiesNotAllowed => 'Elite zombies are not allowed here';

  @override
  String fixToAlias(Object alias) {
    return 'Fix to $alias';
  }

  @override
  String editPresetZombie(Object name) {
    return 'Edit preset zombie: $name';
  }

  @override
  String get missingZombossMechModule =>
      'Missing ZombossMech battle module (ZombossBattleModuleProperties)';

  @override
  String get missingZombossBattleModule =>
      'Missing Zomboss battle module (ZombossLastStandMinigameProperties)';

  @override
  String get challengeNoConfig =>
      'This challenge doesn\'t support configuration.';

  @override
  String get maxPotionCount => 'Max Potion Count';

  @override
  String potionTypesConfigured(int count) {
    return 'Potion types: $count configured';
  }

  @override
  String pipelinesCount(int count) {
    return 'Pipelines: $count';
  }

  @override
  String windN(int n) {
    return 'Freezing Wind #$n';
  }

  @override
  String get zombieList => 'Zombie list';

  @override
  String get positionPoolSpawnPositions => 'Position pool (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect =>
      'Tap tiles to select/deselect spawn positions';

  @override
  String get gravestonePool => 'Item pool (GravestonePool)';

  @override
  String get removePlants => 'Remove plants';

  @override
  String get current => 'Current';

  @override
  String get eliteZombiesUseDefaultLevel => 'Elite zombies use default level.';

  @override
  String get basicParameters => 'Basic parameters';

  @override
  String get zombieSpawnWaitSec => 'Spawn delay (seconds) ';

  @override
  String get gridTypes => 'Grid item types';

  @override
  String zombiesCount(int count) {
    return 'Zombies ($count)';
  }

  @override
  String get eventGraveSpawnSubtitle => 'Event: Grave Item Spawner';

  @override
  String get eventStormSpawnSubtitle => 'Event: Storm Raid';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      'Delay between wave start and zombie spawn. Zombies won\'t spawn if the next wave has already begun.';

  @override
  String get eventHelpStormOverview =>
      'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.';

  @override
  String get eventHelpStormColumnRange =>
      'The left boundary is column 0 and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.';

  @override
  String get eventHelpStormZombieLevels =>
      'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.';

  @override
  String get spawnParameters => 'Spawn parameters';

  @override
  String get sandstorm => 'Sandstorm';

  @override
  String get snowstorm => 'Snowstorm';

  @override
  String get excoldStorm => 'Freezing Storm';

  @override
  String get columnStart => 'Start column (ColumnStart)';

  @override
  String get columnEnd => 'End column (ColumnEnd)';

  @override
  String applyBatchLevelContent(int level) {
    return 'Set all zombies in this wave to level $level (elite zombies unaffected)';
  }

  @override
  String get randomRow => 'Random row';

  @override
  String levelFormat(int level) {
    return 'Level: $level';
  }

  @override
  String get levelAccount => 'Level: account';

  @override
  String levelDisplay(Object value) {
    return 'Level: $value';
  }

  @override
  String get eventStandardSpawnTitle => 'Basic Spawner';

  @override
  String get eventGroundSpawnTitle => 'Ground Spawner';

  @override
  String get eventHelpStandardOverview =>
      'Basic event for spawning zombies. Allows configuring the level and row for each zombie. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\nBy default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.';

  @override
  String get eventHelpStandardRow =>
      'Zombies can spawn in any row from 1–5, or in a random row.';

  @override
  String get eventHelpStandardRowDeepSea =>
      'Zombies can spawn in any row from 1–6, or in a random row.';

  @override
  String get warningStageSwitchedTo5Rows =>
      'The lawn only has 5 rows, but some data references row 6. These objects may not appear correctly in-game.';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return 'Some objects are placed outside the lawn ($rows rows × $cols cols).';
  }

  @override
  String get izombieModeTitle => 'I, Zombie Mode';

  @override
  String get izombieModeSubtitle =>
      'Switches to zombie placement gameplay. Seed selection will be locked.';

  @override
  String get reverseZombieFactionTitle => 'Invert Zombie Faction';

  @override
  String get reverseZombieFactionSubtitle =>
      'Placed zombies will belong to the plant faction. Useful for Plant Wars (ZvZ) mini-game.';

  @override
  String get initialWeight => 'Initial weight';

  @override
  String get plantLevelLabel => 'Plant level';

  @override
  String get missingIntroModule => 'Missing Intro Module';

  @override
  String get missingIntroModuleHint =>
      'Level is missing ZombossMech intro module (ZombossBattleIntroProperties). The level may not function correctly. Please add the module and reselect the ZombossMech.';

  @override
  String get zombossMechType => 'ZombossMech type';

  @override
  String get unknownZombossMech => 'Unknown ZombossMech';

  @override
  String get zombossMechSelection => 'ZombossMech selection';

  @override
  String get zombossMechBaseLabel => 'Base ZombossMech';

  @override
  String get zombossMechBaseHint =>
      'Mech boss family (Egypt, Future, Memory Lane robot, etc.). Changing this updates the available variations below.';

  @override
  String get zombossMechVariationLabel => 'Variation';

  @override
  String get zombossMechVariationHint =>
      'Specific mech type used in-game (ZombossMechType). Options depend on the base ZombossMech selected above. Phase count and spawn position sync automatically.';

  @override
  String get zombossBattleSelection => 'Zomboss selection';

  @override
  String get zombossBattleBaseLabel => 'Base zomboss';

  @override
  String get zombossBattleBaseHint =>
      'Boss family (Kongfu blade, Qin Shi Huang, etc.). Changing this updates bundled resource groups automatically.';

  @override
  String get zombossBattleVariationLabel => 'Variation';

  @override
  String get zombossBattleVariationHint =>
      'Specific Zomboss type used in-game (ZombossTypeName). Options depend on the base zomboss selected above.';

  @override
  String get zombossBattleStartingSunLabel => 'Starting sun (StartingSun)';

  @override
  String get zombossBattleStartingSunHint =>
      'Sun available when the battle begins.';

  @override
  String get zombossBattleStartingPlantfoodLabel =>
      'Starting plant food (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint =>
      'Plant Food available when the battle begins.';

  @override
  String get zombossBattleInitialGridColLabel =>
      'Spawn column (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint =>
      'Grid column where the Zomboss appears.';

  @override
  String get zombossBattleInitialGridRowLabel =>
      'Spawn row (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint =>
      'Grid row where the Zomboss appears.';

  @override
  String get zombossBattleStartStageIndexLabel =>
      'Start stage (ZombossStartStageIndex)';

  @override
  String get zombossBattleStartStageIndexHint =>
      'Which boss phase index the fight begins at (0 = first phase).';

  @override
  String get zombossBattleSkipPlantingLabel =>
      'Skip planting phase (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint =>
      'When enabled, the level skips the setup/planting phase before the boss fight.';

  @override
  String get parameters => 'Parameters';

  @override
  String get reservedColumnCount => 'Reserved Columns (ReservedColumnCount)';

  @override
  String get reservedColumnCountHint =>
      'Number of columns reserved on the right where planting is disabled. Typically 2 or more columns are reserved.';

  @override
  String get protectedList => 'Protected Targets';

  @override
  String get plantLevelsFollowGlobal =>
      'Plants in this module follow their respective tiers from the player’s account. You can standardize their levels using the Tier Definition module.';

  @override
  String get protectPlantsOverview =>
      'Defines plants that must be protected. The level fails if any of them are eaten or destroyed.';

  @override
  String get protectPlantsAutoCount =>
      'The required count updates automatically based on the number of plants added.';

  @override
  String get protectItemsOverview =>
      'Defines grid items that must be protected. The level fails if any of them are destroyed.';

  @override
  String get protectItemsAutoCount =>
      'The required count updates automatically based on the number of grid items added.';

  @override
  String positionsCount(int count) {
    return 'Positions: $count';
  }

  @override
  String totalItemsCount(int count) {
    return 'Total items to be spawned: $count';
  }

  @override
  String get itemCountExceedsPositionsWarning =>
      'Warning: Total grid items exceed available positions. Some grid items will not spawn!';

  @override
  String get gravestoneBlockedInfo =>
      'Grid items like tombstones cannot spawn if blocked by plants. Use other methods to force spawn them, such as the Potion Drop event.';

  @override
  String get enterConditionValue => 'Enter condition value';

  @override
  String get customInputHint => 'Custom input must be accurate';

  @override
  String get presetConditions => 'Preset conditions';

  @override
  String get selectFromPresetHint => 'Select from preset condition list';

  @override
  String get conveyorCardPool => 'Conveyor Pool';

  @override
  String get toolCardsUseFixedLevel =>
      'Tool packets use a fixed level by default and do not need to be modified.';

  @override
  String get maxLimits => 'Max limits';

  @override
  String get maxCountThreshold => 'Max count threshold';

  @override
  String get weightFactor => 'Post-threshold weight multiplier';

  @override
  String get minLimits => 'Min limits';

  @override
  String get minCountThreshold => 'Min count threshold';

  @override
  String get followAccountLevel => 'Level 0 follows the player’s account level';

  @override
  String get enablePointSpawning => 'Enable Point-Based Spawning';

  @override
  String get pointSpawningEnabledDesc =>
      'Enabled (uses points to spawn extra zombies)';

  @override
  String get pointSpawningDisabledDesc =>
      'Disabled (event-based spawning only)';

  @override
  String get pointSettings => 'Point settings';

  @override
  String get startingWave => 'Starting wave';

  @override
  String get startingPoints => 'Starting points';

  @override
  String get pointIncrement => 'Point increase per wave';

  @override
  String get zombiePool => 'Zombie pool';

  @override
  String plantLevelsCount(int count) {
    return 'Plant levels: $count';
  }

  @override
  String lvN(int n) {
    return 'Level $n';
  }

  @override
  String get pennyClassroom => 'Penny Classroom module';

  @override
  String get protectGridItems => 'Event: Save Our Items';

  @override
  String get waveManagerHelpOverview =>
      'Wave Manager defines the wave event container. Wave editing is only available after adding this module.';

  @override
  String get waveManagerHelpPoints =>
      'Point-based spawning generates additional zombies during valid waves based on point cost.\nNormal waves have a cap of 60,000 points, while flag waves use a 2.5× multiplier.\nWhen points are positive, zombies are selected from the zombie pool. Expected spawn values for each zombie can be viewed in the wave event container.\nWhen points are negative, zombies with equivalent point value are removed from natural spawns.\nDo not include elite or custom zombies in the point-based spawning pool.';

  @override
  String get pointsSection => 'Points';

  @override
  String get globalPlantLevelsOverview =>
      'Defines plant levels globally within the level. This setting overrides seed packet levels and allows individual customization for specific plants.';

  @override
  String get globalPlantLevelsScope =>
      'Applies to all instances of the plant used in the level, including endangered plants and packet drops.';

  @override
  String mustProtectCountFormat(int count) {
    return 'Required to protect: $count';
  }

  @override
  String get noWaveManagerPropsFound =>
      'Wave Manager module (WaveManagerProperties) not found.';

  @override
  String get itemsSortedByRow => 'Item(s) in selected tile';

  @override
  String get eventStormSpawn => 'Event: Storm Raid';

  @override
  String get stormEvent => 'Storm Raid';

  @override
  String get makeCustom => 'Set as custom';

  @override
  String get zombieLevelsBody =>
      'Zombie level and row cannot be set independently within storms. Level settings in the editor should be ignored; zombie levels follow the lawn’s level sequence by default.';

  @override
  String get batchLevel => 'Batch level';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get backgroundMusicLevelJam =>
      'Neon Mixtape Tour music switch (LevelJam)';

  @override
  String get onlyAppliesRockEra =>
      'Switches the background music when triggered. Only applies to Neon Mixtape Tour levels.';

  @override
  String get appliesToAllNonElite =>
      'Sets all zombies in this wave to the specified level (elite zombies are unaffected and retain their default level)';

  @override
  String get dropConfigPlants => 'Drop Configuration (seed packets)';

  @override
  String get dropConfigPlantFood => 'Drop config (Plant Food)';

  @override
  String get zombiesCarryingPlants => 'Zombies carrying seed packets';

  @override
  String get zombiesCarryingPlantFood => 'Zombies carrying Plant Food';

  @override
  String get descriptiveName => 'Descriptive Name';

  @override
  String get count => 'Count';

  @override
  String get targetDistance =>
      'Flowerbed Distance (TargetDistance) — Distance from the left edge (in columns); higher values are closer to the house; supports decimals';

  @override
  String get targetSun => 'Target Sun';

  @override
  String get maximumSun => 'Sun Cap (MaximumSun)';

  @override
  String get holdoutSeconds => 'Duration (HoldoutSeconds)';

  @override
  String get zombiesToKill => 'Zombies to Kill (ZombiesToKill)';

  @override
  String get timeSeconds => 'Time Limit (seconds)';

  @override
  String get speedModifier =>
      'Speed Multiplier (SpeedModifier) — e.g. 0.5 = +50% zombie speed';

  @override
  String get sunModifier =>
      'Sun Reduction (SunModifier) — e.g. 0.2 = −20% sun gain';

  @override
  String get maximumPlantsLost => 'Maximum Plants Lost';

  @override
  String get maximumPlants => 'Maximum Plants on the Lawn';

  @override
  String get targetScore => 'Target Score';

  @override
  String get plantBombRadius => 'Plant explosion radius';

  @override
  String get plantType => 'Plant Type';

  @override
  String get gridX => 'Grid X';

  @override
  String get gridY => 'Grid Y';

  @override
  String get noCardsYetAddPlants =>
      'No seed packets yet. Add plants or tool packets.';

  @override
  String get mustProtectCountAll => 'Required to Protect (0 = protect all)';

  @override
  String get mustProtectCount => 'Required to Protect (MustProtectCount)';

  @override
  String get gridItemType => 'Grid item type';

  @override
  String get zombieBombRadius => 'Zombie explosion radius';

  @override
  String get plantDamage => 'Damage to plants';

  @override
  String get zombieDamage => 'Damage to zombies';

  @override
  String get initialPotionCount => 'Initial count (InitialPotionCount)';

  @override
  String get operationTimePerGrid => 'Transfer time (seconds per tile)';

  @override
  String get levelLabel => 'Level: ';

  @override
  String get mistParameters => 'Fog parameters';

  @override
  String get sunDropParameters => 'Sun drop parameters';

  @override
  String get initialDropDelay => 'Initial drop delay (InitialSunDropDelay)';

  @override
  String get baseCountdown => 'Base drop interval (SunCountdownBase)';

  @override
  String get maxCountdown => 'Max drop interval (SunCountdownMax)';

  @override
  String get countdownRange => 'Interval variation range (SunCountdownRange)';

  @override
  String get increasePerSun => 'Increase per sun (SunCountdownIncreasePerSun)';

  @override
  String get inflationParams => 'Inflation parameters';

  @override
  String get baseCostIncreaseLabel =>
      'Cost increase per planting (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel =>
      'Max Increase Count (MaxIncreasedCount) — Capped at 10 in-game, value changes have no effect';

  @override
  String get selectGroup => 'Select group';

  @override
  String get gridTapAddRemove =>
      'Tile (tap to add/change, long-press to remove)';

  @override
  String get sunBombHelpOverview => 'Overview';

  @override
  String get sunBombHelpBody =>
      'Required for the Far Future brain buster \"Sun Bomb\". When enabled, falling sun will turn into purple, detonatable Sun Bombs. Damage dealt by Sun Bombs can be configured separately for different factions.';

  @override
  String get bombProperties => 'Powder Keg module';

  @override
  String get bombPropertiesHelpBody =>
      'Required for configuring the Kongfu World brain buster \"Powder Keg\". When enabled, Powder Kegs will appear at lawn mower positions and spawn a fuse that can be ignited. If a flame travels along the fuse and reaches the Powder Keg, it will explode, destroying plants within a 3×3 area centered on itself.';

  @override
  String get bombPropertiesHelpFuse => 'Fuse lengths';

  @override
  String get bombPropertiesHelpFuseBody =>
      'Fuse length is configured per row, starting from row 1 (top to bottom). Each row corresponds to a value in the array, representing how many tiles the fuse extends to the right. Standard lawns have 5 rows, while Underwater World lawns have 6. The array length will automatically adjust based on the current lawn when opening this panel.';

  @override
  String get bombPropertiesFlameSpeed => 'Fuse Burn Speed (FlameSpeed)';

  @override
  String get bombPropertiesFuseLengths => 'Fuse Lengths (FuseLengths)';

  @override
  String get bombPropertiesFuseLengthsHint =>
      'Set how many tiles the fuse extends to the right for each row (one value per row)';

  @override
  String get bombPropertiesFuseLength => 'Fuse Length';

  @override
  String get damage => 'Explosion Damage';

  @override
  String get explosionRadius => 'Explosion Radius';

  @override
  String get plantRadius => 'Plant explosion radius';

  @override
  String get zombieRadius => 'Zombie explosion radius';

  @override
  String get radiusPixelsHint =>
      'Explosion radius is measured in pixels (1 tile ≈ 60 pixels).';

  @override
  String get enterMaxSunHint => 'Enter the level’s maximum sun cap (e.g. 9900)';

  @override
  String get optionalLabelHint => 'Optional label';

  @override
  String get imageResourceIdHint => 'IMAGE_... resource id';

  @override
  String get enterStartingPlantfoodHint =>
      'Enter the starting Plant Food amount (0 or more)';

  @override
  String get threshold => 'Threshold';

  @override
  String get delay => 'Delay';

  @override
  String get seedBankLetsPlayersChoose =>
      'Seed Bank lets players choose from available plants. In Creative Courtyard, it supports setting a global tier and enables access to all plants. When selection mode is set to Preset, placing the Seed Bank before the Conveyor Belt makes conveyor plants cost sun, while placing it after allows preset plants to be planted without sun cost.';

  @override
  String get iZombieModePresetHint =>
      'When I, Zombie Mode is enabled, available zombies must be preset. Selection mode will be forced to Preset. If both plant and zombie seed packets are used, they must be locked to the same level.';

  @override
  String get invalidIdsHint =>
      'Invalid IDs will appear as empty slots in the Seed Bank. In I, Zombie Mode, plant IDs are invalid, and vice versa. This can be used to create two Seed Banks in one level and combine both modes. Make sure the Zombie Seed Bank is placed first.';

  @override
  String get seedBankIZombie => 'Seed Bank (I, Zombie Mode)';

  @override
  String get basicRules => 'Basic Rules';

  @override
  String get selectionMethod => 'Selection Mode';

  @override
  String get emptyList => 'The list is empty';

  @override
  String get plantsAvailableAtStart => 'Plants pre-selected at the start';

  @override
  String get presetPlantListReorderHint =>
      'Long press the ⋮⋮ handle and drag to reorder.';

  @override
  String get presetPlantListReorderHintDesktop =>
      'Drag the ⋮⋮ handle to reorder.';

  @override
  String get whiteListDescription =>
      'Only these plants can be selected (no restriction if empty)';

  @override
  String get blackListDescription => 'These plants cannot be selected';

  @override
  String get availableZombiesDescription =>
      'Zombies available for I, Zombie Mode';

  @override
  String get izombieCardSlotsHint =>
      'Only certain zombies have dedicate seed packets and sun costs in I, Zombie (IZ) Mode. These zombies can be found under the \"Other\" category in the zombie selection screen.';

  @override
  String get seedBankPresetModeHint =>
      'Preset mode enters game immediately regardless of card count.';

  @override
  String get seedBankPlantLevelLabel => 'Plant level (0-5)';

  @override
  String get seedBankSlotCountLabel => 'Slot count (0-9)';

  @override
  String get seedBankCourtyardSlotsHint =>
      'Courtyard mode ignores slot count. Chooser locks 8 slots.';

  @override
  String get seedBankAddGridItemsTitle => 'Add grid items';

  @override
  String get seedBankAddGridItemsSubtitle =>
      'Append grid items to PresetPlantList. Duplicates are allowed.';

  @override
  String seedBankGridItemCount(int count) {
    return 'In preset list: $count';
  }

  @override
  String get starChallengeSelectConditions => 'Select conditions';

  @override
  String get starChallengeEditConditions => 'Edit conditions';

  @override
  String get selectToolCard => 'Select tool packets';

  @override
  String get searchGridItems => 'Search grid items';

  @override
  String get searchStatues => 'Search renaissance statues or marble mounds';

  @override
  String get noItems => 'No items';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String selectedCountTapToSearch(int count) {
    return 'Selected $count, tap to search';
  }

  @override
  String get noFavoritesLongPress => 'No favorites. Long-press to favorite.';

  @override
  String get gridItemCategoryAll => 'All Items';

  @override
  String get gridItemCategoryScene => 'Scenery';

  @override
  String get gridItemCategoryTrap => 'Interactive Traps';

  @override
  String get gridItemCategorySpawnableObjects => 'Spawnable Objects';

  @override
  String get sunDropperConfigTitle => 'Sun Drop Settings';

  @override
  String get customLocalParams => 'Custom local parameters';

  @override
  String get currentModeLocal => 'Current: local (@CurrentLevel)';

  @override
  String get currentModeSystem => 'Current: system default (@LevelModules)';

  @override
  String get paramAdjust => 'Parameter adjustment';

  @override
  String get firstDropDelay => 'Initial drop delay (InitialSunDropDelay)';

  @override
  String get initialDropInterval => 'Initial drop interval (SunCountdownBase)';

  @override
  String get maxDropInterval => 'Max drop interval (SunCountdownMax)';

  @override
  String get intervalFloatRange =>
      'Interval variation range (SunCountdownRange)';

  @override
  String get sunDropperHelpTitle => 'Sun Dropper';

  @override
  String get sunDropperHelpIntro =>
      'Configures falling sun in a level. For night lawns, this module is usually not needed.';

  @override
  String get sunDropperHelpParams => 'Parameter configuration';

  @override
  String get sunDropperHelpParamsBody =>
      'By default, this module uses the game’s built-in values. You can enable custom settings to edit detailed parameters.';

  @override
  String get noZombossMechFound => 'No ZombossMech found';

  @override
  String get noZombossBattleFound => 'No zomboss definitions found';

  @override
  String get searchChallengeNameOrCode =>
      'Search by challenge name or codename';

  @override
  String get deleteChallengeTitle => 'Delete challenge?';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return 'Remove \"$name\"? This will permanently delete the local challenge data.';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return 'Remove reference to \"$name\"? The challenge will remain in LevelModules.';
  }

  @override
  String get missingModulesRecommended =>
      'The level might not function correctly. Recommended to add the following modules:';

  @override
  String get recommendedTunnelDefendTitle =>
      'Underground Palace Pathways module strongly recommended';

  @override
  String get recommendedTunnelDefendBody =>
      'The tiles in Underground Palace Secret Realm lawns must be placed through the \"Underground Palace Pathways\" module. If this module is not added, the lawns may appear overly empty in-game.';

  @override
  String get itemListRowFirst => 'Item(s) in selected tile';

  @override
  String get railcartCowboy => 'Wild West mine cart (railcart_cowboy)';

  @override
  String get railcartFuture => 'Far Future mine cart (railcart_future)';

  @override
  String get railcartEgypt => 'Ancient Egypt mine cart (railcart_egypt)';

  @override
  String get railcartPirate => 'Pirate Seas mine cart (railcart_pirate)';

  @override
  String get railcartWorldcup => 'Ice Hockey mine cart (railcart_worldcup)';

  @override
  String get clearUnusedTitle => 'Clear unused objects?';

  @override
  String get clearUnusedMessage =>
      'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?';

  @override
  String get clearUnusedNone => 'No unused objects found.';

  @override
  String clearUnusedDone(int count) {
    return 'Removed $count unused object(s).';
  }

  @override
  String get lawnMowerTitle => 'Lawn Mowers';

  @override
  String get lawnMowerNotes => 'Notes';

  @override
  String get lawnMowerHelpOverview =>
      'Controls the appearance of lawn mowers in a level. This module does not work when the Creative Courtyard module is enabled.';

  @override
  String get lawnMowerHelpNotes =>
      'This module is typically referenced from LevelModules and does not require custom configuration within the level.';

  @override
  String get lawnMowerSelectType => 'Select mower type';

  @override
  String get zombieRushTitle => 'Level Timer module';

  @override
  String get zombieRushHelpOverview =>
      'A countdown module from Zombie Elimination Initiative. The level ends and results are calculated when the timer reaches zero.';

  @override
  String get zombieRushHelpNotes => 'Notes';

  @override
  String get zombieRushHelpIncompat =>
      'Penny’s Pursuit timer module is incompatible with Creative Courtyard and may cause crashes. It is recommended to use the Zombie Elimination Initiative timer module instead.';

  @override
  String get zombieRushTimeSettings => 'Time Settings';

  @override
  String get levelCountdown => 'Level countdown (seconds)';

  @override
  String get tunnelDefendTitle => 'Underground Palace Pathway Settings';

  @override
  String get tunnelDefendHelpOverview =>
      'Use this module to add pathways from the Underground Palace secret realm to the level. Certain zombies have their interactions with plants affected by pathways.';

  @override
  String get tunnelDefendHelpUsage => 'Usage';

  @override
  String get tunnelDefendHelpUsageBody =>
      'Select a pathway component from the list below, then click on the grid above to place it. Tapping an existing component of the same type removes it, while selecting a different component will replace it directly.';

  @override
  String get tunnelDefendSelectComponent => 'Select component';

  @override
  String get tunnelDefendPlacedCount => 'Placed components';

  @override
  String get tunnelDefendClearAll => 'Clear all';

  @override
  String get tunnelDefendClearConfirmTitle => 'Clear all pathway components?';

  @override
  String get tunnelDefendClearConfirmMessage =>
      'This will remove all placed pathway components from the lawn. This action cannot be undone.';

  @override
  String get tunnelDefendPathOutsideLawn =>
      'Pathway components outside the lawn: ';

  @override
  String get tunnelDefendDeleteOutside =>
      'Remove pathway components outside the lawn';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle =>
      'Remove pathway components outside the lawn?';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      'This will remove all pathway components outside the 5×9 lawn. This action cannot be undone.';

  @override
  String get tunnelDefendTileStylePreset => 'Tile style preset';

  @override
  String get tunnelDefendTileStylePart1 =>
      'Underground Palace Ruins (Chapter 1)';

  @override
  String get tunnelDefendTileStylePart2 =>
      'Underground Palace Spirit Supression (Chapter 2)';

  @override
  String get moduleTitle_LawnMowerProperties => 'Lawn Mowers';

  @override
  String get moduleDesc_LawnMowerProperties =>
      'Sets mower styles (may not work in custom lawns)';

  @override
  String get moduleTitle_TunnelDefendModuleProperties =>
      'Underground Palace Pathways';

  @override
  String get moduleDesc_TunnelDefendModuleProperties =>
      'Configures pathways and tile styles for Underground Palace secret realm levels';

  @override
  String get moduleTitle_WitchModuleProperties => 'Fright Witch';

  @override
  String get moduleDesc_WitchModuleProperties =>
      'Fright Witches periodically sweep across the lawn, scattering magical potions';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties =>
      'Gulliver Tunnel';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      'Places pre-set Gulliver tunnels on the lawn';

  @override
  String get witchModuleTitle => 'Fright Witch Settings';

  @override
  String get witchModuleHelpTitle => 'Fright Witch module';

  @override
  String get witchModuleHelpIntro =>
      'Enabling this module adds 2 Fright Witches to the level. After the level begins, Fright Witch will periodically enter from either the left or right side of the lawn, randomly choosing a lane and flying across it on a magic broomstick while scattering magical potions along the way. After a period of time, she returns and repeats the process.\nDifferent potions have different effects: Orange Explosion Potions deal percentage-based damage in a 3×3 area around the landing point; Green Transmutation Potions transform single-tile plants into a sheep, frog, or chicken, and may also turn them into Tall-nut seed packets; Blue Necromancy Potions continuously revive zombies that die within a 3×3 area around the landing point for a duration; Red Berserk Potions grant zombies increased health and movement speed.\nFright Witch cannot be targeted by plants. Planting a Tall-nut in her path will knock her off the lawn; if the Tall-nut has previously used Plant Food, it will shatter the witch permanently, preventing her from returning.';

  @override
  String get witchModuleHelpParams => 'Parameter configuration';

  @override
  String get witchModuleHelpParamsBody =>
      'By default, this module uses the values defined in the game files. Alternatively, you may enable custom local parameters and modify the interval between witch appearances';

  @override
  String get witchModuleSpawnInterval =>
      'Witch spawn interval (WitchSpawnInterval, seconds)';

  @override
  String get gulliverTunnelTitle => 'Gulliver Tunnel Settings';

  @override
  String get gulliverTunnelHelpOverview =>
      'This module is used to place Gulliver Tunnels on the lawn before the level begins. Depending on their orientation, Gulliver Tunnels come in two forms: a small opening on the right and a large opening on the left, or a small opening on the left and a large opening on the right.\nImps entering through the small opening become Giant Imps with increased health. Regular zombies entering through the large opening become Mini Zombies, gaining increased movement speed and the ability to avoid some higher-flying straight projectiles.\nStraight-flying plant projectiles can also enter through the large opening and emerge from the small opening after being shrunk, dealing reduced damage. Lobbed projectiles can pass over the tunnel and attack zombies normally.';

  @override
  String get gulliverTunnelHelpUsage => 'Usage';

  @override
  String get gulliverTunnelHelpUsageBody =>
      'Select a tunnel orientation below, then click a tile to place it. Clicking a tile containing an existing tunnel removes it. Selecting a different orientation and clicking an existing tunnel replaces its orientation.';

  @override
  String get gulliverTunnelOrientationBigOnLeft =>
      'Small Opening on Right, Large Opening on Left';

  @override
  String get gulliverTunnelOrientationBigOnRight =>
      'Small Opening on Left, Large Opening on Right';

  @override
  String get gulliverTunnelPlacedCount => 'Placed';

  @override
  String get gulliverTunnelClearAll => 'Clear all';

  @override
  String get gulliverTunnelClearConfirmTitle => 'Clear all Gulliver Tunnels?';

  @override
  String get gulliverTunnelClearConfirmMessage =>
      'This will removbe all placed Gulliver Tunnels from the lawn. This action cannot be undone.';

  @override
  String get gulliverTunnelSelectOrientation => 'Select orientation';

  @override
  String get gulliverTunnelOutsideLawn => 'Tunnels outside the lawn: ';

  @override
  String get gulliverTunnelDeleteOutside =>
      'Remove Gulliver Tunnels outside the lawn';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle =>
      'Remove Gulliver Tunnels outside the lawn?';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      'This will remove all Gulliver Tunnels outside the 5×9 lawn. This action cannot be undone.';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => 'Theme Configuration';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      'Adds theme effects from Penny\'s Pursuit, Memory Lane, and other game modes to the level';

  @override
  String get riftThemeModuleTitle => 'Theme Configuration';

  @override
  String get riftThemeHelpTitle => 'Theme Configuration module';

  @override
  String get riftThemeHelpOverview =>
      'This module defines a list of themes for the level. Themes are global conditions found in modes such as Penny\'s Pursuit, Memory Lane, and Secret Realm. Each theme provides unique effects. For detailed descriptions of individual themes, please refer to the wiki.gg pages covering those themes.';

  @override
  String get riftThemeHelpUsage => 'Usage';

  @override
  String get riftThemeHelpUsageBody =>
      'Click the button in the lower-right corner to open the theme selection screen. Themes can be added to or removed from the theme list by clicking them. Once all settings are complete, click the button again to confirm. Themes take effect in the order they appear in the list.';

  @override
  String get riftThemeHelpUnique => 'Addition Rules';

  @override
  String get riftThemeHelpUniqueBody =>
      'Each theme can only appear once in the list. Adding an excessive number of themes may cause the level to crash.';

  @override
  String get riftThemeEmpty =>
      'No themes selected. Tap the button in the lower-right corner to choose themes.';

  @override
  String get riftThemeAddTheme => 'Add theme';

  @override
  String get riftThemeSelectThemes => 'Select themes';

  @override
  String get riftThemeSelectTheme => 'Theme';

  @override
  String get riftThemeSearchPlaceholder => 'Search theme name or codename';

  @override
  String get riftThemeAlreadyAdded => 'Already added';

  @override
  String get riftThemeNoSearchResults => 'No matching themes';

  @override
  String get riftThemeAllUsedTitle => 'All themes added';

  @override
  String get riftThemeAllUsedMessage =>
      'All available themes have already been added. Each theme can only be added once.';

  @override
  String get moduleTitle_ZombieRushModuleProperties => 'Level Timer';

  @override
  String get moduleDesc_ZombieRushModuleProperties =>
      'Level ends when the timer reaches zero';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => 'Portal Combat';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties =>
      'Configures the spawning of PvZ1-style portals';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => 'Guess Who I Am';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties =>
      'Configures Magic Hat summons, enables Magic Hat selection';

  @override
  String get pvz1CopycatsModuleTitle => 'Guess Who I Am';

  @override
  String get pvz1CopycatsSectionParams => 'Parameters';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel =>
      'Zombie weight (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      'The probability of summoning a zombie per attempt (0–1). The probability of summoning a plant is 1 minus this value.';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      'Plant level (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel =>
      'The level of plants summoned by the Magic Hat.';

  @override
  String get pvz1CopycatsSectionPlantBlackList =>
      'Plant blacklist (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      'Each type of Magic Hat has its own plant pool. This pool is not affected by the blacklist, so modifying the blacklist has no effect.';

  @override
  String get pvz1CopycatsSectionZombieWhiteList =>
      'Zombie whitelist (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList =>
      'Only zombies in the whitelist can be summoned by the Magic Hat.';

  @override
  String get pvz1CopycatsHelpTip =>
      'After adding this module, remember to pre-select Magic Hats in the Seed Bank or Conveyor Belt module. Long press or right-click the Magic Hat in the plant selection screen to preview the plants it can summon.';

  @override
  String get pvz1CopycatsHelpOverview =>
      'This module configures the summon behavior of Magic Hats that can be planted in the seed slots, commonly used in the Memory Lane mini-game \"Guess Who I Am\". Without this module, Magic Hats will not function properly. Different types of Magic Hat vary in sun cost and cooldown time. After being planted, a Magic Hat will transform into a random plant or zombie. Plants are selected from the Magic Hat’s own plant pool, while zombies are selected only from the whitelist. The weights of individual entries in the plant or zombie pools cannot be adjusted.';

  @override
  String get pvz1CopycatsHelpFieldsTitle => 'Parameter details';

  @override
  String get pvz1CopycatsPlantListEmpty => 'Blacklist is empty';

  @override
  String get pvz1CopycatsZombieListEmpty => 'Whitelist is empty';

  @override
  String get pvz1CopycatsAddPlant => 'Add plant to blacklist';

  @override
  String get pvz1CopycatsAddZombie => 'Add zombie to whitelist';

  @override
  String get magicHatSpawnPreviewTitle => 'Possible plants from Magic Hat';

  @override
  String get magicHatSpawnPreviewEmpty => 'No plants match this blacklist.';

  @override
  String get pvz1PassageModuleTitle => 'Portal Combat';

  @override
  String get pvz1PassageSectionParams => 'Portal parameters';

  @override
  String get pvz1PassageHelpOverview =>
      'This module configures PvZ1-style portals, commonly used in the Memory Lane mini-game \"Portal Combat\". Portals appear in groups and affect the movement paths of plant projectiles and zombies, and will periodically change positions. Note that portals do not affect plant targeting. Plants will not attack zombies on the other end of a portal ahead of them, and will only attack if there are zombies in their lane.';

  @override
  String get pvz1PassageHelpFieldsTitle => 'Parameter Overview';

  @override
  String get pvz1PassageFieldGroupAmount => 'Portal types (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      'The number of portal types that appear in the level. PvZ1-style portals have two types: square and circular. If set to 1, only square portals will appear. If set to 2, both square and circular portals will appear. If set to 3 or higher, the extra portal types will display as sun textures; these portals do not change position, but can still teleport zombies.';

  @override
  String get pvz1PassageFieldPassageAmount =>
      'Portals per type (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      'The number of portals within each type. For example, if set to 2, each type will have 2 portals. The total number of portals cannot exceed the number of tiles in the spawn area. If multiple valid destination portals exist within the same type, zombies will always teleport to the designated one.';

  @override
  String get pvz1PassageFieldGridXMin => 'Minimum spawn column (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return 'The leftmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column $maxIndex. This value must be less than the maximum column value.';
  }

  @override
  String get pvz1PassageFieldGridXMax => 'Maximum spawn column (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return 'The rightmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column $maxIndex. This value must be greater than the minimum column value.';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      'Same-zombie teleport cooldown (transferCooldown, unit: seconds)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      'The minimum time between two teleports of the same zombie. If set too low, a zombie that fails to leave the portal tile within the interval may be teleported back to the original portal again once the cooldown ends.';

  @override
  String get pvz1PassageFieldRefreshTime =>
      'Portal reposition interval (refreshTime, unit: seconds)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      'The interval at which portal positions are regenerated. Portals are refreshed one at a time, meaning each refresh only changes the position of one portal within the same type.';

  @override
  String get pvz1PassagePortalSpawnPreview => 'Portal spawn column preview';

  @override
  String get pvz1PassageHelpPreview => 'Spawn Range Preview';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return 'The orange highlighted area indicates which columns portals may appear in. The column range of the current lawn is 0–$maxIndex (including both lawn boundaries). This module cannot restrict the row range where portals spawn.';
  }

  @override
  String get moduleWaveIndexZeroBasedHint => '0 = Wave 1, 1 = Wave 2, ...';

  @override
  String get moduleWaveFieldZeroBased => 'Wave (0 = Wave 1, 1 = Wave 2, ...)';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get airDropShipGroupLabel => 'Group';

  @override
  String get moduleTitle_RenaiModuleProperties => 'Renaissance Module';

  @override
  String get moduleDesc_RenaiModuleProperties =>
      'Enables the Vitruvian Wheel and day–night cycle, configures Renaissance Statues and Marble Mounds';

  @override
  String get renaiModuleTitle => 'Renaissance Module Settings';

  @override
  String get renaiModuleHelpTitle => 'Renaissance Module';

  @override
  String get renaiModuleHelpOverview => 'Overview';

  @override
  String get renaiModuleHelpOverviewBody =>
      'This module is used to make the Vitruvian Wheel respond to Floor-de-Lis tiles; configure day–night cycle waves; and, at night, revive Renaissance Statues and Marble Mounds, and spawn grid items based on settings. Typically used in Renaissance Ages levels.';

  @override
  String get renaiModuleHelpStatues => 'Notes';

  @override
  String get renaiModuleHelpStatuesBody =>
      'Initial grid items refer to statues and Marble Mounds present at the start of the level, which revive into zombies at specified waves. Night grid items are generated after night begins; if a plant occupies the target tile, they will not spawn. Night start wave uses a 0-based index (e.g., 0 = first wave, 1 = second wave).';

  @override
  String get renaiModuleEnableNight => 'Enable Day–Night Cycle';

  @override
  String get renaiModuleEnableNightSubtitle =>
      'Allows setting the wave when night begins and configuring night grid items';

  @override
  String get renaiModuleNightStart => 'Night Start Wave';

  @override
  String get renaiModuleDayStatues => 'Initial grid items';

  @override
  String get renaiModuleNightStatues => 'Night grid items';

  @override
  String get renaiModuleNightStatuesDisabledHint =>
      'Please enable the day–night cycle first';

  @override
  String get renaiModuleAddStatue => 'Add statue';

  @override
  String get renaiModuleCarveWave => 'Statue revival wave';

  @override
  String get renaiModuleStatuesInCell => 'Item(s) in selected tile';

  @override
  String get renaiModuleExpectationLabel => 'Night event';

  @override
  String get renaiModuleNightStarts => 'Night begins';

  @override
  String get renaiModuleStatueCarve => 'Statue revival';

  @override
  String get moduleTitle_DropShipProperties => 'Transport Boat Assault';

  @override
  String get moduleDesc_DropShipProperties =>
      'Airdrops Flying Imp Zombies onto the lawn';

  @override
  String get airDropShipModuleTitle => 'Transport Boat Assault';

  @override
  String get airDropShipModuleHelpTitle => 'Transport Boat Assault module';

  @override
  String get airDropShipModuleHelpOverview => 'Overview';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      'This module is used to configure Transport Boats that appear during waves in a level, commonly seen in Sky City levels. Transport Boats cannot be damaged. A set number of Flying Imp Zombies will drop sequentially into the designated drop area.';

  @override
  String get airDropShipModuleHelpImps => 'Parameters';

  @override
  String get airDropShipModuleHelpImpsBody =>
      'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Each Transport Boat drops at least one Flying Imp Zombie. The extra imp count specifies how many additional imps are dropped on top of the initial one for that wave.';

  @override
  String get airDropShipModuleAppearWaves =>
      'Appear waves (Wave; starts from 0)';

  @override
  String get airDropShipModuleAppearances => 'Assault Groups';

  @override
  String get airDropShipModuleExtraImpCount => 'Extra imp count (Imp)';

  @override
  String get airDropShipModuleDropArea => 'Drop area';

  @override
  String get airDropShipModuleDropAreaPreview => 'Drop area preview';

  @override
  String get airDropShipModuleExpectationLabel => 'Airdropped Imps';

  @override
  String get airDropShipModuleImpLevel => 'Imp level (ImpLv)';

  @override
  String get airDropShipModuleRowMin => 'Start row';

  @override
  String get airDropShipModuleRowMax => 'End row';

  @override
  String get airDropShipModuleColMin => 'Start column';

  @override
  String get airDropShipModuleColMax => 'End column';

  @override
  String get openModuleSettings => 'Open Module Settings';

  @override
  String get moduleTitle_GlacierModuleProperties => 'Glacier Spawn';

  @override
  String get moduleDesc_GlacierModuleProperties =>
      'Zombie spawn weights for Ice Age Zomboss glacier blocks (6 columns from the left)';

  @override
  String get glacierModuleTitle => 'Glacier module';

  @override
  String get glacierModuleHelpTitle => 'Glacier module';

  @override
  String get glacierModuleHelpOverviewBody =>
      'Configures which zombies can emerge from glacier blocks when the Ice Age Zomboss destroys them. Place this module at the start of the level Modules list. Without it, glacier blocks will not spawn zombies.';

  @override
  String get glacierModuleHelpColumnsTitle => 'Columns and entries';

  @override
  String get glacierModuleHelpColumnsBody =>
      'ZombieSpawnData always has exactly six elements, one per column counting from the left edge of the lawn. Each column holds a weighted list of zombie types (TypeName), spawn weight (Weight), and level (Level, 0–10).';

  @override
  String get glacierModuleHelpRequirementsTitle => 'Requirements';

  @override
  String get glacierModuleHelpRequirementsBody =>
      'Only takes effect together with the Zomboss Battle module when the selected Zomboss Mech is an Ice Age variant (zombossmech_iceage and its variations).';

  @override
  String get glacierModuleCompatibilityWarning =>
      'This module only works with the Zomboss Battle module and an Ice Age Zomboss Mech (zombossmech_iceage). Add or fix those settings so glacier blocks can spawn zombies.';

  @override
  String glacierModuleColumn(int columnIndex) {
    return 'Column $columnIndex (from left)';
  }

  @override
  String glacierModuleEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String glacierModuleEntryLabel(int index) {
    return 'Entry $index';
  }

  @override
  String get glacierModuleNoEntries => 'No zombie entries for this column.';

  @override
  String get glacierModuleAddEntry => 'Add zombie entry';

  @override
  String get glacierModuleSelectZombie => 'Select zombie';

  @override
  String get glacierModuleEmptyType => 'No zombie selected';

  @override
  String get glacierModuleWeight => 'Weight';

  @override
  String get glacierModuleWeightTooltip =>
      'Relative spawn weight for this zombie in this column.';

  @override
  String get glacierModuleLevel => 'Level (0–10)';

  @override
  String get glacierModuleLevelTooltip => 'Zombie level from 0 to 10.';

  @override
  String get moduleTitle_HeianWindModuleProperties => 'Heian Divine Wind';

  @override
  String get moduleDesc_HeianWindModuleProperties =>
      'Wind that pushes zombies and knocks plants into the air';

  @override
  String get heianWindModuleTitle => 'Heian Divine Wind Settings';

  @override
  String get heianWindModuleHelpTitle => 'Heian Divine Wind module';

  @override
  String get heianWindModuleHelpOverview => 'Overview';

  @override
  String get heianWindModuleHelpOverviewBody =>
      'This module is used to summon Divine Wind at specified waves, commonly seen in Heian Ages levels. The wind pushes a set number of small and medium zombies within its range horizontally. After all winds in a wave finish, rows affected by single-row winds will generate a whirlwind (one per row). The whirlwind carries zombies forward and knocks plants into the air on contact before disappearing.';

  @override
  String get heianWindModuleHelpDistance => 'Distance';

  @override
  String get heianWindModuleHelpDistanceBody =>
      '1 tile = 50 distance units. Negative values push zombies to the left, while positive values push them to the right.';

  @override
  String get heianWindModuleHelpRow => 'Coverage';

  @override
  String get heianWindModuleHelpRowBody =>
      'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Target rows are also indexed from 0. You can specify a single row or set it to -1 to affect all rows; in this case, no whirlwind will be generated.';

  @override
  String get heianWindModuleWaves => 'Appear waves (WaveNumber; starts from 0)';

  @override
  String get heianWindModuleAppearances => 'Summon Batches';

  @override
  String get heianWindModuleWindDelay => 'Wind Delay (unit: seconds)';

  @override
  String get heianWindModuleWindEntries => 'Wind configurations';

  @override
  String get heianWindModuleAddWind => 'Add wind';

  @override
  String get heianWindModuleRow => 'Single Row (starts from 0)';

  @override
  String get heianWindModuleAllRows => 'All rows (-1)';

  @override
  String get heianWindModuleAffectZombies =>
      'Affected zombie count (AffectZombies)';

  @override
  String get heianWindModuleDistance =>
      'Push Distance (Distance; 1 tile = 50 units)';

  @override
  String get heianWindModuleMoveTime =>
      'Move Duration (MoveTime; unit: seconds)';

  @override
  String get heianWindModuleExpectationLabel => 'Divine Wind Settings';

  @override
  String get jsonViewerModeReading => '(plain text view)';

  @override
  String get jsonViewerModeObjectReading => '(structured view)';

  @override
  String get jsonViewerModeEdit => '(edit mode)';

  @override
  String get tooltipAboutModule => 'About this module';

  @override
  String get tooltipAboutEvent => 'About this event';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipClose => 'Close';

  @override
  String get tooltipToggleObjectView => 'Toggle plain text / structured view';

  @override
  String get tooltipClearUnused => 'Clear unused objects';

  @override
  String get tooltipJsonViewer => 'View/edit JSON';

  @override
  String get tooltipAdd => 'Add';

  @override
  String get tooltipDecrease => 'Decrease';

  @override
  String get tooltipIncrease => 'Increase';

  @override
  String get bungeeWaveEventTitle => 'Bungee Drop Settings';

  @override
  String get bungeeWaveEventHelpTitle => 'Bungee Drop';

  @override
  String get bungeeWaveEventHelpOverview =>
      'Configures the zombie type and drop position for Bungee Zombie deployment. Each event can drop only one zombie.';

  @override
  String get bungeeWaveEventHelpGrid => 'Coordinates';

  @override
  String get bungeeWaveEventHelpGridBody =>
      'Tap a cell in the grid to set where the Bungee Zombie will land.';

  @override
  String get bungeeWaveCurrentTarget => 'Current target';

  @override
  String get bungeeWaveCol => 'Col';

  @override
  String get bungeeWaveRow => 'Row';

  @override
  String get bungeeWavePropertiesConfig => 'Properties';

  @override
  String get bungeeWaveZombieLevel => 'Zombie level (Level)';

  @override
  String get bungeeWaveRoofWarning =>
      'In Roof levels, if a Bungee Zombie spawned by this event is blocked by Umbrella Leaf, it may immediately trigger a loss. Use with caution.';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => 'Zombie Sun Drop';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps =>
      'Zombies drop sun when defeated';

  @override
  String get zombieSunDropTitle => 'Zombie Sun Drop Settings';

  @override
  String get zombieSunDropHelpTitle => 'Zombie Sun Drop module';

  @override
  String get zombieSunDropHelpOverview =>
      'This module is used to configure how much sun specific zombies drop in a level, mainly for Penny\'s Pursuit Level 5. As a side effect, the Sun Shovel becomes ineffective.';

  @override
  String get zombieSunDropHelpValues => 'Values';

  @override
  String get zombieSunDropHelpValuesBody =>
      '10 integer values correspond to sun dropped at levels 1–10. For levels above 6, the value for level 1 will be used.';

  @override
  String get zombieSunDropEmpty =>
      'No configuration yet. Tap the \"+\" button in the bottom right to add.';

  @override
  String get zombieSunDropDefaultDrop => 'Default drop';

  @override
  String get zombieSunDropSun => 'sun';

  @override
  String get zombieSunDropEditTitle => 'Edit values';

  @override
  String get zombieSunDropEditHint =>
      'Configure the amount of sun dropped by this zombie at different levels; for levels above 6, the level 1 value will be used';

  @override
  String get zombieSunDropTier => 'Level';

  @override
  String get moduleTitle_PickupCollectableTutorialProperties =>
      'Pickup Collectible Tutorial';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties =>
      'Shows tutorial dialog boxes when specific zombies are defeated';

  @override
  String get pickupCollectableTutorialTitle =>
      'Pickup Collectible Tutorial Settings';

  @override
  String get pickupCollectableTutorialHelpTitle =>
      'Pickup Collectible Tutorial module';

  @override
  String get pickupCollectableTutorialHelpBasic => 'Overview';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      'Configures zombies that drop specific items and the guidance text shown before and after picking them up. A dialog box will appear when this type of zombie (including custom zombies) is defeated for the first time in the level.';

  @override
  String get pickupCollectableTutorialHelpDialogs => 'Dialogs';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      'Dialogs will appear before and after picking up the item. These dialogs pause level progression and delay the next wave.';

  @override
  String get pickupCollectableTutorialCoreConfig => 'Core configuration';

  @override
  String get pickupCollectableTutorialZombieLabel => 'Item-carrying zombie';

  @override
  String get pickupCollectableTutorialLootType => 'Item type';

  @override
  String get pickupCollectableTutorialGuideText => 'Guidance text';

  @override
  String get pickupCollectableTutorialPickupAdvice =>
      'Pre-pickup dialog (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      'Post-pickup dialog (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => 'Not set';

  @override
  String get pickupCollectableLootGoldCoin => 'Coin';

  @override
  String get invalidRtonMagic => 'Invalid RTON file: magic must be \"RTON\".';

  @override
  String get invalidRtonVersion => 'Invalid RTON version (expected 1).';

  @override
  String get invalidRtonEnd => 'Invalid RTON file: must end with \"DONE\".';

  @override
  String get invalidRtonArrayEnd => 'Invalid RTON array delimiter.';

  @override
  String get invalidRtid => 'Invalid RTID value.';

  @override
  String get invalidValueType => 'Invalid value type for RTON.';

  @override
  String get musicSuffix => 'Music settings';

  @override
  String get ambientAudioSuffix => 'Ambient audio settings';

  @override
  String get selectMusicSuffix => 'Select music settings';

  @override
  String get searchMusicSuffix => 'Search by name or codename';

  @override
  String get noMusicSuffixFound => 'No music settings found';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => 'Custom';

  @override
  String get editCustomZombossMech => 'Edit';

  @override
  String get customZombossMechProperties => 'Custom ZombossMech properties';

  @override
  String get customZombossMechScalars => 'General';

  @override
  String get customZombossMechStages => 'Battle phases';

  @override
  String get customZombossMechEditHint =>
      'Edit level-local property sheet for the memo (custom) mech variation.';

  @override
  String get zombossMechMinColumn => 'Min column';

  @override
  String get zombossMechMaxColumn => 'Max column';

  @override
  String get zombossMechStageActions => 'Actions';

  @override
  String get zombossMechActions => 'Actions';

  @override
  String get zombossMechPropertiesLabel => 'Properties';

  @override
  String get zombossMechAliasLabel => 'Alias';

  @override
  String get zombossMechDeletePhase => 'Delete phase';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return 'Delete phase $number?';
  }

  @override
  String get zombossMechDeletePhaseMessage =>
      'This removes the phase and its action list. This cannot be undone.';

  @override
  String get zombossMechPhasesHelp =>
      'Each phase has hit points, an ordered action list (executed top to bottom), and optionally a retreat action when the mech supports it.';

  @override
  String get zombossMechAddAction => 'Add action';

  @override
  String get zombossMechNoStageActions => 'No actions yet';

  @override
  String get zombossMechSelectAction => 'Select action';

  @override
  String get zombossMechSelectRetreatAction => 'Select retreat action';

  @override
  String get zombossMechCreateCustomAction => 'New custom action';

  @override
  String get zombossMechEditCustomAction => 'Edit custom action';

  @override
  String get zombossMechActionCategoryAll => 'All';

  @override
  String get zombossMechActionCategoryMovement => 'Movement';

  @override
  String get zombossMechActionCategoryAttack => 'Attack';

  @override
  String get zombossMechActionCategorySpecial => 'Special';

  @override
  String get zombossMechActionCategorySpawn => 'Spawn';

  @override
  String get zombossMechActionCategoryRetreat => 'Retreat';

  @override
  String get zombossMechNoActionsFound => 'No actions found';

  @override
  String get zombossMechCustomActionLabel => 'Custom (CurrentLevel)';

  @override
  String get zombossMechActionAliasHint =>
      'Codename used in RTID(alias@CurrentLevel). You can change it later; references in this property sheet update automatically.';

  @override
  String get zombossMechActionBaseObjclass => 'Base objclass';

  @override
  String get zombossMechEditRetreatAction => 'Choose retreat action';

  @override
  String get zombossMechAddZombie => 'Add zombie';

  @override
  String get zombossMechPickZombie => 'Pick zombie';

  @override
  String get zombossMechNoZombiesInList => 'No zombies in list';

  @override
  String get zombossMechCatalogActionReadOnly =>
      'Built-in actions cannot be edited here. Create a custom action to change zombie lists.';

  @override
  String get zombossMechRetreatDisabled => 'Disabled';

  @override
  String get zombossMechOpenGlacierModule => 'Open glacier module settings';

  @override
  String get zombossMechRobotSpawnRow => 'Row';

  @override
  String get zombossMechRobotSpawnRowRandom => 'Random (-1)';

  @override
  String get zombossMechRobotSpawnLevel => 'Level';

  @override
  String get zombossMechRobotSpawnWeight => 'Weight';

  @override
  String get zombossMechRobotSpawnPlantfood => 'Plant food';

  @override
  String get zombossMechRetreatAction => 'Retreat action';

  @override
  String zombossMechPhaseNumber(int number) {
    return 'Phase $number';
  }

  @override
  String get zombossMechAddPhase => 'Add phase';

  @override
  String get zombossMechRemovePhase => 'Remove phase';

  @override
  String get zombossMechHitPoints => 'Hit points';
}
