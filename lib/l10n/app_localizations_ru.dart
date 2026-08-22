// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get error => 'Ошибка';

  @override
  String get warning => 'Предупреждение';

  @override
  String get info => 'Информация';

  @override
  String get success => 'Успех';

  @override
  String get previewTabPlants => 'Растения';

  @override
  String get previewTabZombies => 'Зомби';

  @override
  String get previewTabGridItems => 'Объекты';

  @override
  String get sunBombFalling => 'Падают солнечные бомбы';

  @override
  String get sunDroppingActive => 'Солнце падает с неба';

  @override
  String get sunDroppingInactive => 'Солнце не падает с неба';

  @override
  String get conveyorChanges => 'Изменения в конвейере';

  @override
  String get willBeAdded => 'добавится';

  @override
  String get willBeRemoved => 'удалится';

  @override
  String get waveNumberLegend => 'Цифра — номер волны';

  @override
  String get expand => 'Развернуть';

  @override
  String get obtainableInLevel => 'Можно получить на уровне';

  @override
  String get allZombiesInLevel => 'Все зомби на уровне';

  @override
  String get allObjectsInLevel => 'Все объекты на уровне';

  @override
  String get allEventsInLevel => 'Все события на уровне';

  @override
  String get overwhelmLabel => 'Заполнение колонн';

  @override
  String get fastEntryLabel => 'Быстрый вход';

  @override
  String get zombieRushLabel => 'Таймер уровня';

  @override
  String get spermWhaleLabel => 'Приближение кита';

  @override
  String get witchLabel => 'Испуганная ведьма';

  @override
  String get lawnMowerLabel => 'Газонокосилка';

  @override
  String get lawnMowerTypeLabel => 'Тип газонокосилок';

  @override
  String get renaissanceStatues => 'Статуи Ренессанса';

  @override
  String get zomboss => 'Зомбосс';

  @override
  String get boss => 'Босс';

  @override
  String get zombossData => 'Данные Зомбосса';

  @override
  String get contentsLabel => 'Содержимое:';

  @override
  String get vaseSpawnArea => 'Зона появления ваз';

  @override
  String get guessWhoIAm => 'Угадай, кто я';

  @override
  String get plantBlackList => 'Чёрный список растений';

  @override
  String get zombieWhiteList => 'Белый список зомби';

  @override
  String get zombieWeight => 'Вес зомби';

  @override
  String get rainContent => 'Содержимое дождя';

  @override
  String get heianWind => 'Ветер Хэйан';

  @override
  String get all => 'Все';

  @override
  String get impLv => 'Ур. импа';

  @override
  String get sortByLabel => 'Сортировка';

  @override
  String get sortByName => 'Сортировка: по имени';

  @override
  String get sortByCreationDate => 'Сортировка: по дате создания';

  @override
  String get sortByModificationDate => 'Сортировка: по дате изменения';

  @override
  String get sortBySize => 'Сортировка: по размеру';

  @override
  String get sortByFileType => 'Сортировка: по типу файла';

  @override
  String impsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count импов',
      many: '$count импов',
      few: '$count импа',
      one: '1 имп',
    );
    return '$_temp0';
  }

  @override
  String get dropShip => 'Воздушный сброс';

  @override
  String get totalLabel => 'Всего';

  @override
  String get totalPlantFoodTooltip =>
      'Всего подкормки на уровне (включая дроп и события)';

  @override
  String get appTitle => 'Моё рабочее пространство';

  @override
  String get about => 'О программе';

  @override
  String get refresh => 'Обновить';

  @override
  String get toggleTheme => 'Переключить тему';

  @override
  String get switchFolder => 'Сменить папку';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get ultra => 'Ультра';

  @override
  String get uiSize => 'Размер интерфейса';

  @override
  String get aboutSoftware => 'О программе';

  @override
  String get pluginsTitle => 'Плагины';

  @override
  String get pluginInstallNew => 'Установить новый плагин';

  @override
  String get pluginInstallFromDevice => 'Установить с устройства';

  @override
  String get pluginInstallFromUrl => 'Установить по URL';

  @override
  String get pluginInstallFromFolder => 'Загрузить папку (отладка)';

  @override
  String get pluginUrlHint => 'https://example.com/my_plugin.cplugin';

  @override
  String get pluginDownload => 'Скачать';

  @override
  String get pluginInstalling => 'Установка плагина…';

  @override
  String pluginDownloadProgress(String received, String total) {
    return 'Загрузка $received / $total';
  }

  @override
  String pluginDownloadProgressUnknown(String received) {
    return 'Загрузка $received';
  }

  @override
  String pluginInstallSuccess(String name) {
    return 'Установлен $name';
  }

  @override
  String pluginInstallFailed(String error) {
    return 'Ошибка установки: $error';
  }

  @override
  String pluginInvalidFile(String reason) {
    return 'Неверный плагин: $reason';
  }

  @override
  String get pluginInvalidUrl => 'Введите корректный http(s) URL';

  @override
  String get pluginReadFailed => 'Не удалось прочитать выбранный файл';

  @override
  String get pluginTrustWarningTitle => 'Предупреждение';

  @override
  String get pluginTrustWarningBody =>
      'Плагины выполняют код внутри C-Editor. Устанавливайте плагины только из доверенных источников. Доступ к файлам и сети по умолчанию ограничен, но вредоносные плагины всё ещё могут нарушить работу интерфейса редактора.';

  @override
  String get pluginInstalledSection => 'Установленные плагины';

  @override
  String get pluginScreensSection => 'Функции и экраны';

  @override
  String get pluginEmpty =>
      'Плагины ещё не установлены. Установите файл .cplugin с устройства или по ссылке.';

  @override
  String get pluginNoScreens => 'Этот плагин не регистрирует экраны.';

  @override
  String get pluginUninstall => 'Удалить';

  @override
  String get pluginUninstallTitle => 'Удалить плагин';

  @override
  String pluginUninstallConfirm(String name) {
    return 'Удалить $name с этого устройства?';
  }

  @override
  String get pluginLoadError => 'Ошибка загрузки';

  @override
  String get pluginBundledBadge => 'Встроенный';

  @override
  String get pluginImportedBadge => 'Установленный';

  @override
  String get pluginsFolderReserved =>
      'Имя папки \".plugins\" зарезервировано для плагинов редактора. Выберите другое имя.';

  @override
  String get pluginNoLibraryForInstall =>
      'Сначала выберите папку рабочего пространства, затем установите плагины.';

  @override
  String pluginShowingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показано $count плагинов',
      many: 'Показано $count плагинов',
      few: 'Показано $count плагина',
      one: 'Показан $count плагин',
    );
    return '$_temp0';
  }

  @override
  String get pluginSearchHint => 'Поиск плагинов';

  @override
  String get pluginSelectHint =>
      'Выберите плагин, чтобы увидеть сведения, настройки и функции.';

  @override
  String get pluginEnabled => 'Включён';

  @override
  String get pluginDisabled => 'Выключен';

  @override
  String get pluginAuthors => 'Авторы';

  @override
  String get pluginContributors => 'Участники';

  @override
  String pluginByAuthors(String authors) {
    return 'Авторы: $authors';
  }

  @override
  String get pluginLicense => 'Лицензия';

  @override
  String pluginVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get pluginIdLabel => 'ID';

  @override
  String get pluginLinks => 'Ссылки';

  @override
  String get pluginLinkWebsite => 'Сайт';

  @override
  String get pluginLinkIssues => 'Issues';

  @override
  String get pluginLinkSource => 'Исходный код';

  @override
  String get pluginLinkDiscord => 'Discord';

  @override
  String get pluginIncompatibleWith => 'Несовместим с';

  @override
  String get pluginOpenScreen => 'Открыть';

  @override
  String get pluginFeaturesSection => 'Функции и экраны';

  @override
  String get pluginNoDescription => 'Описание не указано.';

  @override
  String get share => 'Поделиться';

  @override
  String shareLevelFileText(String name) {
    return 'Файл уровня: $name';
  }

  @override
  String get shareLevelFailed => 'Не удалось поделиться файлом уровня';

  @override
  String get shareAsFile => 'Поделиться файлом';

  @override
  String get shareAsPreview => 'Поделиться превью';

  @override
  String get selectBackground => 'Выберите фон';

  @override
  String get autoSelectBackground => 'Автоподбор';

  @override
  String get customBackground => 'Свой фон';

  @override
  String get selectPlantList => 'Выберите список растений';

  @override
  String get levelContainsCustomZombies =>
      'В уровне присутствуют кастомные зомби';

  @override
  String get generatingPreview => 'Создание превью...';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get imageSavedSuccessfully => 'Изображение успешно сохранено';

  @override
  String get shareOptionTitle => 'Как поделиться?';

  @override
  String get selectLevelType => 'Выберите тип уровня';

  @override
  String get autoSelectLevelType => 'Автоподбор';

  @override
  String get manualSelectLevelType => 'Ручной выбор';

  @override
  String get levelTypeAdventure => 'Приключение';

  @override
  String get levelTypeLastStand => 'Последний рубеж';

  @override
  String get levelTypeConveyor => 'Конвейер';

  @override
  String get levelTypeSeedRain => 'Дождь из семян';

  @override
  String get levelTypeIPlant => 'Я растение';

  @override
  String get levelTypeOldStyle => 'Старый тип';

  @override
  String get levelTypeUnknown => 'Неизвестно';

  @override
  String get selectFolder => 'Выбрать папку';

  @override
  String get storagePermissionHint =>
      'Требуется разрешение на доступ к хранилищу. Включите «Разрешить управление всеми файлами» в настройках.';

  @override
  String get storagePermissionDialogTitle =>
      'Требуется разрешение на хранилище';

  @override
  String get storagePermissionDialogMessage =>
      'Приложению необходим доступ к внешнему хранилищу для открытия и сохранения файлов уровней. Пожалуйста, предоставьте разрешение «Управление всеми файлами» в настройках.';

  @override
  String get storagePermissionGoToSettings => 'Перейти в настройки';

  @override
  String get storagePermissionDeny => 'Отказать';

  @override
  String get initSetup => 'Начальная настройка';

  @override
  String get selectFolderPrompt => 'Выберите папку для хранения уровней.';

  @override
  String get selectFolderButton => 'Выбрать папку';

  @override
  String get uploadToWebsite => 'Загрузить на сайт';

  @override
  String get importFiles => 'Импортировать файлы';

  @override
  String get importFolder => 'Импортировать папку';

  @override
  String get importFolderEmpty => 'В выбранной папке нет файлов уровней';

  @override
  String importFolderSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count уровней',
      many: 'Импортировано $count уровней',
      few: 'Импортировано $count уровня',
      one: 'Импортирован $count уровень',
    );
    return '$_temp0';
  }

  @override
  String get importFilesUnreadable =>
      'Не удалось прочитать выбранные файлы. Попробуйте меньшие файлы или другой браузер.';

  @override
  String get importFolderUnsupported =>
      'Импорт папки не поддерживается в этом браузере.';

  @override
  String get uploadLevelPickerTitle =>
      'Выберите один или несколько уровней для загрузки';

  @override
  String get smartUploadTitle => 'Дубликат файла';

  @override
  String smartUploadFileMessage(String fileName) {
    return 'Этот файл уже есть в вашем рабочем пространстве:\n\n$fileName\n\nЧто сделать?';
  }

  @override
  String get smartUploadSkip => 'Не загружать';

  @override
  String get smartUploadOverwrite => 'Перезаписать';

  @override
  String get smartUploadAsCopy => 'Загрузить как копию';

  @override
  String get smartUploadSkipAll => 'Не загружать все';

  @override
  String get smartUploadOverwriteAll => 'Перезаписать все';

  @override
  String get smartUploadCopyAll => 'Загрузить все как копии';

  @override
  String get localFileKeepTitle => 'Сохранить уровень из браузера?';

  @override
  String localFileKeepMessage(String fileName) {
    return 'Этот уровень хранится только в браузере:\n\n$fileName\n\nСохранить его при подключении локальной папки?';
  }

  @override
  String get localFileKeep => 'Сохранить';

  @override
  String get localFileDiscard => 'Удалить';

  @override
  String get localFileKeepAll => 'Сохранить все';

  @override
  String get localFileDiscardAll => 'Удалить все';

  @override
  String get openFolder => 'Открыть папку';

  @override
  String get levelLibraryPath => 'Папка рабочего пространства';

  @override
  String get levelLibraryPathHint =>
      'Уровни хранятся в этой папке. На iOS можно выбрать любую папку — доступ сохраняется после перезапуска.';

  @override
  String get pathCopied => 'Путь скопирован в буфер обмена';

  @override
  String get useDefaultLibraryFolder => 'Использовать папку по умолчанию';

  @override
  String get emptyFolder => 'Папка пуста';

  @override
  String get newFolder => 'Новая папка';

  @override
  String get newLevel => 'Новый уровень';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get copy => 'Копировать';

  @override
  String get download => 'Скачать';

  @override
  String get downloadAllLevels => 'Экспорт рабочей области';

  @override
  String get downloadFolder => 'Скачать эту папку';

  @override
  String get exportLevels => 'Экспорт уровней';

  @override
  String get exportSelectLevels => 'Выберите уровни для экспорта';

  @override
  String get exportSelectFile =>
      'Выберите архив уровней для экспорта (.rsb.smf)';

  @override
  String exportSelectedFile(String path) {
    return 'Выбранный файл: $path';
  }

  @override
  String get backupRecommendationTitle =>
      'Рекомендация по резервному копированию';

  @override
  String get backupRecommendationBody =>
      'Настоятельно рекомендуется создать резервную копию архива уровней перед экспортом. Это поможет избежать потери данных в случае прерывания операции.';

  @override
  String get backupAndProceed => 'Создать копию и продолжить';

  @override
  String get proceedWithoutBackup => 'Продолжить без копии';

  @override
  String get backupSuffix => '_копия';

  @override
  String get exportNoFilesFound => 'Нужные файлы не найдены (.rsb.smf).';

  @override
  String get exportDownloadExternalDynamic => 'Скачать dynamic…';

  @override
  String get cancelExportTitle => 'Отмена экспорта';

  @override
  String get cancelExportMessage =>
      'Вы уверены, что хотите прервать процесс экспорта?';

  @override
  String get exportDisclaimerTitle =>
      'Предупреждение о рисках и отказ от ответственности';

  @override
  String get exportDisclaimerBody =>
      'Данный инструмент предназначен для прямого изменения данных игры «Plants vs. Zombies 2».\n\n• Использование этого инструмента для изменения игровых данных может нарушать условия обслуживания игры.\n• Это может привести к временной или постоянной блокировке вашей игровой учетной записи.\n• Это может привести к повреждению игровых сохранений или потере данных.\n• Все действия совершаются пользователем добрововольно, на свой страх и риск.\n\nОтказ от ответственности:\n\nРазработчик настоящим заявляет:\n1. Данный инструмент предназначен только для ознакомления и исследований; любые формы читерства в игре не поощряются.\n2. Все последствия использования данного инструмента, включая, помимо прочего, блокировку аккаунта, потерю данных и ухудшение игрового процесса, ложатся исключительно на пользователя. Разработчик не несет никакой прямой или косвенной ответственности.\n3. Пользователи должны полностью осознавать связанные с этим риски перед использованием данного инструмента и самостоятельно принимать решение о принятии этих рисков.\n4. Дальнейшее использование означает, что вы прочитали, поняли и согласны со всеми условиями данного отказа от ответственности.';

  @override
  String get exportDisclaimerDoNotShowAgain =>
      'Больше не показывать по умолчанию';

  @override
  String get importProgressTitle => 'Импорт файлов…';

  @override
  String get exportProgressTitle => 'Подготовка экспорта…';

  @override
  String get backupProgressTitle => 'Создание резервной копии…';

  @override
  String transferProgressCount(int completed, int total) {
    return '$completed / $total';
  }

  @override
  String get folderAccessError =>
      'Выбранная папка доступна только для чтения или недоступна. Пожалуйста, выберите другую папку.';

  @override
  String get webFolderImportNotice =>
      'Папка импортирована в хранилище браузера. В этом браузере изменения не записываются на диск автоматически — используйте «Экспорт».';

  @override
  String get favorite => 'В избранное';

  @override
  String get unfavorite => 'Убрать из избранного';

  @override
  String get move => 'Переместить';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get convert => 'Преобразовать';

  @override
  String get convertHelpTooltip =>
      'Преобразование между JSON, HUJSON (хот-апдейт) и зашифрованным RTON (dynamic.rsb.smf).';

  @override
  String get create => 'Создать';

  @override
  String get newName => 'Новое имя';

  @override
  String get folderName => 'Имя папки';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String confirmDeleteMessage(String name, String detail) {
    return 'Вы уверены, что хотите удалить «$name»? $detail';
  }

  @override
  String get folderDeleteDetail =>
      'Если это папка, её содержимое также будет удалено.';

  @override
  String get levelDeleteDetail => 'Это действие нельзя отменить.';

  @override
  String get confirmDeleteCheckbox => 'Я подтверждаю безвозвратное удаление';

  @override
  String get renameSuccess => 'Успешно переименовано';

  @override
  String get renameFail => 'Ошибка переименования, файл уже существует';

  @override
  String get uploadLevel => 'Опубликовать на Креаторскую Площадку';

  @override
  String get uploadLevelConfirm =>
      'Сейчас вы покинете редактор и перейдёте на официальный сайт продвинутой Креаторской Площадки. После регистрации/входа через эл. почту, вы сможете загружать JSON файлы уровней из редактора прямо в игровую Креаторскую Площадку, чтобы другие люди могли сыграть в ваш уровень. Хотите продолжить?';

  @override
  String get back => 'Назад';

  @override
  String get noLevelsFound => 'Уровни не найдены';

  @override
  String get searchLevel => 'Поиск уровней...';

  @override
  String get proceed => 'Продолжить';

  @override
  String get startExport => 'Приступить';

  @override
  String get exportProceed => 'Продолжить';

  @override
  String get exportBegin => 'Приступить';

  @override
  String get exportStatusCreatingRton => 'Создание RTON уровней...';

  @override
  String get exportStatusUnpackingRsb => 'Распаковка RSB...';

  @override
  String get exportStatusUnpackingRsg => 'Распаковка Packages.rsg...';

  @override
  String get exportStatusInjecting => 'Инъекция уровней...';

  @override
  String get exportStatusRepackingRsg => 'Запаковка RSG...';

  @override
  String get exportStatusRepackingRsb => 'Запаковка RSB...';

  @override
  String get exportStatusFinalizing => 'Завершение...';

  @override
  String get exportAssignmentProposalTitle => 'Распределение уровней';

  @override
  String get exportWorld => 'Мир';

  @override
  String get exportLevelNumber => 'Номер уровня';

  @override
  String exportLevelShort(int level) {
    return 'ур. $level';
  }

  @override
  String get exportFinish => 'Завершить';

  @override
  String get exportSuccessTitle => 'Экспорт завершён';

  @override
  String exportSuccessMessage(String file) {
    return 'Уровни были успешно экспортированы в $file.';
  }

  @override
  String get exportCancelled => 'Экспорт отменён.';

  @override
  String exportDuplicateAssignment(String world, int level) {
    return 'Повторяющееся распределение: $world $level';
  }

  @override
  String get exportAssignmentIncomplete => 'Не все уровни распределены';

  @override
  String get exportConfirmationTitle => 'Подтвердите выбор';

  @override
  String get exportConfirmationBody =>
      'Пожалуйста, проверьте распределение перед продолжением.';

  @override
  String get exportFinalCheckTitle => 'Финальная проверка';

  @override
  String get exportFinalCheckBody =>
      'Следующие уровни будут экспортированы с новыми именами:';

  @override
  String exportTargetArchive(String file) {
    return 'Все уровни будут экспортированы в $file';
  }

  @override
  String get exportStart => 'Начать экспорт';

  @override
  String get exportAssignmentProposalBody =>
      'Выбранные уровни проверены. Теперь необходимо выбрать, какой слот в приключении будет занимать каждый из них.';

  @override
  String get copyReferenceOrDeep =>
      'Скопировать ссылку или создать полную копию?';

  @override
  String get copyReference => 'Скопировать ссылку';

  @override
  String get deepCopy => 'Полная копия';

  @override
  String get discordLabel => 'Наш Discord сервер:';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get allLevelsCategory => 'Все';

  @override
  String get favoritesCategory => 'Избранное';

  @override
  String get newFolderNameHint => 'Оставьте пустым для имени по умолчанию';

  @override
  String get emptyFavorites => 'У вас пока нет избранных уровней';

  @override
  String get copyEventTarget => 'Целевая волна';

  @override
  String get targetWaveIndex => 'Номер целевой волны';

  @override
  String get moveToWaveIndex => 'Переместить в волну №';

  @override
  String get invalidWaveIndex => 'Неверный номер волны';

  @override
  String get renamingFailed => 'Ошибка переименования';

  @override
  String get deleted => 'Удалено';

  @override
  String get copyLevel => 'Копировать уровень';

  @override
  String get newFileName => 'Новое имя файла';

  @override
  String get copySuccess => 'Копирование выполнено';

  @override
  String get copyFail => 'Ошибка копирования';

  @override
  String moving(String name) {
    return 'Перемещение: $name';
  }

  @override
  String get movePrompt => 'Перейдите в целевую папку и нажмите «Вставить»';

  @override
  String get paste => 'Вставить';

  @override
  String get movingSuccess => 'Файл перемещён';

  @override
  String get movingFail => 'Ошибка перемещения';

  @override
  String get moveSameFolder => 'Исходная и целевая папки совпадают';

  @override
  String get moveFileExistsTitle => 'Файл уже существует';

  @override
  String get moveFileExistsMessage =>
      'В целевой папке уже есть файл с таким именем.';

  @override
  String get moveOverwrite => 'Перезаписать';

  @override
  String fileOverwritten(String name) {
    return 'Файл перезаписан: $name';
  }

  @override
  String get moveSaveAsCopy => 'Сохранить как копию';

  @override
  String get moveCancelled => 'Операция отменена';

  @override
  String movedAs(String name) {
    return 'Перемещено и сохранено как $name';
  }

  @override
  String get folderCreated => 'Папка создана';

  @override
  String get createFail => 'Ошибка создания';

  @override
  String get noTemplates => 'Шаблоны не найдены';

  @override
  String get newLevelTemplate => 'Новый уровень — выбор шаблона';

  @override
  String get nameLevel => 'Название уровня';

  @override
  String get levelCreated => 'Уровень создан';

  @override
  String get levelCreateFail => 'Ошибка создания, файл уже существует';

  @override
  String get templateLoadFail => 'Не удалось загрузить выбранный шаблон уровня';

  @override
  String get adjustUiSize => 'Настроить размер интерфейса';

  @override
  String currentScale(String percent) {
    return 'Текущий масштаб: $percent%';
  }

  @override
  String get small => 'Малый';

  @override
  String get standard => 'Стандартный';

  @override
  String get large => 'Большой';

  @override
  String get done => 'Готово';

  @override
  String get reset => 'Сброс';

  @override
  String cacheCleared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Очищено $count файлов в кэше',
      many: 'Очищено $count файлов в кэше',
      few: 'Очищено $count файла в кэше',
      one: 'Очищен $count файл в кэше',
    );
    return '$_temp0';
  }

  @override
  String get returnUp => 'Назад';

  @override
  String get jsonFile => 'JSON-файл';

  @override
  String get convertToJson => 'Преобразовать в JSON';

  @override
  String get convertToHotUpdateJson => 'Преобразовать в hot update json';

  @override
  String get convertToEncryptedRton => 'Преобразовать в зашифрованный rton';

  @override
  String get hujsonFormatDescription =>
      'Формат для хот-апдейта. Внутри использует PopCap CompiledText (JSON уровня с zlib-сжатием и шифрованием Rijndael). Перед импортом в игру переименуйте расширение с .hujson на .json.';

  @override
  String get rtonFormatDescription =>
      'Бинарный формат PopCap RTON (шифрование Rijndael). Используется для данных уровней в dynamic.rsb.smf.';

  @override
  String get conversionRequiredTitle => 'Требуется преобразование';

  @override
  String get conversionRequiredMessage =>
      'Этот файл нужно преобразовать в JSON, прежде чем его можно открыть в редакторе.';

  @override
  String get convertAction => 'Преобразовать';

  @override
  String get conversionFailed => 'Преобразование не удалось';

  @override
  String convertedMessage(String name) {
    return 'Преобразовано: $name';
  }

  @override
  String get softwareIntro => 'О программе';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'Визуальный редактор уровней PVZ2';

  @override
  String get introSection => 'Введение';

  @override
  String get introText =>
      'C-Editor — визуальный редактор уровней для китайской версии Plants vs. Zombies 2. Упрощает редактирование JSON-файлов уровней с помощью интуитивного интерфейса.';

  @override
  String get featuresSection => 'Основные возможности';

  @override
  String get feature1 =>
      'Модульное редактирование: управление модулями и событиями уровня в едином интерфейсе для быстрой настройки.';

  @override
  String get feature2 =>
      'Поддержка режимов: редактирование «Я зомби», «Разбей горшки», «Несокрушимый», боёв с Зомбоссом и других режимов.';

  @override
  String get feature3 =>
      'Пользовательские объекты: добавление и управление пользовательскими зомби, полями и мехами Зомбосса внутри уровня, включая их основные свойства.';

  @override
  String get feature4 =>
      'Умная проверка: автоматическое обнаружение отсутствующих зависимостей модулей, неверных ссылок и других проблем для предотвращения сбоев уровня.';

  @override
  String get feature5 =>
      'Предпросмотр ресурсов: встроенные значки растений, зомби и объектов поля делают редактирование нагляднее.';

  @override
  String get usageSection => 'Использование';

  @override
  String get usageText =>
      '1. Папка: при первом запуске нажмите значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: нажмите уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования нажмите кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageTextDesktop =>
      '1. Папка: при первом запуске щёлкните значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: щёлкните уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования щёлкните кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageTextMobile =>
      '1. Папка: при первом запуске нажмите значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: нажмите уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования нажмите кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageRecommendedLevelsLabel =>
      'Creative Courtyard · Recommended Levels Showcase:';

  @override
  String get discordInviteLabel =>
      'Ссылка-приглашение на Discord-сервер Plants vs. Zombies:';

  @override
  String get cEditorInviteLabel =>
      'Ссылка-приглашение на Discord-сервер C-Editor:';

  @override
  String get linksSubsection => 'Ссылки';

  @override
  String get creditsSection => 'Благодарности';

  @override
  String get authorLabel => 'Авторы:';

  @override
  String get authorName => 'CyberSteve777, Devourdoom, Chara';

  @override
  String get thanksLabel => 'Особая благодарность:';

  @override
  String get thanksNames =>
      'Evilhack28, Rebus, KL12, vi_i_guess, Haruma, nineteendo';

  @override
  String get sourceLabel => 'Исходный код:';

  @override
  String get issuesLabel => 'Проблемы:';

  @override
  String get zEditorAcknowledgment =>
      'Без создателей Z-Editor создание этого инструмента было бы невозможным.';

  @override
  String get zEditorCreditsSubsection => 'Благодарности Z-Editor';

  @override
  String get zEditorAuthorLabel => 'Автор:';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => 'Благодарность:';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ-группа:';

  @override
  String get tagline => 'Создавайте бесконечные возможности';

  @override
  String editorVersion(String version) {
    return 'Версия редактора: $version';
  }

  @override
  String supportedGameVersion(String version) {
    return 'Поддерживаемая версия игры: $version';
  }

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => 'Пустой уровень';

  @override
  String get templateCardPickExample => 'Пример выбора карт';

  @override
  String get templateConveyorExample => 'Пример конвейера';

  @override
  String get templateLastStandExample => 'Пример «Несокрушимый»';

  @override
  String get templateIZombieExample => 'Пример «Я зомби»';

  @override
  String get templateVaseBreakerExample => 'Пример «Вазобой»';

  @override
  String get templateZombossMechExample => 'Пример боя с Зомботом';

  @override
  String get templateZombossBattleExample => 'Пример боя с Зомбоссом';

  @override
  String get templateCustomZombieExample => 'Пример кастомного зомби';

  @override
  String get templateIPlantExample => 'Пример «Я растение»';

  @override
  String get templateOldStyleExample => 'Уровень старого типа';

  @override
  String get templateCustomLawnExample => 'Пример пользовательского газона';

  @override
  String get unsavedChanges => 'Несохранённые изменения';

  @override
  String get saveBeforeLeaving => 'Сохранить перед выходом?';

  @override
  String get discard => 'Не сохранять';

  @override
  String get stayInEditor => 'Остаться';

  @override
  String get saved => 'Сохранено';

  @override
  String get failedToLoadLevel =>
      'Не удалось загрузить уровень.\nРекомендуется проверить, не зашифрован ли файл уровня (например, JSON-файл из горячего обновления).';

  @override
  String get noLevelDefinition => 'Определение уровня не найдено';

  @override
  String get noLevelDefinitionHint =>
      'Модуль определения уровня (LevelDefinition) не найден. Это базовый узел файла уровня. Попробуйте добавить его вручную.';

  @override
  String get levelBasicInfo => 'Основные данные уровня';

  @override
  String get levelBasicInfoSubtitle => 'Название, номер, описание, стадия';

  @override
  String get removeModule => 'Удалить модуль';

  @override
  String get zombieCategoryMain => 'По миру';

  @override
  String get zombieCategorySize => 'По размеру';

  @override
  String get zombieCategoryOther => 'Прочее';

  @override
  String get zombieCategoryCollection => 'Моя коллекция';

  @override
  String get zombieTagAll => 'Все зомби';

  @override
  String get zombieTagEgyptPirate => 'Египет/Пираты';

  @override
  String get zombieTagWestFuture => 'Запад/Будущее';

  @override
  String get zombieTagDarkBeach => 'Тёмные/Пляж';

  @override
  String get zombieTagIceageLostcity => 'Ледниковый/Затерянный город';

  @override
  String get zombieTagKongfuSkycity => 'Кунг-фу/Небесный город';

  @override
  String get zombieTagEightiesDino => '80-е/Динозавры';

  @override
  String get zombieTagModernPvz1 => 'Современный/PvZ1';

  @override
  String get zombieTagSteamRenai => 'Пар/Ренессанс';

  @override
  String get zombieTagHenaiAtlantis => 'Хэйан/Атлантида';

  @override
  String get zombieTagMoon => 'Moon Base';

  @override
  String get zombieTagTaleZCorp => 'Сказка/ZCorp';

  @override
  String get zombieTagParkourSpeed => 'Паркур/Скорость';

  @override
  String get zombieTagTothewest => 'Путь на Запад';

  @override
  String get zombieTagMemory => 'Путь воспоминаний';

  @override
  String get zombieTagUniverse => 'Параллельный мир';

  @override
  String get zombieTagFestival1 => 'Фестиваль 1';

  @override
  String get zombieTagFestival2 => 'Фестиваль 2';

  @override
  String get zombieTagRoman => 'Рим';

  @override
  String get zombieTagCustom => 'Готовые кастомные';

  @override
  String get zombieTagExpedition => 'Expedition Gate Variants';

  @override
  String get zombieTagPet => 'Питомец';

  @override
  String get zombieTagImp => 'Имп';

  @override
  String get zombieTagBasic => 'Базовый';

  @override
  String get zombieTagFat => 'Толстый';

  @override
  String get zombieTagStrong => 'Сильный';

  @override
  String get zombieTagGargantuar => 'Гаргантюар';

  @override
  String get zombieTagElite => 'Элита';

  @override
  String get zombieTagEvildave => 'Злой Дейв';

  @override
  String get plantCategoryQuality => 'По качеству';

  @override
  String get plantCategoryRole => 'По роли';

  @override
  String get plantCategoryAttribute => 'По атрибуту';

  @override
  String get plantCategoryWorld => 'По миру';

  @override
  String get plantCategoryOther => 'Прочее';

  @override
  String get plantCategoryCollection => 'Моя коллекция';

  @override
  String get plantTagAll => 'Все растения';

  @override
  String get plantTagWhite => 'Обычная редкость';

  @override
  String get plantTagGreen => 'Необычная редкость';

  @override
  String get plantTagBlue => 'Редкая редкость';

  @override
  String get plantTagPurple => 'Эпическая редкость';

  @override
  String get plantTagOrange => 'Легендарная редкость';

  @override
  String get plantTagRed => 'Особая редкость';

  @override
  String get plantTagSupport => 'Поддержка';

  @override
  String get plantTagRanger => 'Дальний бой';

  @override
  String get plantTagSunProducer => 'Солнце дающие';

  @override
  String get plantTagDefence => 'Защита';

  @override
  String get plantTagVanguard => 'Ближний бой';

  @override
  String get plantTagTrapper => 'Ловушка';

  @override
  String get plantTagFire => 'Огонь';

  @override
  String get plantTagIce => 'Лёд';

  @override
  String get plantTagMagic => 'Магия';

  @override
  String get plantTagPoison => 'Яд';

  @override
  String get plantTagElectric => 'Электричество';

  @override
  String get plantTagPhysical => 'Физика';

  @override
  String get plantTagWorldTutorial => 'Туториал';

  @override
  String get plantTagWorldEgypt => 'Древний Египет';

  @override
  String get plantTagWorldPirate => 'Пиратское море';

  @override
  String get plantTagWorldWildWest => 'Дикий Запад';

  @override
  String get plantTagWorldKongfu => 'Мир Кунг-фу';

  @override
  String get plantTagWorldFuture => 'Далёкое Будующее';

  @override
  String get plantTagWorldDarkAges => 'Тёмные века';

  @override
  String get plantTagWorldBeach => 'Пляж Большой Волны';

  @override
  String get plantTagWorldIceage => 'Ледниковый период';

  @override
  String get plantTagWorldSkycity => 'Небесный город';

  @override
  String get plantTagWorldLostCity => 'Затерянный город';

  @override
  String get plantTagWorldEighties => 'Микстейп';

  @override
  String get plantTagWorldDino => 'Юрские Болота';

  @override
  String get plantTagWorldModern => 'Современные Дни';

  @override
  String get plantTagWorldSteam => 'Паровой Век';

  @override
  String get plantTagWorldRenai => 'Ренессанс';

  @override
  String get plantTagWorldHeian => 'Эпоха Хэйан';

  @override
  String get plantTagWorldAtlantis => 'Атлантида';

  @override
  String get plantTagWorldMoon => 'Moon Base';

  @override
  String get plantTagWorldFairytale => 'Сказочный лес';

  @override
  String get plantTagWorldZcorp => 'Z-корп';

  @override
  String get plantTagWorldMausoleum => 'Мавзолей';

  @override
  String get plantTagOriginal => 'PvZ1';

  @override
  String get plantTagParallel => 'Параллельный мир';

  @override
  String get plantTagSpecial => 'Специальные';

  @override
  String get plantTagHidden => 'Hidden Plants';

  @override
  String get plantTagInternational => 'Интернациональные';

  @override
  String get plantTagChinese => 'Китайские';

  @override
  String get removeModuleConfirm =>
      'Удалить этот модуль? Локальные модули (@CurrentLevel) и их данные будут удалены безвозвратно.';

  @override
  String get confirmRemove => 'Удалить';

  @override
  String get addModule => 'Добавить модуль';

  @override
  String get settings => 'Настройки';

  @override
  String get timeline => 'Волны';

  @override
  String get iZombie => 'Я зомби';

  @override
  String get vaseBreaker => 'Вазобой';

  @override
  String get zombossMech => 'Бой с Зомботом';

  @override
  String get zombossBattle => 'Бой с Зомбоссом';

  @override
  String get moveSourceSameAsDest => 'Исходная и целевая папки совпадают';

  @override
  String get moveSuccess => 'Перемещение выполнено';

  @override
  String get moveFail => 'Ошибка перемещения';

  @override
  String get rootFolder => 'Корень';

  @override
  String get createEmptyWave => 'Добавить пустую волну';

  @override
  String get createEmptyWaveContainer => 'Создать пустой контейнер волн';

  @override
  String get deleteEmptyContainer => 'Удалить пустой контейнер';

  @override
  String get deleteWaveContainerTitle => 'Удалить контейнер волн?';

  @override
  String get deleteWaveContainerConfirm =>
      'Вы уверены, что хотите удалить пустой контейнер волн? Позже вы можете создать новый.';

  @override
  String get noWaveManager => 'Менеджер волн не найден';

  @override
  String get noWaveManagerHint =>
      'У уровня есть модуль волн, но отсутствует объект WaveManagerProperties.';

  @override
  String get waveTimelineHint =>
      'Нажмите на событие для редактирования. Нажмите + для добавления.';

  @override
  String get waveTimelineHintDetail => 'Смахните влево для удаления волны.';

  @override
  String get waveTimelineGuideTitle => 'Инструкция';

  @override
  String get waveTimelineGuideBody =>
      'Свайп вправо: управление событиями волны\nСвайп влево: удалить волну\nНажмите на очки: ожидание по зомби';

  @override
  String get waveTimelineGuideBodyDesktop =>
      'Клик левой кнопокой мыши по волне: управление событиями\nКнопка удаления: убрать волну\nКлик по очкам: ожидание по зомби';

  @override
  String get waveTimelineGuideBodyMobile =>
      'Свайп вправо: управление событиями волны\nСвайп влево: удалить волну\nНажмите на очки: ожидание по зомби';

  @override
  String get waveDeadLinksTitle => 'Неверные ссылки';

  @override
  String get waveDeadLinksClear => 'Очистить неверные ссылки';

  @override
  String get customZombieManagerTitle => 'Управление пользовательскими зомби';

  @override
  String get customZombieEmpty => 'Нет данных о пользовательских зомби';

  @override
  String get switchCustomZombie => 'Сменить пользовательского зомби';

  @override
  String get switchProperties => 'Сменить свойства';

  @override
  String get defaultPropertiesLabel => 'По умолчанию';

  @override
  String get addNewVariation => '+ Добавить вариант';

  @override
  String editCustomZombieAlias(String alias) {
    return 'Редактировать $alias';
  }

  @override
  String get switchZombie => 'Сменить зомби';

  @override
  String get customZombieAppearanceLocation => 'Появление:';

  @override
  String get customZombieNotUsed =>
      'Этот кастомный зомби не используется ни в одной волне.';

  @override
  String customZombieWaveItem(int n) {
    return 'Волна $n';
  }

  @override
  String get customZombieDeleteConfirm =>
      'Удалить этого кастомного зомби и его данные.';

  @override
  String get customZombieOrphanDeleteTitle =>
      'Удалить пользовательские свойства из уровня?';

  @override
  String customZombieOrphanDeleteMessage(String alias) {
    return '«$alias» больше не будет использоваться в этом уровне. Удалить объект типа зомби и его свойства из файла уровня? Это действие нельзя отменить.';
  }

  @override
  String get customZombieOrphanDeleteKeep => 'Оставить в уровне';

  @override
  String get customZombieOrphanDeleteErase => 'Удалить из уровня';

  @override
  String get editCustomZombieProperties =>
      'Редактировать свойства кастомного зомби';

  @override
  String get makeZombieAsCustom => 'Сделать зомби кастомным';

  @override
  String get customLabel => 'Пользовательский';

  @override
  String get moduleTitle_WaveManagerProperties =>
      'Linked Wave Parameters (WaveManagerProps)';

  @override
  String waveManagerPropsCurrent(String value) {
    return 'Current: $value';
  }

  @override
  String get waveManagerGlobalParams => 'Глобальные параметры волн';

  @override
  String get waveContainerAliasSection => 'Псевдоним контейнера волн';

  @override
  String get waveContainerAliasHint =>
      'Псевдоним объекта WaveManagerProperties, в котором хранятся данные волн.';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return 'Интервал флага: $interval, порог здоровья: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => 'Список волн пуст';

  @override
  String get waveEmptySubtitle =>
      'Добавьте первую волну или удалите этот пустой контейнер.';

  @override
  String get waveHeaderPreview => 'Содержимое и очки';

  @override
  String waveTotalLabel(int total) {
    return 'Всего: $total';
  }

  @override
  String get waveEmptyRowHint => 'Пустая волна (свайп влево/вправо)';

  @override
  String get waveEmptyRowHintDesktop =>
      'Пустая волна (щёлкните для управления)';

  @override
  String get waveEmptyRowHintMobile => 'Пустая волна (свайп влево/вправо)';

  @override
  String get removeFromWave => 'Удалить из волны';

  @override
  String get deleteEventEntityTitle => 'Удалить объект события?';

  @override
  String get deleteEventEntityBody => 'Это удалит объект события из уровня.';

  @override
  String waveEventsTitle(int wave) {
    return 'События волны $wave';
  }

  @override
  String get waveManagerSettings => 'Настройки менеджера волн';

  @override
  String get flagInterval => 'Интервал флага';

  @override
  String get waveManagerHelpTitle => 'Менеджер волн';

  @override
  String get waveManagerHelpOverviewTitle => 'Обзор';

  @override
  String get waveManagerHelpOverviewBody =>
      'Глобальные параметры волн и пороги здоровья.';

  @override
  String get waveManagerHelpFlagTitle => 'Интервал флага';

  @override
  String get waveManagerHelpFlagBody =>
      'Каждые N волн — флаговая; последняя волна всегда флаговая.';

  @override
  String get waveManagerHelpTimeTitle => 'Контроль времени';

  @override
  String get waveManagerHelpTimeBody =>
      'Задержка первой волны зависит от наличия конвейера.';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHint =>
      'Изменение текущей задержки первой волны действует только на уровни с конвейером; обычные уровни используют значение по умолчанию';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHelp =>
      'Изменение текущей задержки первой волны действует только на уровни с конвейером; обычные уровни используют значение по умолчанию.';

  @override
  String get waveManagerHelpMusicTitle => 'Тип музыки';

  @override
  String get waveManagerHelpMusicBody =>
      'Только Modern; задает фиксированный фон.';

  @override
  String get waveManagerBasicParams => 'Базовые параметры';

  @override
  String get waveManagerMaxHealthThreshold => 'Макс. порог здоровья';

  @override
  String get waveManagerMinHealthThreshold => 'Мин. порог здоровья';

  @override
  String get waveManagerThresholdHint => 'Порог должен быть от 0 до 1.';

  @override
  String get waveManagerTimeControl => 'Контроль времени';

  @override
  String get waveManagerFirstWaveDelayConveyor =>
      'Задержка первой волны (конвейер)';

  @override
  String get waveManagerFirstWaveDelayNormal =>
      'Задержка первой волны (обычно)';

  @override
  String get waveManagerFlagWaveDelay => 'Задержка флаговой волны';

  @override
  String get waveManagerConveyorDetected =>
      'Обнаружен конвейер; применена задержка конвейера.';

  @override
  String get waveManagerConveyorNotDetected =>
      'Конвейер не найден; применена обычная задержка.';

  @override
  String get waveManagerSpecial => 'Особое';

  @override
  String get waveManagerSuppressFlagZombieTitle => 'Отключить флаг-зомби';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint =>
      'При включении флаговые волны не спавнят флаг-зомби.';

  @override
  String get waveManagerLevelJam => 'Level Jam';

  @override
  String get waveManagerLevelJamHint =>
      'Только Modern; фиксированная фоновая музыка.';

  @override
  String get jamNone => 'Нет';

  @override
  String get jamPop => 'Поп';

  @override
  String get jamRap => 'Рэп';

  @override
  String get jamMetal => 'Метал';

  @override
  String get jamPunk => 'Панк';

  @override
  String get jam8Bit => '8-бит';

  @override
  String get noWaves => 'Нет волн';

  @override
  String get addFirstWave => 'Добавьте первую волну.';

  @override
  String get deleteWave => 'Удалить волну';

  @override
  String deleteWaveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будет удалена эта волна и её $count событий.',
      many: 'Будет удалена эта волна и её $count событий.',
      few: 'Будет удалена эта волна и её $count события.',
      one: 'Будет удалена эта волна и её $count событие.',
    );
    return '$_temp0';
  }

  @override
  String get deleteWaveConfirmCheckbox =>
      'Я подтверждаю безвозвратное удаление этой волны';

  @override
  String get addEvent => 'Добавить событие';

  @override
  String get emptyWave => 'Пустая волна';

  @override
  String get addWave => 'Добавить волну';

  @override
  String get expectation => 'Ожидание';

  @override
  String get close => 'Закрыть';

  @override
  String get editProperties => 'Редактировать свойства';

  @override
  String get deleteEntity => 'Удалить объект';

  @override
  String get deleteObjectTitle => 'Удалить объект?';

  @override
  String get deleteObjectConfirmMessage =>
      'Удалить этот объект из файла уровня? Это действие нельзя отменить.';

  @override
  String get objectDeleted => 'Объект удалён';

  @override
  String get moduleEditorInProgress => 'Редактор модуля в разработке';

  @override
  String get dataEmpty => 'Данные пусты';

  @override
  String get saveSuccess => 'Сохранено успешно';

  @override
  String get saveFail => 'Ошибка сохранения';

  @override
  String get confirmRemoveRef => 'Удалить ссылку';

  @override
  String get confirmRemoveRefMessage =>
      'Удалить эту ссылку? Данные объекта останутся до удаления всех ссылок.';

  @override
  String get deleteEventConfirmCheckbox =>
      'Я понимаю, что это действие нельзя отменить';

  @override
  String get noZombiesInLane => 'Нет зомби на этой полосе';

  @override
  String get code => 'Код';

  @override
  String get name => 'Название';

  @override
  String get levelNumber => 'Номер уровня';

  @override
  String get startingSun => 'Начальное солнце';

  @override
  String get startingPlantfood => 'Начальная подкормка';

  @override
  String get stageModule => 'Стадия';

  @override
  String get musicType => 'Тип музыки';

  @override
  String get loot => 'Добыча';

  @override
  String get victoryModule => 'Условие победы';

  @override
  String get basicInfoSection => 'Основная информация';

  @override
  String get sceneSettingsSection => 'Настройки сцены';

  @override
  String get restrictionsSection => 'Ограничения';

  @override
  String get victoryModuleWarning =>
      'Использование нестандартных условий победы может вызвать сбой уровня из-за конфликтов модулей. Используйте с осторожностью.';

  @override
  String get hintTextDisplay => 'Текст подсказки (Description)';

  @override
  String get beatTheLevelDialogIntro =>
      'Показывать текст подсказки во всплывающем окне в начале уровня.';

  @override
  String get beatTheLevelDialogHint =>
      'Поддерживает китайский; для многострочного текста вводите переносы напрямую, \\n не нужен. Примечание: подсказки не отображаются в iOS courtyard.';

  @override
  String get levelHintText => 'Текст подсказки уровня';

  @override
  String get missingModules => 'Отсутствующие модули';

  @override
  String get moduleConflict => 'Конфликт модулей';

  @override
  String get conflictTitle_ModuleLogic => 'Логический конфликт модулей';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '«$module1» и «$module2» конфликтуют. Рекомендуется оставить только один.';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      'Модули Seed Bank и Conveyor конфликтуют в интерфейсе и могут вызвать сбой. Убедитесь, что Seed Bank в режиме предвыбора.';

  @override
  String get conflictDesc_VaseBreakerIntro =>
      'Режиму Vase Breaker не нужна вступительная заставка.';

  @override
  String get conflictDesc_LastStandIntro =>
      'Режиму Last Stand не нужна вступительная заставка.';

  @override
  String get conflictDesc_EvilDaveZombieDrop =>
      'В режиме I, Zombie нельзя использовать модуль Zombie Drop.';

  @override
  String get conflictDesc_EvilDaveVictory =>
      'В режиме I, Zombie нельзя использовать условие победы зомби.';

  @override
  String get conflictDesc_ZombossDeathDrop =>
      'Смертельные капли в режиме ZombossMech помешают корректному завершению уровня.';

  @override
  String get conflictDesc_ZombossBattleDeathDrop =>
      'Смертельные капли в режиме боя с Зомбоссом помешают корректному завершению уровня.';

  @override
  String get conflictDesc_WinConditionExclusive =>
      'В LevelModules должно быть только одно условие победы/поражения из: смертельные капли, победа за бронзу или стандартное «съели мозги». Удалите лишние модули.';

  @override
  String get conflictDesc_ZombossTwoIntros =>
      'Две вступительные заставки не могут сосуществовать, иначе шкала здоровья Zomboss отображается неверно.';

  @override
  String get conflictDesc_InitialPlantEntryRoof =>
      'Предустановленные растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_InitialPlantRoof =>
      'Легаси-растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_ProtectPlantRoof =>
      'Защищаемые растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_LawnMowerYard =>
      'Газонокосилки неэффективны в модуле Yard.';

  @override
  String get conflictDesc_WaveGeneratorWaveManagerModule =>
      'Генератор волн и модуль менеджера волн нельзя использовать одновременно: это две разные системы волн.';

  @override
  String get conflictDesc_WaveGeneratorWaveManager =>
      'Генератор волн хранит данные волн внутри модуля и не может использоваться вместе с отдельным контейнером менеджера волн.';

  @override
  String get conflictDesc_WaveGeneratorRenai =>
      'Генератор волн несовместим с модулем «Ренессанс» и приводит к сбою уровня.';

  @override
  String get conflictDesc_WaveGeneratorWitch =>
      'Генератор волн несовместим с модулем «Тыквенная ведьма» и приводит к сбою уровня.';

  @override
  String get missingPlantModuleWarningTitle =>
      'Отсутствует модуль для параллельных растений';

  @override
  String get editableModules => 'Редактируемые модули';

  @override
  String get parameterModules => 'Модули параметров';

  @override
  String get addNewModule => 'Добавить модуль';

  @override
  String get selectStage => 'Выбрать стадию';

  @override
  String get searchStage => 'Поиск стадии';

  @override
  String get noStageFound => 'Стадия не найдена';

  @override
  String get stageTypeAll => 'Все';

  @override
  String get stageTypeMain => 'Основные';

  @override
  String get stageTypeExtra => 'Дополнительные';

  @override
  String get stageTypeSeasons => 'Сезоны';

  @override
  String get stageTypeSpecial => 'Мини-игры';

  @override
  String get search => 'Поиск';

  @override
  String get disablePeavine => 'Отключить плющ';

  @override
  String get disableArtifact => 'Отключить артефакт';

  @override
  String get selectPlant => 'Выбрать растение';

  @override
  String get searchPlant => 'Поиск растения';

  @override
  String get noPlantFound => 'Растение не найдено';

  @override
  String noResultsFor(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String get noModulesInCategory => 'Нет модулей в этой категории';

  @override
  String get noEventsInCategory => 'Нет событий в этой категории';

  @override
  String get eventCategoryZombieSpawn => 'Появление зомби';

  @override
  String get eventCategoryGridItemSpawn => 'Появление предметов на поле';

  @override
  String get eventCategoryEnvironmental => 'Окружение';

  @override
  String get eventCategoryOther => 'Прочее';

  @override
  String addEventForWave(int wave) {
    return 'Добавить событие для волны $wave';
  }

  @override
  String get waveLabel => 'Волна';

  @override
  String get pointsLabel => 'Очки';

  @override
  String wavePointsShort(int points) {
    return '$points очк.';
  }

  @override
  String get noDynamicZombies => 'Нет динамических зомби';

  @override
  String get moduleTitle_WaveManagerModuleProperties => 'Менеджер волн';

  @override
  String get moduleDesc_WaveManagerModuleProperties =>
      'Управление волнами уровня';

  @override
  String get moduleTitle_WaveGeneratorProperties => 'Генератор волн';

  @override
  String get moduleDesc_WaveGeneratorProperties =>
      'Старый формат волн, используемый в Мире кунг-фу и других ранних уровнях';

  @override
  String get moduleTitle_CustomLevelModuleProperties => 'Модуль лужайки';

  @override
  String get moduleDesc_CustomLevelModuleProperties =>
      'Включает режим творческого двора. Костюмы растений в этом режиме недоступны.';

  @override
  String get powerTileModuleRequiredTitle => 'Нужен модуль силовых плиток';

  @override
  String get powerTileModuleRequiredBody =>
      'Инструменты силовых плиток требуют модуль Power Tiles в уровне. Добавить модуль по умолчанию?';

  @override
  String get conveyorPlantWearCostume => 'Костюм (iAvatar)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      'Если включено, на карточке может отображаться костюм. Недоступно при модуле творческого двора.';

  @override
  String get modifyConveyorAddPoolTitle => 'Добавить в пул конвейера';

  @override
  String get modifyConveyorAddPoolEmpty =>
      'Пусто. Добавьте растение или инструмент и настройте веса.';

  @override
  String get modifyConveyorRemovePoolTitle => 'Убрать с конвейера';

  @override
  String get modifyConveyorEntryEditTitle => 'Параметры записи конвейера';

  @override
  String get moduleTitle_UnchartedModeNo42UniverseModule =>
      'Модуль вселенной 42';

  @override
  String get moduleDesc_UnchartedModeNo42UniverseModule =>
      'Включает растения параллельной вселенной No 42';

  @override
  String get moduleTitle_PVZ2MausoleumModuleUnchartedMode => 'Модуль мавзолея';

  @override
  String get moduleDesc_PVZ2MausoleumModuleUnchartedMode =>
      'Включает растения мавзолея';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return 'Чтобы выбрать это растение, нужно добавить модуль «$moduleName».';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle =>
      'Нельзя выбрать растение';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      'Растения тайных миров нельзя выбрать в режиме выбора. Используйте предустановку, конвейер, выпадение карт и другие способы.';

  @override
  String get hiddenPlantChooserBlockedLabel => 'Нельзя выбрать растение';

  @override
  String get hiddenPlantChooserBlockedTitle => 'Нельзя выбрать растение';

  @override
  String get hiddenPlantChooserBlockedMessage =>
      'Скрытые растения нельзя выбирать в режиме выбора карт. Используйте предустановленный режим, конвейер, выпадение карт или другие способы.\nКроме того, за исключением некоторых растений, таких как Жрец-пухомор и Сборщик растеброни - Огненная звезда, большинство скрытых растений отображаются в игровых слотах карт значком подсолнуха, что может повлиять на общий вид уровня. Используйте их осторожно.';

  @override
  String get comingSoonPlantBlockedLabel => 'Продолжение следует';

  @override
  String get comingSoonPlantBlockedTitle => 'Продолжение следует';

  @override
  String get comingSoonPlantBlockedMessage =>
      'Растения продолжают расти и крепнуть. Следите за будущими обновлениями!';

  @override
  String get stayTunedMoonPlantBlockedTitle => 'Послание из космоса';

  @override
  String get stayTunedMoonPlantBlockedMessage =>
      'Вторая часть «Лунной базы» скоро выйдет. Следите за новостями!';

  @override
  String get stayTunedMoonZombieBlockedLabel => 'Послание из космоса';

  @override
  String get stayTunedMoonZombieBlockedTitle => 'Послание из космоса';

  @override
  String get stayTunedMoonZombieBlockedMessage =>
      'Вторая часть «Лунной базы» скоро выйдет. Следите за новостями!';

  @override
  String get stayTunedTaleZCorpZombieBlockedLabel =>
      'История ZCorp еще не закончена';

  @override
  String get stayTunedTaleZCorpZombieBlockedTitle => 'Продолжение следует';

  @override
  String get stayTunedTaleZCorpZombieBlockedMessage =>
      'Вторая глава ZCorp скоро выйдет. Следите за новостями!';

  @override
  String get stayTunedZombieBlockedLabel => 'Следите за новостями';

  @override
  String get stayTunedZombieBlockedTitle => 'Продолжение следует';

  @override
  String get stayTunedZombieBlockedMessage =>
      'Впереди ещё больше зомби. Следите за будущими обновлениями!';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return 'Отсутствует модуль «$moduleName» для растений: $plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => 'Заставка';

  @override
  String get moduleDesc_StandardLevelIntroProperties =>
      'Прокрутка камеры в начале уровня';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => 'Условие поражения';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties => 'Зомби дошёл до дома';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => 'Смертельная капля';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties =>
      'Нужно для стабильности уровня';

  @override
  String get moduleTitle_BronzeDeadWinConProperties => 'Победа: бронза очищена';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      'Победа при уничтожении всех бронзовых статуй и бронзовых гаргантюар (стиль Kongfu). Несовместимо с «Смертельная капля» и другими модулями условия победы — оставьте один.';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => 'Кит (спермакит)';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      'Параметры глотания кита в Атлантиде; в игре нужны криль и др.';

  @override
  String get spermWhaleModuleTitle => 'Модуль кита';

  @override
  String get spermWhaleModuleHelpTitle => 'Модуль кита';

  @override
  String get spermWhaleModuleParameters => 'Параметры';

  @override
  String get spermWhaleModuleHelpOverview => 'Обзор';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      'Настройка глотания растений китом: интервалы в обычном и отравленном режиме, длительность фазы, порог срабатывания яда. Обычно для глубоководной сцены с крилем (часто нужно ≥3).';

  @override
  String get spermWhaleModuleHelpFieldsTitle => 'Поля';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      'SwallowInterval — пауза между глотаниями. PoisonSwallowInterval — при активном яде. SwallowDuration — длительность фазы глотания. PoisonTriggerCount — сколько раз должен сработать дебафф яда, чтобы использовать отравленный интервал.';

  @override
  String get spermWhaleModuleSwallowInterval =>
      'Интервал глотания (SwallowInterval)';

  @override
  String get spermWhaleModuleHelpSwallowInterval =>
      'Секунды между глотаниями в обычном режиме.';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      'Интервал при яде (PoisonSwallowInterval)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval =>
      'Секунды между глотаниями, пока действует яд.';

  @override
  String get spermWhaleModuleSwallowDuration =>
      'Длительность глотания (SwallowDuration)';

  @override
  String get spermWhaleModuleHelpSwallowDuration =>
      'Длительность фазы глотания в секундах.';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      'Счётчик яда (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      'Сколько срабатываний негативного эффекта яда нужно, чтобы перейти на интервалы при яде.';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      'Рекомендуется использовать этот модуль на лужайках Подводного мира. На лужайках, отличных от «20 000 лье под водой»/Атлантиды, возможны проблемы совместимости.';

  @override
  String get spermWhaleModuleLawnPreview => 'Сетка газона (ориентир)';

  @override
  String get spermWhaleModuleLawnPreviewHint =>
      'Глубоководный газон 6×10; обычный 5×9.';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => 'Уровень растений';

  @override
  String get moduleDesc_PennyClassroomModuleProperties =>
      'Глобальные уровни растений';

  @override
  String get moduleTitle_SeedBankProperties => 'Банк семян';

  @override
  String get moduleDesc_SeedBankProperties => 'Набор растений и способ выбора';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => 'Конвейер';

  @override
  String get moduleDesc_ConveyorSeedBankProperties =>
      'Растения на конвейере и веса';

  @override
  String get moduleTitle_SunDropperProperties => 'Падающее солнце';

  @override
  String get moduleDesc_SunDropperProperties => 'Частота падения солнца';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => 'Макс. солнце';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps => 'Лимит солнца';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps =>
      'Стартовая подкормка';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps =>
      'Начальная подкормка';

  @override
  String get moduleTitle_StarChallengeModuleProperties => 'Звёздные испытания';

  @override
  String get moduleDesc_StarChallengeModuleProperties =>
      'Ограничения и цели уровня';

  @override
  String get starChallengeNoConfigTitle => 'Испытание';

  @override
  String get starChallengeNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.';

  @override
  String get starChallengeSaveMowersTitle => 'Не потерять газонокосилки';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.\n\nВсе газонокосилки должны остаться целыми. Примечание: в модуле двора газонокосилок по умолчанию нет.';

  @override
  String get starChallengePlantFoodNonuseTitle => 'Не использовать подкормку';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.\n\nИспользование подкормки запрещено.';

  @override
  String get moduleTitle_LevelScoringModuleProperties => 'Очки';

  @override
  String get moduleDesc_LevelScoringModuleProperties => 'Очки за убийства';

  @override
  String get moduleTitle_SouDaCheDamageTextModuleProperties =>
      'Отображение урона';

  @override
  String get moduleDesc_SouDaCheDamageTextModuleProperties =>
      'Показывает урон, нанесенный каждой атакой растения во время уровня';

  @override
  String get moduleTitle_BowlingMinigameProperties => 'Боулинг';

  @override
  String get moduleDesc_BowlingMinigameProperties =>
      'Линия и отключение лопаты';

  @override
  String get moduleTitle_NewBowlingMinigameProperties => 'Боулинг с орехами';

  @override
  String get moduleDesc_NewBowlingMinigameProperties =>
      'Настройка линии боулинга';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => 'Расклад ваз';

  @override
  String get moduleDesc_VaseBreakerPresetProperties => 'Содержимое ваз';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties =>
      'Режим «Разбей горшки»';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      'Включить интерфейс режима';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => 'Анимация ваз';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties =>
      'Анимация падения ваз';

  @override
  String get moduleTitle_EvilDaveProperties => 'Я зомби';

  @override
  String get moduleDesc_EvilDaveProperties => 'Включить режим «Я зомби»';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => 'Бой с Зомботом';

  @override
  String get moduleDesc_ZombossBattleModuleProperties => 'Параметры Зомботов';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => 'Заставка Зомбота';

  @override
  String get moduleDesc_ZombossBattleIntroProperties =>
      'Заставка и полоска здоровья Зомбота';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties => 'Бой с Боссом';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      'Параметры боя с Боссами (Мастер Цигун, Пиродьявол и т.д.)';

  @override
  String get moduleTitle_SeedRainProperties => 'Дождь из семян';

  @override
  String get moduleDesc_SeedRainProperties =>
      'Падающие растения/зомби/предметы';

  @override
  String get moduleTitle_LastStandMinigameProperties => 'Последний Выживший';

  @override
  String get moduleDesc_LastStandMinigameProperties =>
      'Стартовые ресурсы и фаза подготовки';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties =>
      'Высадка по 5-ти линиям';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties =>
      'Мини-игра Колона, как вы её видите';

  @override
  String get moduleTitle_SunBombChallengeProperties => 'Солнечные бомбы';

  @override
  String get moduleDesc_SunBombChallengeProperties =>
      'Настройка падающих солнечных бомб';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => 'Инфляция';

  @override
  String get moduleDesc_IncreasedCostModuleProperties =>
      'Рост стоимости солнца при посадке';

  @override
  String get moduleTitle_DeathHoleModuleProperties => 'Смертельные ямы';

  @override
  String get moduleDesc_DeathHoleModuleProperties =>
      'Растения оставляют непосадочные ямы';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => 'Быстрый вход';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties =>
      'Зомби быстрее выходят';

  @override
  String get moduleTitle_InitialPlantProperties =>
      'Начальные растения (устаревший модуль)';

  @override
  String get moduleDesc_InitialPlantProperties =>
      'Предустановленные растения (замороженные)';

  @override
  String get moduleTitle_InitialPlantEntryProperties => 'Начальные растения';

  @override
  String get moduleDesc_InitialPlantEntryProperties =>
      'Растения в начале уровня';

  @override
  String get frozenPlantPlacementTitle =>
      'Растения в начале уровня (устаревший модуль с возможностью сделать замороженные растения)';

  @override
  String get frozenPlantPlacementLastStand =>
      'Сжигание всех растений при старте уровня';

  @override
  String get frozenPlantPlacementSelectedPosition => 'Выбранная позиция';

  @override
  String get frozenPlantPlacementPlaceHere => 'Разместить растение';

  @override
  String get frozenPlantPlacementPlantList => 'Список растений (по рядам)';

  @override
  String frozenPlantPlacementEditPlant(String name) {
    return 'Редактировать $name';
  }

  @override
  String get frozenPlantPlacementLevel => 'Уровень';

  @override
  String get frozenPlantPlacementCondition => 'Состояние';

  @override
  String get frozenPlantPlacementConditionNull => 'Нет (null)';

  @override
  String get noConditions => 'Нет условий';

  @override
  String get frozenPlantPlacementHelpTitle =>
      'Устаревшие предустановленные растения - Справка';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => 'Обзор';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      'Этот модуль настраивает раскладку растений до начала уровня. Похож на предустановленную раскладку, но с другой структурой и поддержкой особых состояний.';

  @override
  String get frozenPlantPlacementHelpConditionTitle => 'Особое состояние';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      'Растения можно установить в замороженное состояние, часто используется на уровнях Ледникового периода.';

  @override
  String get frozenPlantPlacementHelpLastStandTitle =>
      'Режим последнего рубежа';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      'При включении режима последнего рубежа начальные растения будут уничтожены после старта игры. Примечание: в китайской версии не отображается эффект огня при уничтожении растений.';

  @override
  String get save => 'Сохранить';

  @override
  String get moduleTitle_InitialZombieProperties => 'Начальные зомби';

  @override
  String get moduleDesc_InitialZombieProperties => 'Зомби в начале уровня';

  @override
  String get moduleTitle_InitialGridItemProperties => 'Начальные объекты сетки';

  @override
  String get moduleDesc_InitialGridItemProperties =>
      'Объекты сетки в начале уровня';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties =>
      'Защитить растения';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties =>
      'Растения, которые нужно защитить';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties =>
      'Защитить предметы';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      'Предметы, которые нужно защитить';

  @override
  String get moduleTitle_MoldColonyChallengeProps => 'Зона плесени';

  @override
  String get moduleDesc_MoldColonyChallengeProps =>
      'Настраивает клетки газона с колониями плесени, на которых нельзя сажать растения';

  @override
  String get moldColonyLocationsTitle => 'Схема колоний плесени (Locations)';

  @override
  String moldColonyLocationsValue(String value) {
    return 'Текущее значение: $value';
  }

  @override
  String get moldColonyLevelModulesError =>
      'Ошибка: ссылка на схему колоний плесени использует LevelModules. Переключите её на объект текущего уровня.';

  @override
  String get moldColonyInvalidLinkError =>
      'Ошибка: Locations должен ссылаться на объект BoardGridMapProps текущего уровня со схемой колоний плесени.';

  @override
  String moldColonyRepairLink(String alias) {
    return 'Исправить ссылку на: $alias';
  }

  @override
  String get moldColonies => 'Колонии плесени';

  @override
  String get moldColonyEmpty => 'Пусто';

  @override
  String get moldColonyHelpOverview =>
      'Настраивает клетки газона, покрытые колониями плесени. На таких клетках игрок не может сажать растения.';

  @override
  String get moldColonyHelpGridTitle => 'Управление сеткой';

  @override
  String get moldColonyHelpGridBody =>
      'Нажмите клетку, чтобы переключить её между пустой (можно сажать) и колониями плесени (сажать нельзя). Выбранные строка и столбец показаны над сеткой.';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => 'Зелья зомби';

  @override
  String get moduleDesc_ZombiePotionModuleProperties =>
      'Генерация зелий в Тёмных веках';

  @override
  String get moduleTitle_PiratePlankProperties => 'Пиратские доски';

  @override
  String get moduleDesc_PiratePlankProperties => 'Ряды досок в Пиратских Морях';

  @override
  String get moduleTitle_RailcartProperties => 'Вагонетки';

  @override
  String get moduleDesc_RailcartProperties => 'Вагонетки и рельсы';

  @override
  String get moduleTitle_MechanismPlankProperties => 'Объединённые вагонетки';

  @override
  String get moduleDesc_MechanismPlankProperties =>
      'Редактирование распложения вагонеток и рельс Кунг-Фу Мира';

  @override
  String get moduleTitle_PowerTileProperties => 'Силовые плитки';

  @override
  String get moduleDesc_PowerTileProperties =>
      'Расположение разноцветных плиток из Далёкого Будущего';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => 'Проходные люки';

  @override
  String get moduleDesc_ManholePipelineModuleProperties =>
      'Настраивает проходы для зомби в виде люков';

  @override
  String get moduleTitle_SmokePollutionModuleProperties => 'Дымовые люки';

  @override
  String get moduleDesc_SmokePollutionModuleProperties =>
      'Настраивает люки с ядовитым паром на газоне';

  @override
  String get moduleTitle_RoofProperties => 'Горшки крыши';

  @override
  String get moduleDesc_RoofProperties => 'Колонки горшков на крыше';

  @override
  String get moduleTitle_TideProperties => 'Система прилива';

  @override
  String get moduleDesc_TideProperties => 'Включить прилив';

  @override
  String get moduleTitle_BombProperties => 'Взрывоопасные бочки';

  @override
  String get moduleDesc_BombProperties =>
      'Длина фитиля взрывоопасной бочки по рядам';

  @override
  String get moduleTitle_BronzeProperties => 'Бронзовые статуи';

  @override
  String get moduleDesc_BronzeProperties =>
      'Мини-игра бронзовых статуй Кунг-Фу Мира: размещение статуй и настройка времени пробуждения (не привязано к волнам)';

  @override
  String get moduleTitle_ArmrackProperties => 'Оружейные стойки';

  @override
  String get moduleDesc_ArmrackProperties =>
      'Настройка отображения оружейных стоек на газоне (только волна 1)';

  @override
  String get moduleTitle_EnergyGridProperties => 'Плитки с подкормкой';

  @override
  String get moduleDesc_EnergyGridProperties =>
      'Настройка отображения плиток с подкормкой на газоне (только волна 1)';

  @override
  String get bronzeModuleTitle => 'Бронзовые статуи';

  @override
  String get bronzeModuleHelpTitle => 'Бронзовые статуи';

  @override
  String get bronzeModuleHelpOverview => 'Обзор';

  @override
  String get bronzeModuleHelpOverviewBody =>
      'Размещает статуи Хань, Сигун и Рыцаря на газоне в начале уровня. Время пробуждения задаётся в секундах (spawnTime). Каждая группа волн — отдельная запись в массиве data; в игре действует только волна 1.';

  @override
  String get bronzeModuleHelpBatches => 'Пакеты и время';

  @override
  String get bronzeModuleHelpBatchesBody =>
      'Статуи с одинаковым временем пробуждения появляются вместе. Последующие пакеты могут продолжать отсчёт. Выберите клетку, тип и секунды до пробуждения.';

  @override
  String get bronzeModuleShakeOffset => 'Анимация';

  @override
  String get bronzeModuleShakeOffsetLabel => 'Смещение тряски при пробуждении';

  @override
  String get bronzeModuleInCell => 'Статуи в выбранной клетке';

  @override
  String get bronzeModuleAddTitle => 'Добавить тип статуи';

  @override
  String get bronzeKindStrength => 'Хань-бронза (сила)';

  @override
  String get bronzeKindMage => 'Цигун-бронза (маг)';

  @override
  String get bronzeKindAgile => 'Рыцарь-бронза (ловкость)';

  @override
  String get bronzeKindStrengthShort => 'Сила';

  @override
  String get bronzeKindMageShort => 'Маг';

  @override
  String get bronzeKindAgileShort => 'Ловкость';

  @override
  String get bronzeModuleTypeLabel => 'Тип';

  @override
  String get bronzeModuleSpawnTimeLabel => 'Время пробуждения (с)';

  @override
  String get moduleTitle_WarMistProperties => 'Туман';

  @override
  String get moduleDesc_WarMistProperties => 'Система тумана';

  @override
  String get moduleTitle_RainDarkProperties => 'Погода';

  @override
  String get moduleDesc_RainDarkProperties => 'Дождь, снег, буря';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps =>
      'GroundSpawnEvent';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps =>
      'Зомби появляются из-под земли';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => 'Jittered Event';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps =>
      'Основной естественный спавн';

  @override
  String get eventTitle_FrostWindWaveActionProps => 'Морозный ветер';

  @override
  String get eventDesc_FrostWindWaveActionProps => 'Холодный ветер по рядам';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps => 'Низкая вода';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps =>
      'Зомби появляются при низкой воде';

  @override
  String get eventTitle_TidalChangeWaveActionProps => 'Смена прилива';

  @override
  String get eventDesc_TidalChangeWaveActionProps => 'Изменение уровня прилива';

  @override
  String get eventTitle_TideWaveWaveActionProps => 'Волна прилива';

  @override
  String get eventDesc_TideWaveWaveActionProps =>
      'Подводная волна (влево/вправо)';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => 'Зомби-рыбы';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      'Зомби и рыбы для подводных уровней';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => 'Изменение конвейера';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps =>
      'Динамическое добавление/удаление карт';

  @override
  String get eventTitle_DinoWaveActionProps => 'Призыв динозавра';

  @override
  String get eventDesc_DinoWaveActionProps => 'Призвать динозавра на ряд';

  @override
  String get eventTitle_DinoTreadActionProps => 'Шаг динозавра';

  @override
  String get eventDesc_DinoTreadActionProps =>
      'Динозавр наступает на область сетки';

  @override
  String get eventTitle_DinoRunActionProps => 'Бег динозавра';

  @override
  String get eventDesc_DinoRunActionProps => 'Динозавр бежит по ряду';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps => 'Разлом времени';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps =>
      'Создать порталы времени';

  @override
  String get eventTitle_StormZombieSpawnerProps => 'Штормовой спавн';

  @override
  String get eventDesc_StormZombieSpawnerProps => 'Песчаная буря или метель';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => 'Налет пиратов';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps =>
      'Разбойники/пиратские зомби вторгаются';

  @override
  String get eventTitle_ZombiePotionActionProps => 'Бросок зелий';

  @override
  String get eventDesc_ZombiePotionActionProps => 'Появление зелий на сетке';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => 'Спавн ракушек';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps =>
      'Появление атлантических ракушек на сетке';

  @override
  String get eventTitle_PumpkinHouseActionProps =>
      'Появление тыквенных домиков';

  @override
  String get eventDesc_PumpkinHouseActionProps =>
      'Размещает тыквенные домики в указанных клетках';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => 'Спавн надгробий';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps => 'Создать надгробия';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps =>
      'Спавн из надгробий';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps =>
      'Появление зомби из могил';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => 'Сказочный туман';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps => 'Породить туман';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => 'Сказочный ветер';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps => 'Сдувать туман';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps => 'Дождь импов';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps => 'Импы падают с неба';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => 'Парашютный дождь';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps =>
      'Зомби падают с парашютами';

  @override
  String get eventTitle_BassRainZombieSpawnerProps =>
      'Дождь басистов/джетпаков';

  @override
  String get eventDesc_BassRainZombieSpawnerProps =>
      'Падают басисты/джетпак-зомби';

  @override
  String get eventTitle_BlackHoleWaveActionProps => 'Чёрная дыра';

  @override
  String get eventDesc_BlackHoleWaveActionProps =>
      'Чёрная дыра притягивает растения';

  @override
  String get eventTitle_BarrelWaveActionProps => 'Бочки';

  @override
  String get eventDesc_BarrelWaveActionProps =>
      'Катящиеся бочки по рядам (пустые, зомби, взрывные)';

  @override
  String get eventTitle_SchoolBusWaveActionProps => 'Фургон с мороженым';

  @override
  String get eventDesc_SchoolBusWaveActionProps =>
      'Фургон с мороженым в ряду с настраиваемыми зомби внутри';

  @override
  String get eventTitle_BungeeWaveActionProps => 'Прыжок с парашютом';

  @override
  String get eventDesc_BungeeWaveActionProps =>
      'Один сброс зомби с парашютом (тип, уровень, клетка)';

  @override
  String get eventTitle_ThunderWaveActionProps => 'Гром';

  @override
  String get eventDesc_ThunderWaveActionProps =>
      'Молнии во время волны (положительные/отрицательные)';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => 'Волшебное зеркало';

  @override
  String get eventDesc_MagicMirrorWaveActionProps => 'Зеркальные порталы';

  @override
  String get weatherOption_DefaultSnow_label => 'Снег';

  @override
  String get weatherOption_DefaultSnow_desc => 'Эффект снега из Ледяных пещер';

  @override
  String get weatherOption_LightningRain_label => 'Дождь с грозой';

  @override
  String get weatherOption_LightningRain_desc =>
      'Дождь и молнии, Тёмные века день 8';

  @override
  String get weatherOption_DefaultRainDark_label => 'Дождь';

  @override
  String get weatherOption_DefaultRainDark_desc =>
      'Эффект дождя в Тёмных веках';

  @override
  String get iZombiePlantReserveLabel =>
      'Колонна резерва растений (PlantDistance)';

  @override
  String get column => 'Колонна';

  @override
  String get iZombieInfoText =>
      'В режиме «Я, Зомби» предварительные растения и зомби необходимо настроить в модуле уровня (Preset Plants) и в банке семян.';

  @override
  String get vaseRangeTitle => 'Диапазон генерации ваз и черный список';

  @override
  String get startColumnLabel => 'Начальная колонна (мин.)';

  @override
  String get endColumnLabel => 'Конечная колонна (макс.)';

  @override
  String get toggleBlacklistHint => 'Нажмите, чтобы переключить черный список';

  @override
  String get vaseCapacityTitle => 'Вместимость ваз';

  @override
  String vaseCapacitySummary(String current, String total) {
    return 'Назначено: $current / Всего ячеек: $total';
  }

  @override
  String get vaseListTitle => 'Список ваз';

  @override
  String get addVaseTitle => 'Добавить вазу';

  @override
  String get plantVaseOption => 'Ваза с растением';

  @override
  String get zombieVaseOption => 'Ваза с зомби';

  @override
  String get plantVaseOptionDescription =>
      'Выберите карточку растения для зелёной вазы.';

  @override
  String get zombieVaseOptionDescription =>
      'Выберите зомби для фиолетовой вазы.';

  @override
  String get collectableVaseOptionDescription =>
      'Выберите предмет, который будет находиться внутри вазы.';

  @override
  String get searchZombie => 'Поиск зомби';

  @override
  String get noZombieFound => 'Зомби не найден';

  @override
  String get unknownVaseLabel => 'Неизвестная ваза';

  @override
  String get plantLabel => 'Растение';

  @override
  String get zombieLabel => 'Зомби';

  @override
  String get itemLabel => 'Предмет';

  @override
  String get railcartSettings => 'Настройки рельсов';

  @override
  String get railcartType => 'Тип вагонетки';

  @override
  String get layRails => 'Уложить рельсы';

  @override
  String get placeCarts => 'Разместить вагонетки';

  @override
  String get railSegments => 'Сегменты рельсов';

  @override
  String get railcartCount => 'Количество вагонеток';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get moduleCategoryBase => 'Базовые';

  @override
  String get moduleCategoryMode => 'Режимы';

  @override
  String get moduleCategoryScene => 'Сцена';

  @override
  String get moduleCategoryGimmick => 'Гиммики';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties =>
      'Смахивание ракетного зомби';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      'Позволяет смахивать импов с ракетницей с газона (шаблон).';

  @override
  String get kongfuRocketFlickDialogTitle => 'Ракетный зомби';

  @override
  String get kongfuRocketFlickDialogMessage =>
      'Смахивать этого зомби с газона? Можно добавить в уровень модуль смахивания ракетного зомби.';

  @override
  String get customZombie => 'Кастомный зомби';

  @override
  String get customZombieProperties => 'Свойства кастомного зомби';

  @override
  String get zombieTypeNotFound => 'Объект типа зомби не найден.';

  @override
  String get propertyObjectNotFound => 'Объект свойств не найден';

  @override
  String propertyObjectNotFoundHint(String alias) {
    return 'Объект свойств кастомного зомби ($alias) не найден в уровне. Определение свойств не указывает на внутренние данные уровня, поэтому его нельзя редактировать здесь.';
  }

  @override
  String get baseStats => 'Базовые параметры';

  @override
  String get hitpoints => 'Очки здоровья';

  @override
  String get speed => 'Скорость';

  @override
  String get speedVariance => 'Вариация скорости';

  @override
  String get eatDPS => 'Урон поедания';

  @override
  String get hitPosition => 'Попадание / позиция';

  @override
  String get hitRect => 'Радиус попадания';

  @override
  String get editHitRect => 'Редактировать радиус попадания';

  @override
  String get attackRect => 'Радиус атаки';

  @override
  String get editAttackRect => 'Редактировать радиус атаки';

  @override
  String get artCenter => 'Центр отрисовки';

  @override
  String get editArtCenter => 'Редактировать центр отрисовки';

  @override
  String get shadowOffset => 'Смещение тени';

  @override
  String get editShadowOffset => 'Редактировать смещение тени';

  @override
  String get groundTrackName => 'Траектория движения';

  @override
  String get groundTrackNormal => 'Обычная земля (ground_swatch)';

  @override
  String get groundTrackNone => 'Нет (null)';

  @override
  String get appearanceBehavior => 'Внешний вид и поведение';

  @override
  String get sizeType => 'Размер';

  @override
  String get selectSize => 'Выбрать размер';

  @override
  String get disableDropFractions => 'Отключить доли дропа';

  @override
  String get immuneToKnockback => 'Иммунитет к отбрасыванию';

  @override
  String get showHealthBarOnDamage => 'Показывать полоску здоровья при уроне';

  @override
  String get drawHealthBarTime => 'Время отображения полоски';

  @override
  String get enableEliteScale => 'Включить масштаб для элитных зомби';

  @override
  String get eliteScale => 'Масштаб для элитных зомби';

  @override
  String get enableEliteImmunities => 'Включить элитный иммунитет';

  @override
  String get canSpawnPlantFood => 'Может выпадать подкормка';

  @override
  String get canSurrender => 'Может сдаться';

  @override
  String get canTriggerZombieWin => 'Может вызвать победу зомби';

  @override
  String get resilience => 'Устойчивость';

  @override
  String get resilienceArmor => 'Устойчивость (броня)';

  @override
  String get enableResilience => 'Включить устойчивость';

  @override
  String get resilienceSource => 'Источник';

  @override
  String get resiliencePreset => 'Существующий';

  @override
  String get resilienceCustom => 'Свой';

  @override
  String get resiliencePresetSelect => 'Выбранный щит устойчивости';

  @override
  String get resilienceAmount => 'Количество';

  @override
  String get resilienceWeakType => 'Слабый тип';

  @override
  String get resilienceRecoverSpeed => 'Скорость восстановления';

  @override
  String get resilienceDamageThresholdPerSecond => 'Порог урона в секунду';

  @override
  String get resilienceBaseDamageThreshold =>
      'Базовый порог урона устойчивости';

  @override
  String get resilienceExtraDamageThreshold => 'Доп. порог урона устойчивости';

  @override
  String get resilienceCodename => 'Кодовое имя';

  @override
  String get resilienceCodenameHint => 'напр. CustomResilience0';

  @override
  String get resistances => 'Сопротивления';

  @override
  String get zombieResilience => 'Броня / Устойчивость';

  @override
  String get resilienceEnable => 'Включить броню';

  @override
  String get weakTypeExplosive => 'Взрыв';

  @override
  String get instantKillResistance => 'Устойчивость к мгновенной смерти';

  @override
  String get resiliencePhysics => 'Физ.урон';

  @override
  String get resiliencePoison => 'Яд';

  @override
  String get resilienceElectric => 'Электричество';

  @override
  String get resilienceMagic => 'Магия';

  @override
  String get resilienceIce => 'Лёд';

  @override
  String get resilienceFire => 'Огонь';

  @override
  String get resilienceHint => '0.0 = нет, 1.0 = полный иммунитет';

  @override
  String get resilienceSelectedShieldLabel => 'Выбранный щит стойкости:';

  @override
  String get selectionFilterBySource => 'По источнику';

  @override
  String get selectionFilterByType => 'По типу';

  @override
  String get selectionPreMade => 'Готовые';

  @override
  String get selectionDefinedByUser => 'Пользовательские';

  @override
  String get aliasAlreadyTakenTitle => 'Псевдоним уже занят';

  @override
  String get aliasRenameConfirmTitle => 'Переименовать псевдоним?';

  @override
  String aliasRenameConfirmMessage(String oldAlias, String newAlias) {
    return 'Переименовать «$oldAlias» в «$newAlias»? Все ссылки на этом уровне будут обновлены.';
  }

  @override
  String get resilienceSelectShield => 'Выбрать щит стойкости';

  @override
  String get resilienceCreateCustom => 'Новый пользовательский щит';

  @override
  String get resilienceEditCustom => 'Редактировать щит';

  @override
  String get resilienceSourceResilienceConfig => 'ResilienceConfig';

  @override
  String get resilienceSourceCurrentLevel => 'CurrentLevel';

  @override
  String get resilienceTypeAll => 'Все типы';

  @override
  String get resilienceNoShieldsFound => 'Щиты стойкости не найдены';

  @override
  String get resilienceShieldInUseCannotDelete =>
      'Нельзя удалить — этот щит используется зомби на уровне.';

  @override
  String get resilienceShieldDeleteTitle =>
      'Удалить пользовательский щит стойкости?';

  @override
  String resilienceShieldDeleteMessage(String alias) {
    return 'Удалить «$alias» из этого уровня?';
  }

  @override
  String get aliasAlreadyExists => 'Такой псевдоним уже есть на этом уровне.';

  @override
  String zombieTypeLabel(String type) {
    return 'Тип зомби: $type';
  }

  @override
  String propertyAliasLabel(String alias) {
    return 'Псевдоним свойств: $alias';
  }

  @override
  String get ok => 'ОК';

  @override
  String get helpDialogGotIt => 'Понятно';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Высота';

  @override
  String get customZombieHelpIntro => 'Краткое введение';

  @override
  String get customZombieHelpIntroBody =>
      'На этом экране редактируются параметры своего зомби, внедрённого в уровень. Поддерживаются только общие свойства; многие специальные атрибуты требуют ручного редактирования JSON.';

  @override
  String get customZombieHelpBase => 'Базовые свойства';

  @override
  String get customZombieHelpBaseBody =>
      'Свои зомби могут изменять базовые параметры (HP, скорость, урон поедания). Свои зомби не отображаются в пуле предпросмотра уровня.';

  @override
  String get customZombieHelpHit => 'Попадание/позиция';

  @override
  String get customZombieHelpHitBody =>
      'X и Y — смещения; W и H — ширина и высота. Смещение ArtCenter может скрыть спрайт зомби. Оставьте траекторию пустой, чтобы зомби ходил на месте.';

  @override
  String get customZombieHelpManual => 'Ручное редактирование';

  @override
  String get customZombieHelpManualBody =>
      'Пользовательская инъекция автоматически заполняет все свойства из файлов игры. При необходимости можно дополнительно отредактировать JSON-файл вручную.';

  @override
  String editAlias(String alias) {
    return 'Редактировать $alias';
  }

  @override
  String editNamedEvent(String name) {
    return 'Редактировать событие «$name»';
  }

  @override
  String editNamedModule(String name) {
    return 'Редактировать модуль «$name»';
  }

  @override
  String get addEventAliasTitle => 'Добавить событие';

  @override
  String get addModuleAliasTitle => 'Добавить модуль';

  @override
  String get aliasLabel => 'Псевдоним';

  @override
  String get add => 'Добавить';

  @override
  String get overview => 'Обзор';

  @override
  String get left => 'Влево';

  @override
  String get right => 'Вправо';

  @override
  String get weight => 'Вес';

  @override
  String get maxCount => 'Макс. количество';

  @override
  String get startColumn => 'Начальная колонка';

  @override
  String get endColumn => 'Конечная колонка';

  @override
  String get removeItem => 'Удалить предмет';

  @override
  String removeItemConfirm(String name) {
    return 'Удалить $name?';
  }

  @override
  String groupN(int n) {
    return 'Группа $n';
  }

  @override
  String rowN(int n) {
    return 'Ряд $n';
  }

  @override
  String get addWind => 'Добавить ветер';

  @override
  String get addDropItem => 'Добавить дроп';

  @override
  String get addMirrorGroup => 'Добавить группу зеркал выше';

  @override
  String pipeN(int n) {
    return 'Труба $n';
  }

  @override
  String get setStart => 'Установить начало';

  @override
  String get setEnd => 'Установить конец';

  @override
  String get collectable => 'Собираемый (подкормка)';

  @override
  String get selectGridItem => 'Выбрать предмет';

  @override
  String get addItemTitle => 'Добавить препятствие';

  @override
  String get initialPlantLayout => 'Начальная расстановка растений';

  @override
  String get gridItemLayout => 'Расположение предметов';

  @override
  String get zombieCount => 'Количество зомби';

  @override
  String get timeBeforeSpawn => 'Время до появления (с)';

  @override
  String get waterBoundaryColumn => 'Колонка границы воды';

  @override
  String get columnsDragged => 'Перетаскиваемые колонки (ColNumPlantIsDragged)';

  @override
  String get typeIndex => 'Индекс типа';

  @override
  String get noStyle => 'Без стиля';

  @override
  String styleN(int n) {
    return 'Стиль $n';
  }

  @override
  String get existDurationSec => 'Время существования (сек)';

  @override
  String get mirror1 => 'Зеркало 1';

  @override
  String get mirror2 => 'Зеркало 2';

  @override
  String get ignoreGravestone => 'Игнорировать надгробия (IgnoreGraveStone)';

  @override
  String zombiePreview(String name) {
    return '$name - Превью зомби';
  }

  @override
  String get zombiePreviewTooltip => 'Предпросмотр зомби';

  @override
  String get weatherSettings => 'Настройки погоды';

  @override
  String get holeLifetimeSeconds => 'Время жизни ямы (сек)';

  @override
  String get startingWaveLocation => 'Начальная волна';

  @override
  String get rainIntervalSeconds => 'Интервал падения (сек)';

  @override
  String get startingPlantFood => 'Начальная подкормка';

  @override
  String get bowlingFoulLine => 'Линия запрета посадки';

  @override
  String get bowlingFoulLinePreview => 'Предпросмотр линии запрета посадки';

  @override
  String get bowlingMinigameParams => 'Параметры';

  @override
  String get bowlingMinigameHelpOverview =>
      'Задаёт столбец линии, за которой нельзя сажать растения в режиме боулинга с луковицей.';

  @override
  String get bowlingMinigameHelpFoulLine =>
      'BowlingFoulLine — индекс столбца слева (с 0). Растения нельзя ставить на этой линии и правее неё.\nНа газонах Подводного мира игра автоматически прибавляет к этому значению 1. Например, при значении 0 в первом столбце сажать можно, а со второго — нельзя; поэтому минимальное значение в редакторе равно -1.';

  @override
  String get stopColumn => 'Стоп-колонка';

  @override
  String get speedUp => 'Множитель скорости';

  @override
  String get baseCostIncreased =>
      'Базовое увеличение стоимости (BaseCostIncreased)';

  @override
  String get maxIncreasedCount =>
      'Макс. количество увеличений (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => 'Начальная позиция тумана X';

  @override
  String get normalValueX => 'Нормальное значение X';

  @override
  String get bloverEffectInterval => 'Интервал эффекта травинки (сек)';

  @override
  String get dinoType => 'Тип динозавра';

  @override
  String get dinoRowTitle => 'Ряд';

  @override
  String dinoRow(int n) {
    return 'Ряд: $n';
  }

  @override
  String get dinoWaveDuration => 'Время на поле (волны)';

  @override
  String get eventHelpDinoType =>
      'Какой динозавр появится на поле. У каждого вида своё поведение при помощи зомби.';

  @override
  String get eventHelpDinoRow =>
      'Ряд появления динозавра (с 0). На картах глубокого моря доступен ряд 5.';

  @override
  String get eventHelpDinoWaveDuration =>
      'Сколько волн динозавр остаётся на поле перед уходом.';

  @override
  String get unknownModuleTitle => 'Редактор модуля в разработке';

  @override
  String get unknownModuleHelpTitle => 'Неизвестный модуль';

  @override
  String get unknownModuleHelpBody =>
      'Модуль не зарегистрирован в интерпретаторе уровней.';

  @override
  String get noEditorForModule => 'Редактор для этого модуля недоступен';

  @override
  String get noEditorForModuleBody =>
      'Модуль не зарегистрирован. Возможно добавлен вручную или objclass изменён.';

  @override
  String get invalidEventTitle => 'Недействительное событие';

  @override
  String get invalidEventBody => 'Объект события не удалось разобрать.';

  @override
  String get invalidReference => 'Недействительная ссылка';

  @override
  String aliasNotFound(String alias) {
    return 'Псевдоним \"$alias\" не найден';
  }

  @override
  String invalidRefBody(int wave) {
    return 'Волна $wave ссылается на событие, но объект не найден. Игра упадёт.';
  }

  @override
  String get removeInvalidRef => 'Удалить недействительную ссылку из волны';

  @override
  String get spawnCount => 'Количество появления';

  @override
  String get columnRangeTiming => 'Диапазон колонок и время';

  @override
  String get waveStartMessage => 'Сообщение при старте волны';

  @override
  String get zombieTypeZombieName => 'Тип зомби (ZombieName)';

  @override
  String get optional => 'Необязательно';

  @override
  String get eventHelpBeachStageBody =>
      'Зомби появляются при отливе. Используется в Пиратских морях.';

  @override
  String get eventHelpTidalChangeBody =>
      'Это событие меняет позицию прилива во время волны.';

  @override
  String get eventTideWave => 'Событие: волна прилива';

  @override
  String get eventHelpTideWaveBody =>
      'Подводная волна. Направление: влево или вправо.';

  @override
  String get tideWaveHelpType => 'Направление';

  @override
  String get eventHelpTideWaveType =>
      'Влево: прилив влево. Вправо: прилив вправо.';

  @override
  String get tideWaveHelpParams => 'Параметры';

  @override
  String get eventHelpTideWaveParams =>
      'Длительность, расстояние движения подлодки, ускорение.';

  @override
  String get tideWaveType => 'Направление';

  @override
  String get tideWaveTypeLeft => 'Влево';

  @override
  String get tideWaveTypeRight => 'Вправо';

  @override
  String get tideWaveDuration => 'Длительность';

  @override
  String get tideWaveSubmarineMovingDistance => 'Расстояние подлодки';

  @override
  String get tideWaveSpeedUpDuration => 'Ускорение длит.';

  @override
  String get tideWaveSpeedUpIncreased => 'Ускорение увел.';

  @override
  String get tideWaveSubmarineMovingTime => 'Время подлодки';

  @override
  String get tideWaveZombieMovingSpeed => 'Скорость зомби';

  @override
  String get eventZombieFishWave => 'Зомби-рыбы';

  @override
  String get eventHelpZombieFishWaveBody =>
      'Настройка зомби и рыб. Строка и столбец с 0.';

  @override
  String get eventHelpZombieFishWaveFish =>
      'Размещение рыб на сетке. Размер зависит от стадии: Глубокое море 6×10, обычная 5×9. Строка=Y, Столбец=X.';

  @override
  String get eventHelpBatchLevel =>
      'Установить уровень для всех неэлитных зомби в этой волне. Элитные сохраняют уровень по умолчанию.';

  @override
  String get eventHelpDropConfig =>
      'Подкормка или семена растений, которые несут зомби. Добавьте растения для выпадения карт.';

  @override
  String get fishPropertiesEntryHelp =>
      'Нажмите на ячейку, затем добавьте рыб. Нажмите + для встроенной рыбы. Нажмите на карточку рыбы для копирования, удаления, переключения варианта или создания кастомной. Кастомные рыбы отображают синий значок C. Рыбы вне газона показываются с предупреждением.';

  @override
  String get fishAddCustom => 'Добавить пользовательскую рыбу';

  @override
  String get addFishLabel => 'Добавить рыбу';

  @override
  String get addBuiltInFishLabel => 'Добавить встроенную рыбу';

  @override
  String get makeFishAsCustom => 'Сделать кастомной';

  @override
  String get switchCustomFish => 'Переключить';

  @override
  String get selectCustomFish => 'Выбрать пользовательскую рыбу';

  @override
  String get editCustomFishProperties =>
      'Редактировать свойства пользовательской рыбы';

  @override
  String get fishPropertiesButton => 'Свойства рыб';

  @override
  String get addFishProperties => 'Добавить рыб';

  @override
  String get editFishProperties => 'Редактировать рыб';

  @override
  String get fishPropertiesGrid => 'Размещение рыб (строка Y, столбец X)';

  @override
  String get fishSelectedPosition => 'Выбрано:';

  @override
  String get fishRow => 'Строка';

  @override
  String get fishColumn => 'Столбец';

  @override
  String get fishAtPosition => 'Рыбы здесь:';

  @override
  String get searchFish => 'Поиск рыб';

  @override
  String get noFishFound => 'Рыбы не найдены';

  @override
  String get customFishManagerTitle => 'Пользовательские рыбы';

  @override
  String get customFishAppearanceLocation => 'Место появления:';

  @override
  String get customFishNotUsed =>
      'Эта пользовательская рыба не используется ни в одной волне.';

  @override
  String customFishWaveItem(int n) {
    return 'Волна $n';
  }

  @override
  String get customFishDeleteConfirm =>
      'Удалить эту пользовательскую рыбу и её данные свойств.';

  @override
  String get customFish => 'Пользовательская рыба';

  @override
  String get customFishProperties => 'Свойства пользовательской рыбы';

  @override
  String get fishTypeNotFound => 'Объект типа рыбы не найден.';

  @override
  String fishTypeLabel(String type) {
    return 'Тип рыбы: $type';
  }

  @override
  String get customFishHelpIntro => 'Краткое введение';

  @override
  String get customFishHelpIntroBody =>
      'На этом экране редактируются параметры пользовательской рыбы. Поддерживаются только общие свойства; анимацию и специальные атрибуты нужно редактировать вручную в JSON.';

  @override
  String get customFishHelpProps => 'Свойства';

  @override
  String get customFishHelpPropsBody =>
      'HitRect, AttackRect, ScareRect определяют области столкновения. Speed и ScareSpeed управляют движением. ArtCenter — якорь отрисовки.';

  @override
  String get noEditableFishProps => 'Редактируемые свойства не найдены.';

  @override
  String get fishPropSpeed => 'Скорость';

  @override
  String get fishPropScareSpeed => 'Скорость испуга';

  @override
  String get fishPropDamage => 'Урон';

  @override
  String get fishPropHitpoints => 'Прочность';

  @override
  String get fishPropHitPoints => 'Очки здоровья';

  @override
  String get fishPropHitRect => 'Область попадания';

  @override
  String get fishPropAttackRect => 'Область атаки';

  @override
  String get fishPropScareRect => 'Область испуга';

  @override
  String get fishPropScarerect => 'Область испуга';

  @override
  String get fishPropArtCenter => 'Центр отрисовки';

  @override
  String get edit => 'Редактировать';

  @override
  String get eventHelpTidalChangePosition =>
      'Колонка 0 — справа, 9 — слева. ChangeAmount задаёт границу воды.';

  @override
  String get eventHelpBlackHoleBody =>
      'Событие мира Кунг-фу. Чёрная дыра притягивает растения вправо.';

  @override
  String get eventHelpBlackHoleColumns =>
      'Количество колонок, на которые притягиваются растения.';

  @override
  String get eventHelpMagicMirrorBody =>
      'Волшебные зеркала создают парные порталы на поле.';

  @override
  String get eventHelpMagicMirrorType =>
      'Индекс типа меняет вид зеркала. 3 стиля.';

  @override
  String get eventHelpParachuteRainBody =>
      'Зомби падают с неба во время волны.';

  @override
  String get eventHelpParachuteRainLogic =>
      'Зомби появляются группами. Контроль количества, размера группы, колонок.';

  @override
  String get eventHelpModernPortalsBody =>
      'Создаёт временные порталы на поле, типично для Modern world.';

  @override
  String get eventHelpModernPortalsType =>
      'Много типов порталов; выберите нужный.';

  @override
  String get eventHelpModernPortalsIgnore =>
      'Включено — порталы появятся даже при блокировке надгробиями.';

  @override
  String get eventHelpFrostWindBody =>
      'Событие Ice Age. Морозный ветер замораживает растения.';

  @override
  String get eventHelpFrostWindDirection =>
      'Направление ветра: слева или справа.';

  @override
  String get eventHelpModifyConveyorBody =>
      'Изменяет конвейер во время волны. Добавить или удалить растения.';

  @override
  String get eventHelpModifyConveyorAdd => 'Добавить растения на конвейер.';

  @override
  String get eventHelpModifyConveyorRemove => 'Удалить растения с конвейера.';

  @override
  String get eventHelpDinoBody =>
      'Событие Dino Crisis. Вызов динозавра на указанный ряд.';

  @override
  String get eventHelpDinoDuration => 'Время пребывания динозавра, в волнах.';

  @override
  String get eventDinoTread => 'Событие: Шаг динозавра';

  @override
  String get eventDinoRun => 'Событие: Бег динозавра';

  @override
  String get eventHelpDinoTreadBody =>
      'Динозавр наступает на область сетки (ряд Y, столбцы XMin–XMax), нанося урон растениям.';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY — ряд центра удара; GridXMin и GridXMax задают диапазон возможных центральных столбцов (с 0). Каждый удар покрывает область 3×3 вокруг центра. На предпросмотре выделены все клетки, которые могут быть затронуты. Глубокое море: ряды 0–5, столбцы 0–9.';

  @override
  String get dinoTreadPreview => 'Предпросмотр области удара';

  @override
  String get dinoTreadRowLabel => 'Ряд [GridY]';

  @override
  String get dinoTreadColMinLabel => 'Столбец мин [GridXMin]';

  @override
  String get dinoTreadColMaxLabel => 'Столбец макс [GridXMax]';

  @override
  String get dinoTreadTimeIntervalLabel => 'Интервал [TimeInterval]';

  @override
  String get columnStartLabel => 'Начало [ColumnStart]';

  @override
  String get columnEndLabel => 'Конец [ColumnEnd]';

  @override
  String get eventHelpDinoRunBody =>
      'Динозавр бежит по ряду, нанося урон растениям.';

  @override
  String get eventHelpDinoRunRow =>
      'DinoRow — центральный ряд бега (красный на предпросмотре). Стадо может появиться и в соседних рядах сверху и снизу (жёлтые). Нумерация с 0. Глубокое море поддерживает ряд 5.';

  @override
  String get dinoRunPreview => 'Предпросмотр стада';

  @override
  String get positionAndArea => 'Позиция и область';

  @override
  String get positionAndDuration => 'Позиция и время';

  @override
  String get rowCol0Index => 'Ряд/столбец (с 0)';

  @override
  String get timeInterval => 'Интервал времени';

  @override
  String get eventHelpZombiePotionBody =>
      'Создаёт зелья на сетке, может перекрывать растения.';

  @override
  String get eventHelpZombiePotionUsage =>
      'Выберите клетку, нажмите добавить, выберите тип зелья.';

  @override
  String get eventHelpShellBody =>
      'Создаёт атлантические ракушки на сетке в указанных позициях.';

  @override
  String get eventHelpShellUsage =>
      'Выберите клетку, нажмите добавить для размещения ракушки (5×9 или 6×10 в зависимости от этапа).';

  @override
  String get eventHelpPumpkinHouseBody =>
      'Размещает тыквенные домики в указанных клетках во время волны.';

  @override
  String get eventHelpPumpkinHouseUsage =>
      'Выберите клетку и нажмите «+», чтобы разместить тыквенный домик (5×9 или 6×10 в зависимости от этапа).';

  @override
  String get eventHelpFairyFogBody =>
      'Создаёт туман, дающий зомби щиты. Только ветер развеивает.';

  @override
  String get eventHelpFairyFogRange =>
      'mX, mY — центр; mWidth, mHeight — вправо и вниз.';

  @override
  String get eventHelpFairyWindBody =>
      'Создаёт ветер, разгоняющий сказочный туман.';

  @override
  String get eventHelpFairyWindVelocity =>
      'Меняет скорость снарядов. 1.0 — базовая.';

  @override
  String get eventHelpRaidingPartyBody =>
      'Событие Pirate. Пиратские зомби появляются группами.';

  @override
  String get eventHelpRaidingPartyGroup => 'Зомби в группе.';

  @override
  String get eventHelpRaidingPartyCount => 'Всего пиратских зомби.';

  @override
  String get eventHelpGravestoneBody =>
      'Случайно создаёт препятствия во время волны.';

  @override
  String get eventHelpGravestoneLogic =>
      'Выбор из пула позиций. Предметов не больше позиций.';

  @override
  String get eventHelpGravestoneMissingAssets =>
      'На картах без эффекта надгробий могут отображаться текстуры солнца.';

  @override
  String get eventHelpBarrelWaveBody =>
      'Катящиеся бочки по рядам. Три типа: пустая (без награды), зомби (внутри зомби), взрывная (взрывается при попадании). Ряды с 1.';

  @override
  String get barrelWaveHelpTypes => 'Типы бочек';

  @override
  String get eventHelpBarrelWaveTypes =>
      'Пустая: бочка без зомби. Зомби (монстр): бочка с зомби; используйте выбор зомби. Взрывная: бочка взрывается при попадании; задайте урон взрыва.';

  @override
  String get barrelWaveHelpRows => 'Ряды';

  @override
  String get eventHelpBarrelWaveRows =>
      'Ряды с 1: ряд 1 = сверху, 5/6 = снизу. Стандарт: 5 рядов. Глубокое море: 6 рядов.';

  @override
  String get eventHelpSchoolBusBody =>
      'Спавнит фургон с мороженым в выбранном ряду. Фургон выезжает справа, занимает два ряда и раздавливает растения на пути. Тип «Особый» (schoolbus_special) — с зомби на кузове, использующими способности в движении. Тип «Обычный» (schoolbus_normal) — стандартный вариант. После уничтожения выпускает настроенных зомби.';

  @override
  String get schoolBusHelpRows => 'Ряд';

  @override
  String get eventHelpSchoolBusRows =>
      'Ряды с 1: ряд 1 = сверху, 5/6 = снизу. Стандарт: 5 рядов. Глубокое море: 6 рядов.';

  @override
  String get eventHelpSchoolBusType =>
      'Тип выбирает вариант фургона. Обычный (schoolbus_normal) — стандартный фургон. Особый (schoolbus_special) — с пузырными и леденцовыми зомби на кузове; они используют способности во время движения.';

  @override
  String get schoolBusHelpZombies => 'Зомби';

  @override
  String get eventHelpSchoolBusZombies =>
      'Зомби, выпускаемые при уничтожении фургона. Уровень от 0 до 10 (0 = без бонуса уровня).';

  @override
  String get schoolBusRow => 'Ряд';

  @override
  String get schoolBusType => 'Тип';

  @override
  String get schoolBusTypeNormal => 'Обычный';

  @override
  String get schoolBusTypeSpecial => 'Особый';

  @override
  String get schoolBusHitPoints => 'Здоровье фургона (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => 'Скорость фургона (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => 'Зомби внутри (Zombies)';

  @override
  String get schoolBusZombieLevel => 'Уровень зомби (Level)';

  @override
  String get schoolBusAddZombie => 'Добавить зомби';

  @override
  String get schoolBusRowsHint => 'Ряды с 1: ряд 1 = сверху, 5/6 = снизу.';

  @override
  String get eventHelpThunderWaveBody =>
      'Молнии случайно бьют во время волны. Каждая молния может быть положительной (полезной) или отрицательной (вредной для растений).';

  @override
  String get thunderWaveHelpTypes => 'Типы молний';

  @override
  String get eventHelpThunderWaveTypes =>
      'Положительная: полезная молния. Отрицательная: вредная молния, может убивать растения по вероятности Kill rate.';

  @override
  String get thunderWaveHelpKillRate => 'Вероятность убийства';

  @override
  String get eventHelpThunderWaveKillRate =>
      'Вероятность (0.0–1.0) того, что отрицательная молния убьёт растения на поражённой клетке.';

  @override
  String get thunderWaveTypePositive => 'Положительная';

  @override
  String get thunderWaveTypeNegative => 'Отрицательная';

  @override
  String get thunderWaveKillRate => 'Вероятность убийства';

  @override
  String get thunderWaveKillRateHint =>
      'Вероятность убийства растений при ударе молнии (0.0–1.0)';

  @override
  String get thunderWaveThunders => 'Молнии';

  @override
  String get thunderWaveAddThunder => 'Добавить молнию';

  @override
  String get thunderWaveThunder => 'Молния';

  @override
  String get barrelWaveTypeEmpty => 'Пустая';

  @override
  String get barrelWaveTypeZombie => 'Зомби';

  @override
  String get barrelWaveTypeExplosive => 'Взрывная';

  @override
  String get barrelWaveRowsHint => 'Ряды с 1 (5 стандарт, 6 глубокое море).';

  @override
  String get barrelWaveAddBarrel => 'Добавить бочку';

  @override
  String get barrelWaveBarrel => 'Бочка';

  @override
  String get barrelWaveRow => 'Ряд';

  @override
  String get barrelWaveType => 'Тип';

  @override
  String get barrelWaveHitPoints => 'Прочность';

  @override
  String get barrelWaveSpeed => 'Скорость';

  @override
  String get barrelWaveZombies => 'Зомби';

  @override
  String get barrelWaveZombieLevel => 'Уровень зомби';

  @override
  String get barrelWaveAddZombie => 'Добавить зомби';

  @override
  String get barrelWaveExplosionDamage => 'Урон взрыва';

  @override
  String get barrelWaveDeleteTitle => 'Удалить бочку';

  @override
  String get barrelWaveDeleteConfirm => 'Удалить эту бочку?';

  @override
  String get barrelWaveDeleteLastHint =>
      'Это последняя бочка. У события не останется бочек. Продолжить?';

  @override
  String get eventHelpGraveSpawnWait =>
      'Задержка от начала волны до появления зомби.';

  @override
  String get eventHelpStormBody =>
      'Песчаная буря или метель телепортирует зомби вперёд.';

  @override
  String get eventHelpStormColumns =>
      'Колонка 0 — слева, 9 — справа. Начало < конец.';

  @override
  String get eventHelpStormLevels =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get eventHelpGroundSpawnBody => 'Настройка зомби этой волны.';

  @override
  String get moduleHelpDeathHoleBody =>
      'После того как растение выкопано или съедено, на его клетке на некоторое время остаётся непригодная для посадки яма.';

  @override
  String get moduleHelpZombieMoveFastBody =>
      'Зомби быстро перемещаются при выходе на поле и возвращаются к обычной скорости после достижения указанного столбца. Этот модуль используется в Zombie Elimination Initiative.';

  @override
  String get moduleHelpSeedRainBody =>
      'Этот модуль через заданные интервалы сбрасывает с неба карточки предметов.';

  @override
  String get moduleHelpSeedRainParameters => 'Настройка параметров';

  @override
  String get moduleHelpSeedRainParametersBody =>
      'Вес определяет вероятность выпадения, а максимальное количество — сколько одинаковых предметов может одновременно находиться на поле. Для большинства зомби нет подходящих значков карточек.';

  @override
  String get moduleHelpSeedRainPlantLevels => 'Уровни растений';

  @override
  String get seedRainAddContentTitle => 'Добавить содержимое дождя из семян';

  @override
  String get seedRainAddPlantDescription =>
      'Выберите одну или несколько карточек растений, которые будут падать с неба.';

  @override
  String get seedRainAddZombieDescription =>
      'Выберите одну или несколько карточек зомби, которые будут падать с неба.';

  @override
  String get seedRainAddPlantFoodDescription =>
      'Добавьте подкормку как возможный выпадающий предмет.';

  @override
  String get moduleHelpRailcartBody =>
      'Здесь можно размещать вагонетки и рельсы и выбирать вид вагонетки. Нажмите клетку один раз для размещения и ещё раз для удаления.';

  @override
  String get moduleHelpRailcartRailsBody =>
      'В режиме укладки рельсов нажимайте клетки сетки. Редактор автоматически объединяет соседние клетки одного столбца в единый сегмент рельсов.';

  @override
  String get moduleHelpRailcartCartsBody =>
      'Нажимайте клетки, чтобы размещать или удалять вагонетки. Вагонетки на одном сегменте рельсов могут накладываться друг на друга.';

  @override
  String get moduleHelpTideBody =>
      'Включает систему приливов и начальную позицию.';

  @override
  String get moduleHelpTidePosition =>
      'Правая граница 0, левая 9. Отрицательные допустимы.';

  @override
  String get initialTidePosition => 'Начальная позиция прилива';

  @override
  String get moduleHelpManholeBody => 'Определяет подземные трубы Steam Age.';

  @override
  String get moduleHelpManholeEdit => 'Режим начало/конец, затем тап по сетке.';

  @override
  String get moduleHelpWeatherBody =>
      'Глобальные погодные эффекты (дождь, снег, темнота).';

  @override
  String get moduleHelpWeatherRef => 'Эти опции ссылаются на LevelModules.';

  @override
  String get moduleHelpZombiePotionBody =>
      'Этот модуль периодически создаёт указанные препятствия в случайных рядах справа налево.';

  @override
  String get moduleHelpZombiePotionMechanism => 'Механика появления';

  @override
  String get moduleHelpZombiePotionMechanismBody =>
      'Препятствия появляются случайно в заданном интервале времени. Если их количество на поле достигло предела, генерация приостанавливается.';

  @override
  String get moduleHelpZombiePotionPotionTypes => 'Типы зелий';

  @override
  String get moduleHelpZombiePotionTypes =>
      'Тип выбирается случайно из настроенного списка. Чтобы через фиксированный интервал создавать несколько препятствий, добавьте этот модуль в уровень несколько раз.';

  @override
  String get moduleHelpUnknownBody =>
      'Уровни состоят из корня и модулей. У каждого — aliases, objclass, objdata.';

  @override
  String get moduleHelpUnknownEvents =>
      'Приложение парсит по objclass. Модуль не зарегистрирован.';

  @override
  String get eventHelpInvalidBody =>
      'Событие указано, но парсер не находит объект.';

  @override
  String get eventHelpInvalidImpact =>
      'Сохранять ссылку — игра упадёт. Удалите вручную.';

  @override
  String get position => 'Позиция';

  @override
  String get editing => 'Редактирование';

  @override
  String get logic => 'Логика';

  @override
  String get impact => 'Влияние';

  @override
  String get events => 'События';

  @override
  String get referenceModules => 'Ссылки на модули';

  @override
  String get portalType => 'Тип портала (PortalType)';

  @override
  String get selectPortalType => 'Выберите тип портала';

  @override
  String get noPortalTypesFound => 'Типы порталов не найдены.';

  @override
  String get noPortalTypeSelected => 'Тип портала не выбран.';

  @override
  String get direction => 'Направление';

  @override
  String get windDirectionLabel => 'Направление ветра';

  @override
  String get velocityScale => 'Масштаб скорости';

  @override
  String get range => 'Диапазон';

  @override
  String get columnRange => 'Диапазон колонок';

  @override
  String get eventColumnRangeBoundaryHint =>
      'Левая граница газона — столбец 0, правая — столбец 9. Начальная колонка должна быть меньше конечной.';

  @override
  String get eventColumnRangeExampleHint =>
      'Чтобы спавнить с n-й по m-ю колонку, укажите n - 1 в начальной колонке и m в конечной.';

  @override
  String get zombieLevels => 'Уровни зомби';

  @override
  String get missingAssets => 'Отсутствуют ресурсы';

  @override
  String get usage => 'Использование';

  @override
  String get types => 'Типы';

  @override
  String get eventBlackHole => 'Событие чёрной дыры';

  @override
  String get attractionConfig => 'Настройка притяжения';

  @override
  String get placePlant => 'Разместить растение';

  @override
  String get plantList => 'Список растений (строки сначала)';

  @override
  String get firstCostume => 'Первый костюм (Avatar)';

  @override
  String get costumeOn => 'Костюм: надет';

  @override
  String get costumeOff => 'Костюм: не надет';

  @override
  String get outsideLawnItems => 'Объекты вне газона';

  @override
  String get zombieFromLeft => 'Слева';

  @override
  String get eventMagicMirror => 'Событие волшебного зеркала';

  @override
  String get eventParachuteRain =>
      'Событие парашютного/басового/паучьего дождя';

  @override
  String get selectZombie => 'Выбрать зомби';

  @override
  String get manholePipeline => 'Люковая труба';

  @override
  String get manholePipelines => 'Люковые трубы';

  @override
  String get manholePipelineHelpTitle => 'Люковый трубопровод';

  @override
  String get manholePipelineHelpOverview =>
      'Определяет подземные соединения труб в Паровых Веках.';

  @override
  String get manholePipelineHelpEditing =>
      'Переключайте режим начала/конца, затем нажмите на сетку для размещения.';

  @override
  String get smokePollutionModuleTitle => 'Модуль дымовых люков';

  @override
  String get smokePollutionModuleHelpTitle => 'Справка: дымовые люки';

  @override
  String get smokePollutionModuleHelpOverview => 'Обзор';

  @override
  String get smokePollutionModuleHelpOverviewBody =>
      'Размещает на газоне дымовые люки, которые через заданное время выбрасывают ядовитый пар. Часто используется в уровнях Парового века.';

  @override
  String get smokePollutionModuleHelpManholes => 'Проходные люки';

  @override
  String get smokePollutionModuleHelpManholesBody =>
      'Выберите клетку на сетке и добавьте люки в этой позиции. У каждого люка есть стартовое время — секунды от начала уровня до выброса ядовитого пара.';

  @override
  String get smokePollutionModuleStartTimeLabel => 'Стартовое время (с)';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return 'Начало: ($sx, $sy)  Конец: ($ex, $ey)';
  }

  @override
  String get piratePlank => 'Пиратская доска';

  @override
  String get weatherModule => 'Модуль погоды';

  @override
  String get zombiePotion => 'Зелье зомби';

  @override
  String get zombiePotionSettings => 'Настройки зелий зомби';

  @override
  String get zombiePotionHelpTitle => 'Справка по модулю зелий зомби';

  @override
  String get eventTimeRift => 'Событие временного разлома';

  @override
  String get deathHole => 'Дыра смерти';

  @override
  String get seedRain => 'Семенной дождь';

  @override
  String get eventFrostWind => 'Событие ледяного ветра';

  @override
  String get lastStandSettings => 'Настройки последнего рубежа';

  @override
  String get lastStandInitialResourceSettings => 'Начальные ресурсы';

  @override
  String get lastStandManualStartupHint =>
      'После добавления модуля Last Stand редактор автоматически включает Manual Startup в модуле Wave Manager.';

  @override
  String get lastStandHelpTitle => 'Справка по модулю Last Stand';

  @override
  String get lastStandHelpOverviewBody =>
      'Когда этот модуль включён, уровень начинается с фазы подготовки: зомби не появляются сразу, а игрок может тратить начальное солнце на размещение растений. Волны начнутся только после нажатия кнопки начала боя.';

  @override
  String get lastStandHelpNotes => 'Примечания';

  @override
  String get lastStandHelpNotesBody =>
      'Для Last Stand нужно включить Manual Startup в Wave Manager, иначе зомби появятся автоматически. Редактор сам управляет этим переключателем при добавлении или удалении модуля Last Stand.';

  @override
  String get roofFlowerPot => 'Цветочный горшок на крыше';

  @override
  String get roofFlowerPotColumns => 'Диапазон цветочных горшков';

  @override
  String get roofFlowerPotStartColumn => 'Начальная колонка (StartColumn)';

  @override
  String get roofFlowerPotEndColumn => 'Конечная колонка (EndColumn)';

  @override
  String get roofFlowerPotPreview => 'Предпросмотр горшков';

  @override
  String get roofFlowerPotLawnMismatchWarning =>
      'Текущий газон не является крышей. Модуль может не сработать в игре и даже вызвать сбой уровня.';

  @override
  String get eventConveyorModify => 'Событие изменения конвейера';

  @override
  String get bowlingMinigame => 'Мини-игра в боулинг';

  @override
  String get zombieMoveFast => 'Быстрое движение зомби';

  @override
  String get eventPotionDrop => 'Событие падения зелья';

  @override
  String get eventShellSpawn => 'Событие спавна ракушек';

  @override
  String get eventPumpkinHouseSpawn => 'Событие: тыквенные домики';

  @override
  String get eventSchoolBusSpawn => 'Событие: фургон с мороженым';

  @override
  String get warMist => 'Военный туман';

  @override
  String get eventDino => 'Событие динозавра';

  @override
  String get duration => 'Длительность';

  @override
  String get sunDropper => 'Солнечный дождь';

  @override
  String get eventFairyWind => 'Событие сказочного ветра';

  @override
  String get eventFairyFog => 'Событие сказочного тумана';

  @override
  String get eventRaidingParty => 'Событие пиратского рейда';

  @override
  String get swashbucklerCount => 'Количество пиратов';

  @override
  String get sunBomb => 'Солнечная бомба';

  @override
  String get eventSpawnGravestones => 'Событие спавна надгробий';

  @override
  String get eventBarrelWave => 'Событие: бочки';

  @override
  String get eventThunderWave => 'Событие: гром';

  @override
  String get eventGraveSpawn => 'Событие спавна из могил';

  @override
  String get zombieSpawnWait => 'Ожидание спавна зомби';

  @override
  String get selectCustomZombie => 'Выбрать кастомного зомби';

  @override
  String get change => 'Изменить';

  @override
  String get autoLevel => 'Автоуровень';

  @override
  String get apply => 'Применить';

  @override
  String get applyBatchLevel => 'Применить групповой уровень?';

  @override
  String get conveyorBelt => 'Конвейер';

  @override
  String get starChallenges => 'Звёздные испытания';

  @override
  String get addChallenge => 'Добавить испытание';

  @override
  String get unknownChallengeType => 'Неизвестный тип испытания';

  @override
  String get protectedPlants => 'Защищаемые растения';

  @override
  String get addPlant => 'Разместить растение';

  @override
  String get protectedGridItems => 'Защищаемые предметы';

  @override
  String get addGridItem => 'Разместить препятствие';

  @override
  String get plantLevels => 'Уровни растений';

  @override
  String get scope => 'Область';

  @override
  String get applyBatch => 'Применить группу';

  @override
  String get addPlants => 'Добавить растения';

  @override
  String get noPlantsConfigured => 'Растения не настроены';

  @override
  String batchLevelFormat(int level) {
    return 'Групповой уровень: $level';
  }

  @override
  String get protectPlants => 'Защищать растения';

  @override
  String get autoCount => 'Автосчёт';

  @override
  String get overrideStartingPlantfood => 'Переопределить начальную еду';

  @override
  String get startingPlantfoodOverride => 'Переопределение начальной еды';

  @override
  String get iconText => 'Текст иконки';

  @override
  String get iconImage => 'Изображение иконки';

  @override
  String get overrideMaxSun => 'Переопределить максимум солнца';

  @override
  String get maxSunOverride => 'Переопределение макс. солнца';

  @override
  String get maxSunHelpTitle => 'Модуль макс. солнца';

  @override
  String get maxSunHelpOverview =>
      'Этот модуль изначально использовался для настройки уровней сложности. Используйте его для переопределения максимального количества солнца в уровне.';

  @override
  String get startingPlantfoodHelpTitle => 'Модуль начальной еды';

  @override
  String get startingPlantfoodHelpOverview =>
      'Этот модуль изначально использовался для настройки уровней сложности. Используйте его для переопределения начального количества подкормки в уровне.';

  @override
  String get starChallengeHelpTitle => 'Модуль звёздных испытаний';

  @override
  String get starChallengeHelpOverview =>
      'Выберите модули испытаний для уровня. Можно задать несколько целей и использовать один тип испытания несколько раз.';

  @override
  String get starChallengeHelpSuggestionTitle => 'Рекомендации';

  @override
  String get starChallengeHelpSuggestion =>
      'У некоторых испытаний есть окна прогресса в игре. При большом количестве модулей они могут перекрываться.';

  @override
  String get remove => 'Удалить';

  @override
  String get plant => 'Растение';

  @override
  String get zombie => 'Зомби';

  @override
  String get initialZombieLayout => 'Начальная расстановка зомби';

  @override
  String get placeZombie => 'Разместить зомби';

  @override
  String get manualInput => 'Ручной ввод';

  @override
  String get waveManagerModule => 'Модуль менеджера волн';

  @override
  String get points => 'Очки';

  @override
  String get eventStorm => 'Событие бури';

  @override
  String get row => 'Ряд';

  @override
  String get addType => 'Добавить тип';

  @override
  String get plantFunExperimental => 'Растение (Развлечение/Эксп.)';

  @override
  String get availableZombies => 'Доступные зомби';

  @override
  String get presetPlants => 'Пресеты растений (PresetPlantList)';

  @override
  String get whiteList => 'Белый список (WhiteList)';

  @override
  String get blackList => 'Чёрный список (BlackList)';

  @override
  String get chooser => 'Выбор';

  @override
  String get preset => 'Пресет';

  @override
  String get seedBankHelp => 'Справка по банку семян';

  @override
  String get conveyorBeltHelp => 'Справка по конвейеру';

  @override
  String get dropDelayConditions => 'Задержка падения (DropDelayConditions)';

  @override
  String get unitSeconds => 'Ед.: секунды';

  @override
  String get speedConditions => 'Скорость (SpeedConditions)';

  @override
  String get speedConditionsSubtitle => 'Станд. 100, выше — быстрее';

  @override
  String get addPlantConveyor => 'Добавить растение';

  @override
  String get addTool => 'Добавить инструмент';

  @override
  String get increasedCost => 'Повышенная стоимость';

  @override
  String get powerTile => 'Силовая плитка';

  @override
  String get powerTileGridSection => 'Сетка силовых плиток';

  @override
  String get powerTileGridHelpPrimary =>
      'Нажмите клетку, чтобы поставить выбранную группу. Повторное нажатие снимает плитку той же группы. Если там другая группа — она заменяется.';

  @override
  String get powerTileGridHelpSecondaryMobile =>
      'Долгое нажатие на клетку: выбор группы, очистка или задержка распространения.';

  @override
  String get powerTileGridHelpSecondaryDesktop =>
      'Правый щелчок по клетке: выбор группы, очистка или задержка распространения.';

  @override
  String get powerTileLinkedTilesSection => 'Связанные плитки';

  @override
  String get powerTilePropagationDelayLabel => 'Задержка распространения (с)';

  @override
  String get powerTilePropagationDelayTooltip =>
      'Задержка в секундах перед распространением эффекта по связи (0–5).';

  @override
  String get powerTileDialogEditCell => 'Редактировать клетку';

  @override
  String get powerTileDialogTileGroup => 'Группа плитки';

  @override
  String get powerTileDialogNone => 'Нет';

  @override
  String get powerTileDialogPropagationDelay => 'Задержка распространения (с)';

  @override
  String get powerTileHelpOverview =>
      'Размещайте силовые плитки по группам (α–ε). Для каждой можно задать задержку распространения. Плитки не из выбранной группы в сетке отображаются полупрозрачными.';

  @override
  String get powerTileHelpGridSize =>
      'На этапах «Глубокое море» / Атлантида сетка 10×6; на остальных — 9×5.';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return 'Быстрое редактирование: $interaction';
  }

  @override
  String get eventStandardSpawn => 'Событие: стандартный спавн';

  @override
  String get eventGroundSpawn => 'Событие: наземный спавн';

  @override
  String get eventEditorInDevelopment => 'Редактор событий в разработке';

  @override
  String get level => 'Уровень';

  @override
  String get missingTideModule => 'Отсутствует модуль приливов';

  @override
  String get levelHasNoTideProperties =>
      'В уровне нет TideProperties. Событие может не работать.';

  @override
  String get changePosition => 'Изменить позицию';

  @override
  String get changePositionChangeAmount => 'Изменить позицию (ChangeAmount)';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get fogPreview => 'Предпросмотр тумана';

  @override
  String get water => 'Вода';

  @override
  String get land => 'Суша';

  @override
  String get tidePositionOrderHint =>
      'Крайняя правая координата поля — 0, крайняя левая — 9. Модуль приливов необходимо добавлять последним, иначе уровень может аварийно завершиться.';

  @override
  String groupConfigN(int n) {
    return 'Конфигурация группы $n';
  }

  @override
  String get globalParameters => 'Глобальные параметры';

  @override
  String get timePerGrid => 'Время на клетку';

  @override
  String get damagePerSecond => 'Урон в секунду';

  @override
  String get pipe => 'Труба';

  @override
  String get stageMismatch => 'Несовпадение этапа';

  @override
  String get currentStageNotPirate =>
      'Текущий этап не Pirate. Модуль может не работать.';

  @override
  String get plankPreview => 'Предпросмотр досок';

  @override
  String get plankRows => 'Ряды досок (0–4)';

  @override
  String get plankRowsDeepSea => 'Ряды досок (0–5)';

  @override
  String get selectedRows => 'Выбранные ряды';

  @override
  String get indexLabel => 'Индекс';

  @override
  String get selectWeatherType => 'Выбрать тип погоды';

  @override
  String get counts => 'Управление количеством';

  @override
  String get initialCount => 'Начальное количество';

  @override
  String get maximumCount => 'Максимальное количество';

  @override
  String get spawnInterval => 'Интервал появления';

  @override
  String get minimumIntervalSeconds => 'Минимальный интервал (секунды)';

  @override
  String get maximumIntervalSeconds => 'Максимальный интервал (секунды)';

  @override
  String get potionTypeList => 'Список типов зелий';

  @override
  String get initial => 'Начальное';

  @override
  String get max => 'Макс';

  @override
  String get spawnTimerShort => 'Таймер спавна';

  @override
  String get minSec => 'Мин (сек)';

  @override
  String get maxSec => 'Макс (сек)';

  @override
  String get ignoreGravestoneSubtitle =>
      'Разрешить спавн несмотря на препятствия';

  @override
  String get thisPortalSpawns => 'Этот портал создаёт:';

  @override
  String startEndFormat(int sx, int sy, int ex, int ey) {
    return 'Начало: ($sx, $sy)  Конец: ($ex, $ey)';
  }

  @override
  String indexN(int n) {
    return 'Индекс: $n';
  }

  @override
  String get noItemsAddHint =>
      'Нет предметов. Добавьте растения, зомби или коллекционные.';

  @override
  String get zombieTypeSpiderZombieName => 'Тип зомби (SpiderZombieName)';

  @override
  String get noneSelected => 'Не выбрано';

  @override
  String get totalSpiderCount => 'Всего (SpiderCount)';

  @override
  String get perBatchGroupSize => 'В группе (GroupSize)';

  @override
  String get fallTime => 'Время падения (с)';

  @override
  String get waveStartMessageLabel => 'Красный подзаголовок (WaveStartMessage)';

  @override
  String get optionalWarningText => 'Необязательный текст предупреждения';

  @override
  String rowNShort(int n) {
    return 'Ряд $n';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return 'Вес: $weight, Макс: $max';
  }

  @override
  String seedRainTypeLabel(String type) {
    return 'Тип: $type';
  }

  @override
  String seedRainWeightLabel(int weight) {
    return 'Вес: $weight';
  }

  @override
  String seedRainMaxLabel(int max) {
    return 'Макс: $max';
  }

  @override
  String get random => 'Случайно';

  @override
  String get noChallengesConfigured => 'Нет настроенных испытаний';

  @override
  String get whiteListBlackListHint =>
      'Белый список: пусто = без ограничений. Чёрный список имеет приоритет.';

  @override
  String get conveyorBeltHelpIntro =>
      'Режим конвейера случайно генерирует карты по весу. Настройте пул растений и задержку.';

  @override
  String get conveyorBeltHelpPool =>
      'Пул растений и вес: вероятность = вес / общий вес.';

  @override
  String get conveyorBeltHelpDropDelay =>
      'Задержка падения: интервал появления карт. Больше растений — медленнее.';

  @override
  String get conveyorBeltHelpSpeed =>
      'Скорость: физическая скорость ленты. Станд. = 100.';

  @override
  String get cannotAddEliteZombies => 'Нельзя добавить элитных зомби';

  @override
  String get eliteZombiesNotAllowed => 'Элитные зомби здесь не допускаются';

  @override
  String get yetiZombiesNotAllowed => 'Yetis are not allowed here';

  @override
  String fixToAlias(String alias) {
    return 'Исправить на $alias';
  }

  @override
  String editPresetZombie(String name) {
    return 'Редактировать пресет зомби: $name';
  }

  @override
  String get missingZombossMechModule =>
      'Отсутствует ZombossBattleModuleProperties';

  @override
  String get missingZombossBattleModule =>
      'Отсутствует ZombossLastStandMinigameProperties';

  @override
  String get challengeNoConfig => 'Это испытание не поддерживает настройку.';

  @override
  String get maxPotionCount => 'Макс. кол-во зелий';

  @override
  String potionTypesConfigured(int count) {
    return 'Типов зелий настроено: $count';
  }

  @override
  String pipelinesCount(int count) {
    return 'Трубы: $count';
  }

  @override
  String windN(int n) {
    return 'Ветер #$n';
  }

  @override
  String get zombieList => 'Список зомби (строки сначала)';

  @override
  String get positionPoolSpawnPositions => 'Пул позиций (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect =>
      'Нажмите клетки для выбора позиций спавна';

  @override
  String get gravestonePool => 'Пул надгробий (GravestonePool)';

  @override
  String get removePlants => 'Удалить растения';

  @override
  String get current => 'Текущий';

  @override
  String get eliteZombiesUseDefaultLevel =>
      'Элитные зомби используют уровень по умолчанию.';

  @override
  String get basicParameters => 'Основные параметры';

  @override
  String get zombieSpawnWaitSec => 'Ожидание спавна зомби (сек)';

  @override
  String get gridTypes => 'Типы препятствий';

  @override
  String zombiesCount(int count) {
    return 'Зомби ($count)';
  }

  @override
  String stormCarriedZombiesCount(int count) {
    return 'Переносимые зомби (всего: $count)';
  }

  @override
  String get eventGraveSpawnSubtitle => 'Событие: спавн из препятствий';

  @override
  String get eventStormSpawnSubtitle => 'Событие: спавн бури';

  @override
  String get eventHelpGraveSpawnBody =>
      'Событие спавнит зомби из определённых препятствий, часто в эре Тёмных веков.';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      'Задержка от начала волны до спавна. Если волна уже сменилась — зомби не появятся.';

  @override
  String get eventHelpStormOverview =>
      'Песчаная или снежная буря быстро доставляет зомби на переднюю линию. Экстрим-холод замораживает растения.';

  @override
  String get eventHelpStormColumnRange =>
      'Колонки 0–9. Левый край — 0, правый — 9. Начальная колонка меньше конечной.';

  @override
  String get eventHelpStormZombieLevels =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get spawnParameters => 'Параметры спавна';

  @override
  String get sandstorm => 'Песчаная буря';

  @override
  String get snowstorm => 'Снежная буря';

  @override
  String get excoldStorm => 'Экстрим-холод';

  @override
  String get columnStart => 'Начальная колонка';

  @override
  String get columnEnd => 'Конечная колонка';

  @override
  String get groupSize => 'Размер группы';

  @override
  String get timeBetweenGroups => 'Время между группами';

  @override
  String applyBatchLevelContent(int level) {
    return 'Установить всем зомби этой волны уровень $level (элитные без изменений).';
  }

  @override
  String get randomRow => 'Случайный ряд';

  @override
  String levelFormat(int level) {
    return 'Уровень: $level';
  }

  @override
  String get levelAccount => 'Уровень: учётная запись';

  @override
  String levelDisplay(String value) {
    return 'Уровень: $value';
  }

  @override
  String get eventStandardSpawnTitle => 'Событие стандартного спавна';

  @override
  String get eventGroundSpawnTitle => 'Событие спавна с земли';

  @override
  String get eventHelpStandardOverview =>
      'Настройка зомби этой волны. Уровень 0 — по уровню карты.';

  @override
  String get eventHelpStandardRow => 'Ряды 0–4. Пусто — случайный ряд.';

  @override
  String get eventHelpStandardRowDeepSea =>
      'Ряды 0–5 (6 рядов). Пусто — случайный ряд.';

  @override
  String get ztPerksSectionTitle => 'Баффы Ztalemate';

  @override
  String get ztPerksSectionHint =>
      'Каждый тип баффа можно назначить зомби только один раз.';

  @override
  String get ztPerksNone => 'Баффы не назначены.';

  @override
  String get ztPerksAdd => 'Добавить бафф';

  @override
  String get ztPerksAddTitle => 'Добавить баффы зомби';

  @override
  String get ztPerksTypeAlreadyAssigned => 'Бафф этого типа уже назначен.';

  @override
  String get eventHelpJitteredZtPerks =>
      'Назначайте баффы Ztalemate Escape отдельным зомби. Они сохраняются в массиве Titles. На одного зомби можно назначить только один бафф каждого типа (например, Crystal I и Crystal II вместе нельзя).';

  @override
  String get ztPerkCategoryCrystal => 'Кристалл';

  @override
  String get ztPerkCategoryAttack => 'Атака';

  @override
  String get ztPerkCategorySpeed => 'Скорость';

  @override
  String get ztPerkCategoryShield => 'Щит';

  @override
  String get ztPerkCategoryGravity => 'Гравитация';

  @override
  String get ztPerkCategoryImmuneControl => 'Иммунитет к контролю';

  @override
  String get ztPerkCategoryAntiControl => 'Сопротивление контролю';

  @override
  String get ztPerksViewStats => 'Показать параметры';

  @override
  String get ztPerkPropDamageTakenInterval => 'Интервал получения урона';

  @override
  String get ztPerkPropDamageTotalTaken => 'Всего получено урона';

  @override
  String get ztPerkPropDamageTakenPerTime => 'Урон за интервал';

  @override
  String get ztPerkPropHpReduced => 'Снижение HP';

  @override
  String get ztPerkPropShieldNum => 'Слоёв щита';

  @override
  String get ztPerkPropReducedControlPercent => 'Снижение контроля';

  @override
  String get ztPerkPropReducedDamagePercent => 'Снижение урона';

  @override
  String get ztPerkPropImprovedDamagePercent => 'Усиление урона';

  @override
  String get ztPerkPropImprovedSpeedPercent => 'Усиление скорости';

  @override
  String ztPerkDescCrystal(
    String interval,
    String damagePerHit,
    String hpReduced,
  ) {
    return 'Даёт иммунитет к мгновенному убийству. Урон можно получать не чаще одного раза в $interval с, каждый удар наносит $damagePerHit урона, а здоровье снижается на $hpReduced.';
  }

  @override
  String get ztPerkDescGravity =>
      'Отбрасывание и подбрасывание больше не действуют.';

  @override
  String ztPerkDescShield(String shieldNum) {
    return 'Первые $shieldNum получения урона игнорируются; иммунитет к мгновенному убийству сохраняется на всё время действия баффа.';
  }

  @override
  String ztPerkDescImmuneControl(String percent) {
    return 'Сопротивление контролю увеличено на $percent.';
  }

  @override
  String ztPerkDescAntiControl(String percent) {
    return 'Под контролем получаемый урон снижается на $percent.';
  }

  @override
  String ztPerkDescAttack(String percent) {
    return 'Сила атаки увеличена на $percent.';
  }

  @override
  String ztPerkDescSpeed(String percent) {
    return 'Скорость передвижения увеличена на $percent.';
  }

  @override
  String get ztPerksCategoryInfoTitle => 'Описание баффов';

  @override
  String get ztPerkCategoryDescNumericHint =>
      'Буквы A, B, X, N, P и т. п. обозначают числовые значения, которые меняются по уровню баффа.';

  @override
  String get ztPerkCategoryDescCrystal =>
      'Даёт иммунитет к мгновенному убийству. Урон можно получать не чаще одного раза в A секунд, каждый удар наносит B урона, а здоровье снижается на X.';

  @override
  String get ztPerkCategoryDescGravity =>
      'Отбрасывание и подбрасывание больше не действуют.';

  @override
  String get ztPerkCategoryDescShield =>
      'Первые N получения урона игнорируются; иммунитет к мгновенному убийству сохраняется на всё время действия баффа.';

  @override
  String get ztPerkCategoryDescImmuneControl =>
      'Сопротивление контролю увеличено на P%.';

  @override
  String get ztPerkCategoryDescAntiControl =>
      'Под контролем получаемый урон снижается на P%.';

  @override
  String get ztPerkCategoryDescAttack => 'Сила атаки увеличена на P%.';

  @override
  String get ztPerkCategoryDescSpeed =>
      'Скорость передвижения увеличена на P%.';

  @override
  String get warningStageSwitchedTo5Rows =>
      'Этап использует 5 рядов, но часть данных ссылается на 6-й ряд. Объекты могут отображаться некорректно.';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return 'Некоторые объекты вне игровой области ($rows×$cols).';
  }

  @override
  String get izombieModeTitle => 'Режим «Я — зомби»';

  @override
  String get izombieModeSubtitle =>
      'Включить для расстановки зомби. Блокирует способ выбора.';

  @override
  String get reverseZombieFactionTitle => 'Обратная фракция зомби';

  @override
  String get reverseZombieFactionSubtitle =>
      'Зомби становятся фракцией растений. Для ЗвЗ.';

  @override
  String get initialWeight => 'Начальный вес';

  @override
  String get plantLevelLabel => 'Уровень растения';

  @override
  String get missingIntroModule => 'Отсутствует модуль интро';

  @override
  String get missingIntroModuleHint =>
      'Уровню не хватает ZombossBattleIntroProperties. Добавьте модуль и выберите ZombossMech снова.';

  @override
  String get zombossMechType => 'Тип ZombossMech';

  @override
  String get unknownZombossMech => 'Неизвестный ZombossMech';

  @override
  String get zombossMechSelection => 'Выбор ZombossMech';

  @override
  String get zombossMechBaseLabel => 'Базовый ZombossMech';

  @override
  String get zombossMechBaseHint =>
      'Семейство мех-боссов (Египет, Будущее, робот Memory Lane и т.д.). При смене обновляется список вариантов ниже.';

  @override
  String get zombossMechSelectBaseTitle => 'Выбор базового ZombossMech';

  @override
  String get zombossMechChangeBase => 'Сменить базовый ZombossMech';

  @override
  String get zombossMechUsedProperties => 'Используемые свойства';

  @override
  String get zombossMechVariationLabel => 'Вариант';

  @override
  String get zombossMechVariationHint =>
      'Конкретный тип меха в уровне (ZombossMechType). Список зависит от выбранного базового ZombossMech. Фазы и позиция появления синхронизируются автоматически.';

  @override
  String get zombossBattleSelection => 'Выбор Зомбосса';

  @override
  String get zombossBattleSelectBaseTitle => 'Выбор базового Зомбосса';

  @override
  String get zombossBattleChangeBase => 'Сменить базового Зомбосса';

  @override
  String get zombossBattleBaseLabel => 'Базовый Зомбосс';

  @override
  String get zombossBattleBaseHint =>
      'Семейство боссов (Kongfu, Цинь Шихуанди и т.д.). При смене автоматически обновляются группы ресурсов.';

  @override
  String get zombossBattleVariationLabel => 'Вариант';

  @override
  String get zombossBattleVariationHint =>
      'Конкретный тип Зомбосса в уровне (ZombossTypeName). Список зависит от выбранного базового Зомбосса.';

  @override
  String get zombossBattleStartingSunLabel => 'Начальное солнце (StartingSun)';

  @override
  String get zombossBattleStartingSunHint => 'Солнце в начале боя.';

  @override
  String get zombossBattleStartingPlantfoodLabel =>
      'Начальная удобр. (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint => 'Удобрения в начале боя.';

  @override
  String get zombossBattleInitialGridColLabel =>
      'Колонка появления (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint =>
      'Колонка сетки, где появляется Зомбосс.';

  @override
  String get zombossBattleInitialGridRowLabel =>
      'Строка появления (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint =>
      'Строка сетки, где появляется Зомбосс.';

  @override
  String get zombossBattleStartStageIndexLabel =>
      'Начальная фаза (ZombossStartStageIndex)';

  @override
  String get zombossBattleStartStageIndexHint =>
      'С какой фазы босса начинается бой (0 — первая фаза).';

  @override
  String get zombossBattleSkipPlantingLabel =>
      'Пропустить посадку (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint =>
      'Если включено, фаза посадки перед боем с боссом пропускается.';

  @override
  String get parameters => 'Параметры';

  @override
  String get reservedColumnCount => 'Зарезервировано колонок';

  @override
  String get reservedColumnCountHint =>
      'Колонки справа, где нельзя сажать растения.';

  @override
  String get reservedColumnPreview => 'Предпросмотр зарезервированных колонок';

  @override
  String get protectedList => 'Список защищаемых';

  @override
  String get plantLevelsFollowGlobal =>
      'Уровни растений следуют глобальным настройкам. Уровни банка семян переопределяются.';

  @override
  String get protectPlantsOverview =>
      'Растения в списке должны выжить; потеря — провал уровня.';

  @override
  String get protectPlantsAutoCount =>
      'Требуемое количество соответствует числу растений в списке.';

  @override
  String get protectItemsOverview =>
      'Предметы в списке должны выжить; потеря — провал уровня.';

  @override
  String get protectItemsAutoCount =>
      'Требуемое количество соответствует числу предметов в списке.';

  @override
  String positionsCount(int count) {
    return 'Позиций: $count';
  }

  @override
  String totalItemsCount(int count) {
    return 'Предметов: $count';
  }

  @override
  String get itemCountExceedsPositionsWarning =>
      'Внимание: предметов больше, чем позиций. Часть не заспавнится.';

  @override
  String get gravestoneBlockedInfo =>
      'Надгробия и подобные объекты, заблокированные растениями, не появятся. Используйте другие методы.';

  @override
  String get enterConditionValue => 'Введите значение условия';

  @override
  String get customInputHint => 'Пользовательский ввод должен быть точным';

  @override
  String get presetConditions => 'Предустановленные условия';

  @override
  String get selectFromPresetHint => 'Выберите из списка условий';

  @override
  String get spawnTimer => 'Таймер спавна';

  @override
  String get potionTypes => 'Типы зелий';

  @override
  String get noPotionTypes =>
      'Типы зелий не настроены. Добавьте тип зелья, чтобы продолжить.';

  @override
  String get conveyorCardPool => 'Пул карт конвейера';

  @override
  String get toolCardsUseFixedLevel =>
      'Инструментальные карты используют фиксированный уровень';

  @override
  String get maxLimits => 'Верхние пределы';

  @override
  String get maxCountThreshold => 'Порог макс. количества';

  @override
  String get weightFactor => 'Весовой коэффициент';

  @override
  String get minLimits => 'Нижние пределы';

  @override
  String get minCountThreshold => 'Порог мин. количества';

  @override
  String get followAccountLevel =>
      'Растения 0 уровня используют соответствующий ранг из аккаунта игрока.';

  @override
  String get enablePointSpawning => 'Включить очки спавна';

  @override
  String get pointSpawningEnabledDesc =>
      'Включено (использует доп. очки для спавна)';

  @override
  String get pointSpawningDisabledDesc => 'Выключено (только события волн)';

  @override
  String get pointSettings => 'Настройки очков';

  @override
  String get startingWave => 'Начальная волна';

  @override
  String get startingPoints => 'Начальные очки';

  @override
  String get pointIncrement => 'Прирост очков';

  @override
  String get zombiePool => 'Пул зомби';

  @override
  String plantLevelsCount(int count) {
    return 'Уровни растений: $count';
  }

  @override
  String lvN(int n) {
    return 'Ур. $n';
  }

  @override
  String get pennyClassroom => 'Класс Пенни';

  @override
  String get protectGridItems => 'Защищать объекты сетки';

  @override
  String get waveManagerHelpOverview =>
      'Включает менеджер волн. Без этого модуля редактирование волн отключено.';

  @override
  String get waveManagerHelpPoints =>
      'Спавн по очкам использует этот пул. Избегайте элитных и кастомных зомби.';

  @override
  String get pointsSection => 'Очки';

  @override
  String get globalPlantLevels => 'Глобальные уровни растений';

  @override
  String get globalPlantLevelsOverview =>
      'Определяет глобальные уровни для указанных растений.';

  @override
  String get globalPlantLevelsScope =>
      'Применяется к защите растений, семенному дождю и другим модулям.';

  @override
  String mustProtectCountFormat(int count) {
    return 'Нужно защитить: $count';
  }

  @override
  String get noWaveManagerPropsFound =>
      'Объект WaveManagerProperties не найден.';

  @override
  String get itemsSortedByRow => 'Предметы (по рядам)';

  @override
  String get eventStormSpawn => 'Событие: штормовой спавн';

  @override
  String get stormEvent => 'Штормовое событие';

  @override
  String get makeCustom => 'Сделать кастомным';

  @override
  String get zombieLevelsBody =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get batchLevel => 'Пакетный уровень';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get backgroundMusicLevelJam => 'Фоновая музыка (LevelJam)';

  @override
  String get onlyAppliesRockEra => 'Только для карт эры рока.';

  @override
  String get appliesToAllNonElite =>
      'Применяется ко всем неэлитным зомби в этой волне.';

  @override
  String get dropConfigPlants => 'Настройка дропа (растения)';

  @override
  String get dropConfigPlantFood => 'Настройка дропа (подкормка)';

  @override
  String get waveDropConfigTitle => 'Настройка дропа';

  @override
  String get waveDropTotalLabel => 'Всего зомби с дропом (AdditionalPlantfood)';

  @override
  String get waveDropAddZombiesFirst =>
      'Добавьте зомби в эту волну перед настройкой дропа.';

  @override
  String get waveDropIncreaseTotalBeforePlants =>
      'Увеличьте общее число дропов перед добавлением растений.';

  @override
  String waveDropPlantFoodOnlyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подкормок',
      many: '$count подкормок',
      few: '$count подкормки',
      one: '1 подкормка',
    );
    return '$_temp0';
  }

  @override
  String waveDropPlantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count растений',
      many: '$count растений',
      few: '$count растения',
      one: '1 растение',
    );
    return '$_temp0';
  }

  @override
  String get zombiesCarryingPlants => 'Зомби с растениями';

  @override
  String get zombiesCarryingPlantFood => 'Зомби с подкормкой';

  @override
  String get description => 'Описание';

  @override
  String get descriptiveName => 'Описательное имя';

  @override
  String get count => 'Количество';

  @override
  String get targetDistance => 'Целевая дистанция';

  @override
  String get targetSun => 'Целевое солнце';

  @override
  String get maximumSun => 'Максимум солнца';

  @override
  String get holdoutSeconds => 'Секунды удержания';

  @override
  String get zombiesToKill => 'Зомби для убийства';

  @override
  String get timeSeconds => 'Время (секунды)';

  @override
  String get speedModifier => 'Модификатор скорости';

  @override
  String get sunModifier => 'Модификатор солнца';

  @override
  String get maximumPlantsLost => 'Макс. потерянных растений';

  @override
  String get maximumPlants => 'Максимум растений';

  @override
  String get targetScore => 'Целевой счёт';

  @override
  String get plantBombRadius => 'Радиус бомбы растения';

  @override
  String get plantType => 'Тип растения';

  @override
  String get gridX => 'Сетка X';

  @override
  String get gridY => 'Сетка Y';

  @override
  String get noCardsYetAddPlants =>
      'Карт пока нет. Добавьте растения или инструменты.';

  @override
  String get mustProtectCountAll => 'Обязательно защитить (0 = все)';

  @override
  String get gridItemType => 'Тип объекта сетки';

  @override
  String get zombieBombRadius => 'Радиус бомбы зомби';

  @override
  String get plantDamage => 'Урон растения';

  @override
  String get zombieDamage => 'Урон зомби';

  @override
  String get initialPotionCount => 'Начальное кол-во зелий';

  @override
  String get operationTimePerGrid => 'Время на ячейку';

  @override
  String get levelLabel => 'Уровень: ';

  @override
  String get mistParameters => 'Параметры тумана';

  @override
  String get sunDropParameters => 'Параметры падения солнца';

  @override
  String get initialDropDelay => 'Начальная задержка падения';

  @override
  String get baseCountdown => 'Базовый обратный отсчёт';

  @override
  String get maxCountdown => 'Макс. обратный отсчёт';

  @override
  String get countdownRange => 'Диапазон отсчёта';

  @override
  String get increasePerSun => 'Увеличение за солнце';

  @override
  String get inflationParams => 'Параметры инфляции';

  @override
  String get baseCostIncreaseLabel =>
      'Увеличение базовой стоимости (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel =>
      'Макс. кол-во увеличений (MaxIncreasedCount)';

  @override
  String get inflationMaxIncreaseCountWarning =>
      'Из-за проблемы самого модуля изменение максимального количества увеличений пока не действует. Игра считывает только значение по умолчанию — 10.';

  @override
  String get inflationHelpTitle => 'Инфляция';

  @override
  String get inflationHelpOverview =>
      'После каждой посадки растения его стоимость в солнцах увеличивается — подобно механике улучшающих растений в бесконечном режиме первой Plants vs. Zombies.';

  @override
  String get inflationHelpParametersTitle => 'Описание параметров';

  @override
  String get inflationHelpParametersBody =>
      'Можно настроить прибавку стоимости в солнцах после каждой посадки и максимальное количество повышений цены.';

  @override
  String get selectGroup => 'Выбрать группу';

  @override
  String get gridTapAddRemove =>
      'Сетка (нажмите — добавить/изменить, долгое нажатие — удалить)';

  @override
  String get sunBombHelpOverview => 'Обзор';

  @override
  String get sunBombHelpBody =>
      'Превращает падающее солнце в взрывные бомбы. Настройте радиус и урон.';

  @override
  String get bombProperties => 'Свойства бомб';

  @override
  String get bombPropertiesHelpBody =>
      'Настройка длины фитиля бочки и вишни для каждого ряда. Используется в Kongfu/мини-играх. Размер массива соответствует рядам газона (5 или 6).';

  @override
  String get bombPropertiesHelpFuse => 'Длина фитиля';

  @override
  String get bombPropertiesHelpFuseBody =>
      'FuseLengths: одно значение на ряд. Длина в игровых единицах. Стандартный газон: 5 рядов. Глубокое море: 6 рядов. Массив автоматически подстраивается при открытии экрана.';

  @override
  String get bombPropertiesFlameSpeed => 'Скорость огня';

  @override
  String get bombPropertiesFuseLengths => 'Длина фитиля';

  @override
  String get bombPropertiesFuseLengthsHint =>
      'Одно значение на ряд (0–4 стандарт, 0–5 глубокое море). Размер массива подстраивается при открытии.';

  @override
  String get bombPropertiesFuseLength => 'Длина';

  @override
  String get damage => 'Урон';

  @override
  String get explosionRadius => 'Радиус взрыва';

  @override
  String get plantRadius => 'Радиус растения';

  @override
  String get zombieRadius => 'Радиус зомби';

  @override
  String get radiusPixelsHint => 'Радиус в пикселях. Одна клетка ≈ 60 px.';

  @override
  String get enterMaxSunHint => 'Введите макс. солнце (напр., 9900)';

  @override
  String get optionalLabelHint => 'Необязательная подпись';

  @override
  String get imageResourceIdHint => 'ID ресурса IMAGE_...';

  @override
  String get enterStartingPlantfoodHint =>
      'Введите начальное растениепитание (0+)';

  @override
  String get threshold => 'Порог';

  @override
  String get delay => 'Задержка';

  @override
  String get seedBankLetsPlayersChoose =>
      'Банк семян позволяет игрокам выбирать растения. В режиме двора можно задать глобальный уровень и все растения.';

  @override
  String get iZombieModePresetHint =>
      'Режим «Я, зомби»: предустановленные зомби для игрока. Выбор заблокирован предустановкой.';

  @override
  String get invalidIdsHint =>
      'Неверные ID оставляют пустые слоты. ID зомби в режиме растений и наоборот. Сначала разместите слоты зомби.';

  @override
  String get seedBankWhiteAndBlacklistTitle => 'Белый и чёрный списки';

  @override
  String get seedBankIZombieHelpTitle => 'Режим «Я, зомби»';

  @override
  String get seedBankSlotOccupancyTitle => 'Заполнение слотов';

  @override
  String get seedBankAdvancedGameplayTitle => 'Продвинутая игра';

  @override
  String get seedBankAdvancedGameplayBody =>
      'В режиме предустановленного выбора Банк семян перед Конвейером заставляет растения с конвейера расходовать солнце, а Банк семян после Конвейера позволяет высаживать предустановленные растения бесплатно.';

  @override
  String get seedBankIZombie => 'Банк семян (Я, зомби)';

  @override
  String get basicRules => 'Основные правила';

  @override
  String get selectionMethod => 'Метод выбора';

  @override
  String get emptyList => 'Пустой список';

  @override
  String get plantsAvailableAtStart => 'Растения в начале';

  @override
  String get presetPlantListReorderHint =>
      'Удерживайте ручку ⋮⋮ и перетаскивайте для изменения порядка';

  @override
  String get presetPlantListReorderHintDesktop =>
      'Перетащите ручку ⋮⋮ для изменения порядка';

  @override
  String get whiteListDescription =>
      'Только эти растения (пусто = без ограничений)';

  @override
  String get blackListDescription => 'Эти растения запрещены';

  @override
  String get availableZombiesDescription => 'Зомби для режима «Я, зомби»';

  @override
  String get izombieCardSlotsHint =>
      'Только некоторые зомби имеют слоты карт IZ. Проверьте категорию «Другое» в выборе зомби.';

  @override
  String get seedBankPresetModeHint =>
      'Режим предустановки запускает игру сразу, независимо от числа карт.';

  @override
  String get seedBankPlantLevelLabel => 'Уровень растений (0–5)';

  @override
  String get seedBankSlotCountLabel => 'Число слотов (0–9)';

  @override
  String get seedBankCourtyardSlotsHint =>
      'В режиме двора число слотов не учитывается. При выборе фиксируется 8 слотов.';

  @override
  String get seedBankAddGridItemsTitle => 'Добавить предметы сетки';

  @override
  String get seedBankAddGridItemsSubtitle =>
      'Добавляет предметы сетки в PresetPlantList. Дубликаты разрешены.';

  @override
  String seedBankGridItemCount(int count) {
    return 'В списке пресетов уже есть: $count';
  }

  @override
  String get seedBankGridItemsPresetOnlySwitchWarning =>
      'Функция добавления объектов работает только в режиме предустановки. При переходе в режим выбора она будет отключена. Продолжить переключение?';

  @override
  String get starChallengeSelectConditions => 'Выбор состояний';

  @override
  String get starChallengeEditConditions => 'Изменить состояния';

  @override
  String get selectToolCard => 'Выбрать карту инструмента';

  @override
  String get searchGridItems => 'Поиск объектов сетки';

  @override
  String get searchStatues => 'Поиск статуй';

  @override
  String get noItems => 'Нет объектов';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String selectedCountTapToSearch(int count) {
    return 'Выбрано: $count, нажмите для поиска';
  }

  @override
  String get noFavoritesLongPress =>
      'Нет избранных. Долгое нажатие — добавить.';

  @override
  String get gridItemCategoryAll => 'Все';

  @override
  String get gridItemCategoryScene => 'Сцена';

  @override
  String get gridItemCategoryTrap => 'Ловушка';

  @override
  String get gridItemCategorySpawnableObjects => 'Появляющиеся препятствия';

  @override
  String get sunDropperConfigTitle => 'Настройка падения солнца';

  @override
  String get customLocalParams => 'Пользовательские локальные параметры';

  @override
  String get currentModeLocal => 'Текущий: локальный (@CurrentLevel)';

  @override
  String get currentModeSystem => 'Текущий: системный (@LevelModules)';

  @override
  String get paramAdjust => 'Настройка параметров';

  @override
  String get firstDropDelay => 'Задержка первого падения';

  @override
  String get initialDropInterval => 'Начальный интервал падения';

  @override
  String get maxDropInterval => 'Макс. интервал падения';

  @override
  String get intervalFloatRange => 'Диапазон интервала';

  @override
  String get sunDropperHelpTitle => 'Модуль падающего солнца';

  @override
  String get sunDropperHelpIntro =>
      'Модуль настраивает параметры падения солнца. Для ночных уровней можно не добавлять.';

  @override
  String get sunDropperHelpParams => 'Параметры';

  @override
  String get sunDropperHelpParamsBody =>
      'По умолчанию используются игровые значения. Можно включить пользовательский режим для редактирования.';

  @override
  String get noZombossMechFound => 'ZombossMech не найден';

  @override
  String get noZombossBattleFound => 'Данные Зомбосса не найдены';

  @override
  String get searchChallengeNameOrCode =>
      'Поиск по названию или коду испытания';

  @override
  String get deleteChallengeTitle => 'Удалить испытание?';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return 'Удалить «$name»? Локальные данные испытания будут удалены безвозвратно.';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return 'Удалить ссылку на «$name»? Испытание останется в LevelModules.';
  }

  @override
  String get missingModulesRecommended =>
      'Уровень может работать некорректно. Рекомендуется добавить:';

  @override
  String get recommendedTunnelDefendTitle =>
      'Рекомендуется модуль тоннелей Подземного Дворца';

  @override
  String get recommendedTunnelDefendBody =>
      'Арены Подземного дворца рассчитаны на визуал тоннелей. Настоятельно рекомендуется добавить модуль тоннелей Подземного Дворца — иначе газон в игре может выглядеть пустым.';

  @override
  String get recommendedExpeditionTilesTitle =>
      'Works with the \"Expedition Tiles\" module';

  @override
  String get recommendedExpeditionTilesBody =>
      'Add the \"Expedition Tiles\" module to work around the lawn\'s missing tiles and create an experience that more closely matches Expedition Gate.';

  @override
  String get selectedPosition => 'Выбранная позиция';

  @override
  String get addItem => 'Добавить препятствие';

  @override
  String get itemListRowFirst => 'Список препятствий (по строкам)';

  @override
  String get railcartCowboy => 'Вагонетка Дикого Запада';

  @override
  String get railcartFuture => 'Вагонетка Далёкого Будущего';

  @override
  String get railcartEgypt => 'Вагонетка Древнего Египта';

  @override
  String get railcartPirate => 'Вагонетка Пиратских Морей';

  @override
  String get railcartWorldcup => 'Чемпионат Дейва';

  @override
  String get clearUnusedTitle => 'Удалить неиспользуемые объекты?';

  @override
  String get clearUnusedMessage =>
      'Будут безвозвратно удалены все неиспользуемые объекты из файла уровня, включая пользовательских зомби, их свойства и другие неиспользуемые данные. Действие нельзя отменить. Продолжить?';

  @override
  String get clearUnusedNone => 'Неиспользуемые объекты не найдены.';

  @override
  String clearUnusedDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count неиспользуемых объектов.',
      many: 'Удалено $count неиспользуемых объектов.',
      few: 'Удалено $count неиспользуемых объекта.',
      one: 'Удалён $count неиспользуемый объект.',
    );
    return '$_temp0';
  }

  @override
  String get lawnMowerTitle => 'Стиль газонокосилок';

  @override
  String get lawnMowerNotes => 'Заметки';

  @override
  String get lawnMowerHelpOverview =>
      'Управляет внешним видом газонокосилок. В режиме двора газонокосилки неэффективны.';

  @override
  String get lawnMowerHelpNotes =>
      'Модуль газонокосилок обычно ссылается на LevelModules напрямую.';

  @override
  String get lawnMowerSelectType => 'Выбрать тип газонокосилки';

  @override
  String get zombieRushTitle => 'Таймер уровня';

  @override
  String get zombieRushHelpOverview =>
      'Таймер обратного отсчёта для Zombie Rush. Уровень заканчивается по истечении времени.';

  @override
  String get zombieRushHelpNotes => 'Заметки';

  @override
  String get zombieRushHelpIncompat =>
      'Модуль таймера несовместим с режимом двора и может вызвать сбой. Используйте таймер Zombie Rush.';

  @override
  String get zombieRushTimeSettings => 'Настройки времени';

  @override
  String get levelCountdown => 'Обратный отсчёт уровня';

  @override
  String get tunnelDefendTitle => 'Тоннели Подземного Дворца';

  @override
  String get tunnelDefendHelpOverview =>
      'Добавление путей тоннелей Подземного Дворца. Некоторые зомби и растения взаимодействуют с тоннелями.';

  @override
  String get tunnelDefendHelpUsage => 'Использование';

  @override
  String get tunnelDefendHelpUsageBody =>
      'Выберите элемент тоннеля ниже, затем нажмите на сетку для размещения. Нажмите тот же элемент снова, чтобы удалить. Нажмите другой элемент для замены.';

  @override
  String get tunnelDefendSelectComponent => 'Выбрать компонент';

  @override
  String get tunnelDefendPlacedCount => 'Размещено';

  @override
  String get tunnelDefendClearAll => 'Очистить всё';

  @override
  String get tunnelDefendClearConfirmTitle =>
      'Очистить все компоненты тоннелей?';

  @override
  String get tunnelDefendClearConfirmMessage =>
      'Удалить все размещённые компоненты тоннелей из сетки. Действие нельзя отменить.';

  @override
  String get tunnelDefendPathOutsideLawn => 'Элементы путей вне газона: ';

  @override
  String get tunnelDefendDeleteOutside => 'Удалить элементы путей вне газона';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle =>
      'Удалить элементы путей вне газона?';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      'Удалить элементы путей за пределами сетки газона 5×9. Действие нельзя отменить.';

  @override
  String get tunnelDefendTileStylePreset => 'Пресет стиля плитки';

  @override
  String get tunnelDefendTileStylePart1 => 'часть 1';

  @override
  String get tunnelDefendTileStylePart2 => 'часть 2';

  @override
  String get tunnelDefendSequenceInterval =>
      'Интервал последовательности тоннелей (TunnelSequenceInterval, сек.)';

  @override
  String get tunnelDefendHelpSequenceInterval => 'Интервал последовательности';

  @override
  String get tunnelDefendHelpSequenceIntervalBody =>
      'Задержка между шагами последовательности тоннелей. Меньшие значения ускоряют появление путей.';

  @override
  String get tunnelDefendHelpSodPromptBody =>
      'The \"Sod Planting Prompt\" controls whether a Sod requirement prompt appears when planting on restricted tiles. Underground Palace Pathways enables this prompt by default.';

  @override
  String get sodPlantingPromptTitle => 'Sod Planting Prompt';

  @override
  String get expeditionTilesSodPromptBody =>
      'Whether to show a Sod requirement prompt when planting.';

  @override
  String get tunnelDefendSodPromptBody =>
      'Whether to show a Sod requirement prompt when planting. Enabled by default.';

  @override
  String get expeditionTilesPresetLayout => 'Preset Layout';

  @override
  String get expeditionTilesPresetFloor1 => 'Expedition Gate – Floor 1';

  @override
  String get expeditionTilesPresetFloor2 => 'Expedition Gate – Floor 2';

  @override
  String get expeditionTilesPresetFloor3 => 'Expedition Gate – Floor 3';

  @override
  String get customLayout => 'Custom layout';

  @override
  String get switchAction => 'Switch';

  @override
  String get expeditionTilesSwitchPresetTitle => 'Switch preset layout';

  @override
  String get expeditionTilesSwitchPresetMessage =>
      'Switch to the preset layout? This will remove all placed non-plantable tiles from the lawn and cannot be undone.';

  @override
  String expeditionTilesSwitchPresetBetweenMessage(String from, String to) {
    return 'Switch from \"$from\" to \"$to\"? This will replace the current non-plantable tile layout and cannot be undone.';
  }

  @override
  String get expeditionTilesUnderwaterMismatchWarning =>
      'The current lawn uses an Underwater World appearance, which is incompatible with the Expedition Tiles module and will cause the level to crash.';

  @override
  String get expeditionTilesBlockedCount => 'Non-plantable tiles';

  @override
  String get expeditionTilesClearConfirmTitle =>
      'Clear all non-plantable tiles?';

  @override
  String get expeditionTilesClearConfirmMessage =>
      'This will remove all placed non-plantable tiles from the lawn. This action cannot be undone.';

  @override
  String get expeditionTilesHelpTitle => 'Expedition Tiles Module';

  @override
  String get expeditionTilesHelpOverview =>
      'The Expedition Tiles module configures non-plantable areas on Expedition Gate lawns. It uses the same tile data structure as Underground Palace Pathways and displays restricted areas with Expedition-specific tile art. Planting Sod on a non-plantable tile can restore that tile\'s planting function.';

  @override
  String get expeditionTilesHelpEditing => 'Tile Editing';

  @override
  String get expeditionTilesHelpEditingBody =>
      'Tap any tile on the lawn to add or remove a non-plantable tile. Non-plantable tiles cover the original floor and cannot be planted on in-game. Whirlpool tiles and blank tiles are both plantable areas; the whirlpool tiles here only recreate the initial lawn layout used by this module.';

  @override
  String get expeditionTilesHelpPresets => 'Preset Layouts';

  @override
  String get expeditionTilesHelpPresetsBody =>
      'The editor includes the three official Expedition Gate layouts for Floor 1, Floor 2, and Floor 3. Switching presets replaces all placed non-plantable tiles and cannot be undone; after applying a preset, you can still adjust tiles manually.';

  @override
  String get expeditionTilesHelpSodPrompt => 'Planting Prompt';

  @override
  String get expeditionTilesHelpSodPromptBody =>
      'The \"Sod Planting Prompt\" controls whether a Sod requirement prompt appears when planting on restricted tiles. Expedition Tiles disables this prompt by default.';

  @override
  String get expeditionTilesHelpNotesBody =>
      'Expedition Tiles is intended for five-row lawns such as Expedition Gate. Do not use it with six-row Underwater World appearances such as 20,000 Leagues Under the Sea or Atlantis, or the level will crash.';

  @override
  String get tunnelExpeditionCompatibilityWarningTitle =>
      'Предупреждение о совместимости модулей';

  @override
  String get tunnelExpeditionCompatibilityWarningBody =>
      'Using the \"Underground Palace Pathways\" module together with the \"Expedition Tiles\" module can cause tile textures to overlap and may affect the level\'s overall appearance. If you must use both, be extremely careful.';

  @override
  String get lifeSupportLastStandConflictWarning =>
      'Модули «Система жизнеобеспечения» и «Последний рубеж» нельзя использовать одновременно, иначе уровень не сможет нормально запуститься.';

  @override
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Лимит времени финальной фазы';

  @override
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Включает таймер отчаяния на финальной фазе Zomboss. Только добавление/удаление — значение таймера берётся из листа свойств Zomboss (напр. ZombossFinalStageTimeLimited у Цинь Шihuang), а не из параметров модуля.';

  @override
  String get finalStageTimeLimitedChallengeTitle =>
      'Лимит времени финальной фазы';

  @override
  String get finalStageTimeLimitedChallengeHelpTitle =>
      'Модуль лимита времени финальной фазы';

  @override
  String get finalStageTimeLimitedChallengeHelpIntro =>
      'Добавляет ограничение по времени на финальной фазе боя с Zomboss (часто используется в боях с Цинь Шihuang). Фактический таймер читается из листа свойств Zomboss (ZombossFinalStageTimeLimited), а не из поля ZombossTimeLimit этого модуля.';

  @override
  String get finalStageTimeLimitedChallengeHelpParams => 'Параметры';

  @override
  String get finalStageTimeLimitedChallengeHelpParamsBody =>
      'Этот экран редактора сейчас отключён. Уровни должны ссылаться только на RTID(FinalStageTimeLimitedChallenge@LevelModules). Пользовательские переопределения @CurrentLevel не поддерживаются, пока игра их не читает.';

  @override
  String get finalStageTimeLimitedChallengeTimeLimit =>
      'Лимит времени Zomboss (ZombossTimeLimit, сек.)';

  @override
  String get moduleTitle_LawnMowerProperties => 'Газонокосилки';

  @override
  String get moduleDesc_LawnMowerProperties => 'Стиль газонокосилок для уровня';

  @override
  String get moduleTitle_TunnelDefendModuleProperties =>
      'Тоннели Подземного Дворца';

  @override
  String get moduleDesc_TunnelDefendModuleProperties =>
      'Размещение тоннелей Подземного Дворца';

  @override
  String get moduleTitle_SouDaCheTunnelDefendDefault => 'Expedition Tiles';

  @override
  String get moduleDesc_SouDaCheTunnelDefendDefault =>
      'Configure non-plantable areas on Expedition Gate lawns.';

  @override
  String get moduleTitle_WitchModuleProperties => 'Тыквенная ведьма';

  @override
  String get moduleDesc_WitchModuleProperties =>
      'Анимация появления тыквенной ведьмы и интервал';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties =>
      'Тоннели Гулливера';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      'Предустановленные тоннели Гулливера на газоне';

  @override
  String get witchModuleTitle => 'Тыквенная ведьма';

  @override
  String get witchModuleHelpTitle => 'Модуль тыквенной ведьмы';

  @override
  String get witchModuleHelpIntro =>
      'Добавляет анимацию и субтитры появления тыквенной ведьмы. По умолчанию используется WitchModule из LevelModules.';

  @override
  String get witchModuleHelpParams => 'Параметры';

  @override
  String get witchModuleHelpParamsBody =>
      'Включите локальные параметры, чтобы изменить WitchSpawnInterval. Иначе используются значения LevelModules.';

  @override
  String get witchModuleSpawnInterval =>
      'Интервал появления ведьмы (WitchSpawnInterval, сек.)';

  @override
  String get gulliverTunnelTitle => 'Тоннели Гулливера';

  @override
  String get gulliverTunnelHelpOverview =>
      'Размещение тоннелей Гулливера на газоне до начала уровня.';

  @override
  String get gulliverTunnelHelpUsage => 'Использование';

  @override
  String get gulliverTunnelHelpUsageBody =>
      'Выберите ориентацию и нажмите на сетку для размещения. Повторное нажатие удаляет тоннель; другая ориентация заменяет существующую.';

  @override
  String get gulliverTunnelOrientationBigOnLeft => 'Большой проход слева';

  @override
  String get gulliverTunnelOrientationBigOnRight => 'Большой проход справа';

  @override
  String get gulliverTunnelPlacedCount => 'Размещено';

  @override
  String get gulliverTunnelClearAll => 'Очистить всё';

  @override
  String get gulliverTunnelClearConfirmTitle =>
      'Очистить все тоннели Гулливера?';

  @override
  String get gulliverTunnelClearConfirmMessage =>
      'Удалить все размещённые тоннели Гулливера с сетки.';

  @override
  String get gulliverTunnelSelectOrientation => 'Выберите ориентацию';

  @override
  String get gulliverTunnelOutsideLawn => 'Вне газона';

  @override
  String get gulliverTunnelDeleteOutside => 'Удалить вне газона';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle =>
      'Удалить тоннели вне газона?';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      'Удалить размещения тоннелей за пределами сетки 5×9.';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => 'Модификаторы уровня';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      'Задаёт пользовательские модификаторы уровня (Погоня Пенни / Дорога Воспоминаний)';

  @override
  String get riftThemeModuleTitle => 'Модификаторы уровня';

  @override
  String get riftThemeHelpTitle => 'Модуль модификаторов уровня';

  @override
  String get riftThemeHelpOverview =>
      'Задаёт пользовательский список модификаторов для уровня — как в уровнях Погони Пенни и Дороги Воспоминаний. Подробности тем см. в справочнике.';

  @override
  String get riftThemeHelpUsage => 'Использование';

  @override
  String get riftThemeHelpUsageBody =>
      'Нажмите кнопку, чтобы открыть выбор тем. Нажимайте темы, чтобы включить или снять выбор, затем подтвердите галочкой. Темы применяются в порядке списка.';

  @override
  String get riftThemeHelpUnique => 'Уникальные темы';

  @override
  String get riftThemeHelpUniqueBody =>
      'Каждая тема может встречаться в списке только один раз.';

  @override
  String get riftThemeEmpty =>
      'Темы не выбраны. Нажмите кнопку ниже, чтобы выбрать темы.';

  @override
  String get riftThemeAddTheme => 'Добавить тему';

  @override
  String get riftThemeSelectThemes => 'Выбрать темы';

  @override
  String get riftThemeSelectTheme => 'Тема';

  @override
  String get riftThemeSearchPlaceholder => 'Поиск по названию или id';

  @override
  String get riftThemeAlreadyAdded => 'Уже добавлена';

  @override
  String get riftThemeNoSearchResults => 'Темы не найдены';

  @override
  String get riftThemeAllUsedTitle => 'Все темы добавлены';

  @override
  String get riftThemeAllUsedMessage =>
      'Все модификаторы уже в списке. Каждую тему можно добавить только один раз.';

  @override
  String get moduleTitle_ZombieRushModuleProperties =>
      'Таймер (из плана уничтожения зомби / нанесения урона снеговикам за время)';

  @override
  String get moduleDesc_ZombieRushModuleProperties => 'Обратный отсчёт уровня';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => 'Бой с порталами';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties =>
      'Порталы в стиле PvZ 1: группы, колонки появления и тайминги телепорта';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => 'Угадай, кто я';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties =>
      'Мини-игра: призыв растений или зомби; веса, тир и белые/чёрные списки';

  @override
  String get pvz1CopycatsModuleTitle => 'Угадай, кто я';

  @override
  String get pvz1CopycatsSectionParams => 'Параметры';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel => 'Вес зомби (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      'Относительный вес призыва зомби по сравнению с растениями.';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      'Тир растения (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel =>
      'Тир при призыве растения шляпой.';

  @override
  String get pvz1CopycatsSectionPlantBlackList =>
      'Чёрный список растений (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      'Растения, которые шляпа не может призвать.';

  @override
  String get pvz1CopycatsSectionZombieWhiteList =>
      'Белый список зомби (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList =>
      'Допустимые типы зомби при призыве зомби.';

  @override
  String get pvz1CopycatsHelpTip =>
      'Не забудьте дать игроку шляпу в банке семян.';

  @override
  String get pvz1CopycatsHelpOverview =>
      'Угадай, кто я: шляпа случайно призывает растения (из каталога, кроме чёрного списка) или зомби (из белого списка); задаётся ZombieWeight и SpawnPlantLevel.';

  @override
  String get pvz1CopycatsHelpFieldsTitle => 'Описание полей';

  @override
  String get pvz1CopycatsPlantListEmpty => 'Список пуст';

  @override
  String get pvz1CopycatsZombieListEmpty => 'Список пуст';

  @override
  String get pvz1CopycatsAddPlant => 'Добавить растение в чёрный список';

  @override
  String get pvz1CopycatsAddZombie => 'Добавить зомби в белый список';

  @override
  String get magicHatSpawnPreviewTitle => 'Шляпа — возможные растения';

  @override
  String get magicHatSpawnPreviewEmpty => 'Нет растений для этого списка.';

  @override
  String get pvz1PassageModuleTitle => 'Бой с порталами';

  @override
  String get pvz1PassageSectionParams => 'Параметры порталов';

  @override
  String get pvz1PassageHelpOverview =>
      'Настраивает порталы-проходы на газоне в стиле PvZ 1: число типов групп порталов, число порталов в каждой группе, диапазон колонок появления, минимальный интервал между телепортами одного зомби и период обновления позиций порталов.';

  @override
  String get pvz1PassageHelpFieldsTitle => 'Описание полей';

  @override
  String get pvz1PassageFieldGroupAmount =>
      'Типов групп порталов (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      'Число различных типов групп порталов.';

  @override
  String get pvz1PassageFieldPassageAmount =>
      'Порталов в группе (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      'Сколько порталов в каждой группе.';

  @override
  String get pvz1PassageFieldGridXMin =>
      'Минимальная колонка появления (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return 'Самая левая колонка газона, где могут появляться порталы. На этом газоне индексы колонок от 0 до $maxIndex.';
  }

  @override
  String get pvz1PassageFieldGridXMax =>
      'Максимальная колонка появления (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return 'Самая правая колонка газона, где могут появляться порталы. На этом газоне индексы колонок от 0 до $maxIndex.';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      'Перезарядка телепорта на зомби (transferCooldown)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      'Минимальное время между телепортами одного и того же зомби.';

  @override
  String get pvz1PassageFieldRefreshTime =>
      'Интервал смены позиций порталов (refreshTime)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      'Как часто заново выбираются позиции порталов.';

  @override
  String get pvz1PassagePortalSpawnPreview => 'Предпросмотр колонок появления';

  @override
  String get pvz1PassageHelpPreview => 'Предпросмотр';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return 'Оранжевым выделены колонки в диапазоне GridXMin–GridXMax включительно. На этом газоне допустимы индексы колонок 0–$maxIndex. Строки в этом модуле не ограничивают появление.';
  }

  @override
  String get moduleWaveIndexZeroBasedHint =>
      'Индекс волны: 0 = первая волна, 1 = вторая и т.д.';

  @override
  String get moduleWaveFieldZeroBased =>
      'Волна (0 = волна 1, 1 = волна 2, ...)';

  @override
  String get appearanceLabel => 'Появление';

  @override
  String get airDropShipGroupLabel => 'Группа';

  @override
  String get moduleTitle_RenaiModuleProperties => 'Ренессанс';

  @override
  String get moduleDesc_RenaiModuleProperties =>
      'Включает функционал ролика и плиток Ренессанса, позволяет настраивать статуи';

  @override
  String get renaiModuleTitle => 'Модуль Ренессанса';

  @override
  String get renaiModuleHelpTitle => 'Справка по модулю Ренессанса';

  @override
  String get renaiModuleHelpOverview => 'Обзор';

  @override
  String get renaiModuleHelpOverviewBody =>
      'Включает ролик и плитки. Волна начала ночи (0-базовый индекс) переключает на ночной режим. Дневные и ночные статуи оживают на своей волне.';

  @override
  String get renaiModuleHelpStatues => 'Статуи';

  @override
  String get renaiModuleHelpStatuesBody =>
      'Дневные статуи: днём. Ночные — после начала ночи. Волна начала ночи и волна «оживления» статуи задаются индексом с 0 (0 = первая волна).';

  @override
  String get renaiModuleEnableNight => 'Включить ночь';

  @override
  String get renaiModuleEnableNightSubtitle =>
      'Разрешить волну начала ночи и ночные статуи';

  @override
  String get renaiModuleNightStart => 'Волна начала ночи';

  @override
  String get renaiModuleDayStatues => 'Дневные статуи';

  @override
  String get renaiModuleNightStatues => 'Ночные статуи';

  @override
  String get renaiModuleNightStatuesDisabledHint =>
      'Включите ночь, чтобы добавить ночные статуи';

  @override
  String get renaiModuleAddStatue => 'Добавить статую';

  @override
  String get renaiModuleCarveWave => 'Волна оживления';

  @override
  String get renaiModuleStatuesInCell => 'Статуи в выбранной ячейке';

  @override
  String get renaiModuleExpectationLabel => 'Превью события Ренессанса';

  @override
  String get renaiModuleNightStarts => 'Начало ночи';

  @override
  String get renaiModulePreviewNightStatues => 'Ночные статуи:';

  @override
  String get renaiModulePreviewRevivingStatues => 'Воскрешаемые статуи:';

  @override
  String get renaiModuleStatueCarve => 'Оживление статуи';

  @override
  String get moduleTitle_DropShipProperties => 'Воздушный сброс';

  @override
  String get moduleDesc_DropShipProperties =>
      'Настройка волн сброса импов с воздуха';

  @override
  String get airDropShipModuleTitle => 'Воздушный сброс';

  @override
  String get airDropShipModuleHelpTitle => 'Справка по воздушному сбросу';

  @override
  String get airDropShipModuleHelpOverview => 'Обзор';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      'Настройка волн, когда импы сбрасываются с воздуха. Номер волны — индекс с 0 (0 = первая волна). Каждая запись задаёт волну, доп. количество импов, уровень импов и зону сброса.';

  @override
  String get airDropShipModuleHelpImps => 'Импы';

  @override
  String get airDropShipModuleHelpImpsBody =>
      'Индекс волны с 0. Доп. количество импов — число дополнительных импов поверх минимум одного.';

  @override
  String get airDropShipModuleAppearWaves => 'Волны появления';

  @override
  String get airDropShipModuleAppearances => 'Группы сброса';

  @override
  String get airDropShipModuleExtraImpCount => 'Доп. количество импов';

  @override
  String get airDropShipModuleDropArea => 'Зона сброса';

  @override
  String get airDropShipModuleDropAreaPreview => 'Предпросмотр зоны сброса';

  @override
  String get airDropShipModuleAreaDropPreviewLabel =>
      'Предпросмотр зоны сброса:';

  @override
  String get airDropShipModuleExpectationLabel => 'Сброс импов';

  @override
  String get airDropShipModuleImpLevel => 'Уровень импа';

  @override
  String get airDropShipModuleRowMin => 'Минимальная строка';

  @override
  String get airDropShipModuleRowMax => 'Максимальная строка';

  @override
  String get airDropShipModuleColMin => 'Минимальный столбец';

  @override
  String get airDropShipModuleColMax => 'Максимальный столбец';

  @override
  String get openModuleSettings => 'Открыть настройки модуля';

  @override
  String get moduleTitle_GlacierModuleProperties => 'Ледниковый спавн';

  @override
  String get moduleDesc_GlacierModuleProperties =>
      'Веса зомби для ледяных блоков босса Ледникового периода (6 столбцов слева)';

  @override
  String get glacierModuleTitle => 'Модуль ледника';

  @override
  String get glacierModuleHelpTitle => 'Модуль ледника';

  @override
  String get glacierModuleHelpOverviewBody =>
      'Задаёт, какие зомби появляются из ледяных блоков, когда босс Ледникового периода их разрушает. Размещайте модуль в начале списка Modules уровня. Без него блоки не призывают зомби.';

  @override
  String get glacierModuleHelpColumnsTitle => 'Столбцы и записи';

  @override
  String get glacierModuleHelpColumnsBody =>
      'Модуль содержит шесть групп содержимого — по одной для каждого столбца ледяных глыб слева направо. После выбора «Добавить содержимое» можно добавить зомби или пустой результат, при котором после разрушения глыбы зомби не появляется. У каждого элемента есть отдельный вес; только для зомби можно менять тип и задавать уровень от 0 до 4, а у пустого результата настраивается только вес.';

  @override
  String get glacierModuleHelpRequirementsTitle => 'Требования';

  @override
  String get glacierModuleHelpRequirementsBody =>
      'Работает только вместе с модулем битвы с боссом, если выбран мех Ледникового периода (zombossmech_iceage и его варианты).';

  @override
  String get glacierModuleHelpPresetsTitle => 'Предустановленные конфигурации';

  @override
  String get glacierModuleHelpPresetsBody =>
      'Редактор содержит конфигурации ледяных глыб, использованные вариантами босса Ледникового периода в оригинальной игре. Применение пресета заменяет все шесть групп и не может быть отменено; после этого записи можно изменить вручную. Варианту головоломки с растениями модуль ледяных глыб не нужен, поэтому для него нет пресета. Пользовательский вариант по умолчанию использует пустой пресет.';

  @override
  String get glacierModulePresetSectionTitle => 'Пресеты ледяных глыб';

  @override
  String get glacierModulePresetBlankCustom =>
      'Пользовательский вариант (пустой пресет)';

  @override
  String get glacierModulePresetCustomConfiguration =>
      'Пользовательская конфигурация';

  @override
  String get glacierModuleSwitchPresetTitle => 'Сменить пресет ледяных глыб';

  @override
  String glacierModuleSwitchPresetMessage(String from, String to) {
    return 'Переключиться с «$from» на «$to»? Все шесть текущих групп ледяных глыб будут заменены без возможности отмены.';
  }

  @override
  String get glacierModuleVariationPresetPromptTitle =>
      'Включить соответствующий пресет ледяных глыб';

  @override
  String get glacierModuleVariationPresetPrompt =>
      'Босс Ледникового периода призывает зомби через ледяные глыбы, содержимое которых настраивается отдельным модулем. Вы собираетесь выбрать другой вариант босса Ледникового периода. Включить также пресет модуля ледяных глыб, использованный этим вариантом в оригинальной игре?';

  @override
  String get glacierModuleCustomVariationPresetPrompt =>
      'Пользовательский вариант по умолчанию использует пустой пресет ледяных глыб. Переключить модуль на пустой пресет?';

  @override
  String get zombossMechSwitchVariationOnly => 'Сменить только вариант';

  @override
  String get glacierModuleEnablePreset => 'Также включить пресет';

  @override
  String get iceAgePlantPuzzleVariationWarningTitle =>
      'Головоломке с растениями не нужны ледяные глыбы';

  @override
  String get iceAgePlantPuzzleVariationWarning =>
      'Этот вариант создан специально для мини-игры с растениями в Ледниковом периоде. Его способности не требуют модуля ледяных глыб.';

  @override
  String get glacierModuleCompatibilityWarningTitle =>
      'Требования модуля ледяных глыб';

  @override
  String get glacierModuleCompatibilityWarning =>
      'Модуль работает только с модулем битвы с боссом и мехом Ледникового периода (zombossmech_iceage). Добавьте или исправьте эти настройки, чтобы ледяные блоки призывали зомби.';

  @override
  String get glacierModuleUnderwaterWarningTitle =>
      'Несовместимость с оформлением Подводного мира';

  @override
  String get glacierModuleUnderwaterWarning =>
      'Не рекомендуется использовать босса Ледникового периода и модуль ледяных глыб на лужайке Подводного мира. Это может испортить внешний вид уровня.';

  @override
  String glacierModuleColumn(int columnIndex) {
    return 'Столбец $columnIndex (слева)';
  }

  @override
  String glacierModuleEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '1 запись',
    );
    return '$_temp0';
  }

  @override
  String glacierModuleEntryLabel(int index) {
    return 'Запись $index';
  }

  @override
  String get glacierModuleNoEntries =>
      'Для этого столбца пока не настроено содержимое.';

  @override
  String get glacierModuleAddEntry => 'Добавить содержимое';

  @override
  String get glacierModuleAddContentTitle =>
      'Добавить содержимое ледяной глыбы';

  @override
  String get glacierModuleAddZombieContent => 'Добавить зомби';

  @override
  String get glacierModuleAddZombieDescription =>
      'Выберите зомби, который может появиться после разрушения ледяной глыбы.';

  @override
  String get glacierModuleAddEmptyDescription =>
      'Добавьте отдельно взвешенный результат, при котором ледяная глыба не выпускает зомби.';

  @override
  String get glacierModuleSelectZombie => 'Выбрать зомби';

  @override
  String get glacierModuleEmptyType =>
      'После разрушения глыбы зомби не появляется';

  @override
  String get glacierModuleWeight => 'Вес';

  @override
  String get glacierModuleWeightTooltip =>
      'Относительный вес появления этого зомби в столбце.';

  @override
  String get glacierModuleEmptyWeightTooltip =>
      'Вес результата, при котором ледяная глыба не выпускает зомби.';

  @override
  String get glacierModuleLevel => 'Уровень зомби';

  @override
  String get glacierModuleLevelTooltip => 'Уровень зомби от 0 до 4.';

  @override
  String get moduleTitle_HeianWindModuleProperties => 'Ветер Хэйан';

  @override
  String get moduleDesc_HeianWindModuleProperties =>
      'Настройка ветров, влияющих на зомби в волнах';

  @override
  String get heianWindModuleTitle => 'Ветер Хэйан';

  @override
  String get heianWindModuleHelpTitle => 'Справка по ветру Хэйан';

  @override
  String get heianWindModuleHelpOverview => 'Обзор';

  @override
  String get heianWindModuleHelpOverviewBody =>
      'Настройка ветров на конкретных волнах. Индекс волны с 0 (0 = первая волна). Ветер толкает зомби; на отдельных рядах может вызвать торнадо, которое несёт зомби вперёд и сдувает растения.';

  @override
  String get heianWindModuleHelpDistance => 'Дистанция';

  @override
  String get heianWindModuleHelpDistanceBody =>
      'Дистанция 50 равна одной клетке сетки. Отрицательные значения двигают зомби влево; положительные — вправо.';

  @override
  String get heianWindModuleHelpRow => 'Ряд';

  @override
  String get heianWindModuleHelpRowBody =>
      'Можно указать любой ряд или все ряды сразу. Ветер на отдельных рядах также вызывает торнадо, которое несёт зомби вперёд и сдувает растение.';

  @override
  String get heianWindModuleWaves => 'Волны с ветром';

  @override
  String get heianWindModuleWavesHint => 'starts from 0';

  @override
  String get heianWindModuleAppearances => 'Появления';

  @override
  String get heianWindModuleWindDelay => 'Задержка ветра';

  @override
  String get heianWindModuleWindDelayHint => 'unit: seconds';

  @override
  String get heianWindModuleWindEntries => 'Записи ветра';

  @override
  String get heianWindModuleAddWind => 'Добавить ветер';

  @override
  String get heianWindModuleRow => 'Ряд';

  @override
  String get heianWindModuleAllRows => 'Все ряды';

  @override
  String get heianWindModuleAffectZombies => 'Затронуто зомби';

  @override
  String get heianWindModuleDistance => 'Дистанция';

  @override
  String get heianWindModuleDistanceHint => '1 tile = 50 units';

  @override
  String get heianWindModuleMoveTime => 'Время движения';

  @override
  String get heianWindModuleMoveTimeHint => 'unit: seconds';

  @override
  String get heianWindModuleExpectationLabel => 'Ветер Хэйан';

  @override
  String get jsonViewerModeReading => '(режим чтения)';

  @override
  String get jsonViewerModeObjectReading => '(режим чтения объектов)';

  @override
  String get jsonViewerModeEdit => '(режим редактирования)';

  @override
  String get jsonViewerFontSize => 'Размер шрифта';

  @override
  String get jsonViewerSearchHint => 'Поиск';

  @override
  String get jsonViewerReplaceHint => 'Заменить';

  @override
  String get jsonViewerSearchHistory => 'Недавние запросы';

  @override
  String get jsonViewerReplaceHistory => 'Недавние замены';

  @override
  String get jsonViewerInsertNewline => 'Вставить перевод строки';

  @override
  String get jsonViewerMatchCase => 'Учитывать регистр';

  @override
  String get jsonViewerWholeWords => 'Слова';

  @override
  String get jsonViewerRegex => 'Regex';

  @override
  String get jsonViewerPreviousMatch => 'Предыдущее совпадение';

  @override
  String get jsonViewerNextMatch => 'Следующее совпадение';

  @override
  String get jsonViewerReplaceOne => 'Заменить';

  @override
  String get jsonViewerReplaceAll => 'Заменить все';

  @override
  String jsonViewerMatchCounter(int current, int total) {
    return '$current из $total';
  }

  @override
  String get tooltipAboutModule => 'О модуле';

  @override
  String get tooltipAboutSection => 'Об этом разделе';

  @override
  String get tooltipAboutEvent => 'О событии';

  @override
  String get tooltipSave => 'Сохранить';

  @override
  String get tooltipEdit => 'Редактировать';

  @override
  String get tooltipClose => 'Закрыть';

  @override
  String get tooltipToggleObjectView =>
      'Переключить вид объектов/сырого текста';

  @override
  String get tooltipClearUnused => 'Удалить неиспользуемые объекты';

  @override
  String get tooltipCopyJson => 'Копировать JSON уровня';

  @override
  String get tooltipCopyObject => 'Копировать JSON объекта';

  @override
  String get tooltipMore => 'Ещё';

  @override
  String get jsonViewerCopied => 'JSON скопирован в буфер обмена';

  @override
  String get tooltipJsonViewer => 'Просмотр/редактирование JSON';

  @override
  String get tooltipAdd => 'Добавить';

  @override
  String get tooltipDecrease => 'Уменьшить';

  @override
  String get tooltipIncrease => 'Увеличить';

  @override
  String get bungeeWaveEventTitle => 'Событие сброса с парашютом';

  @override
  String get bungeeWaveEventHelpTitle => 'Событие сброса с парашютом';

  @override
  String get bungeeWaveEventHelpOverview =>
      'Задайте тип зомби и клетку лужайки для одного сброса. Одно событие — один зомби.';

  @override
  String get bungeeWaveEventHelpGrid => 'Сетка';

  @override
  String get bungeeWaveEventHelpGridBody =>
      'Нажмите на клетку в сетке, чтобы задать место приземления зомби с парашютом.';

  @override
  String get bungeeWaveCurrentTarget => 'Текущая цель';

  @override
  String get bungeeWaveCol => 'Столб.';

  @override
  String get bungeeWaveRow => 'Ряд';

  @override
  String get bungeeWavePropertiesConfig => 'Свойства';

  @override
  String get bungeeWaveZombieLevel => 'Уровень зомби (Level)';

  @override
  String get bungeeWaveRoofWarning =>
      'На крыше зонтики могут перехватить сброс и вызвать мгновенное съедание мозга. Используйте осторожно.';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => 'Солнце за зомби';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps =>
      'Солнце за зомби по уровням (Погоня); отключает солнечную лопатку';

  @override
  String get zombieSunDropTitle => 'Настройка солнца за зомби';

  @override
  String get zombieSunDropHelpTitle => 'Солнце за зомби';

  @override
  String get zombieSunDropHelpOverview =>
      'Задайте количество солнца за конкретных зомби по уровням (Погоня). Модуль также отключает солнечную лопатку.';

  @override
  String get zombieSunDropHelpValues => 'Значения';

  @override
  String get zombieSunDropHelpValuesBody =>
      'Шесть целых чисел соответствуют уровням 1–6. При уровне выше 6 используется значение 1-го уровня.';

  @override
  String get zombieSunDropEmpty => 'Нет записей. Нажмите +, чтобы добавить.';

  @override
  String get zombieSunDropDefaultDrop => 'Сброс по умолчанию';

  @override
  String get zombieSunDropSun => 'солнце';

  @override
  String get zombieSunDropEditTitle => 'Редактировать значения';

  @override
  String get zombieSunDropEditHint =>
      'Настройте солнце для уровней 1–6. При уровне выше 6 используется значение 1-го уровня.';

  @override
  String get zombieSunDropTier => 'Уровень';

  @override
  String zombieSunDropTierLabel(int tier) {
    return 'Уровень $tier';
  }

  @override
  String get moduleTitle_PickupCollectableTutorialProperties => 'Урок подбора';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties =>
      'Зомби, роняющий предмет + текст диалога подбора';

  @override
  String get pickupCollectableTutorialTitle => 'Урок подбора';

  @override
  String get pickupCollectableTutorialHelpTitle => 'Урок подбора';

  @override
  String get pickupCollectableTutorialHelpBasic => 'Описание';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      'Настройте зомби, роняющего предмет, и текст до/после подбора. При первом убийстве такого зомби в уровне показывается диалог.';

  @override
  String get pickupCollectableTutorialHelpDialogs => 'Диалоги';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      'Диалоги показываются до и после подбора предмета и могут приостанавливать уровень.';

  @override
  String get pickupCollectableTutorialCoreConfig => 'Основная настройка';

  @override
  String get pickupCollectableTutorialZombieLabel => 'Зомби с предметом';

  @override
  String get pickupCollectableTutorialLootType => 'Тип добычи';

  @override
  String get pickupCollectableTutorialGuideText => 'Текст подсказок';

  @override
  String get pickupCollectableTutorialPickupAdvice =>
      'До подбора (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      'После подбора (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => 'Не задано';

  @override
  String get pickupCollectableLootGoldCoin => 'Золотая монета';

  @override
  String get invalidRtonMagic =>
      'Неверный файл RTON: магия должна быть «RTON».';

  @override
  String get invalidRtonVersion => 'Неверная версия RTON (ожидается 1).';

  @override
  String get invalidRtonEnd =>
      'Неверный файл RTON: должен заканчиваться на «DONE».';

  @override
  String get invalidRtonArrayEnd => 'Неверный разделитель массива RTON.';

  @override
  String get invalidRtid => 'Недопустимое значение RTID.';

  @override
  String get invalidValueType => 'Недопустимый тип значения для RTON.';

  @override
  String get musicSuffix => 'Суффикс музыки';

  @override
  String get ambientAudioSuffix => 'Суффикс фонового звука';

  @override
  String get selectMusicSuffix => 'Выбор суффикса музыки';

  @override
  String get searchMusicSuffix => 'Поиск по названию или коду';

  @override
  String get noMusicSuffixFound => 'Суффикс не найден';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => 'Свой';

  @override
  String get editCustomZombossMech => 'Изменить';

  @override
  String get customZombossMechProperties => 'Свои свойства ZombossMech';

  @override
  String get customZombossMechScalars => 'Общие';

  @override
  String get customZombossMechStages => 'Фазы боя';

  @override
  String get customZombossMechEditHint =>
      'Редактирование свойств memo-варианта меха в файле уровня.';

  @override
  String get zombossMechMinColumn => 'Мин. колонка';

  @override
  String get zombossMechMaxColumn => 'Макс. колонка';

  @override
  String get zombossMechStageActions => 'Действия';

  @override
  String get zombossMechActions => 'Действия';

  @override
  String get zombossMechPropertiesLabel => 'Свойства';

  @override
  String get zombossMechAliasLabel => 'Псевдоним';

  @override
  String get zombossMechDeletePhase => 'Удалить фазу';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return 'Удалить фазу $number?';
  }

  @override
  String get zombossMechDeletePhaseMessage =>
      'Фаза и её список действий будут удалены. Это нельзя отменить.';

  @override
  String get zombossMechDeleteEightiesPhaseMessage =>
      'Фаза, её список действий, а также соответствующие ей музыка и анимация Зомбосса будут удалены. Это действие нельзя отменить.';

  @override
  String get zombossMechStageJamOrder => 'Порядок музыки (StageJamOrder)';

  @override
  String get zombossMechZombossAnimOrder =>
      'Порядок анимаций Зомбосса (ZombossAnimOrder)';

  @override
  String get zombossMechAddEightiesPhaseTitle =>
      'Выберите музыку и анимацию Зомбосса для новой фазы';

  @override
  String get zombossMechEightiesPhaseSelectionRequired =>
      'Перед созданием фазы необходимо выбрать музыку и анимацию Зомбосса.';

  @override
  String get zombossMechCreatePhase => 'Создать фазу';

  @override
  String get zombossAnimNewWave => 'Новая волна';

  @override
  String get zombossAnimHipHop => 'Хип-хоп';

  @override
  String get zombossMechOrphanActionDeleteTitle =>
      'Удалить данные пользовательского действия?';

  @override
  String zombossMechOrphanActionDeleteMessage(String alias) {
    return '«$alias» больше не используется в уровне. Удалить объект действия из файла уровня?';
  }

  @override
  String get zombossMechPhasesHelp =>
      'У каждой фазы есть очки здоровья, упорядоченный список действий (сверху вниз) и при поддержке — действие отступления.';

  @override
  String get zombossMechPhasesHelpTitle => 'Содержимое фаз';

  @override
  String get zombossMechAddAction => 'Добавить действие';

  @override
  String get zombossMechNoStageActions => 'Действий пока нет';

  @override
  String get zombossMechSelectAction => 'Выбрать действие';

  @override
  String get zombossMechSelectRetreatAction => 'Выбрать отступление';

  @override
  String get zombossMechCreateCustomAction => 'Новое своё действие';

  @override
  String get zombossMechEditCustomAction => 'Редактировать своё действие';

  @override
  String get zombossMechActionCategoryAll => 'Все';

  @override
  String get zombossMechActionCategoryMovement => 'Движение';

  @override
  String get zombossMechActionCategoryAttack => 'Атака';

  @override
  String get zombossMechActionCategorySpecial => 'Особые';

  @override
  String get zombossMechActionCategorySpawn => 'Призыв';

  @override
  String get zombossMechActionCategoryCustom => 'Свои';

  @override
  String get zombossMechActionCategoryRetreat => 'Отступление';

  @override
  String get zombossMechNoActionsFound => 'Действия не найдены';

  @override
  String get zombossMechCustomActionLabel => 'Своё (CurrentLevel)';

  @override
  String zombossCustomActionBaseAction(String action) {
    return 'Базовое действие: $action';
  }

  @override
  String zombossPresetDerivedBaseAction(String action) {
    return 'На основе предустановленного пользовательского действия: $action';
  }

  @override
  String get zombossMechActionAliasHint =>
      'Имя в RTID(псевдоним@CurrentLevel). Можно изменить позже; ссылки в этом листе свойств обновятся автоматически.';

  @override
  String get zombossMechActionBaseObjclass => 'Тип действия (objclass)';

  @override
  String get zombossMechActionBaseAction => 'Базовое действие';

  @override
  String get zombossMechBaseActionAliasSyncTitle =>
      'Обновить кодовое имя действия?';

  @override
  String zombossMechBaseActionAliasSyncMessage(String alias) {
    return 'После смены базового действия также изменить кодовое имя действия на «$alias»?';
  }

  @override
  String get zombossMechBaseActionAliasKeep => 'Сохранить текущее имя';

  @override
  String get zombossMechBaseActionAliasUpdate => 'Обновить имя';

  @override
  String get zombossMechActionDetails => 'Сведения о действии';

  @override
  String get zombossMechActionRtid => 'RTID';

  @override
  String get zombossMechActionFields => 'Поля действия';

  @override
  String get zombossMechPropertiesViewTitle => 'Свойства ZombossMech';

  @override
  String get viewZombossMechProperties => 'Просмотреть свойства';

  @override
  String get zombossMechEditRetreatAction => 'Выбрать отступление';

  @override
  String get zombossMechAddZombie => 'Добавить зомби';

  @override
  String get zombossMechPickZombie => 'Выбрать зомби';

  @override
  String get zombossMechNoZombiesInList => 'Список зомби пуст';

  @override
  String get zombossMechSpawnBallSettings =>
      'Настройка выпадения (ZombieDropProps)';

  @override
  String get zombossMechAwardDropInvalidTitle =>
      'Недействительная ссылка SpawnBall';

  @override
  String zombossMechAwardDropInvalidBody(String rtid) {
    return 'AwardDrop ссылается на «$rtid», но это не является корректным объектом ZombieDropProps текущего уровня. Игра может не загрузить это действие.';
  }

  @override
  String get zombossMechAwardDropClearInvalid =>
      'Очистить неверное значение и восстановить значение по умолчанию';

  @override
  String get zombossMechCatalogActionReadOnly =>
      'Встроенные действия здесь не редактируются. Создайте своё действие, чтобы изменить списки зомби.';

  @override
  String get zombossMechRetreatDisabled => 'Отключено';

  @override
  String get zombossMechOpenGlacierModule =>
      'Перейти к настройкам модуля ледяных глыб';

  @override
  String get zombossMechConfigureInitialGridItems =>
      'Настроить начальные объекты сетки';

  @override
  String get zombossMechEightiesSpeakerPresetPromptTitle =>
      'Разместить динамики заранее?';

  @override
  String get zombossMechEightiesSpeakerPresetPrompt =>
      'На первой фазе Зомбот Микстейпа обычно использует специальные динамики на поле для применения своих способностей, поэтому на официальных уровнях их заранее размещают в определённых позициях.\nВы собираетесь переключиться на Зомбота Микстейпа. Разместить эти динамики на тех же позициях, что и на официальных уровнях?';

  @override
  String get zombossMechSwitchBaseOnly => 'Только сменить мех';

  @override
  String get zombossMechPreplaceSpeakers => 'Разместить динамики';

  @override
  String get zombossMechEightiesSpeakerRemovePromptTitle => 'Удалить динамики?';

  @override
  String get zombossMechEightiesSpeakerRemovePrompt =>
      'Вы собираетесь переключиться с Зомбота Микстейпа на другой базовый мех. Удалить специальные динамики, ранее размещённые на тех же позициях, что и на официальных уровнях?\nБудут удалены только те объекты в этих позициях, которые всё ещё являются динамиками Зомбосса; всё, чем вы заменили их позднее, останется без изменений.';

  @override
  String get zombossMechKeepSpeakers => 'Оставить динамики';

  @override
  String get zombossMechRemoveSpeakers => 'Удалить динамики';

  @override
  String get zombossMechRobotSpawnRow => 'Ряд';

  @override
  String get zombossMechRobotSpawnRowRandom => 'Случайный (-1)';

  @override
  String get zombossMechRobotSpawnLevel => 'Уровень';

  @override
  String get zombossMechRobotSpawnWeight => 'Вес';

  @override
  String get zombossMechRobotSpawnPlantfood => 'Удобрение';

  @override
  String get zombossMechRetreatAction => 'Отступление';

  @override
  String zombossMechPhaseNumber(int number) {
    return 'Фаза $number';
  }

  @override
  String get zombossMechAddPhase => 'Добавить фазу';

  @override
  String get zombossMechRemovePhase => 'Удалить фазу';

  @override
  String get zombossMechHitPoints => 'Очки здоровья';

  @override
  String get continueAnyway => 'Всё равно продолжить';

  @override
  String get armrackModuleTitle => 'Оружейные стойки';

  @override
  String get armrackModuleHelpTitle => 'Модуль оружейных стоек';

  @override
  String get armrackModuleHelpOverview => 'Обзор';

  @override
  String get armrackModuleHelpOverviewBody =>
      'Размещает оружейные стойки на газоне. Волна 1 — начальный пресет (до старта уровня); последующие группы появляются в волнах генератора по правилу N−1.';

  @override
  String get armrackModuleHelpPlacement => 'Размещение';

  @override
  String get armrackModuleHelpPlacementBody =>
      'Выберите тип стойки и нажмите на клетку (одна на клетку). ПКМ или долгое нажатие удаляет стойку с клетки.';

  @override
  String get armrackModuleHelpWaveLimit => 'Ограничение по волнам';

  @override
  String get armrackModuleHelpWaveLimitBody =>
      'Из-за ограничения игры в игре действуют только записи волны 1. Другие группы волн можно редактировать здесь и сохранять в файл уровня, но на временной шкале отображается только волна 1.';

  @override
  String get armrackModuleTypePalette => 'Тип стойки';

  @override
  String get armrackModuleExpectationLabel => 'Оружейные стойки';

  @override
  String get armrackModuleIgnoredWaveOverridesWarning =>
      'В уровне есть переопределения оружейных стоек для волн, отличных от 1. Они сохраняются, но не отображаются на временной шкале, так как игра применяет только волну 1.';

  @override
  String armrackModuleRequiredMessage(String moduleName) {
    return 'Чтобы оружейные стойки отображались правильно и без текстур солнца, нужно добавить модуль «$moduleName».';
  }

  @override
  String renaiGridItemModuleRequiredMessage(String moduleName) {
    return 'Для корректной работы колеса Витрувия требуется модуль «$moduleName». Добавить его?';
  }

  @override
  String get energyGridModuleTitle => 'Плитки с подкормкой';

  @override
  String get energyGridModuleHelpTitle => 'Модуль плиток с подкормкой';

  @override
  String get energyGridModuleHelpOverview => 'Обзор';

  @override
  String get energyGridModuleHelpOverviewBody =>
      'Размещает плитки с подкормкой на газоне. Волна 1 — начальный пресет (до старта уровня); последующие группы появляются в волнах генератора по правилу N−1.';

  @override
  String get energyGridModuleHelpPlacement => 'Размещение';

  @override
  String get energyGridModuleHelpPlacementBody =>
      'Нажмите пустую клетку, чтобы поставить плитку (одна на клетку). ПКМ или долгое нажатие удаляет плитку.';

  @override
  String get energyGridModuleHelpWaveLimit => 'Ограничение по волнам';

  @override
  String get energyGridModuleHelpWaveLimitBody =>
      'Из-за ограничения игры в игре действуют только записи волны 1. Другие группы волн можно редактировать здесь и сохранять в файл уровня, но на временной шкале отображается только волна 1.';

  @override
  String get energyGridModuleTapToPlace =>
      'Нажмите пустую клетку, чтобы поставить плитку с подкормкой.';

  @override
  String get energyGridModuleExpectationLabel => 'Плитки с подкормкой';

  @override
  String get energyGridModuleIgnoredWaveOverridesWarning =>
      'В уровне есть переопределения плиток с подкормкой для волн, отличных от 1. Они сохраняются, но не отображаются на временной шкале, так как игра применяет только волну 1.';

  @override
  String get energyGridModuleWarningMessage =>
      'Из-за ошибки игры сгенерированные плитки с подкормкой могут отображаться как фиолетовые маркеры X. На функциональность это не влияет.';

  @override
  String get gridOverrideModuleAppearances => 'Группы волн';

  @override
  String get gridOverrideModuleWaveFieldOneBased =>
      'Волна модуля (1 = начальный пресет, 2+ = появление в волне генератора N−1)';

  @override
  String get gridOverrideModuleTimelineNote =>
      'На временной шкале отображаются только записи волны 1.';

  @override
  String get gridOverrideModuleInitialWaveNote =>
      'Это начальный пресет: объекты появляются на газоне до старта уровня.';

  @override
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave) {
    return 'Эта группа появляется, когда начинается волна генератора $waveGeneratorWave.';
  }

  @override
  String get gridOverrideModuleWaveSpawnTimelineNote =>
      'Эти записи не действуют во вкладке менеджера волн.';

  @override
  String get gridOverrideModuleHelpWaveNumbering => 'Нумерация волн';

  @override
  String get gridOverrideModuleHelpWaveNumberingBody =>
      'Волна 1 — начальный пресет: объекты на газоне до старта уровня. С волны 2 правило N−1: волна модуля N появляется при волне генератора N−1 (волна 2 → волна генератора 1, волна 3 → волна генератора 2 и т. д.).';

  @override
  String get gridOverridePreviewArmrackTitle => 'Размещение оружейных стоек';

  @override
  String get gridOverridePreviewEnergyGridTitle =>
      'Размещение плиток с подкормкой';

  @override
  String get waveGeneratorInitialGridOverridesTitle =>
      'Управление начальными препятствиями мира Кунг-фу';

  @override
  String get waveGeneratorPreviewInitialArmrack => 'Начальные оружейные стойки';

  @override
  String get waveGeneratorPreviewInitialEnergyGrid =>
      'Начальные плитки с подкормкой';

  @override
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label) {
    return 'Волна $wave — $label';
  }

  @override
  String get mechanismPlankSettings => 'Настройки объединённых вагонеток';

  @override
  String get mechanismPlankStartColumn => 'Стартовая колонка (mx)';

  @override
  String get mechanismPlankTrackLength => 'Длина рельсовых дорожек (mWidth)';

  @override
  String get mechanismPlankEditNotice =>
      'Этот интерфейс поддерживает только изменение стартовой колонны и длины рельсовых дорожек. Все остальные параметры используют уже заранее заготовленные значения, так как их изменение может привести к поломке вагонеток. Для более продвинутой кастомизации воспользуйтесь функцией редактирования JSON файла.\nК тому же, не рекомендуется использовать модуль объединённых вагонеток вне лужайки Кунг-Фу мира, так как сами вагонетки могут не прогрузиться и отображаться как фиолетовые кресты. Их работоспособность не постарадает, но на визуальной составляющей уровня это может сказаться сильно.';

  @override
  String get mechanismPlankOutOfAreaWarning =>
      'The current rail range may go outside the lawn.';

  @override
  String get portalTypeEgypt => 'Ancient Egypt';

  @override
  String get portalTypeEgypt2 => 'Ancient Egypt 2';

  @override
  String get portalTypePirate => 'Pirate Seas';

  @override
  String get portalTypeWest => 'Wild West';

  @override
  String get portalTypeFuture => 'Far Future';

  @override
  String get portalTypeFuture2 => 'Far Future 2';

  @override
  String get portalTypeDark => 'Dark Ages';

  @override
  String get portalTypeBeach => 'Big Wave Beach';

  @override
  String get portalTypeIceAge => 'Frostbite Caves';

  @override
  String get portalTypeLostCity => 'Lost City';

  @override
  String get portalTypeEighties => 'Neon Mixtape Tour';

  @override
  String get portalTypeDino => 'Jurassic Marsh';

  @override
  String get portalTypeEndlessEgypt => 'Ancient Egypt (Endless)';

  @override
  String get portalTypeEndlessPirate => 'Pirate Seas (Endless)';

  @override
  String get portalTypeEndlessWest => 'Wild West (Endless)';

  @override
  String get portalTypeEndlessKongfu => 'Kongfu World (Endless)';

  @override
  String get portalTypeEndlessFuture => 'Far Future (Endless)';

  @override
  String get portalTypeEndlessDark => 'Dark Ages (Endless)';

  @override
  String get portalTypeEndlessBeach => 'Big Wave Beach (Endless)';

  @override
  String get portalTypeEndlessIceAge => 'Frostbite Caves (Endless)';

  @override
  String get portalTypeEndlessSkyCity => 'Sky City (Endless)';

  @override
  String get portalTypeEndlessLostCity => 'Lost City (Endless)';

  @override
  String get portalTypeEndlessEighties => 'Neon Mixtape Tour (Endless)';

  @override
  String get portalTypeEndlessDino => 'Jurassic Marsh (Endless)';

  @override
  String get portalTypeEndlessModern => 'Modern Day (Endless)';

  @override
  String get portalTypeMemoryLane1 => 'Memory Lane 1';

  @override
  String get portalTypeMemoryLane2 => 'Memory Lane 2';

  @override
  String get portalTypeMemoryLane3 => 'Memory Lane 3';

  @override
  String get portalTypeShieldGenerator => 'Shield Generator';

  @override
  String get portalTypeGlacialNianSkill => 'Glacial Nian Skill';

  @override
  String get portalTypeZombotany => 'Zombotany';

  @override
  String get portalTypeSlimeZombies => 'Zom-Blob';

  @override
  String get portalTypeUniverse42 => 'Parallel Universe No. 42';

  @override
  String get portalTypeUniverse41 => 'Parallel Universe No. 41';

  @override
  String get portalTypeEliteHealerNormal => 'Elite Healer (Normal)';

  @override
  String get portalTypeEliteElectricNormal => 'Elite Lightning Gun (Normal)';

  @override
  String get portalTypeEliteBallistaNormal => 'Elite Zcorpion (Normal)';

  @override
  String get portalTypeEliteOnmyojiNormal => 'Elite Onmyoji (Normal)';

  @override
  String get portalTypeEliteHealerHard => 'Elite Healer (Hard)';

  @override
  String get portalTypeEliteElectricHard => 'Elite Lightning Gun (Hard)';

  @override
  String get portalTypeEliteBallistaHard => 'Elite Zcorpion (Hard)';

  @override
  String get portalTypeEliteOnmyojiHard => 'Elite Onmyoji (Hard)';

  @override
  String get portalTypeRomeoHard => 'Romeo (Memory Lane)';

  @override
  String get portalTypeRomeoHard2 => 'Romeo 2 (Memory Lane)';

  @override
  String get portalTypeJulietHard => 'Juliet (Memory Lane)';

  @override
  String get portalTypeJulietHard2 => 'Juliet 2 (Memory Lane)';

  @override
  String get portalTypeSherlockHard => 'Sherlock (Memory Lane)';

  @override
  String get portalTypeEliteHunter => 'Elite Hunter';

  @override
  String get portalTypeEliteChief => 'Elite Chief';

  @override
  String get portalTypeEliteWeasel => 'Elite Weasel Hoarder';

  @override
  String get portalTypeEliteBumperCar => 'Elite Bumper Car';

  @override
  String get portalTypeGlacialNian => 'Glacial Nian';

  @override
  String get portalTypeEliteWizard => 'Elite Wizard';

  @override
  String get portalTypeEliteKing => 'Elite King';

  @override
  String get portalTypeEliteMirrorQueen => 'Elite Mirror Queen';

  @override
  String get waveGeneratorTabLabel => 'Линия генерации волн';

  @override
  String get waveGeneratorModuleTitle => 'Генератор волн';

  @override
  String get waveGeneratorModuleHelpTitle =>
      'Справка по модулю генератора волн';

  @override
  String get waveGeneratorModuleHelpOverview => 'Краткое описание';

  @override
  String get waveGeneratorModuleHelpOverviewBody =>
      'Генератор волн — ранняя система волн, используемая в мире Кунг-фу, испытаниях с фрагментами и других старых уровнях. Данные всех волн хранятся непосредственно в модуле, без отдельных событий волн.\nГруппы в модулях оружейных стоек и плиток с подкормкой можно сопоставить с волнами генератора один к одному, чтобы получить эффект, аналогичный событиям волн. На экране «Линия генерации волн» отображаются позиции появления этих препятствий мира Кунг-фу.';

  @override
  String get waveGeneratorModuleHelpSpending => 'Спавн за очки';

  @override
  String get waveGeneratorModuleHelpSpendingBody =>
      'Случайный спавн расходует очки, доступные на текущей волне. Игра выбирает по весу одного из зомби, доступных за оставшиеся очки, вычитает его стоимость и снова фильтрует кандидатов, пока подходящих зомби не останется. Неиспользованные очки не переносятся на следующую волну, а фиксированный спавн их не расходует.';

  @override
  String get waveGeneratorModuleHelpPointTrajectory => 'Параметры';

  @override
  String get waveGeneratorModuleHelpPointTrajectoryBody =>
      'Первая волна использует «Начальные очки случайного спавна (WaveSpendingPoints)». Затем количество очков по умолчанию увеличивается на «Прирост очков за волну (WaveSpendingPointIncrement)» с каждой волной; отключение случайного спавна на отдельной волне не останавливает этот рост.\n«Очки случайного спавна текущей волны (WavePointStart)» изменяют очки текущей волны, «Новый прирост очков (WavePointIncrement)» изменяет прирост для последующих волн, а «Сброс траектории очков (WavePointOverride)» определяет, вернётся ли следующая волна к значению, рассчитанному по исходному номеру волны, или продолжит расчёт от очков текущей волны как от новой начальной точки.';

  @override
  String get waveGeneratorModuleHelpPool => 'Пул зомби';

  @override
  String get waveGeneratorModuleHelpPoolBody =>
      'Пул зомби для случайного спавна постепенно расширяется по мере прохождения волн. Сначала используется начальный пул, затем зомби, добавленные на каждой волне, сохраняются для этой и всех последующих волн. Даже если случайный спавн на текущей волне отключён, добавленные на ней зомби всё равно попадут в пул.';

  @override
  String get waveGeneratorModuleHelpIncompat => 'Совместимость модулей';

  @override
  String get waveGeneratorModuleHelpIncompatBody =>
      'Генератор волн нельзя использовать одновременно с менеджером волн, модулем «Ренессанс» или модулем «Тыквенная ведьма»: это приведёт к сбою уровня.';

  @override
  String get waveGeneratorModuleHelpRow => 'Номера рядов';

  @override
  String get waveGeneratorModuleHelpRowBody =>
      'Нумерация рядов для фиксированного спавна начинается с 1: для первого ряда укажите «1», для второго — «2». Значение «?» позволяет игре выбрать ряд случайно.';

  @override
  String get waveGeneratorModuleGlobalParams => 'Глобальные параметры';

  @override
  String get waveGeneratorGlobalParams => 'Параметры генератора волн';

  @override
  String get waveGeneratorFlagIntervalHint =>
      'Через указанное число волн создаётся флаговая волна. Это не изменяет её очки случайного спавна.';

  @override
  String get flagWaveInterval => 'Интервал флаговых волн (FlagWaveInterval)';

  @override
  String get waveGeneratorSpendingPoints =>
      'Начальные очки случайного спавна (WaveSpendingPoints)';

  @override
  String get waveGeneratorSpendingPointIncrement =>
      'Прирост очков за волну (WaveSpendingPointIncrement)';

  @override
  String get waveGeneratorSpendingCompatibilityWarning =>
      'Начальные очки случайного спавна превышают прирост очков за волну; это может привести к сбою при загрузке уровня.';

  @override
  String waveGeneratorWaveCountSummary(int count) {
    return 'Всего волн: $count';
  }

  @override
  String get waveGeneratorInitialPool =>
      'Начальный пул зомби (AddToZombiePool)';

  @override
  String get waveGeneratorEmptyPool => 'Начальный пул зомби пуст.';

  @override
  String get waveGeneratorCustomZombieBlocked =>
      'Здесь нельзя добавлять пользовательских зомби';

  @override
  String get waveGeneratorTabMissingModule =>
      'Добавьте модуль генератора волн, чтобы настроить здесь дополнительные группы.';

  @override
  String waveGeneratorTabSummary(int interval, int points, int increment) {
    return 'Флаговая волна каждые $interval волн · Начальные очки $points · Прирост $increment за волну';
  }

  @override
  String get waveGeneratorNoWaves => 'Волны ещё не настроены.';

  @override
  String waveGeneratorDeleteWaveConfirm(int count) {
    return 'Будут удалены эта волна и настроенные в ней объекты фиксированного спавна ($count).';
  }

  @override
  String get waveGeneratorEmptyWaveRow => 'Нет фиксированного спавна';

  @override
  String get waveGeneratorRandomSpawnsEnabled => 'Случайный спавн включён';

  @override
  String get waveGeneratorRandomSpawnsDisabled =>
      'Случайный спавн на этой волне отключён';

  @override
  String get waveGeneratorRandomZombiesLabel => 'Текущий пул случайного спавна';

  @override
  String get waveGeneratorWavePoolDisabled =>
      'На этой волне случайный спавн не выполняется, но изменения пула зомби вступают в силу с этой волны.';

  @override
  String get waveGeneratorDisableRandomSpawns =>
      'Отключить случайный спавн (DisableRandomSpawns)';

  @override
  String get waveGeneratorDisableRandomSpawnsHint =>
      'Пропускает только спавн за очки на этой волне. Количество очков продолжает расти с номером волны, а изменения пула сохраняются и влияют на последующие волны.';

  @override
  String get waveGeneratorWaitUntilAllDie =>
      'Создать эту волну после уничтожения всех зомби предыдущей волны (WaitUntilAllZombiesDie)';

  @override
  String get waveGeneratorNoScriptedZombies =>
      'На этой волне нет фиксированного спавна.';

  @override
  String get waveGeneratorSpawnPlantFood =>
      'Количество зомби с подкормкой (SpawnPlantFoodCount)';

  @override
  String get waveGeneratorWavePointStart =>
      'Очки случайного спавна текущей волны (WavePointStart)';

  @override
  String get waveGeneratorWavePointStartHint =>
      'Задаёт очки случайного спавна только для текущей волны. Оставьте поле пустым, чтобы использовать значение, рассчитанное по умолчанию.';

  @override
  String get waveGeneratorWavePointIncrement =>
      'Новый прирост очков (WavePointIncrement)';

  @override
  String get waveGeneratorWavePointIncrementHint =>
      'Изменяет прирост очков для последующих волн и действует только при заданных очках случайного спавна текущей волны (WavePointStart).';

  @override
  String get waveGeneratorWavePointIncrementInactiveHint =>
      'Без очков случайного спавна текущей волны (WavePointStart) этот параметр не действует, но сохранённое значение не удаляется.';

  @override
  String get waveGeneratorWavePointOverride =>
      'Сброс траектории очков (WavePointOverride)';

  @override
  String get waveGeneratorWavePointOverrideHint =>
      'Когда параметр отключён, очки случайного спавна текущей волны (WavePointStart) влияют только на эту волну, а следующая получает значение, рассчитанное по её исходному номеру. Когда параметр включён, очки текущей волны становятся новой начальной точкой для последующих волн. В обоих случаях используется текущий прирост очков.';

  @override
  String get waveGeneratorPointTrajectory => 'Предпросмотр траектории очков';

  @override
  String get waveGeneratorPointTrajectoryTemporary =>
      'Очки случайного спавна текущей волны влияют только на эту волну. Следующая волна получает значение, рассчитанное по её исходному номеру, и продолжает увеличиваться с действующим приростом.';

  @override
  String get waveGeneratorPointTrajectoryReset =>
      'Очки текущей волны становятся новой начальной точкой для последующих волн, которые продолжают увеличиваться с действующим приростом.';

  @override
  String waveGeneratorPointTrajectoryWaveValue(int wave, int points) {
    return 'Волна $wave · очки: $points';
  }

  @override
  String get waveGeneratorBlackHoleFieldHint =>
      'Укажите число столбцов, чтобы в конце этой волны появилась пространственно-временная чёрная дыра и сдвинула все растения вправо.\nЧёрная дыра появляется только в том случае, если эта волна не является последней и включён параметр «Создать эту волну после уничтожения всех зомби предыдущей волны (WaitUntilAllZombiesDie)».';

  @override
  String waveGeneratorBlackHoleWaveHint(int cols) {
    return 'В конце этой волны появляется пространственно-временная чёрная дыра и сдвигает растения на $cols столбцов вправо';
  }

  @override
  String get waveGeneratorCurrentPool => 'Текущий эффективный пул зомби';

  @override
  String get waveGeneratorCurrentPoolEmpty =>
      'Текущий эффективный пул зомби пуст.';

  @override
  String get waveGeneratorWavePoolAdd =>
      'Расширение пула на этой волне (AddToZombiePool)';

  @override
  String get waveGeneratorWavePoolNoChanges =>
      'На этой волне пул зомби не расширяется.';

  @override
  String get waveGeneratorWaveScreenSubtitle => 'Модуль генератора волн';

  @override
  String get waveGeneratorWaveScreenHelpTitle =>
      'Справка по модулю генератора волн';

  @override
  String get waveGeneratorWaveScreenHelpBody =>
      'Во время случайного спавна игра выбирает по весу одного из зомби, доступных за оставшиеся очки, вычитает его стоимость и снова фильтрует кандидатов, пока доступных зомби не останется. Неиспользованные очки не переносятся на следующую волну. Фиксированный спавн добавляется непосредственно в текущую волну и не расходует очки случайного спавна.';

  @override
  String get waveGeneratorRandomSpawnsSectionTitle => 'Случайный спавн';

  @override
  String get waveGeneratorZombiePoolSectionTitle => 'Пул зомби';

  @override
  String get waveGeneratorWaveSettingsTitle => 'Настройки волны';

  @override
  String get waveGeneratorFixedSpawnsHelpTitle =>
      'Раздел «Фиксированный спавн»';

  @override
  String get waveGeneratorRandomSpawnsHelpTitle => 'Раздел «Случайный спавн»';

  @override
  String get waveGeneratorZombiePoolHelpTitle => 'Раздел «Пул зомби»';

  @override
  String get waveGeneratorWaveSettingsHelpTitle => 'Раздел «Настройки волны»';

  @override
  String get waveGeneratorFixedSpawnsHelpBody =>
      'Фиксированный спавн добавляется непосредственно в текущую волну, не расходует очки случайного спавна и может использоваться одновременно с ним.';

  @override
  String get waveGeneratorPointTrajectoryHelpBody =>
      'Предпросмотр траектории показывает эффективные очки случайного спавна, рассчитанные редактором для каждой волны. Он не отражает количество объектов фиксированного спавна.';

  @override
  String get waveGeneratorWavePoolAddHelpBody =>
      'Зомби, добавленные на этой волне, сразу входят в эффективный пул и продолжают влиять на последующие волны. Добавление действует, даже если случайный спавн на этой волне отключён.';

  @override
  String get waveGeneratorPoolCompatibilityTitle => 'Ограничения типов';

  @override
  String get waveGeneratorPoolCompatibilityHelpBody =>
      'Пул генератора волн поддерживает только стандартные игровые типы зомби, но не пользовательских зомби, определённых в уровне.';

  @override
  String get waveGeneratorWaitUntilAllDieHelpBody =>
      'Определяет, должна ли эта волна дождаться уничтожения всех зомби предыдущей волны перед началом спавна.';

  @override
  String get waveGeneratorSpawnPlantFoodHelpBody =>
      'Задаёт количество зомби на этой волне, которые несут и оставляют подкормку.';

  @override
  String waveGeneratorFixedSummary(int count, int rows) {
    return 'Фиксированный спавн: $count · Рядов: $rows';
  }

  @override
  String get waveGeneratorFixedSummaryEmpty => 'Нет фиксированного спавна';

  @override
  String waveGeneratorRandomSummary(int points) {
    return 'Включён · $points очков';
  }

  @override
  String waveGeneratorRandomLocalSummary(int points) {
    return 'Включён · $points очков · Очки текущей волны';
  }

  @override
  String get waveGeneratorRandomSummaryDisabled =>
      'На этой волне нет случайного спавна';

  @override
  String waveGeneratorPoolSummary(int current, int added) {
    return 'Текущих типов: $current · Добавлено: $added';
  }

  @override
  String waveGeneratorPoolSummaryNoAdditions(int current) {
    return 'Текущих типов: $current · Без расширения на этой волне';
  }

  @override
  String get waveGeneratorWaveSettingsDefaultSummary =>
      'Настройки по умолчанию';

  @override
  String waveGeneratorWaveSettingsPlantFoodSummary(int count) {
    return 'Подкормка ×$count';
  }

  @override
  String waveGeneratorWaveSettingsBlackHoleSummary(int cols) {
    return 'Пространственно-временная дыра · $cols столбцов';
  }

  @override
  String get waveGeneratorExpectationTapHint =>
      'Открыть статистический предпросмотр случайного спавна';

  @override
  String get waveGeneratorStatisticalPreview => 'Статистический предпросмотр';

  @override
  String get waveGeneratorExpectationEmpty =>
      'В пуле этой волны нет зомби, доступных для случайного спавна.';

  @override
  String get waveGeneratorExpectationPoolNote =>
      'Предпросмотр оценивает количество зомби с помощью повторных симуляций взвешенного выбора. Даже при одинаковом числе очков результат может меняться из-за порядка выбора, поэтому точно предсказать фактический спавн в игре невозможно.';

  @override
  String waveGeneratorExpectationTitle(int wave) {
    return 'Предпросмотр случайного спавна: волна $wave';
  }

  @override
  String waveGeneratorEffectiveRandomPoints(int points) {
    return 'Очки случайного спавна: $points';
  }

  @override
  String waveGeneratorFixedSpawnCount(int count) {
    return 'Фиксированный спавн: $count';
  }

  @override
  String get waveGeneratorFixedSpawns => 'Фиксированный спавн';

  @override
  String waveGeneratorPoolAddedCount(int count) {
    return 'Добавлено в пул на этой волне: $count';
  }

  @override
  String get waveGeneratorWaitStatus => 'Ожидание завершения предыдущей волны';

  @override
  String get waveGeneratorExpectationDisabled =>
      'Случайный спавн на этой волне отключён.';

  @override
  String waveGeneratorExpectationMissingData(String types) {
    return 'Невозможно рассчитать предпросмотр случайного спавна: у следующих зомби отсутствуют надёжные данные WavePointCost или Weight: $types';
  }

  @override
  String waveGeneratorExpectationEstimatedTotal(String count) {
    return 'Среднее количество зомби при случайном спавне: около $count';
  }

  @override
  String waveGeneratorExpectationCommonRange(int minimum, int maximum) {
    return 'Ожидаемый диапазон количества: $minimum–$maximum';
  }

  @override
  String waveGeneratorExpectationCostWeight(int cost, String weight) {
    return 'Стоимость $cost · Вес $weight';
  }

  @override
  String waveGeneratorExpectationAverageCount(String count) {
    return 'В среднем $count';
  }

  @override
  String get protectItems => 'Save Our Items';

  @override
  String get protectGridItemChallengeHelpTitle => 'Save Our Items module';

  @override
  String get briefOverview => 'Overview';

  @override
  String get automaticCount => 'Automatic Count';

  @override
  String get operationGuide => 'Operation Guide';

  @override
  String get protectGridItemChallengeHelpOverview =>
      'Specify the grid items that must be protected in the level. The level will immediately fail if any of them are destroyed.';

  @override
  String get protectGridItemChallengeHelpAutoCountBody =>
      'The editor will automatically update the number of grid items that need to be protected based on the number of items you add.';

  @override
  String get protectGridItemChallengeHelpOperationGuide =>
      'Click a position in the grid above, then click the \"Add item\" button to select the type of item to protect.';

  @override
  String mustProtectCount(int count) {
    return 'Текущее количество целей для защиты: $count';
  }

  @override
  String get customStageProperties => 'Свойства пользовательской локации';

  @override
  String get customStageNotFound =>
      'Объект пользовательской локации не найден.';

  @override
  String get customStageSectionGeneral => 'Общие';

  @override
  String get customStageSectionZombies => 'Типы зомби';

  @override
  String get customStageSectionResourceGroups => 'Группы ресурсов';

  @override
  String get customStageSectionMusicAndOther => 'Вид газона, музыка и прочее';

  @override
  String get customStageSectionAdvanced => 'Дополнительно';

  @override
  String get customStageAlias => 'Псевдоним локации';

  @override
  String get customStageNoResourceGroups => 'В списке нет групп ресурсов';

  @override
  String get customStageMissingBackgroundWarning =>
      'Импортируйте хотя бы одну группу DelayLoad_Background из справочника локаций, иначе газон может отображаться полностью чёрным.';

  @override
  String get customStageEnableAmbient => 'Включить эмбиент';

  @override
  String get customStageDisabledCellsEmpty => 'Пусто';

  @override
  String get customStageDisabledCellsDefault => 'По умолчанию';

  @override
  String get customStageEnableSubmarine => 'Включить подлодку';

  @override
  String get customStageSubmarineHitpoints => 'Прочность подлодки';

  @override
  String get customStageBeachMinigame => 'Использовать мини-игровую версию';

  @override
  String get customStageOnePerLevelLimit =>
      'В этом уровне уже есть пользовательский газон. Удалите его, прежде чем добавлять другой.';

  @override
  String get selectStageBackground => 'Выберите вид газона';

  @override
  String get searchStageBackground => 'Поиск газона';

  @override
  String get noStageBackgroundFound => 'Вид газона не найден';

  @override
  String get stageBackgroundNeedMorePromptTitle => 'Нужен другой вид газона?';

  @override
  String get stageBackgroundNeedMorePromptMessage =>
      'Импортируйте группы ресурсов из другой локации, чтобы открыть здесь больше вариантов газона.';

  @override
  String get stageBackgroundAddFromStage => 'Добавить ещё вид газона';

  @override
  String get customStageNameSuffix => ' (Пользов.)';

  @override
  String get customStageLawnAppearance => 'Вид газона';

  @override
  String get customStageBaseStage => 'Базовая локация';

  @override
  String get selectCustomStageBase => 'Выберите базовую локацию';

  @override
  String get noStageBaseFound => 'Газон не найден';

  @override
  String get importResourceGroup => 'Импорт группы ресурсов';

  @override
  String get importResourceGroupGlobal => 'Из общего списка';

  @override
  String get importResourceGroupFromStage => 'Из локации';

  @override
  String get importResourceGroupSourceStage => 'Исходная локация';

  @override
  String get searchResourceGroup => 'Поиск группы ресурсов';

  @override
  String get noResourceGroupFound => 'Группа ресурсов не найдена';

  @override
  String get importResourceGroupsFromStageTitle =>
      'Добавить группы ресурсов из локации?';

  @override
  String importResourceGroupsFromStageMessage(String stageName) {
    return 'Будут добавлены следующие группы ресурсов из $stageName:';
  }

  @override
  String importResourceGroupsFromStageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count групп ресурсов уже есть на этом уровне и будут пропущены.',
      many: '$count групп ресурсов уже есть на этом уровне и будут пропущены.',
      few: '$count группы ресурсов уже есть на этом уровне и будут пропущены.',
      one: '$count группа ресурсов уже есть на этом уровне и будет пропущена.',
    );
    return '$_temp0';
  }

  @override
  String get importResourceGroupsFromStageAllPresent =>
      'Все группы ресурсов из этой локации уже есть на этом уровне.';

  @override
  String get importResourceGroupsApplySourceLawnAppearance =>
      'Также использовать вид газона этой локации';

  @override
  String get createCustomStage => 'Создать пользовательский газон';

  @override
  String get createCustomStageHint =>
      'Выберите базовый вид газона и отредактируйте его локально в этом уровне.';

  @override
  String get customStageAliasPromptTitle =>
      'Псевдоним пользовательской локации';

  @override
  String get customStageAliasTaken =>
      'Этот псевдоним уже используется в этом уровне.';

  @override
  String get stageSelectionTabBuiltin => 'Встроенные';

  @override
  String get stageSelectionTabCustom => 'Пользовательские';

  @override
  String get customStageSelectionEmpty =>
      'В этом уровне пока нет пользовательского газона.';

  @override
  String get customStageSelectionInLevel => 'Пользовательские газоны в уровне';

  @override
  String get customStageSwitchToBuiltinTitle =>
      'Переключиться на встроенный газон?';

  @override
  String get customStageSwitchToBuiltinMessage =>
      'Это навсегда удалит данные пользовательского газона из этого уровня. Отменить будет нельзя.';

  @override
  String get customStageDeleteTitle => 'Удалить пользовательский газон?';

  @override
  String get customStageDeleteMessage =>
      'Это навсегда удалит данные пользовательского газона из этого уровня. Если он сейчас активен, уровень переключится на встроенный газон по умолчанию.';

  @override
  String get customStagePresetSectionTitle => 'Preset custom lawns';

  @override
  String get editCustomStage => 'Редактировать пользовательский газон';

  @override
  String get startupLoadingLocalization => 'Локализация';

  @override
  String get startupLoadingStages => 'Карты';

  @override
  String get startupLoadingAudio => 'Аудио';

  @override
  String get startupLoadingGridItems => 'Объекты сетки';

  @override
  String get startupLoadingZomboss => 'Зомбосс';

  @override
  String get startupLoadingReference => 'Справочные данные';

  @override
  String get startupLoadingZombies => 'Зомби';

  @override
  String get startupLoadingPlants => 'Растения';

  @override
  String get startupLoadingFish => 'Рыбы';

  @override
  String get startupLoadingImages => 'Изображения';

  @override
  String get startupLoadingPlugins => 'Плагины';

  @override
  String startupLoadingCategoryProgress(String category) {
    return 'Загрузка $category...';
  }

  @override
  String get reselectFiles => 'Выбрать заново';

  @override
  String get validationReviewRequest =>
      'Пожалуйста, ознакомьтесь с результатами проверки выбранных уровней.';

  @override
  String get validationRecommendation =>
      'Рекомендуется отредактировать выбранные уровни для исправления ошибок или выбрать другие файлы.';

  @override
  String validationProgress(int current, int total) {
    return 'Проверка $current / $total';
  }

  @override
  String get invalid_rsb_version => 'Неверная версия RSB, должна быть 3 или 4';

  @override
  String get invalid_file_list_offset => 'Неверное смещение списка файлов';

  @override
  String get invalid_rsb_ver_3_resource_offset =>
      'Неверное смещение ресурса для RSB версии 3';

  @override
  String get invalid_composite_name => 'Неверное имя композита';

  @override
  String get out_of_range_1 => 'Выход за пределы диапазона poolIndex';

  @override
  String get out_of_range_2 => 'Выход за пределы диапазона индекса пакета';

  @override
  String get invalid_rsg_name => 'Неверное имя RSG';

  @override
  String get invalid_packet_width => 'Неверная ширина пакета';

  @override
  String get invalid_packet_height => 'Неверная высота пакета';

  @override
  String get invalid_item_packet => 'Неверный пакет элемента';

  @override
  String get invalid_rsg_number => 'Неверный индекс RSG';

  @override
  String get invalid_part2_offset => 'Неверное смещение Part2';

  @override
  String get invalid_head_length => 'Неверная длина заголовка';

  @override
  String get rsb_is_corrupted => 'Этот RSB поврежден';

  @override
  String get invalid_ptx_info_eachlength => 'Информация PTX неверна';

  @override
  String get invalid_end_offset => 'Неверное конечное смещение';

  @override
  String get invalid_rsb_head =>
      'Несоответствие магического числа RSB, должно начинаться с \"1BSR\"';

  @override
  String get invalid_ptx_info_each_length => 'Неверная информация PTX';

  @override
  String get category_out_of_length => 'Категория выходит за пределы длины';

  @override
  String get name_path_must_be_ascii =>
      'Путь имени должен соответствовать ASCII';

  @override
  String get invalid_rsg_magic =>
      'Неверное магическое число RSG, должно начинаться с \"PGSR\"';

  @override
  String get invalid_rsg_version => 'Неверная версия RSG, должна быть 3 или 4';

  @override
  String get invalid_rsg_compression_flag =>
      'Неверный флаг сжатия RSG, поддерживаются только от 0 до 3';

  @override
  String get mismatch_zlib_magic =>
      'Несоответствие магического числа PopCap Zlib, должно начинаться с 0xDEADFED4';

  @override
  String get customPortalAdd => 'Новый пользовательский портал';

  @override
  String get customPortalSingleName => 'Пользовательский портал';

  @override
  String customPortalName(int index) {
    return 'Пользовательский портал $index';
  }

  @override
  String get customPortalCreateTitle => 'Создать пользовательский портал';

  @override
  String get customPortalEditTitle => 'Изменить пользовательский портал';

  @override
  String get customPortalSelectBaseTitle => 'Выберите базовый портал';

  @override
  String get customPortalBlankTemplate => 'Пустой шаблон портала';

  @override
  String get customPortalBlankTemplateSubtitle =>
      'Стандартная структура портала без зомби.';

  @override
  String get customPortalBuiltInBases => 'Встроенные базовые порталы';

  @override
  String get customPortalUnusedTitle => 'Удалить неиспользуемый портал?';

  @override
  String get customPortalUnusedSingleMessage =>
      'Пользовательский портал больше не используется. Удалить связанные с ним объекты данных из уровня?';

  @override
  String customPortalUnusedMessage(int index) {
    return 'Пользовательский портал $index больше не используется. Удалить связанные с ним объекты данных из уровня?';
  }

  @override
  String get customPortalAppearanceSection => 'Внешний вид портала';

  @override
  String get customPortalSpawnSection => 'Появление зомби';

  @override
  String get customPortalWorld => 'Внешний вид мира';

  @override
  String get customPortalWorldTwister => 'Пусто';

  @override
  String get customPortalPopAnimation => 'Анимация портала';

  @override
  String get customPortalAnimationModern => 'Портал Современного Дня';

  @override
  String get customPortalAnimationMemoryLane => 'Портал Дороги воспоминаний';

  @override
  String get customPortalAnimationHydra => 'Зеркало Зомбота Сказочного Леса';

  @override
  String get customPortalSpawnMethod => 'Способ появления зомби';

  @override
  String get customPortalSpawnMethodShuffled =>
      'Перемешанная последовательность';

  @override
  String get customPortalSpawnMethodInOrder => 'По порядку';

  @override
  String get customPortalSpawnMethodHydra =>
      'Случайный выбор Зомбота Сказочного Леса';

  @override
  String get customPortalZombieTypes => 'Доступные типы зомби';

  @override
  String get customPortalMinimumQuantity => 'Минимальное количество';

  @override
  String get customPortalMaximumQuantity => 'Максимальное количество';

  @override
  String get customPortalSpawnInterval => 'Интервал появления зомби';

  @override
  String get customPortalSpawnIntervalSubtitle =>
      'Необязательно задайте минимальное и максимальное время между появлениями зомби.';

  @override
  String get moduleTitle_MoonLifeSupportSystemProperties =>
      'Система жизнеобеспечения';

  @override
  String get moduleDesc_MoonLifeSupportSystemProperties =>
      'Настраивает запас энергии Лунной базы и протоколы перегрузки';

  @override
  String get moduleTitle_LunarTerminalModuleProperties => 'Лунный терминал';

  @override
  String get moduleDesc_LunarTerminalModuleProperties =>
      'Развёртывает добывающих роботов для сбора энергии кристаллов и повышения предела энергии';

  @override
  String get moduleTitle_LunarMineVeinModuleProperties => 'Лунные жилы';

  @override
  String get moduleDesc_LunarMineVeinModuleProperties =>
      'Размещает жилы лунных энергетических кристаллов и задаёт волны их роста';

  @override
  String get moduleTitle_RadiationMeteorModuleProperties =>
      'Радиоактивный метеорит';

  @override
  String get moduleDesc_RadiationMeteorModuleProperties =>
      'Обрушивает метеориты, уничтожающие растения и заражающие соседние клетки';

  @override
  String get eventTitle_SpawnRocketLandingWaveActionProps => 'Посадка ракеты';

  @override
  String get eventDesc_SpawnRocketLandingWaveActionProps =>
      'Создаёт в заданных позициях лунные ракеты, которые можно захватить';

  @override
  String get moonLifeSupportHelpTitle => 'Система жизнеобеспечения';

  @override
  String get moonLifeSupportHelpOverview =>
      'Экономическая система, часто используемая в уровнях Лунной базы. После добавления этого модуля посадка растений не расходует солнце: вместо этого растения в реальном времени занимают часть запаса энергии системы жизнеобеспечения. Когда растение выкапывают лопатой, уничтожают зомби или оно исчезает из-за особой механики, весь занятый им запас немедленно возвращается.';

  @override
  String get moonLifeSupportHelpProtocolsTitle => 'Протоколы перегрузки';

  @override
  String get moonLifeSupportHelpProtocols =>
      'Когда потребление энергии системы жизнеобеспечения превышает её начальный запас, система переходит в состояние перегрузки и включает протокол энергосбережения, снижая скорость атаки растений на поле и скорость перезарядки ячеек семян.\nКогда потребление энергии превышает (начальный запас энергии × требуемый коэффициент гибернации), после заданного отсчёта система принудительно включает протокол гибернации: все растения на поле впадают в спячку, а ячейки семян и шкала космической подкормки блокируются и становятся недоступны.';

  @override
  String get moonLifeSupportHelpPlantFoodTitle => 'Независимая перезарядка';

  @override
  String get moonLifeSupportHelpPlantFood =>
      'Модуль содержит отдельный список растений с независимой перезарядкой. Время перезарядки растений из списка не зависит от протокола энергосбережения, но при протоколе гибернации их всё равно нельзя высаживать.';

  @override
  String get moonLifeSupportPowerSettings => 'Настройки энергии';

  @override
  String get moonInitialCapacity => 'Начальный запас энергии (InitialCapacity)';

  @override
  String get moonBufferOverloadRatio =>
      'Требуемый коэффициент гибернации (BufferOverloadRatio)';

  @override
  String get moonPenaltyCountdown =>
      'Отсчёт до гибернации (PenaltyCountdown, секунды)';

  @override
  String get moonPlantImmunityList =>
      'Растения с независимой перезарядкой (PlantImmunityList)';

  @override
  String get moonPlantImmunityListHint =>
      'Время перезарядки растений из списка не зависит от протокола энергосбережения, но при протоколе гибернации их всё равно нельзя высаживать.';

  @override
  String get moonSelectImmunePlants =>
      'Выбрать растения для добавления в список';

  @override
  String get lunarTerminalHelpTitle => 'Лунный терминал';

  @override
  String get lunarTerminalHelpOverview =>
      'Артефакт, часто используемый в уровнях Лунной базы. Он занимает постоянную позицию на поле, как пушка Небесного города. После нажатия на терминал сбора энергии можно выбрать одного из трёх добывающих роботов и перетащить его на поле. Роботы автоматически собирают энергию лунных энергетических кристаллов и радиоактивных метеоритов в пределах досягаемости, навсегда увеличивая доступный в этом уровне запас энергии системы жизнеобеспечения и позволяя создавать более сильные построения. У роботов есть здоровье; зомби, радиоактивные метеориты и другие цели могут атаковать и уничтожать их.';

  @override
  String get lunarTerminalHelpFixedTitle => 'Перезарядка развёртывания';

  @override
  String get lunarTerminalHelpFixed =>
      'После каждого развёртывания робота терминал сбора лунной энергии уходит на перезарядку. Её длительность можно настроить в уровне.';

  @override
  String get lunarTerminalCollectorCooldown =>
      'Перезарядка развёртывания робота (CollectorCooldown, секунды)';

  @override
  String get lunarMineVeinHelpTitle => 'Лунные жилы';

  @override
  String get lunarMineVeinHelpOverview =>
      'В начале уровня размещает на поле жилы лунных энергетических кристаллов, часто встречающиеся на Лунной базе. Изначально жилы не дают энергии. На заданной волне на прежнем месте вырастает лунный энергетический кристалл, после чего его можно добывать для получения энергии.';

  @override
  String get lunarMineVeinHelpWaveTitle => 'Нумерация волн';

  @override
  String get lunarMineVeinHelpWave =>
      'Волна роста (EmergenceWave) нумеруется с 1: для роста на первой волне укажите 1, на второй — 2 и так далее.';

  @override
  String get lunarMineVeinPlacements => 'Размещение жил (VeinPlacements)';

  @override
  String get lunarMineEmergenceWave =>
      'Волна роста (EmergenceWave, нумерация с 1)';

  @override
  String get moonPlacementGestureHint =>
      'Нажмите пустую клетку, чтобы добавить объект. Щёлкните правой кнопкой или удерживайте занятую клетку, чтобы удалить его.';

  @override
  String get radiationMeteorHelpTitle => 'Радиоактивный метеорит';

  @override
  String get radiationMeteorHelpOverview =>
      'На заданных волнах обрушивает особые радиоактивные метеориты, часто встречающиеся на Лунной базе. Перед падением метеорита в уровне появляется красное предупреждение, а предполагаемая клетка падения отмечается прицелом. По окончании заданного времени предупреждения метеорит падает вертикально, мгновенно уничтожает всех в клетке приземления, а затем медленно заражает соседние клетки по часовой стрелке.\nЗомби на заражённых клетках получают прибавку к скорости передвижения и восстановлению здоровья, а космические растения непрерывно получают урон.';

  @override
  String get radiationMeteorHelpMiningTitle => 'Уничтожение добычей';

  @override
  String get radiationMeteorHelpMining =>
      'Устройства сбора лунной энергии могут добывать радиоактивные метеориты и через некоторое время уничтожать их. После уничтожения метеорита терминал навсегда повышает доступный в этом уровне запас энергии игрока и устраняет эффект заражения.';

  @override
  String get radiationMeteorParameters => 'Параметры метеорита';

  @override
  String get radiationMeteorWarningDuration =>
      'Длительность предупреждения (WarningDuration, секунды)';

  @override
  String get radiationMeteorPollutionInterval =>
      'Интервал загрязнения (PollutionInterval, секунды)';

  @override
  String get radiationMeteorMiningDuration =>
      'Время добычи (MiningDurationRequired, секунды)';

  @override
  String get radiationMeteorPowerReward =>
      'Награда энергией (PowerRewardOnDestroy)';

  @override
  String get radiationMeteorSpawnSchedule => 'Порядок падения (SpawnSchedule)';

  @override
  String get radiationMeteorWave => 'Волна (Wave, нумерация с 1)';

  @override
  String get rocketLandingHelpTitle => 'Посадка ракеты';

  @override
  String get rocketLandingHelpOverview =>
      'Событие, часто используемое на Лунной базе. Оно создаёт ракеты в заданных позициях как цели, за которые борются растения и зомби. По умолчанию ракеты игнорируют надгробия и другие препятствия на клетках, приземляются напрямую и уничтожают растения в клетках падения. Можно настроить, будут ли препятствия мешать появлению ракет и будут ли растения из клеток падения отброшены.';

  @override
  String get rocketLandingHelpPlantsTitle => 'Захват растениями';

  @override
  String get rocketLandingHelpPlants =>
      'Посадите подходящее космическое растение в ракету. Через некоторое время ракета взлетит, наведётся на опасного зомби на поле и нанесёт ему огромный урон. Космический горох выпускает рикошетящие космические снаряды; Космический гриб создаёт грибные червоточины в области; Космический орех создаёт небольшую кратковременную чёрную дыру, которая притягивает ближайших зомби и непрерывно наносит им урон.';

  @override
  String get rocketLandingHelpZombiesTitle => 'Захват зомби';

  @override
  String get rocketLandingHelpZombies =>
      'Вошедший в ракету зомби после запуска переносится в клетку ближе к тылу. Некоторые зомби не могут входить в ракеты.';

  @override
  String get rocketLandingSettings => 'Настройки ракеты';

  @override
  String get rocketPoolCount => 'Количество ракет (Count)';

  @override
  String get rocketSpawnCount =>
      'Общее количество создаваемых объектов (SpawnCount)';

  @override
  String get rocketSpawnInterval =>
      'Интервал появления (SpawnInterval, секунды)';

  @override
  String get rocketDisplacePlants => 'Отбрасывать растения (DisplacePlants)';

  @override
  String get rocketDisplacePlantsSubtitle =>
      'Если включено, ракета перемещает растения из клетки падения на соседние свободные клетки';
}
