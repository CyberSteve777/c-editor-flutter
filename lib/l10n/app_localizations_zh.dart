// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '我的关卡库';

  @override
  String get about => '关于';

  @override
  String get back => '返回';

  @override
  String get refresh => '刷新';

  @override
  String get toggleTheme => '切换主题';

  @override
  String get switchFolder => '切换目录';

  @override
  String get clearCache => '释放缓存';

  @override
  String get uiSize => '界面大小';

  @override
  String get aboutSoftware => '关于软件';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String get storagePermissionHint => '需要存储权限。请在设置中开启「允许访问以管理所有文件」来打开关卡文件。';

  @override
  String get storagePermissionDialogTitle => '需要存储权限';

  @override
  String get storagePermissionDialogMessage =>
      '本应用需要访问外部存储以打开和保存关卡文件。请在设置中授予「允许访问以管理所有文件」权限。';

  @override
  String get storagePermissionGoToSettings => '前往设置';

  @override
  String get storagePermissionDeny => '拒绝';

  @override
  String get initSetup => '初始化设置';

  @override
  String get selectFolderPrompt => '请选择一个文件夹作为关卡存储目录。';

  @override
  String get selectFolderButton => '选择文件夹';

  @override
  String get emptyFolder => '文件夹为空';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get newLevel => '新建关卡';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get copy => '复制';

  @override
  String get download => '下载';

  @override
  String get move => '移动';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get convert => '格式转换';

  @override
  String get convertHelpTooltip => '格式转换';

  @override
  String get create => '创建';

  @override
  String get newName => '新名称';

  @override
  String get folderName => '文件夹名称';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteMessage(Object detail, Object name) {
    return '确定要删除 \"$name\" 吗？$detail';
  }

  @override
  String get folderDeleteDetail => '如果是文件夹，其内容也将被删除。';

  @override
  String get levelDeleteDetail => '此操作不可恢复。';

  @override
  String get confirmDeleteCheckbox => '我确定要永久删除';

  @override
  String get renameSuccess => '重命名成功';

  @override
  String get renameFail => '重命名失败，已有同名文件';

  @override
  String get uploadLevel => '上传至创意庭院';

  @override
  String get uploadLevelConfirm =>
      '即将离开编辑器并打开官方的高级创作庭院作者中心网站。使用邮箱登录后，您可以将编辑器中的JSON关卡文件上传至游戏内的创意庭院供玩家游玩。是否继续？';

  @override
  String get proceed => '继续';

  @override
  String get copyReferenceOrDeep => '复制事件引用，还是创建独立副本？';

  @override
  String get copyReference => '复制事件引用';

  @override
  String get deepCopy => '创建独立副本';

  @override
  String get copyEventTarget => '目标波次';

  @override
  String get targetWaveIndex => '目标波次序号';

  @override
  String get moveToWaveIndex => '移动至波次序号';

  @override
  String get invalidWaveIndex => '无效波次序号';

  @override
  String get renamingFailed => '重命名失败';

  @override
  String get deleted => '已删除';

  @override
  String get copyLevel => '复制关卡';

  @override
  String get newFileName => '新文件名';

  @override
  String get copySuccess => '复制成功';

  @override
  String get copyFail => '复制失败';

  @override
  String moving(Object name) {
    return '正在移动: $name';
  }

  @override
  String get movePrompt => '请导航至目标文件夹，然后点击粘贴';

  @override
  String get paste => '粘贴';

  @override
  String get movingSuccess => '移动成功';

  @override
  String get movingFail => '移动失败';

  @override
  String get moveSameFolder => '源目录和目标目录相同';

  @override
  String get moveFileExistsTitle => '文件已存在';

  @override
  String get moveFileExistsMessage => '目标文件夹中已存在同名文件。';

  @override
  String get moveOverwrite => '覆盖';

  @override
  String fileOverwritten(Object name) {
    return '文件已覆盖: $name';
  }

  @override
  String get moveSaveAsCopy => '另存为副本';

  @override
  String get moveCancelled => '操作已取消';

  @override
  String movedAs(Object name) {
    return '已移动并另存为 $name';
  }

  @override
  String get folderCreated => '文件夹创建成功';

  @override
  String get createFail => '创建失败';

  @override
  String get noTemplates => '未找到模板';

  @override
  String get newLevelTemplate => '新建关卡 - 选择模板';

  @override
  String get nameLevel => '命名关卡';

  @override
  String get levelCreated => '创建成功';

  @override
  String get levelCreateFail => '创建失败，已有同名文件';

  @override
  String get adjustUiSize => '调整界面大小';

  @override
  String currentScale(Object percent) {
    return '当前缩放: $percent%';
  }

  @override
  String get small => '小';

  @override
  String get standard => '标准';

  @override
  String get large => '大';

  @override
  String get done => '完成';

  @override
  String get reset => '重置';

  @override
  String cacheCleared(Object count) {
    return '已清理 $count 个缓存文件';
  }

  @override
  String get returnUp => '返回上一级';

  @override
  String get jsonFile => 'JSON 文件';

  @override
  String get convertToJson => '转换为 JSON';

  @override
  String get convertToHotUpdateJson => '转换为热更新 JSON (HUJSON)';

  @override
  String get convertToEncryptedRton => '转换为加密 RTON';

  @override
  String get conversionRequiredTitle => '需要转换';

  @override
  String get conversionRequiredMessage => '该文件需要先转换为 JSON 才能在编辑器中打开。';

  @override
  String get convertAction => '格式转换';

  @override
  String get conversionFailed => '转换失败';

  @override
  String convertedMessage(Object name) {
    return '已转换：$name';
  }

  @override
  String get softwareIntro => '软件介绍';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'PVZ2 关卡可视化编辑器';

  @override
  String get introSection => '简介';

  @override
  String get introText =>
      'C-Editor 是一款专为《植物大战僵尸2》中文版设计的可视化关卡编辑工具。它旨在解决直接修改 JSON 文件繁琐、易错的问题，提供直观的图形界面来管理关卡配置。';

  @override
  String get featuresSection => '核心功能';

  @override
  String get feature1 => '模块化编辑：对关卡模块和事件进行模块化管理。';

  @override
  String get feature2 => '多模式支持：我是僵尸、砸罐子、坚不可摧、僵王战等。';

  @override
  String get feature3 => '自定义注入：在关卡内注入并管理自定义僵尸。';

  @override
  String get feature4 => '智能校验：检测模块依赖缺失、引用失效等问题。';

  @override
  String get usageSection => '使用说明';

  @override
  String get usageText =>
      '1. 目录设置：首次进入请选择存放 JSON 关卡文件的目录。\n2. 导入/新建：点击列表项编辑现有关卡，或使用右下角按钮基于模板新建。\n3. 模块管理：在编辑器中可添加新模块。\n4. 保存关卡：编辑完成后点击保存，文件将回写到原 JSON。\n5. 转换关卡文件：可将 JSON 转换为热更新可读的 HUJSON 或加密后的 RTON，随后通过其他工具导入游戏内进行测试（记得在导入前手动将文件扩展名从 .hujson 改回 .json）。\n6. 关卡创作完成后，在关卡列表滚动到顶部时，可点击右下角的“上传至创意庭院”浮动按钮，前往官方的植物大战僵尸2高级创作庭院作者中心。\n7. 你可以在「创意庭院·推荐关卡展示」网页中查看往期官方推荐的关卡ID及推荐理由。游玩这些关卡不仅能够支持优秀的关卡创作者，也有助于提升自己的关卡设计水平。\n8.如有疑问或需要高创关卡制作帮助，欢迎加入Plants vs. Zombies Discord服务器，在 PvZ2C-Modding 子区中提问。';

  @override
  String get usageTextDesktop =>
      '1. 目录设置：点击文件夹图标选择 JSON 关卡目录。\n2. 导入/新建：点击列表项编辑现有关卡，或使用右下角按钮基于模板新建。\n3. 模块管理：在编辑器中可添加新模块。\n4. 保存关卡：编辑完成后点击保存，文件将回写到原 JSON。\n5. 转换关卡文件：可将 JSON 转换为热更新可读的 HUJSON 或加密后的 RTON，随后通过其他工具导入游戏内进行测试（记得在导入前手动将文件扩展名从 .hujson 改回 .json）。\n6. 关卡创作完成后，在关卡列表滚动到顶部时，可点击右下角的“上传至创意庭院”浮动按钮，前往官方的植物大战僵尸2高级创作庭院作者中心。\n7. 你可以在「创意庭院·推荐关卡展示」网页中查看往期官方推荐的关卡ID及推荐理由。游玩这些关卡不仅能够支持优秀的关卡创作者，也有助于提升自己的关卡设计水平。\n8. 如有疑问或需要高创关卡制作帮助，欢迎加入Plants vs. Zombies Discord服务器，在 PvZ2C-Modding 子区中提问。';

  @override
  String get usageTextMobile =>
      '1. 目录设置：点击文件夹图标选择 JSON 关卡目录。\n2. 导入/新建：点击列表项编辑现有关卡，或使用右下角按钮基于模板新建。\n3. 模块管理：在编辑器中可添加新模块。\n4. 保存关卡：编辑完成后点击保存，文件将回写到原 JSON。\n5. 转换关卡文件：可将 JSON 转换为热更新可读的 HUJSON 或加密后的 RTON，随后通过其他工具导入游戏内进行测试（记得在导入前手动将文件扩展名从 .hujson 改回 .json）。\n6. 关卡创作完成后，在关卡列表滚动到顶部时，可点击右下角的“上传至创意庭院”浮动按钮，前往官方的植物大战僵尸2高级创作庭院作者中心。\n7. 你可以在「创意庭院·推荐关卡展示」网页中查看往期官方推荐的关卡ID及推荐理由。游玩这些关卡不仅能够支持优秀的关卡创作者，也有助于提升自己的关卡设计水平。\n8. 如有疑问或需要高创关卡制作帮助，欢迎加入Plants vs. Zombies Discord服务器，在 PvZ2C-Modding 子区中提问。';

  @override
  String get usageRecommendedLevelsLabel => '创意庭院·推荐关卡展示：';

  @override
  String get discordInviteLabel => 'Discord服务器链接：';

  @override
  String get creditsSection => '致谢名单';

  @override
  String get authorLabel => '作者：';

  @override
  String get authorName => 'CyberSteve777';

  @override
  String get thanksLabel => '特别鸣谢：';

  @override
  String get thanksNames =>
      'Devourdoom、Evilhack28、Chara、KL12、Haruma、nineteendo、vi_i_guess';

  @override
  String get sourceLabel => '源码：';

  @override
  String get issuesLabel => '问题反馈：';

  @override
  String get zEditorAcknowledgment => '若没有Z-Editor的创作者，就不可能创造出本工具。';

  @override
  String get zEditorCreditsSubsection => 'Z-Editor 致谢';

  @override
  String get zEditorAuthorLabel => '作者：';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => '特别鸣谢：';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ群：';

  @override
  String get zEditorQqGroupNumber => '960722092';

  @override
  String get tagline => '穿越时空 创造无穷可能';

  @override
  String version(Object version) {
    return '版本 $version';
  }

  @override
  String get language => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => '空白关卡';

  @override
  String get templateCardPickExample => '自选卡示例';

  @override
  String get templateConveyorExample => '传送带示例';

  @override
  String get templateLastStandExample => '坚不可摧示例';

  @override
  String get templateIZombieExample => '我是僵尸示例';

  @override
  String get templateVaseBreakerExample => '砸罐子示例';

  @override
  String get templateZombossMechExample => '僵王机甲战示例';

  @override
  String get templateZombossBattleExample => '僵王战示例';

  @override
  String get templateCustomZombieExample => '自定义僵尸示例';

  @override
  String get templateIPlantExample => '我是植物示例';

  @override
  String get unsavedChanges => '有未保存的更改';

  @override
  String get saveBeforeLeaving => '离开前是否保存？';

  @override
  String get discard => '放弃';

  @override
  String get stayInEditor => '留下';

  @override
  String get saved => '已保存';

  @override
  String get failedToLoadLevel => '加载关卡失败';

  @override
  String get noLevelDefinition => '未找到关卡定义';

  @override
  String get noLevelDefinitionHint =>
      '当前关卡内未找到关卡定义模块 (LevelDefinition)，这是关卡文件的基础节点。请尝试手动添加。';

  @override
  String get levelBasicInfo => '关卡基本信息';

  @override
  String get levelBasicInfoSubtitle => '名称、序号、描述、地图背景';

  @override
  String get removeModule => '移除模块';

  @override
  String get zombieCategoryMain => '按世界';

  @override
  String get zombieCategorySize => '按体型';

  @override
  String get zombieCategoryOther => '其他';

  @override
  String get zombieCategoryCollection => '我的收藏';

  @override
  String get zombieTagAll => '全部僵尸';

  @override
  String get zombieTagEgyptPirate => '埃及/海盗';

  @override
  String get zombieTagWestFuture => '西部/未来';

  @override
  String get zombieTagDarkBeach => '黑暗/沙滩';

  @override
  String get zombieTagIceageLostcity => '冰河/失落';

  @override
  String get zombieTagKongfuSkycity => '功夫/天空';

  @override
  String get zombieTagEightiesDino => '摇滚/恐龙';

  @override
  String get zombieTagModernPvz1 => '现代/一代';

  @override
  String get zombieTagSteamRenai => '蒸汽/复兴';

  @override
  String get zombieTagHenaiAtlantis => '平安/海底';

  @override
  String get zombieTagTaleZCorp => '童话/Z公司';

  @override
  String get zombieTagParkourSpeed => '跑酷/飞车';

  @override
  String get zombieTagTothewest => '西游/地宫';

  @override
  String get zombieTagMemory => '回忆之旅';

  @override
  String get zombieTagUniverse => '平行宇宙';

  @override
  String get zombieTagFestival1 => '节日串烧1';

  @override
  String get zombieTagFestival2 => '节日串烧2';

  @override
  String get zombieTagRoman => '罗马世界';

  @override
  String get zombieTagCustom => '回忆自定义';

  @override
  String get zombieTagPet => '宠物';

  @override
  String get zombieTagImp => '小鬼';

  @override
  String get zombieTagBasic => '常规';

  @override
  String get zombieTagFat => '胖子';

  @override
  String get zombieTagStrong => '壮汉';

  @override
  String get zombieTagGargantuar => '巨人';

  @override
  String get zombieTagElite => '精英';

  @override
  String get zombieTagEvildave => '适配IZ';

  @override
  String get plantCategoryQuality => '按品质';

  @override
  String get plantCategoryRole => '按作用';

  @override
  String get plantCategoryAttribute => '按属性';

  @override
  String get plantCategoryOther => '其他分类';

  @override
  String get plantCategoryCollection => '我的收藏';

  @override
  String get plantTagAll => '全部植物';

  @override
  String get plantTagWhite => '白色品质';

  @override
  String get plantTagGreen => '绿色品质';

  @override
  String get plantTagBlue => '蓝色品质';

  @override
  String get plantTagPurple => '紫色品质';

  @override
  String get plantTagOrange => '橙色品质';

  @override
  String get plantTagRed => '红色品质';

  @override
  String get plantTagSupport => '辅助植物';

  @override
  String get plantTagRanger => '远程植物';

  @override
  String get plantTagSunProducer => '生产植物';

  @override
  String get plantTagDefence => '坚韧植物';

  @override
  String get plantTagVanguard => '先锋植物';

  @override
  String get plantTagTrapper => '奇兵植物';

  @override
  String get plantTagFire => '火焰属性';

  @override
  String get plantTagIce => '冰冻属性';

  @override
  String get plantTagMagic => '魔法属性';

  @override
  String get plantTagPoison => '毒液属性';

  @override
  String get plantTagElectric => '雷电属性';

  @override
  String get plantTagPhysical => '物理属性';

  @override
  String get plantTagOriginal => '一代植物';

  @override
  String get plantTagParallel => '平行世界';

  @override
  String get plantTagSpecial => '魔术帽';

  @override
  String get removeModuleConfirm =>
      '确定要移除该模块吗？本地自定义模块(@CurrentLevel)及其关联数据将一并删除，不可恢复。';

  @override
  String get confirmRemove => '确认移除';

  @override
  String get addModule => '添加模块';

  @override
  String get settings => '设置';

  @override
  String get timeline => '波次时间线';

  @override
  String get iZombie => '我是僵尸';

  @override
  String get vaseBreaker => '砸罐子';

  @override
  String get zombossMech => '僵王机甲战';

  @override
  String get zombossBattle => '僵王战';

  @override
  String get moveSourceSameAsDest => '源目录和目标目录相同';

  @override
  String get moveSuccess => '移动成功';

  @override
  String get moveFail => '移动失败';

  @override
  String get rootFolder => '根目录';

  @override
  String get createEmptyWave => '添加空波次';

  @override
  String get createEmptyWaveContainer => '创建空波次容器';

  @override
  String get deleteEmptyContainer => '删除空容器';

  @override
  String get deleteWaveContainerTitle => '删除波次容器';

  @override
  String get deleteWaveContainerConfirm => '确定要删除空的波次容器吗？删除后您可以重新创建一个新的容器。';

  @override
  String get noWaveManager => '未找到波次容器';

  @override
  String get noWaveManagerHint =>
      '当前关卡启用了波次管理模块，但缺少存储波次数据的实体对象 (WaveManagerProperties)。请创建一个空波次容器。';

  @override
  String get waveTimelineHint => '点击事件即可编辑，点击“+”添加新事件。';

  @override
  String get waveTimelineHintDetail => '左滑波次可删除。';

  @override
  String get waveTimelineGuideTitle => '操作指引';

  @override
  String get waveTimelineGuideBody => '右滑：管理波次事件\n左滑：删除波次\n点击pt：查看点数出怪期望';

  @override
  String get waveTimelineGuideBodyDesktop =>
      '左键点击波次：管理事件\n点击删除按钮：移除波次\n点击pt：查看点数出怪期望';

  @override
  String get waveTimelineGuideBodyMobile => '右滑：管理波次事件\n左滑：删除波次\n点击pt：查看点数出怪期望';

  @override
  String get waveDeadLinksTitle => '引用失效报警';

  @override
  String get waveDeadLinksClear => '一键清理失效事件';

  @override
  String get customZombieManagerTitle => '自定义僵尸管理';

  @override
  String get customZombieEmpty => '暂无自定义僵尸数据';

  @override
  String get switchCustomZombie => '切换自定义僵尸';

  @override
  String get switchZombie => '切换僵尸';

  @override
  String get customZombieAppearanceLocation => '出现位置：';

  @override
  String get customZombieNotUsed => '此自定义僵尸当前未被任何波次或模块使用。';

  @override
  String customZombieWaveItem(int n) {
    return '第$n波';
  }

  @override
  String get customZombieDeleteConfirm => '将移除僵尸实体及其属性数据。';

  @override
  String get editCustomZombieProperties => '编辑自定义属性数值';

  @override
  String get makeZombieAsCustom => '注入为自定义僵尸';

  @override
  String get customLabel => '自定义';

  @override
  String get waveManagerGlobalParams => '波次管理器全局参数';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return '旗帜间隔: $interval, 刷新血线: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => '当前波次列表为空';

  @override
  String get waveEmptySubtitle => '您可以添加第一个波次，或者删除这个空的容器。';

  @override
  String get waveHeaderPreview => '内容及点数预览';

  @override
  String waveTotalLabel(int total) {
    return '总计: $total';
  }

  @override
  String get waveEmptyRowHint => '空波次 (左右划操作)';

  @override
  String get waveEmptyRowHintDesktop => '空波次 (点击管理)';

  @override
  String get waveEmptyRowHintMobile => '空波次 (左右划操作)';

  @override
  String get removeFromWave => '从波次移除';

  @override
  String get deleteEventEntityTitle => '删除事件实体？';

  @override
  String get deleteEventEntityBody => '这会从关卡中移除该事件对象。';

  @override
  String waveEventsTitle(int wave) {
    return '第 $wave 波事件';
  }

  @override
  String get waveManagerSettings => '波次事件参数配置';

  @override
  String get flagInterval => '旗帜间隔 (FlagWaveInterval)';

  @override
  String get waveManagerHelpTitle => '波次事件容器说明';

  @override
  String get waveManagerHelpOverviewTitle => '简要介绍';

  @override
  String get waveManagerHelpOverviewBody =>
      '波次事件容器用于按波次顺序存放关卡的众多事件，大部分关卡都是通过波次事件进行出怪安排的。这个页面用于调控波次事件容器的全局参数。';

  @override
  String get waveManagerHelpFlagTitle => '旗帜间隔';

  @override
  String get waveManagerHelpFlagBody =>
      '旗帜间隔指每隔多少波会出现一个旗帜波，除此之外每关的最后一波也会是旗帜波。旗帜波享有额外的点数加成和刷新间隔。';

  @override
  String get waveManagerHelpTimeTitle => '时间控制';

  @override
  String get waveManagerHelpTimeBody =>
      '第一波僵尸到来前的时间间隔会随关卡是否有传送带而变化，若有传送带，则从自选卡的12秒变为5秒。旗帜波延迟指的是红字提示到僵尸刷新的间隔。';

  @override
  String get waveManagerHelpMusicTitle => '音乐类型';

  @override
  String get waveManagerHelpMusicBody =>
      '本设置项只适用于摩登世界地图，用于设定一类不可更改的全局背景音乐为摇滚年代的特殊僵尸提供技能。';

  @override
  String get waveManagerBasicParams => '基础参数';

  @override
  String get waveManagerMaxHealthThreshold => '最大刷新血线';

  @override
  String get waveManagerMinHealthThreshold => '最小刷新血线';

  @override
  String get waveManagerThresholdHint =>
      '刷新血线的值必须为 0 到 1 之间的数，一波内自然出现的僵尸总血量低于血线值就会自动刷新下一波';

  @override
  String get waveManagerTimeControl => '时间控制';

  @override
  String get waveManagerFirstWaveDelayConveyor => '首波延迟（传送带）';

  @override
  String get waveManagerFirstWaveDelayNormal => '首波延迟（常规）';

  @override
  String get waveManagerFlagWaveDelay => '旗帜波延迟';

  @override
  String get waveManagerConveyorDetected => '检测到传送带模块，已自动使用传送带延迟';

  @override
  String get waveManagerConveyorNotDetected => '未检测到传送带模块，使用常规延迟';

  @override
  String get waveManagerSpecial => '特殊设置';

  @override
  String get waveManagerSuppressFlagZombieTitle => '屏蔽旗帜僵尸';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint => '开启后，大波次来袭时不会生成带旗帜的领头僵尸';

  @override
  String get waveManagerLevelJam => '背景音乐类型 (LevelJam)';

  @override
  String get waveManagerLevelJamHint => '该设置仅在摩登世界有效，用于为关卡加入不可更改的全局音乐';

  @override
  String get jamNone => '默认/无 (None)';

  @override
  String get jamPop => '流行 (Pop)';

  @override
  String get jamRap => '说唱 (Rap)';

  @override
  String get jamMetal => '重金属 (Metal)';

  @override
  String get jamPunk => '朋克 (Punk)';

  @override
  String get jam8Bit => '8位 (8-bit)';

  @override
  String get noWaves => '暂无波次';

  @override
  String get addFirstWave => '添加第一个波次。';

  @override
  String get deleteWave => '删除';

  @override
  String deleteWaveConfirm(int count) {
    return '将移除此波次及其 $count 个事件。';
  }

  @override
  String get deleteWaveConfirmCheckbox => '我确认永久删除此波次';

  @override
  String get addEvent => '添加事件';

  @override
  String get emptyWave => '空波次';

  @override
  String get addWave => '添加波次';

  @override
  String get expectation => '点数出怪期望';

  @override
  String get close => '关闭';

  @override
  String get editProperties => '编辑属性';

  @override
  String get deleteEntity => '删除实体';

  @override
  String get deleteObjectTitle => '删除对象？';

  @override
  String get deleteObjectConfirmMessage => '从关卡文件中移除此对象？此操作不可撤销。';

  @override
  String get objectDeleted => '对象已删除';

  @override
  String get moduleEditorInProgress => '模块编辑器开发中';

  @override
  String get dataEmpty => '数据为空';

  @override
  String get saveSuccess => '保存成功';

  @override
  String get saveFail => '保存失败';

  @override
  String get confirmRemoveRef => '移除引用';

  @override
  String get confirmRemoveRefMessage =>
      '确定要移除此引用吗？只有当这是该事件的最后一个引用时，才会删除事件实体数据。';

  @override
  String get deleteEventConfirmCheckbox => '我理解此操作无法撤销';

  @override
  String get noZombiesInLane => '该行没有僵尸';

  @override
  String get code => '代码';

  @override
  String get name => '名称';

  @override
  String get description => '关卡描述 (Description)';

  @override
  String get levelNumber => '关卡序号';

  @override
  String get startingSun => '初始阳光';

  @override
  String get stageModule => '关卡地图';

  @override
  String get musicType => '音乐类型';

  @override
  String get loot => '关卡默认掉落';

  @override
  String get victoryModule => '胜利结算方式';

  @override
  String get basicInfoSection => '基础信息';

  @override
  String get sceneSettingsSection => '场景设置';

  @override
  String get restrictionsSection => '限制选项';

  @override
  String get victoryModuleWarning => '使用默认结算方式以外的结算方式可能会因为模块冲突导致关卡闪退，请谨慎使用。';

  @override
  String get hintTextDisplay => '文字显示 (Description)';

  @override
  String get beatTheLevelDialogIntro => '在关卡开头用弹窗显示提示文字。';

  @override
  String get beatTheLevelDialogHint =>
      '支持显示中文，多行文字需直接输入回车，无需使用转义序列，注意iOS端庭院内无法查看提示内容。';

  @override
  String get levelHintText => '关卡提示文字';

  @override
  String get missingModules => '缺失模块';

  @override
  String get moduleConflict => '模块冲突';

  @override
  String get conflictTitle_ModuleLogic => '模块逻辑冲突';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '「$module1」与「$module2」逻辑冲突，建议只保留其中一个。';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      '种子库与传送带模块界面冲突，可能导致崩溃。请确保种子库为预选模式。';

  @override
  String get conflictDesc_VaseBreakerIntro => '砸罐子模式不需要开场动画。';

  @override
  String get conflictDesc_LastStandIntro => '坚不可摧模式不需要开场动画。';

  @override
  String get conflictDesc_EvilDaveZombieDrop => '我是僵尸模式不能使用僵尸掉落模块。';

  @override
  String get conflictDesc_EvilDaveVictory => '我是僵尸模式不能使用僵尸胜利条件。';

  @override
  String get conflictDesc_ZombossDeathDrop => '僵王机甲战中死亡掉落会阻止关卡正常完成。';

  @override
  String get conflictDesc_ZombossBattleDeathDrop => '僵王战中死亡掉落会阻止关卡正常完成。';

  @override
  String get conflictDesc_WinConditionExclusive =>
      '「死亡掉落」与「铜人阵死亡结算」不需要同时添加，建议移除其中一个。';

  @override
  String get conflictDesc_ZombossTwoIntros => '两个开场动画不能共存，否则僵王的血条会显示异常。';

  @override
  String get conflictDesc_InitialPlantEntryRoof => '在屋顶上预置植物会导致关卡闪退。';

  @override
  String get conflictDesc_InitialPlantRoof => '在屋顶上预设植物会导致关卡闪退。';

  @override
  String get conflictDesc_ProtectPlantRoof => '在屋顶上设置保护植物会导致关卡闪退。';

  @override
  String get conflictDesc_LawnMowerYard => '庭院模块中小推车无效。';

  @override
  String get missingPlantModuleWarningTitle => '缺少平行宇宙植物所需模块';

  @override
  String get editableModules => '可用编辑模块';

  @override
  String get parameterModules => '默认参数模块';

  @override
  String get addNewModule => '添加新模块';

  @override
  String get selectStage => '选择地图';

  @override
  String get searchStage => '搜索地图名称或代号';

  @override
  String get noStageFound => '未找到相关地图';

  @override
  String get stageTypeAll => '全部地图';

  @override
  String get stageTypeMain => '主线世界';

  @override
  String get stageTypeExtra => '活动/秘境';

  @override
  String get stageTypeSeasons => '一代/季节';

  @override
  String get stageTypeSpecial => '小游戏';

  @override
  String get search => '搜索';

  @override
  String get disablePeavine => '禁用豆藤共生';

  @override
  String get disableArtifact => '禁用神器（庭院模式下自动生效）';

  @override
  String get selectPlant => '选择植物';

  @override
  String get searchPlant => '搜索植物';

  @override
  String get noPlantFound => '未找到植物';

  @override
  String noResultsFor(Object query) {
    return '没有关于“$query”的结果';
  }

  @override
  String get noModulesInCategory => '该分类下没有模块';

  @override
  String addEventForWave(int wave) {
    return '为第 $wave 波添加事件';
  }

  @override
  String get waveLabel => '波次';

  @override
  String get pointsLabel => '点数';

  @override
  String get noDynamicZombies => '没有动态僵尸';

  @override
  String get moduleTitle_WaveManagerModuleProperties => '波次管理器';

  @override
  String get moduleDesc_WaveManagerModuleProperties => '管理关卡的波次事件总配置';

  @override
  String get moduleTitle_CustomLevelModuleProperties => '庭院模块';

  @override
  String get moduleDesc_CustomLevelModuleProperties => '开启后关卡适配庭院框架，并屏蔽装扮功能';

  @override
  String get powerTileModuleRequiredTitle => '需要能量瓷砖模块';

  @override
  String get powerTileModuleRequiredBody =>
      '添加能量瓷砖工具卡需要关卡中包含能量瓷砖模块。是否添加该模块并继续？';

  @override
  String get conveyorPlantWearCostume => '显示装扮 (iAvatar)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      '启用后该植物在传送带上的卡牌将显示其装扮，该功能在庭院模块下不生效。';

  @override
  String get modifyConveyorAddPoolTitle => '加入传送带池 (Add List)';

  @override
  String get modifyConveyorAddPoolEmpty => '列表为空，请添加植物或工具卡';

  @override
  String get modifyConveyorRemovePoolTitle => '移出传送带池（Remove List; 在庭院模块下不生效）';

  @override
  String get modifyConveyorEntryEditTitle => '编辑具体参数';

  @override
  String get moduleTitle_UnchartedModeNo42UniverseModule => '平行宇宙模块';

  @override
  String get moduleDesc_UnchartedModeNo42UniverseModule => '开启后可以选择平行宇宙植物';

  @override
  String get moduleTitle_PVZ2MausoleumModuleUnchartedMode => '地宫秘境模块';

  @override
  String get moduleDesc_PVZ2MausoleumModuleUnchartedMode => '开启后可以选择地宫秘境植物';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return '要选择此植物，需要添加「$moduleName」模块。';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle => '无法选择植物';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      '秘境专属植物无法在选卡模式下选择。请通过预选模式、传送带、卡片掉落等其他方式使用。';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return '缺少模块「$moduleName」，涉及植物：$plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => '转场动画';

  @override
  String get moduleDesc_StandardLevelIntroProperties => '关卡开始时的镜头平移';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => '失败判定';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties => '僵尸进屋判负的位置';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => '死亡掉落';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties => '关卡稳定运行必需模块';

  @override
  String get moduleTitle_BronzeDeadWinConProperties => '铜人阵死亡结算';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      '当所有铜人像和铜人僵尸被消灭后，立即消灭场上的其他僵尸';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => '蓝鲸出没';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      '配置海底世界鲸鱼相关参数，需要场上有磷虾才有效果';

  @override
  String get spermWhaleModuleTitle => '蓝鲸出没设置';

  @override
  String get spermWhaleModuleHelpTitle => '蓝鲸出没模块说明';

  @override
  String get spermWhaleModuleParameters => '参数';

  @override
  String get spermWhaleModuleHelpOverview => '概述';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      '本模块用于配置特殊海洋生物“鲸鱼”的相关参数，通常用于海底世界关卡。随着磷虾出现，鲸鱼会在场地上方盘旋，并触发对应的红色字幕提示。当场上至少存在三只磷虾时，鲸鱼将正式出现在场地左上角。鲸鱼会优先吞食当前场上的磷虾，随后持续吸取并吞噬植物。噗噗鱼藤释放的鱼藤酮可被鲸鱼吸入，首次吸入后会降低其吞噬速度；当吸入次数达到设定的中毒触发次数后，鲸鱼将强制退场。注意鲸鱼在一关中只会登场一次。';

  @override
  String get spermWhaleModuleHelpFieldsTitle => '参数介绍';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      '吞噬间隔 (SwallowInterval) 指鲸鱼在正常状态下吞噬植物的间隔。\n中毒时吞噬间隔 (PoisonSwallowInterval) 指鲸鱼在吸入一次鱼藤酮后吞噬植物的间隔。\n吞噬持续时间 (SwallowDuration) 指鲸鱼在场上驻留并吸取植物的总时长。\n中毒触发次数 (PoisonTriggerCount) 指迫使鲸鱼退场所需的鱼藤酮吸入次数。';

  @override
  String get spermWhaleModuleSwallowInterval => '吞噬间隔 (SwallowInterval，单位：秒)';

  @override
  String get spermWhaleModuleHelpSwallowInterval => '正常状态下，两次吞噬之间间隔的时间。';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      '中毒时吞噬间隔 (PoisonSwallowInterval，单位：秒)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval => '中毒状态下，两次吞噬之间间隔的时间。';

  @override
  String get spermWhaleModuleSwallowDuration => '吞噬持续时间 (SwallowDuration，单位：秒)';

  @override
  String get spermWhaleModuleHelpSwallowDuration => '鲸鱼在场上驻留并吸取植物的总时长。';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      '中毒触发次数 (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      '噗噗鱼藤的鱼藤酮使鲸鱼强制退场所需的累计吸入次数。';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      '推荐在海底世界地图中使用该模块。以下网格仅反映当前关卡地图的配置情况；在非海底两万里/亚特兰蒂斯地图使用该模块可能会出现不兼容的情况。';

  @override
  String get spermWhaleModuleLawnPreview => '场地预览';

  @override
  String get spermWhaleModuleLawnPreviewHint => '海底世界关卡为6×10，其他关卡为5×9。';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => '阶级定义';

  @override
  String get moduleDesc_PennyClassroomModuleProperties => '全局定义植物阶级，能覆盖其他模块';

  @override
  String get moduleTitle_SeedBankProperties => '种子库';

  @override
  String get moduleDesc_SeedBankProperties => '预设卡槽植物与选卡方式';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => '传送带';

  @override
  String get moduleDesc_ConveyorSeedBankProperties => '预设传送带植物种类与权重';

  @override
  String get moduleTitle_SunDropperProperties => '阳光掉落';

  @override
  String get moduleDesc_SunDropperProperties => '控制天上掉落阳光的频率';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => '阳光上限';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps => '覆盖关卡最大阳光存储值';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps => '初始能量豆';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps => '覆盖关卡开始时的能量豆数量';

  @override
  String get moduleTitle_StarChallengeModuleProperties => '挑战模块';

  @override
  String get moduleDesc_StarChallengeModuleProperties => '设置关卡的限制条件与挑战目标';

  @override
  String get starChallengeNoConfigTitle => '挑战';

  @override
  String get starChallengeNoConfigMessage => '该挑战没有可配置的参数。';

  @override
  String get starChallengeSaveMowersTitle => '不丢车挑战';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      '该挑战没有可配置的参数。\n\n通关时所有小推车必须完好无损，注意庭院模块下默认没有小推车。';

  @override
  String get starChallengePlantFoodNonuseTitle => '禁用能量豆挑战';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      '该挑战没有可配置的参数。\n\n禁止玩家使用能量豆。';

  @override
  String get moduleTitle_LevelScoringModuleProperties => '积分模块';

  @override
  String get moduleDesc_LevelScoringModuleProperties => '启用积分模块，杀死僵尸获得分数';

  @override
  String get moduleTitle_BowlingMinigameProperties => '沙滩保龄球';

  @override
  String get moduleDesc_BowlingMinigameProperties => '设置禁种线以及禁用铲子';

  @override
  String get moduleTitle_NewBowlingMinigameProperties => '坚果保龄球';

  @override
  String get moduleDesc_NewBowlingMinigameProperties => '在固定位置绘制保龄球警戒线';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => '罐子布局';

  @override
  String get moduleDesc_VaseBreakerPresetProperties => '配置罐子的内容，需要另外两个模块支持';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties => '砸罐子模式';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      '开启砸罐子模式的基础环境与UI支持';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => '砸罐子动画';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties => '控制砸罐子关卡开始前罐子掉下来的动画';

  @override
  String get moduleTitle_EvilDaveProperties => '我是僵尸模式';

  @override
  String get moduleDesc_EvilDaveProperties => '启用我是僵尸模式，需配置僵尸卡槽和预置植物';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => '僵王机甲战模式';

  @override
  String get moduleDesc_ZombossBattleModuleProperties => '配置僵王机甲战模式参数以及机甲种类';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => '僵王机甲转场';

  @override
  String get moduleDesc_ZombossBattleIntroProperties => '控制僵王机甲战前的过场动画与血条显示';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties => '僵王战';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      '配置非机甲僵王战（功夫、秦始皇等）';

  @override
  String get moduleTitle_SeedRainProperties => '种子雨';

  @override
  String get moduleDesc_SeedRainProperties => '控制植物、僵尸或能量豆从天而降';

  @override
  String get moduleTitle_LastStandMinigameProperties => '坚不可摧';

  @override
  String get moduleDesc_LastStandMinigameProperties => '设置初始资源，开启布阵阶段';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties => '排山倒海';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties => '植物一种种一列，建议配合传送带使用';

  @override
  String get moduleTitle_SunBombChallengeProperties => '阳光炸弹';

  @override
  String get moduleDesc_SunBombChallengeProperties => '配置阳光炸弹掉落的爆炸范围和伤害';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => '通货膨胀';

  @override
  String get moduleDesc_IncreasedCostModuleProperties => '植物阳光价格随种植次数递增';

  @override
  String get moduleTitle_DeathHoleModuleProperties => '死亡坑洞';

  @override
  String get moduleDesc_DeathHoleModuleProperties => '植物消失后留下不可种植的坑洞';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => '加速进场';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties => '僵尸入场时快速移动一段距离';

  @override
  String get moduleTitle_InitialPlantProperties => '旧版预置植物';

  @override
  String get moduleDesc_InitialPlantProperties => '预置植物传统写法，可放置冰封植物';

  @override
  String get moduleTitle_InitialPlantEntryProperties => '预置植物';

  @override
  String get moduleDesc_InitialPlantEntryProperties => '放置关卡开始时场上已存在的植物';

  @override
  String get frozenPlantPlacementTitle => '初始植物配置';

  @override
  String get frozenPlantPlacementLastStand => '复活之战模式';

  @override
  String get frozenPlantPlacementSelectedPosition => '选中位置';

  @override
  String get frozenPlantPlacementPlaceHere => '在此放置';

  @override
  String get frozenPlantPlacementPlantList => '当前格子中的植物';

  @override
  String frozenPlantPlacementEditPlant(Object name) {
    return '编辑 $name';
  }

  @override
  String get frozenPlantPlacementLevel => '等级';

  @override
  String get frozenPlantPlacementCondition => '初始状态 (Condition)';

  @override
  String get frozenPlantPlacementConditionNull => '无状态 (null)';

  @override
  String get noConditions => '无条件';

  @override
  String get frozenPlantPlacementHelpTitle => '初始植物配置模块说明';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => '简要介绍';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      '此模块用于在关卡开始前配置植物布局，与预置植物布局类似，但结构不同且支持特殊状态。';

  @override
  String get frozenPlantPlacementHelpConditionTitle => '特殊状态';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      '可以为植物设置冰封状态 (icecubed)，常见于冰河世界关卡。';

  @override
  String get frozenPlantPlacementHelpLastStandTitle => '复活之战模式';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      '开启复活之战模式后，初始植物将于开始游戏后被销毁。注意中文版没有销毁植物的火焰效果。';

  @override
  String get save => '保存';

  @override
  String get moduleTitle_InitialZombieProperties => '预置僵尸';

  @override
  String get moduleDesc_InitialZombieProperties => '放置关卡开始时场上已存在的僵尸';

  @override
  String get moduleTitle_InitialGridItemProperties => '预置障碍物';

  @override
  String get moduleDesc_InitialGridItemProperties => '放置关卡开始时场上已存在的障碍物';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties => '保护植物挑战';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties => '设置关卡中必须保护的植物';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties => '保护物品挑战';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      '设置关卡中必须保护且不能被破坏的物品';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => '僵尸药水';

  @override
  String get moduleDesc_ZombiePotionModuleProperties => '配置黑暗时代药水自动生成机制';

  @override
  String get moduleTitle_PiratePlankProperties => '海盗甲板';

  @override
  String get moduleDesc_PiratePlankProperties => '配置海盗港湾地图的甲板行数';

  @override
  String get moduleTitle_RailcartProperties => '矿车轨道';

  @override
  String get moduleDesc_RailcartProperties => '配置矿车与轨道初始布局';

  @override
  String get moduleTitle_PowerTileProperties => '能量瓷砖';

  @override
  String get moduleDesc_PowerTileProperties => '配置能量豆联动效果与瓷砖布局';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => '地下管道';

  @override
  String get moduleDesc_ManholePipelineModuleProperties => '配置蒸汽时代的地下传输管道';

  @override
  String get moduleTitle_RoofProperties => '屋顶花盆';

  @override
  String get moduleDesc_RoofProperties => '配置屋顶关卡的预置花盆列数';

  @override
  String get moduleTitle_TideProperties => '潮水系统';

  @override
  String get moduleDesc_TideProperties => '开启关卡中的潮水系统，需最后添加';

  @override
  String get moduleTitle_BombProperties => '炸药桶';

  @override
  String get moduleDesc_BombProperties => '配置功夫世界炸药桶引线的长度与燃烧速度';

  @override
  String get moduleTitle_BronzeProperties => '铜人像';

  @override
  String get moduleDesc_BronzeProperties => '配置功夫世界的铜人像';

  @override
  String get moduleTitle_ArmrackProperties => '兵器架';

  @override
  String get moduleDesc_ArmrackProperties => '配置场上兵器架显示（仅第一波有效）';

  @override
  String get moduleTitle_EnergyGridProperties => '太极瓷砖';

  @override
  String get moduleDesc_EnergyGridProperties => '配置场上太极瓷砖显示（仅第一波有效）';

  @override
  String get bronzeModuleTitle => '铜人像';

  @override
  String get bronzeModuleHelpTitle => '铜人像';

  @override
  String get bronzeModuleHelpOverview => '简要介绍';

  @override
  String get bronzeModuleHelpOverviewBody =>
      '该模块用于在草坪上放置关卡开始时已存在的铜人像障碍物，常用于功夫世界小游戏“铜人阵”关卡。铜人像会随时间逐渐褪去铜皮，并在设定的倒计时结束后复活为铜人。铜人像的生命值与其对应的一阶铜人相同。\n抖动距离 (shakeOffset) 指复活动画中抖动中心的偏移量，调整该数值无实际意义。\n注意：此模块本身不包含在场上全部铜人像和铜人僵尸被消灭后立即消灭其余僵尸的效果。若需实现该效果，需要添加「铜人阵死亡结算」模块。';

  @override
  String get bronzeModuleHelpBatches => '复活逻辑';

  @override
  String get bronzeModuleHelpBatchesBody =>
      '每添加一个铜人像，关卡文件中就会对应生成一组条目。复活使用条目中填写的复活时间 (spawnTime)，以秒为单位，与关卡波次无关。复活时间相同的铜人会同时复活。后续批次铜人的复活倒计时承接第一批铜人（例如：第一批为30秒，第二批为45秒，第三批为50秒，则第二批会在第一批复活后的15秒复活，第三批会在第二批复活后的5秒复活）。';

  @override
  String get bronzeModuleShakeOffset => '动画效果';

  @override
  String get bronzeModuleShakeOffsetLabel => '抖动距离';

  @override
  String get bronzeModuleInCell => '当前格子中的铜人像';

  @override
  String get bronzeModuleAddTitle => '添加铜人像';

  @override
  String get bronzeKindStrength => '大汉铜人像（strength）';

  @override
  String get bronzeKindMage => '气功铜人像（mage）';

  @override
  String get bronzeKindAgile => '侠客铜人像（agile）';

  @override
  String get bronzeKindStrengthShort => '大汉铜人';

  @override
  String get bronzeKindMageShort => '气功铜人';

  @override
  String get bronzeKindAgileShort => '侠客铜人';

  @override
  String get bronzeModuleTypeLabel => '类型';

  @override
  String get bronzeModuleSpawnTimeLabel => '复活时间（秒）';

  @override
  String get moduleTitle_WarMistProperties => '迷雾系统';

  @override
  String get moduleDesc_WarMistProperties => '设置战场迷雾覆盖范围与交互';

  @override
  String get moduleTitle_RainDarkProperties => '环境天气';

  @override
  String get moduleDesc_RainDarkProperties => '设置关卡的雨雪、雷电等环境特效';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps => '地底出怪';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps => '从地下生成僵尸的出怪事件';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => '普通出怪';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps => '最基础的自然出怪事件';

  @override
  String get eventTitle_FrostWindWaveActionProps => '寒风侵袭';

  @override
  String get eventDesc_FrostWindWaveActionProps => '在指定行吹起寒风冻结植物';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps => '退潮';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps => '僵尸在退潮时浮现突袭';

  @override
  String get eventTitle_TidalChangeWaveActionProps => '潮水变更';

  @override
  String get eventDesc_TidalChangeWaveActionProps => '改变潮水位置';

  @override
  String get eventTitle_TideWaveWaveActionProps => '召唤洋流';

  @override
  String get eventDesc_TideWaveWaveActionProps => '改变潜艇位置并影响僵尸移速';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => '海底出怪';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      '在场地左侧或右侧生成僵尸或海洋生物，只能在海底世界使用';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => '传送带修改';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps => '动态添加或移除传送带上的卡片';

  @override
  String get eventTitle_DinoWaveActionProps => '恐龙召唤';

  @override
  String get eventDesc_DinoWaveActionProps => '在指定行召唤一只恐龙协助僵尸';

  @override
  String get eventTitle_DinoTreadActionProps => '恐龙践踏';

  @override
  String get eventDesc_DinoTreadActionProps => '雷龙在一定区域践踏造成伤害';

  @override
  String get eventTitle_DinoRunActionProps => '龙潮突袭';

  @override
  String get eventDesc_DinoRunActionProps => '恐龙沿行冲锋，踩死沿途的植物或僵尸';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps => '时空裂缝';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps => '在指定位置召唤时空裂缝';

  @override
  String get eventTitle_StormZombieSpawnerProps => '风暴突袭';

  @override
  String get eventDesc_StormZombieSpawnerProps => '沙尘暴或暴风雪运送僵尸';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => '海盗登船';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps => '生成若干个飞索僵尸的事件';

  @override
  String get eventTitle_ZombiePotionActionProps => '投放药水';

  @override
  String get eventDesc_ZombiePotionActionProps => '在场地固定位置强行生成障碍物';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => '贝壳生成';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps => '在指定位置生成海底贝壳';

  @override
  String get eventTitle_PumpkinHouseActionProps => '南瓜屋生成';

  @override
  String get eventDesc_PumpkinHouseActionProps => '在指定位置生成南瓜屋';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => '障碍物生成';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps => '在场地的空位处生成障碍物';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps => '障碍物出怪';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps => '从指定的障碍物种类生成僵尸';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => '魔力迷雾';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps => '生成覆盖场地、给僵尸提供护盾的迷雾';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => '童话微风';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps => '把场上所有魔力迷雾吹走的风';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps => '小鬼空降';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps => '小鬼僵尸从天而降';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => '降落伞空降';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps => '僵尸依靠降落伞从天而降';

  @override
  String get eventTitle_BassRainZombieSpawnerProps => '贝斯手/喷射器空降';

  @override
  String get eventDesc_BassRainZombieSpawnerProps => '贝斯手或喷射器僵尸从天而降';

  @override
  String get eventTitle_BlackHoleWaveActionProps => '黑洞吸引';

  @override
  String get eventDesc_BlackHoleWaveActionProps => '生成黑洞吸引所有植物';

  @override
  String get eventTitle_BarrelWaveActionProps => '滚桶危机';

  @override
  String get eventDesc_BarrelWaveActionProps => '在指定行生成具有不同能力的滚桶';

  @override
  String get eventTitle_SchoolBusWaveActionProps => '冰淇淋车生成';

  @override
  String get eventDesc_SchoolBusWaveActionProps => '在指定行生成冰淇淋车，并配置车内僵尸';

  @override
  String get eventTitle_BungeeWaveActionProps => '蹦极投放';

  @override
  String get eventDesc_BungeeWaveActionProps => '由蹦极僵尸投放一只僵尸到场内';

  @override
  String get eventTitle_ThunderWaveActionProps => '雷云风暴';

  @override
  String get eventDesc_ThunderWaveActionProps => '天降闪电，为植物施加正负电荷状态';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => '魔镜传送';

  @override
  String get eventDesc_MagicMirrorWaveActionProps => '在指定位置生成成对的传送门';

  @override
  String get weatherOption_DefaultSnow_label => '冰河飞雪 (DefaultSnow)';

  @override
  String get weatherOption_DefaultSnow_desc => '冰河再临秘境的下雪效果';

  @override
  String get weatherOption_LightningRain_label => '雷雨天气 (LightningRain)';

  @override
  String get weatherOption_LightningRain_desc => '带闪电的下雨效果';

  @override
  String get weatherOption_DefaultRainDark_label => '阴雨天气 (DefaultRainDark)';

  @override
  String get weatherOption_DefaultRainDark_desc => '场上会进入持续较长时间的黑暗状态';

  @override
  String get iZombiePlantReserveLabel => '植物预留列（PlantDistance）';

  @override
  String get column => '列';

  @override
  String get iZombieInfoText => '我是僵尸模式下的预置植物和僵尸选择分别要在关卡模块里的预置植物和种子库里设置。';

  @override
  String get vaseRangeTitle => '罐子生成范围与禁用格点';

  @override
  String get startColumnLabel => '起始列 (Min)';

  @override
  String get endColumnLabel => '结束列 (Max)';

  @override
  String get toggleBlacklistHint => '点击格子可切换禁用状态（禁用点将不生成罐子）';

  @override
  String get vaseCapacityTitle => '罐子容量';

  @override
  String vaseCapacitySummary(Object current, Object total) {
    return '已配置：$current / 有效容量：$total';
  }

  @override
  String get vaseListTitle => '罐子列表';

  @override
  String get addVaseTitle => '添加罐子';

  @override
  String get plantVaseOption => '植物罐子 (绿罐)';

  @override
  String get zombieVaseOption => '僵尸罐子 (紫罐)';

  @override
  String get selectZombie => '选择僵尸';

  @override
  String get searchZombie => '搜索僵尸';

  @override
  String get noZombieFound => '未找到僵尸';

  @override
  String get unknownVaseLabel => '未知罐子';

  @override
  String get plantLabel => '植物 (Plant)';

  @override
  String get zombieLabel => '僵尸 (Zombie)';

  @override
  String get itemLabel => '物品 (Collectable)';

  @override
  String get railcartSettings => '矿车轨道设置';

  @override
  String get railcartType => '矿车类型 (RailcartType)';

  @override
  String get layRails => '铺设轨道';

  @override
  String get placeCarts => '放置矿车';

  @override
  String get railSegments => '轨道段数';

  @override
  String get railcartCount => '矿车数量';

  @override
  String get clearAll => '清空所有配置';

  @override
  String get moduleCategoryBase => '基础功能';

  @override
  String get moduleCategoryMode => '特殊模式';

  @override
  String get moduleCategoryScene => '场地配置';

  @override
  String get moduleCategoryGimmick => '特殊机制';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties => '划走火箭筒';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      '允许在关卡内使用手指划过火箭筒，将火箭筒小鬼僵尸的火箭筒划飞';

  @override
  String get kongfuRocketFlickDialogTitle => '发现可添加模块';

  @override
  String get kongfuRocketFlickDialogMessage =>
      '添加「划走火箭筒」模块后，可划动屏幕，将小鬼僵尸从火箭筒上拨落。是否添加？';

  @override
  String get customZombie => '自定义僵尸';

  @override
  String get customZombieProperties => '自定义僵尸通用属性';

  @override
  String get zombieTypeNotFound => '未找到僵尸类型对象';

  @override
  String get propertyObjectNotFound => '未找到属性对象';

  @override
  String propertyObjectNotFoundHint(Object alias) {
    return '自定义僵尸的属性对象（$alias）在关卡中未找到。属性定义未指向关卡内部，因此无法在此编辑。';
  }

  @override
  String get baseStats => '基础数值';

  @override
  String get hitpoints => '生命值 (Hitpoints)';

  @override
  String get speed => '移动速度 (Speed)';

  @override
  String get speedVariance => '移速方差 (Variance)';

  @override
  String get eatDPS => '啃食伤害 (EatDPS)';

  @override
  String get hitPosition => '判定与位置参数';

  @override
  String get hitRect => '受击判定 (HitRect)';

  @override
  String get editHitRect => '编辑受击判定 (HitRect)';

  @override
  String get attackRect => '攻击判定 (AttackRect)';

  @override
  String get editAttackRect => '编辑攻击判定 (AttackRect)';

  @override
  String get artCenter => '贴图中心 (ArtCenter)';

  @override
  String get editArtCenter => '编辑贴图中心 (ArtCenter)';

  @override
  String get shadowOffset => '阴影偏移 (ShadowOffSet)';

  @override
  String get editShadowOffset => '编辑阴影偏移 (ShadowOffSet)';

  @override
  String get groundTrackName => '行进轨迹 (GroundTrackName)';

  @override
  String get groundTrackNormal => '普通地面 (ground_swatch)';

  @override
  String get groundTrackNone => '无 (null)';

  @override
  String get appearanceBehavior => '外观与行为设置';

  @override
  String get sizeType => '体型大小 (SizeType)';

  @override
  String get selectSize => '选择体型';

  @override
  String get disableDropFractions => '关闭临界值 (headDropFraction)';

  @override
  String get immuneToKnockback => '免疫植物击退 (CanBeLaunchedByPlants)';

  @override
  String get showHealthBarOnDamage => '受伤显示血条 (EnableShowHealthBar)';

  @override
  String get drawHealthBarTime => '血条显示时长 (DrawHealthBarTime)';

  @override
  String get enableEliteScale => '启用精英缩放 (EnableEliteScale)';

  @override
  String get eliteScale => '缩放比例 (EliteScale)';

  @override
  String get enableEliteImmunities => '启用精英免疫 (EnableEliteImmunities)';

  @override
  String get canSpawnPlantFood => '能否携带能量豆 (CanSpawnPlantFood)';

  @override
  String get canSurrender => '可在游戏结束时投降 (CanSurrender)';

  @override
  String get canTriggerZombieWin => '可食脑判负 (CanTriggerZombieWin)';

  @override
  String get resilience => '僵尸抗性设置 (Resistences)';

  @override
  String get resilienceArmor => '韧性条 (Resilience)';

  @override
  String get enableResilience => '启用韧性';

  @override
  String get resilienceSource => '来源';

  @override
  String get resiliencePreset => '预设韧性条';

  @override
  String get resilienceCustom => '自定义韧性条';

  @override
  String get resiliencePresetSelect => '选择预设韧性条';

  @override
  String get resilienceAmount => '韧性条数值 (Amount)';

  @override
  String get resilienceWeakType => '韧性条类型 (WeakType)';

  @override
  String get resilienceRecoverSpeed => '韧性条恢复速度 (RecoverSpeed)';

  @override
  String get resilienceDamageThresholdPerSecond =>
      '僵尸每秒承伤上限 (DamageThresholdPerSecond)';

  @override
  String get resilienceBaseDamageThreshold =>
      '韧性条基础伤害上限 (ResilienceBaseDamageThreshold)';

  @override
  String get resilienceExtraDamageThreshold =>
      '韧性条额外伤害上限 (ResilienceExtraDamageThreshold)';

  @override
  String get resilienceCodename => '韧性条代码名 (aliases)';

  @override
  String get resilienceCodenameHint => '例如： CustomResilience0';

  @override
  String get resistances => '抗性';

  @override
  String get zombieResilience => '韧性条';

  @override
  String get resilienceEnable => '启用韧性条';

  @override
  String get weakTypeExplosive => '爆炸 (Explosive)';

  @override
  String get instantKillResistance => '即死抗性（受到秒杀攻击的免疫概率）';

  @override
  String get resiliencePhysics => '物理 (Physics)';

  @override
  String get resiliencePoison => '毒液 (Poison)';

  @override
  String get resilienceElectric => '电能 (Electric)';

  @override
  String get resilienceMagic => '魔法 (Magic)';

  @override
  String get resilienceIce => '寒冰 (Ice)';

  @override
  String get resilienceFire => '火焰 (Fire)';

  @override
  String get resilienceHint => '数值范围0.0-1.0，0.0表示无影响，1.0表示完全免疫';

  @override
  String zombieTypeLabel(Object type) {
    return '僵尸所属种类：$type';
  }

  @override
  String propertyAliasLabel(Object alias) {
    return '属性链接代号：$alias';
  }

  @override
  String get ok => '确定';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get customZombieHelpIntro => '简要介绍';

  @override
  String get customZombieHelpIntroBody =>
      '这里通过关卡内注入自定义的方式，修改僵尸数据的主要参数。不同种僵尸所含有的特殊属性非常多，软件只对一些通用的属性提供修改。';

  @override
  String get customZombieHelpBase => '基础属性';

  @override
  String get customZombieHelpBaseBody =>
      '自定义僵尸可以自由修改其基础属性，包括血量、移动速度和啃食伤害等。自定义的僵尸不会出现在关卡预览池中。';

  @override
  String get customZombieHelpHit => '部分功能介绍';

  @override
  String get customZombieHelpHitBody =>
      '判定部分中X和Y表示偏移量；W和H分别表示宽度和高度。通过偏移僵尸的贴图中心可以实现隐藏僵尸。在行进轨迹部分选择留空可以让僵尸原地行走。';

  @override
  String get customZombieHelpManual => '手动修改';

  @override
  String get customZombieHelpManualBody =>
      '软件实现自定义注入时会从对应的游戏文件中自动填入原僵尸的所有属性，可以在此基础上手动修改JSON文件。';

  @override
  String editAlias(Object alias) {
    return '编辑 $alias';
  }

  @override
  String get aliasLabel => '别名';

  @override
  String get add => '添加';

  @override
  String get overview => '简要介绍';

  @override
  String get left => '左';

  @override
  String get right => '右';

  @override
  String get weight => '权重';

  @override
  String get maxCount => '最大数量';

  @override
  String get startColumn => '起始列 (Start)';

  @override
  String get endColumn => '结束列 (End)';

  @override
  String get removeItem => '移除物品';

  @override
  String removeItemConfirm(Object name) {
    return '确定要移除$name吗？';
  }

  @override
  String groupN(int n) {
    return '第$n组';
  }

  @override
  String rowN(int n) {
    return '第$n行';
  }

  @override
  String get addItem => '添加物品';

  @override
  String get addWind => '添加寒风';

  @override
  String get addDropItem => '添加掉落物品';

  @override
  String get addMirrorGroup => '在上方添加一组魔镜';

  @override
  String pipeN(int n) {
    return '管道$n';
  }

  @override
  String get setStart => '放置起点（入口）';

  @override
  String get setEnd => '放置终点（出口）';

  @override
  String get collectable => '道具（能量豆）';

  @override
  String get selectGridItem => '选择障碍物';

  @override
  String get addItemTitle => '添加障碍物';

  @override
  String get initialPlantLayout => '初始植物布局';

  @override
  String get gridItemLayout => '场地物品布局';

  @override
  String get zombieCount => '总数量 (Total)';

  @override
  String get groupSize => '每批数量 (GroupSize)';

  @override
  String get timeBetweenGroups => '批次间隔 (TimeBetweenGroups)';

  @override
  String get timeBeforeSpawn => '完全生成前摇时间（秒）';

  @override
  String get waterBoundaryColumn => '变更位置 (ChangeAmount)';

  @override
  String get columnsDragged => '拖拽列数 (ColNumPlantIsDragged)';

  @override
  String get typeIndex => '镜子外观 (TypeIndex)';

  @override
  String get noStyle => '无样式';

  @override
  String styleN(int n) {
    return '样式$n';
  }

  @override
  String get existDurationSec => '存在持续时间（秒）';

  @override
  String get mirror1 => '放置镜子 1';

  @override
  String get mirror2 => '放置镜子 2';

  @override
  String get ignoreGravestone => '无视墓碑 (IgnoreGraveStone)';

  @override
  String zombiePreview(Object name) {
    return '$name - 僵尸预览';
  }

  @override
  String get weatherSettings => '环境天气设置';

  @override
  String get holeLifetimeSeconds => '坑洞存在时间（秒）';

  @override
  String get startingWaveLocation => '初始潮水位置 (StartingWaveLocation)';

  @override
  String get rainIntervalSeconds => '掉落间隔（秒）';

  @override
  String get startingPlantFood => '初始能量豆';

  @override
  String get bowlingFoulLine => '禁种线';

  @override
  String get bowlingMinigameParams => '参数';

  @override
  String get bowlingMinigameHelpOverview => '设置沙滩保龄球模式中禁止种植植物的列位置。';

  @override
  String get bowlingMinigameHelpFoulLine =>
      'BowlingFoulLine 为从左起算的列索引（从 0 开始）。该列及其右侧不可种植植物。';

  @override
  String get stopColumn => '停止列 (StopColumn，范围0-9或0-10)';

  @override
  String get speedUp => '加速倍率 (SpeedUp)';

  @override
  String get baseCostIncreased => '每次增加阳光消耗 (BaseCostIncreased)';

  @override
  String get maxIncreasedCount => '最大增长次数 (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => '迷雾起始列';

  @override
  String get normalValueX => '往右延伸距离（1格为64单位）';

  @override
  String get bloverEffectInterval => '三叶草吹散后恢复秒数';

  @override
  String get dinoType => '恐龙种类';

  @override
  String get dinoRowTitle => '所在行';

  @override
  String dinoRow(int n) {
    return '所在行：$n';
  }

  @override
  String get dinoWaveDuration => '停留波次';

  @override
  String get eventHelpDinoType => '选择进入场地的恐龙种类，不同恐龙协助僵尸的方式不同。';

  @override
  String get eventHelpDinoRow => '恐龙出现的行（从 0 开始）。海底地图可使用第 5 行。';

  @override
  String get eventHelpDinoWaveDuration => '恐龙在场上停留的波次数，结束后离开。';

  @override
  String get unknownModuleTitle => '模块编辑器开发中';

  @override
  String get unknownModuleHelpTitle => '未解析模块';

  @override
  String get unknownModuleHelpBody => '该模块暂时未注册到关卡解释器，暂无可用编辑器。';

  @override
  String get noEditorForModule => '该模块暂无可用编辑器';

  @override
  String get noEditorForModuleBody =>
      '该模块未注册到关卡解释器，暂无可用编辑器。也有可能是手动修改了模块的objclass导致无法正常读取。';

  @override
  String get invalidEventTitle => '无效事件';

  @override
  String get invalidEventBody => '此事件对象无法解析。';

  @override
  String get invalidReference => '引用失效提示';

  @override
  String aliasNotFound(Object alias) {
    return '代号\"$alias\"找不到实体';
  }

  @override
  String invalidRefBody(int wave) {
    return '在第$wave波中引用了此事件，但在关卡中未找到对应的实体定义，这通常是因为对象被误删或手动改名导致的。将其存留在关卡中会导致游戏闪退。';
  }

  @override
  String get removeInvalidRef => '从波次容器中移除此无效引用';

  @override
  String get spawnCount => '生成数量控制';

  @override
  String get columnRangeTiming => '位置与时间参数';

  @override
  String get waveStartMessage => '红色字幕警告信息';

  @override
  String get zombieTypeZombieName => '突袭单位配置';

  @override
  String get optional => '事件开始时在屏幕中央显示，不支持输入中文';

  @override
  String get eventHelpBeachStageBody =>
      '僵尸会从水下浮现。通常用于巨浪沙滩的潜水僵尸，或者需要在低潮期出现的僵尸。\n与空降事件类似，僵尸会分批次出现。可以指定总数量和出现范围。\n在单个事件中只能出现一种僵尸，若想实现多种僵尸出现需要额外添加若干次事件。';

  @override
  String get eventHelpTidalChangeBody => '本事件用于在波次中改变潮水位置。潮水的更改范围不能超出场地。';

  @override
  String get eventTideWave => '事件类型：召唤洋流';

  @override
  String get eventHelpTideWaveBody => '生成推动潜艇、为僵尸提供移速加成的洋流，常用于海底世界第一章-海底两万里关卡。';

  @override
  String get tideWaveHelpType => '类型说明';

  @override
  String get eventHelpTideWaveType =>
      '左方：洋流从潜艇左侧袭来，向右推动潜艇，并增加左侧僵尸的移动速度.\n右方：洋流从潜艇右侧袭来，向左推动潜艇，并增加右侧僵尸的移动速度。';

  @override
  String get tideWaveHelpParams => '注意事项';

  @override
  String get eventHelpTideWaveParams =>
      '除特殊情况外，持续时间结束后，潜艇会自动回到原位。在潜艇移动时，不能在潜艇上种植植物。';

  @override
  String get tideWaveType => '类型 (Type)';

  @override
  String get tideWaveTypeLeft => '左方 (left)';

  @override
  String get tideWaveTypeRight => '右方 (right)';

  @override
  String get tideWaveDuration => '洋流持续时间 (Duration)';

  @override
  String get tideWaveSubmarineMovingDistance =>
      '潜艇被推动列数 (SubmarineMovingDistance)';

  @override
  String get tideWaveSpeedUpDuration => '僵尸加速持续时间 (秒)';

  @override
  String get tideWaveSpeedUpIncreased => '僵尸移动速度加成 (SpeedUpIncreased)';

  @override
  String get tideWaveSubmarineMovingTime => '潜艇被推动时间 (秒)';

  @override
  String get tideWaveZombieMovingSpeed =>
      '僵尸洋流中移动速度 (ZombieMovingSpeed，1格为64单位)';

  @override
  String get eventZombieFishWave => '事件类型：海底出怪';

  @override
  String get eventHelpZombieFishWaveBody =>
      '本事件用于配置双面夹击的僵尸与海洋生物，只能用于海底世界关卡。坐标中的行、列均从 0 开始计数，因此第 1 行对应 0，第 10 列对应 9。';

  @override
  String get eventHelpZombieFishWaveFish =>
      '使用“添加海洋生物属性”按钮在场地上放置深海鱼群。场地大小因关卡而异，海底世界关卡为 6×10，其他关卡为 5×9。坐标中行对应 Y，列对应 X。';

  @override
  String get eventHelpBatchLevel => '将本波次所有僵尸设为指定等级（精英僵尸不受影响，保持默认等级）。';

  @override
  String get eventHelpDropConfig => '当掉落植物列表的植物数等于能量豆数量时会变为掉落植物卡片。';

  @override
  String get fishPropertiesEntryHelp =>
      '点击选中网格后可以添加海洋生物。点击“+”可添加内置海洋生物。点击海洋生物图标可进行复制、删除、自定义等更多操作，自定义的海洋生物会显示蓝色的“C”角标。海洋生物放置在场地外会显示警告。';

  @override
  String get fishAddCustom => '添加自定义海洋生物';

  @override
  String get addFishLabel => '添加海洋生物';

  @override
  String get addBuiltInFishLabel => '添加内置海洋生物';

  @override
  String get makeFishAsCustom => '设为自定义';

  @override
  String get switchCustomFish => '切换自定义海洋生物';

  @override
  String get selectCustomFish => '选择自定义海洋生物';

  @override
  String get editCustomFishProperties => '编辑自定义海洋生物属性';

  @override
  String get fishPropertiesButton => '海洋生物属性';

  @override
  String get addFishProperties => '添加海洋生物属性';

  @override
  String get editFishProperties => '编辑海洋生物属性';

  @override
  String get fishPropertiesGrid => '海洋生物放置';

  @override
  String get fishSelectedPosition => '已选：';

  @override
  String get fishRow => '行';

  @override
  String get fishColumn => '列';

  @override
  String get fishAtPosition => '当前格子中的海洋生物';

  @override
  String get searchFish => '搜索海洋生物';

  @override
  String get noFishFound => '未找到海洋生物';

  @override
  String get customFishManagerTitle => '自定义海洋生物管理';

  @override
  String get customFishAppearanceLocation => '出现位置：';

  @override
  String get customFishNotUsed => '此自定义海洋生物未被任何波次使用。';

  @override
  String customFishWaveItem(int n) {
    return '第$n波';
  }

  @override
  String get customFishDeleteConfirm => '确定要移除此自定义海洋生物及其属性数据？';

  @override
  String get customFish => '自定义海洋生物说明';

  @override
  String get customFishProperties => '自定义海洋生物属性';

  @override
  String get fishTypeNotFound => '未找到海洋生物对象。';

  @override
  String fishTypeLabel(Object type) {
    return '海洋生物：$type';
  }

  @override
  String get customFishHelpIntro => '简要介绍';

  @override
  String get customFishHelpIntroBody =>
      '本界面用于修改自定义海洋生物的参数。软件仅支持对常用属性进行修改，修改动画和特殊属性需手动编辑JSON文件。';

  @override
  String get customFishHelpProps => '属性介绍';

  @override
  String get customFishHelpPropsBody =>
      'HitRect、AttackRect、ScareRect 定义海洋生物的碰撞区域。Speed 和 ScareSpeed 控制海洋生物的移动速度。ArtCenter 为海洋生物的贴图中心。';

  @override
  String get noEditableFishProps => '未找到可编辑属性。';

  @override
  String get fishPropSpeed => '速度 (Speed)';

  @override
  String get fishPropScareSpeed => '受惊后速度 (ScareSpeed)';

  @override
  String get fishPropDamage => '伤害 (Damage)';

  @override
  String get fishPropHitpoints => '生命值 (Hitpoints)';

  @override
  String get fishPropHitPoints => '生命值 (HitPoints)';

  @override
  String get fishPropHitRect => '受击判定 (HitRect)';

  @override
  String get fishPropAttackRect => '攻击判定 (AttackRect)';

  @override
  String get fishPropScareRect => '受惊判定 (ScareRect)';

  @override
  String get fishPropScarerect => '受惊区域 (Scarerect)';

  @override
  String get fishPropArtCenter => '贴图中心 (ArtCenter)';

  @override
  String get edit => '编辑';

  @override
  String get eventHelpTidalChangePosition =>
      '可以指定潮水变更后的位置。场地最右边为0，最左边为9。允许输入负数在内的整数。';

  @override
  String get eventHelpBlackHoleBody => '常见于功夫世界的事件，时空黑洞会随事件生成，将所有植物向右吸动。';

  @override
  String get eventHelpBlackHoleColumns => '可以输入植物被吸引拖拽的列数，表示植物会受黑洞影响向右移多少格。';

  @override
  String get eventHelpMagicMirrorBody =>
      '魔镜事件会在场地上生成成对的传送门。每对传送门包含入口和出口，二者外观相同。';

  @override
  String get eventHelpMagicMirrorType => '可以更改镜子的外观样式用于区分，该事件中共有3种不同形态的魔镜。';

  @override
  String get eventHelpParachuteRainBody =>
      '僵尸会从屏幕上方空降突袭，通常用于未来世界的机器虫小鬼僵尸、失落之城的飞行员僵尸、摇滚年代的贝斯手僵尸、Z公司的技术支持僵尸等。僵尸的阶级随地图阶级序列。';

  @override
  String get eventHelpParachuteRainLogic =>
      '事件触发后，僵尸会分批次从天而降。可以控制总数量和每批次之间的时间间隔。僵尸会随机降落在选择的列数。若到达了下落总前摇时间，剩下的僵尸会立即出现。\n事件出现前会出现红色字幕显示，在字幕中输入中文会显示乱码。可以不设置僵尸让这个事件变为纯粹的字幕显示。';

  @override
  String get eventHelpModernPortalsBody => '在场地上刷新出固定种类的时空裂缝，常见于摩登世界和回忆之旅。';

  @override
  String get eventHelpModernPortalsType => '游戏内有非常多种裂缝类型，可以在此选择具体的裂缝种类，预览出怪。';

  @override
  String get eventHelpModernPortalsIgnore => '开启此开关后，裂缝不会因为被墓碑冲浪板等障碍物挡住而不生成。';

  @override
  String get eventHelpFrostWindBody =>
      '常见于冰河世界的事件，在指定行生成寒风，寒风会携带冰冻效果，将植物冻结成冰块。';

  @override
  String get eventHelpFrostWindDirection =>
      '可以设置寒风来袭的方向（从左或从右）。注意每一次寒风之间会有一定间隔，若想要实现寒风同时出现，可以尝试添加多个寒风事件。';

  @override
  String get eventHelpModifyConveyorBody =>
      '这个事件可以在游戏运行过程中更改传送带的配置情况，具体参数和传送带模块基本一致，请确保关卡中已经加入了传送带模块。';

  @override
  String get eventHelpModifyConveyorAdd =>
      '可以把新植物或工具卡加入传送带。如果传送带上已经有该植物或工具卡，会把之前的数据覆盖掉。';

  @override
  String get eventHelpModifyConveyorRemove =>
      '移除功能在庭院模板下不生效，需要通过将植物权重强行设置为0来替代此效果。';

  @override
  String get eventHelpDinoBody =>
      '常见于恐龙危机的事件，在指定行召唤一只指定的恐龙进入场地，恐龙会协助僵尸进攻。\n一个事件只能配置一只恐龙，若需要同时出现多只恐龙需要在波次内添加多个恐龙召唤事件。';

  @override
  String get eventHelpDinoDuration =>
      '恐龙在场上停留的时间，单位为波次。时间结束或与足够量的僵尸互动后恐龙会离开场地。';

  @override
  String get eventDinoTread => '事件类型：恐龙践踏';

  @override
  String get eventDinoRun => '事件类型：龙潮突袭';

  @override
  String get eventHelpDinoTreadBody =>
      '雷龙的脚移动到指定区域内，并在数秒后落下，对范围内所有植物和僵尸造成伤害，留下一个持续约 7 秒的脚印，期间无法在该区域种植。';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY 表示行，GridXMin/GridXMax 表示列范围，行和列均从0开始计数。海底世界地图的范围为：行0–5，列0–9。';

  @override
  String get dinoTreadRowLabel => '行 (GridY)';

  @override
  String get dinoTreadColMinLabel => '最左列 (GridXMin)';

  @override
  String get dinoTreadColMaxLabel => '最右列 (GridXMax)';

  @override
  String get dinoTreadTimeIntervalLabel => '登场间隔 (秒)';

  @override
  String get columnStartLabel => '起始列 (ColumnStart)';

  @override
  String get columnEndLabel => '结束列 (ColumnEnd)';

  @override
  String get eventHelpDinoRunBody =>
      '触发该事件时，会在2－3行的范围内聚集起恐龙。这些恐龙不会发动能力，而是直接向场内发起冲锋，踩死植物或僵尸。不同的恐龙可以踩死的植物或僵尸数目不同。';

  @override
  String get eventHelpDinoRunRow => 'DinoRow表示龙潮中心的行数，从0开始计数。在海底世界地图中，该值可设置为5。';

  @override
  String get positionAndArea => '位置与区域';

  @override
  String get positionAndDuration => '位置与持续时间';

  @override
  String get rowCol0Index => '行/列（从0开始计数）';

  @override
  String get timeInterval => '时间间隔';

  @override
  String get eventHelpZombiePotionBody =>
      '此事件可以在场地上强行生成药水，能无视植物，可以作为障碍物生成事件的替代。';

  @override
  String get eventHelpZombiePotionUsage =>
      '与障碍物生成的预选池不同，这个事件能精准地在固定格点强行生成障碍物并挤走植物。\n注意在部分缺少墓碑出土特效的地图可能会出现阳光贴图的情况，请谨慎使用此事件。';

  @override
  String get eventHelpShellBody =>
      '此事件可以在指定位置生成海底贝壳。贝壳初始为闭合状态，有僵尸踩中贝壳时，贝壳会张开，将僵尸向前弹射，并在10秒后重新闭合。张开状态下的贝壳可被植物攻击，阻挡平射子弹。每次张开，生成一个随机物品，包括能量豆、鱿鱼、植物卡片或遗迹小鬼僵尸。若3次被僵尸触发，贝壳会游向植物卡槽处，将随机一个卡槽替换为贝壳卡槽。将贝壳种植到场上3次后，卡槽会恢复原植物。';

  @override
  String get eventHelpShellUsage =>
      '选中格子后，点击“+”放置贝壳。场地大小因关卡地图而异，共有5×9和6×10两种规格。';

  @override
  String get eventHelpPumpkinHouseBody =>
      '此事件可在指定位置生成南瓜屋。经过南瓜屋的僵尸将会变为南瓜屋幽灵僵尸。南瓜屋幽灵僵尸有独立的血量，只能被抛投类植物攻击，血量归零时恢复原僵尸。南瓜屋本身也有一定血量，可以被集火打爆。';

  @override
  String get eventHelpPumpkinHouseUsage =>
      '选中格子后，点击“+”放置南瓜屋。场地大小因关卡地图而异，共有5×9和6×10两种规格。';

  @override
  String get eventHelpFairyFogBody =>
      '本事件用于生成覆盖场地、给僵尸提供护盾的魔力迷雾，常用于童话森林关卡，只有微风事件才能吹散。\n迷雾等级越高，僵尸获得的护盾及免控效果越强。等级从低到高依次为白色、蓝色、紫色。';

  @override
  String get eventHelpFairyFogRange =>
      'mX和mY 为计算中心点，mWidth和mHeight分别表示含中心点向右和向下延伸的距离。';

  @override
  String get eventHelpFairyWindBody => '本事件会产生一股持续的微风，用于将魔力迷雾吹散，常见于童话森林。';

  @override
  String get eventHelpFairyWindVelocity =>
      '该事件作用时可以改变抛射物的速度。1.0表示原速，数值越大子弹运动越快。';

  @override
  String get eventHelpRaidingPartyBody =>
      '常见于海盗港湾的事件，能分批依次生成若干只飞索僵尸进攻。组间间隔 (TimeBetweenGroups) 指两批突袭之间的时间间隔。';

  @override
  String get eventHelpRaidingPartyGroup => '每一组所包含的僵尸数量。';

  @override
  String get eventHelpRaidingPartyCount => '该事件总共生成的僵尸数量。';

  @override
  String get eventHelpGravestoneBody => '此事件用于在波次进行中随机生成障碍物，例如黑暗时代的生成墓碑事件。';

  @override
  String get eventHelpGravestoneLogic =>
      '该事件从上面的格子中随机选取可使用的格子生成目标障碍物。障碍物数量总和不能超过上方位置池的坐标总数，否则多余的物品将无法生成。';

  @override
  String get eventHelpGravestoneMissingAssets =>
      '在部分缺少墓碑出土特效的地图可能会出现阳光贴图的情况，请谨慎使用此事件。';

  @override
  String get eventHelpBarrelWaveBody =>
      '本事件用于生成回忆之旅机制“滚桶危机”中的三种滚桶。滚桶会从场地右侧滚入，碾压沿途的所有植物。';

  @override
  String get barrelWaveHelpTypes => '滚桶类型';

  @override
  String get eventHelpBarrelWaveTypes =>
      '空桶：击破后无事发生。\n小鬼桶：击破后会从中钻出僵尸。僵尸种类可以自行选择，通常为小鬼。\n炸药桶：接触到植物或被击破时会爆炸，对周围 3×3 范围内的植物和僵尸造成伤害。';

  @override
  String get barrelWaveHelpRows => '行数说明';

  @override
  String get eventHelpBarrelWaveRows =>
      '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。标准地图共有5行，海底世界地图共有6行。';

  @override
  String get eventHelpSchoolBusBody =>
      '此事件用于在指定行生成冰淇淋车。冰淇淋车载着僵尸从右侧缓慢驶入，占据两行。前进路径上被车体碾压到的植物会被直接摧毁。\n若冰淇淋车贴图显示搭乘的是泡泡枪小鬼僵尸和棒棒糖僵尸（即类型为 schoolbus_special），则会在前进过程中持续释放对应僵尸的技能。\n地刺、钢地刺等植物可以扎破冰淇淋车的轮胎。轮胎破裂后，冰淇淋车会逐渐减速并进入滑行状态，一段时间后停止移动并损毁。';

  @override
  String get schoolBusHelpRows => '行数说明';

  @override
  String get eventHelpSchoolBusRows =>
      '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。标准地图共有5行，海底世界地图共有6行。';

  @override
  String get eventHelpSchoolBusType =>
      '类型决定生成的冰淇淋车变体。普通（schoolbus_normal）为标准冰淇淋车。特殊（schoolbus_special）贴图显示泡泡枪小鬼和棒棒糖僵尸，车辆在前进过程中会持续释放对应技能。';

  @override
  String get schoolBusHelpZombies => '乘客说明';

  @override
  String get eventHelpSchoolBusZombies =>
      '冰淇淋车具有一定血量，车体被击毁后，车上的僵尸会下车继续前进。可以单独设置每个僵尸的阶数（0阶表示随地图阶级，庭院模式下即为1阶）。';

  @override
  String get schoolBusRow => '冰激凌车所在行 (Row)';

  @override
  String get schoolBusType => '车辆类型 (Type)';

  @override
  String get schoolBusTypeNormal => '普通';

  @override
  String get schoolBusTypeSpecial => '特殊';

  @override
  String get schoolBusHitPoints => '车辆血量 (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => '车辆速度 (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => '车内僵尸 (Zombies)';

  @override
  String get schoolBusZombieLevel => '僵尸等级 (Level)';

  @override
  String get schoolBusAddZombie => '添加僵尸';

  @override
  String get schoolBusRowsHint => '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。';

  @override
  String get eventHelpThunderWaveBody =>
      '本事件会在波次持续时间内落下闪电，劈中与其他植物相邻的植物，常见于天空之城地图。每道闪电可为植物施加正电荷或负电荷状态。';

  @override
  String get thunderWaveHelpTypes => '电荷效果';

  @override
  String get eventHelpThunderWaveTypes =>
      '2 枚正电荷会使植物持续受到上方电球的百分比伤害；2 枚负电荷会使植物在一段时间内陷入麻痹状态，无法行动；1 正 1 负两枚电荷会使植物永久减速。植物在已处于上述状态时仍可接收电荷，但不会受到新的电荷效果影响。';

  @override
  String get thunderWaveHelpKillRate => '击杀率';

  @override
  String get eventHelpThunderWaveKillRate =>
      '闪电劈中植物时直接将其杀死的概率（0.0–1.0），电离红掌不受影响。无论是携带正电荷还是负电荷的闪电，均能触发该效果。';

  @override
  String get thunderWaveTypePositive => '劈正电 (positive)';

  @override
  String get thunderWaveTypeNegative => '劈负电 (negative)';

  @override
  String get thunderWaveKillRate => '击杀率 (KillRate)';

  @override
  String get thunderWaveKillRateHint => '闪电劈中植物时直接将其杀死的概率（0.0–1.0），电离红掌不受影响';

  @override
  String get thunderWaveThunders => '雷云风暴';

  @override
  String get thunderWaveAddThunder => '添加闪电';

  @override
  String get thunderWaveThunder => '闪电';

  @override
  String get barrelWaveTypeEmpty => '空桶 (barrelempty)';

  @override
  String get barrelWaveTypeZombie => '小鬼桶 (barrelmoster)';

  @override
  String get barrelWaveTypeExplosive => '炸药桶 (barrelpowder)';

  @override
  String get barrelWaveRowsHint => '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。';

  @override
  String get barrelWaveAddBarrel => '添加滚桶';

  @override
  String get barrelWaveBarrel => '滚桶';

  @override
  String get barrelWaveRow => '滚桶所在行 (Row)';

  @override
  String get barrelWaveType => '滚桶类型 (Type)';

  @override
  String get barrelWaveHitPoints => '滚桶生命值 (BarrelHitPoints)';

  @override
  String get barrelWaveSpeed => '滚桶移动速度 (BarrelSpeed)';

  @override
  String get barrelWaveZombies => '桶内僵尸 (Zombies)';

  @override
  String get barrelWaveZombieLevel => '僵尸等级 (Level)';

  @override
  String get barrelWaveAddZombie => '添加僵尸';

  @override
  String get barrelWaveExplosionDamage => '滚桶爆炸伤害 (BarrelBlowDamageAmount)';

  @override
  String get barrelWaveDeleteTitle => '删除滚桶';

  @override
  String get barrelWaveDeleteConfirm => '确认要删除这个滚桶吗？';

  @override
  String get barrelWaveDeleteLastHint => '这是最后一个滚桶。删除后该事件中将不再有滚桶，确定要继续吗？';

  @override
  String get eventHelpGraveSpawnBody => '此事件可以在特定障碍物类型上出怪，常用于黑暗时代的亡灵返乡。';

  @override
  String get eventHelpGraveSpawnWait =>
      '从波次开始到僵尸生成之间的时间间隔，如果计时尚未结束就已经进入下一波，则不会出怪。';

  @override
  String get eventHelpStormBody =>
      '生成沙尘暴或暴风雪将僵尸快速传送到前线，可以分组出现。极寒风暴出现于回忆之旅，可以冻结经过的植物。';

  @override
  String get eventHelpStormColumns =>
      '场地左边界为0列，右边界为9列（海底世界地图为10列）。起始列数要小于结束列数，否则风暴不会生成。';

  @override
  String get eventHelpStormLevels =>
      '风暴内僵尸的阶级和所在行不能独立设置。因此编辑器内的僵尸阶级设置是无效的，阶级默认随地图阶级序列。';

  @override
  String get eventHelpGroundSpawnBody =>
      '从设定的区间范围直接从地下生成僵尸。参数配置和自然出怪基本一致。0阶表示随地图阶级，庭院模式下即为1阶。\n掉落物默认情况下配置的是携带能量豆的僵尸个数，启用掉落植物功能后会随机从配置的植物库里掉落植物卡片。 ';

  @override
  String get moduleHelpTideBody =>
      '本模块用于开启关卡中的潮水系统，以便后续使用潮水更改事件。注意该模块需要最后添加，否则可能导致闪退。';

  @override
  String get moduleHelpTidePosition =>
      '可以指定潮水的初始位置，即关卡中海岸线所在的位置。场地最右边为0，最左边为9。允许输入负数在内的整数。';

  @override
  String get initialTidePosition => '海岸线配置';

  @override
  String get moduleHelpManholeBody =>
      '定义场景中的地下管道系统，常用于蒸汽时代地图。管道连接两点，僵尸可以通过管道进行移动。';

  @override
  String get moduleHelpManholeEdit =>
      '在上方列表选择管道组，下方网格显示管道布局。点击“放置起点”或“放置终点”切换模式，然后点击网格设定位置。';

  @override
  String get moduleHelpWeatherBody => '本模块用于控制关卡中的全局环境特效，如雨雪天气。';

  @override
  String get moduleHelpWeatherRef => '这些模块通常直接引用自 LevelModules，无需在关卡内自定义参数。';

  @override
  String get moduleHelpZombiePotionBody =>
      '此模块会在指定的时间间隔区间内，从右往左在随机行生成指定类型的障碍物。如果场上指定障碍物数量达到上限，则不会继续生成。';

  @override
  String get moduleHelpZombiePotionTypes =>
      '药水会在指定的种类中随机选取，如果想间隔固定时间同时生成多个，可以尝试在关卡内添加多次此模块。';

  @override
  String get moduleHelpUnknownBody =>
      '关卡文件是由根节点和多个模块构成的，这些可用模块称为PVZ2Object。每一个Object都有代号(Aliases)，类型(objclass)和数据(objdata)。根节点没有代号。';

  @override
  String get moduleHelpUnknownEvents =>
      '本软件通过读取objclass解析模块类型。当前模块的objclass尚未注册到软件的模块列表中，所以没有匹配的模块编辑器，需要等开发者后续完善。';

  @override
  String get eventHelpInvalidBody =>
      '该事件在波次容器中被引用过，但是解析器在关卡里找不到这个事件的实体定义，Rtid语句块落空。';

  @override
  String get eventHelpInvalidImpact =>
      '若将该失效语句保留在关卡中，会导致关卡无法正常读取导致闪退。需要将该语句手动移除。';

  @override
  String get position => '初始潮水位置';

  @override
  String get editing => '编辑';

  @override
  String get logic => '逻辑';

  @override
  String get impact => '影响';

  @override
  String get events => '事件';

  @override
  String get referenceModules => '参考模块';

  @override
  String get portalType => '裂缝类型';

  @override
  String get direction => '方向 (Direction)';

  @override
  String get velocityScale => '速度倍率 (VelocityScale)';

  @override
  String get range => '范围参数 (Range)';

  @override
  String get columnRange => '出怪范围（列数）';

  @override
  String get zombieLevels => '僵尸等级';

  @override
  String get missingAssets => '缺少资源';

  @override
  String get usage => '使用说明';

  @override
  String get types => '类型';

  @override
  String get eventBlackHole => '事件类型：黑洞吸引';

  @override
  String get attractionConfig => '吸引配置';

  @override
  String get selectedPosition => '选中位置';

  @override
  String get placePlant => '放置植物';

  @override
  String get plantList => '当前格子中的植物';

  @override
  String get firstCostume => '佩戴第一装扮 (Avatar)';

  @override
  String get costumeOn => '启用装扮';

  @override
  String get costumeOff => '禁用装扮';

  @override
  String get outsideLawnItems => '场外物体';

  @override
  String get zombieFromLeft => '从场地左侧出现';

  @override
  String get eventMagicMirror => '事件类型：魔镜传送';

  @override
  String get eventParachuteRain => '事件类型：空降突袭';

  @override
  String get manholePipeline => '地下管道模块';

  @override
  String get manholePipelines => '地下管道模块';

  @override
  String get manholePipelineHelpOverview =>
      '定义场景中的地下管道系统，常用于蒸汽时代地图。管道连接两点，僵尸可以通过管道进行移动。';

  @override
  String get manholePipelineHelpEditing =>
      '在上方列表选择管道组，下方网格显示管道布局。点击“放置起点”或“放置终点”切换模式，然后点击网格设定位置。';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return '起点: ($sx, $sy)  终点: ($ex, $ey)';
  }

  @override
  String get piratePlank => '海盗甲板模块';

  @override
  String get weatherModule => '环境天气模块说明';

  @override
  String get zombiePotion => '僵尸药水模块';

  @override
  String get eventTimeRift => '事件类型：时空裂缝';

  @override
  String get deathHole => '死亡坑洞模块';

  @override
  String get seedRain => '种子雨模块';

  @override
  String get eventFrostWind => '事件类型：寒风侵袭';

  @override
  String get lastStandSettings => '坚不可摧设置';

  @override
  String get roofFlowerPot => '屋顶花盆模块';

  @override
  String get eventConveyorModify => '事件类型：传送带更改';

  @override
  String get bowlingMinigame => '旧版保龄球设置';

  @override
  String get zombieMoveFast => '加速进场模块';

  @override
  String get eventPotionDrop => '事件类型：药水投放';

  @override
  String get eventShellSpawn => '事件类型：贝壳生成';

  @override
  String get eventPumpkinHouseSpawn => '事件类型：南瓜屋生成';

  @override
  String get eventSchoolBusSpawn => '事件类型：冰淇淋车生成';

  @override
  String get warMist => '迷雾系统模块';

  @override
  String get eventDino => '事件类型：恐龙召唤';

  @override
  String get duration => '持续时间';

  @override
  String get sunDropper => '事件类型：阳光掉落';

  @override
  String get eventFairyWind => '事件类型：童话微风';

  @override
  String get eventFairyFog => '事件类型：魔力迷雾';

  @override
  String get eventRaidingParty => '事件类型：海盗登船';

  @override
  String get swashbucklerCount => '总僵尸数 (SwashbucklerCount)';

  @override
  String get sunBomb => '阳光炸弹模块';

  @override
  String get eventSpawnGravestones => '事件类型：障碍物生成';

  @override
  String get eventBarrelWave => '事件类型：滚桶危机';

  @override
  String get eventThunderWave => '事件类型：雷云风暴';

  @override
  String get eventGraveSpawn => '障碍物出怪事件';

  @override
  String get zombieSpawnWait => '僵尸生成延迟';

  @override
  String get selectCustomZombie => '选择自定义僵尸';

  @override
  String get change => '更换';

  @override
  String get autoLevel => '自动设置等级';

  @override
  String get apply => '一键应用';

  @override
  String get applyBatchLevel => '确认批量应用';

  @override
  String get conveyorBelt => '传送带';

  @override
  String get starChallenges => '挑战模块';

  @override
  String get addChallenge => '添加新挑战';

  @override
  String get unknownChallengeType => '未知挑战类型';

  @override
  String get protectedPlants => '保护植物挑战';

  @override
  String get addPlant => '添加植物';

  @override
  String get protectedGridItems => '保护物品挑战';

  @override
  String get addGridItem => '添加目标';

  @override
  String get spawnTimer => '生成时间间隔 (PotionSpawnTimer)';

  @override
  String get plantLevels => '阶级定义设置';

  @override
  String get globalPlantLevels => '阶级定义模块说明';

  @override
  String get scope => '范围';

  @override
  String get applyBatch => '批量应用';

  @override
  String get addPlants => '添加植物';

  @override
  String get noPlantsConfigured => '暂无配置，请添加植物';

  @override
  String batchLevelFormat(int level) {
    return '批量设置：$level';
  }

  @override
  String get protectPlants => '保护植物挑战';

  @override
  String get protectItems => '保护物品挑战';

  @override
  String get autoCount => '自动计数';

  @override
  String get overrideStartingPlantfood => '初始能量豆设置';

  @override
  String get startingPlantfoodOverride => '初始能量豆数量 (StartingPlantfoodOverride)';

  @override
  String get iconText => '图标文字';

  @override
  String get iconImage => '图标图片';

  @override
  String get overrideMaxSun => '阳光上限设置';

  @override
  String get maxSunOverride => '最大阳光数值 (MaxSunOverride)';

  @override
  String get maxSunHelpTitle => '阳光上限模块说明';

  @override
  String get maxSunHelpOverview => '该模块原本用于控制潘追关卡不同难度级别，可以用此模块覆盖关卡内能够储存的阳光最大值。';

  @override
  String get startingPlantfoodHelpTitle => '初始能量豆模块说明';

  @override
  String get startingPlantfoodHelpOverview =>
      '该模块原本用于控制潘追关卡不同难度级别，可以用此模块覆盖关卡内携带的初始能量豆数量。';

  @override
  String get starChallengeHelpTitle => '挑战模块说明';

  @override
  String get starChallengeHelpOverview =>
      '这里可用选择关卡使用的各项挑战模块。可以同时设置多项挑战目标以及使用多次同种挑战。';

  @override
  String get starChallengeHelpSuggestionTitle => '优化建议';

  @override
  String get starChallengeHelpSuggestion =>
      '部分挑战在游戏内有统计框记录进度，当挑战模块过多时统计数据框可能会被遮挡。';

  @override
  String get remove => '移除';

  @override
  String get plant => '植物';

  @override
  String get zombie => '僵尸';

  @override
  String get initialZombieLayout => '初始僵尸布局';

  @override
  String get placeZombie => '放置僵尸';

  @override
  String get manualInput => '手动输入';

  @override
  String get waveManagerModule => '波次管理模块';

  @override
  String get points => '积分';

  @override
  String get eventStorm => '事件类型：风暴突袭';

  @override
  String get row => '行';

  @override
  String get addType => '添加类型';

  @override
  String get plantFunExperimental => '植物（功能暂不完善）';

  @override
  String get availableZombies => '可用僵尸列表';

  @override
  String get presetPlants => '预选植物 (PresetPlantList)';

  @override
  String get whiteList => '白名单 (WhiteList)';

  @override
  String get blackList => '黑名单 (BlackList)';

  @override
  String get chooser => '自选 (Chooser)';

  @override
  String get preset => '预设 (Preset)';

  @override
  String get seedBankHelp => '种子库模块说明';

  @override
  String get conveyorBeltHelp => '传送带模块说明';

  @override
  String get dropDelayConditions => '刷新延迟 (DropDelayConditions)';

  @override
  String get unitSeconds => '单位：秒';

  @override
  String get speedConditions => '传输速度 (SpeedConditions)';

  @override
  String get speedConditionsSubtitle => '标准值为 100，值越大越快';

  @override
  String get addPlantConveyor => '添加植物';

  @override
  String get addTool => '添加工具';

  @override
  String get increasedCost => '通货膨胀设置';

  @override
  String get powerTile => '能量瓷砖模块';

  @override
  String get powerTileGridSection => '当前场地';

  @override
  String get powerTileGridHelpPrimary =>
      '点击格子放置瓷砖，再次点击进行删除，若该格已有其他瓷砖将直接替换。场地中非当前选中组的瓷砖会以半透明效果显示。';

  @override
  String get powerTileGridHelpSecondaryMobile => '长按瓷砖可快速更改其所在组，或单独修改其传导延迟。';

  @override
  String get powerTileGridHelpSecondaryDesktop => '右键点击瓷砖可快速更改其所在组，或单独修改其传导延迟。';

  @override
  String get powerTileLinkedTilesSection => '瓷砖列表';

  @override
  String get powerTilePropagationDelayLabel => '传导延迟（PropagationDelay，单位：秒）';

  @override
  String get powerTilePropagationDelayTooltip =>
      '能量开始传导至其他瓷砖之前的前摇时间（0–5秒），注意该时间不包含传输本身的时间。延迟默认为1.5秒。';

  @override
  String get powerTileDialogEditCell => '编辑瓷砖';

  @override
  String get powerTileDialogTileGroup => '瓷砖所在组';

  @override
  String get powerTileDialogNone => '无';

  @override
  String get powerTileDialogPropagationDelay => '传导延迟（PropagationDelay，单位：秒）';

  @override
  String get powerTileHelpOverview =>
      '瓷砖分为五组。种植在瓷砖上的植物在触发能量豆大招时，会传导能量，使其他同组瓷砖上的植物也释放一次大招。可以设置能量开始传导的前摇时间。';

  @override
  String get powerTileHelpGridSize => '场地大小因关卡而异，海底世界关卡为6行10列，其他关卡为5行9列。';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return '快捷编辑：$interaction';
  }

  @override
  String get eventStandardSpawn => '事件类型：普通出怪';

  @override
  String get eventGroundSpawn => '事件类型：地下突袭';

  @override
  String get eventEditorInDevelopment => '事件编辑器开发中';

  @override
  String get level => '等级';

  @override
  String get missingTideModule => '模块缺失警告';

  @override
  String get levelHasNoTideProperties =>
      '关卡未检测到潮水模块 (TideProperties)，此事件在游戏中可能无法生效，甚至导致闪退。';

  @override
  String get changePosition => '潮水变更配置';

  @override
  String get changePositionChangeAmount => '潮水变更配置';

  @override
  String get preview => '潮水位置预览';

  @override
  String get water => '有潮水';

  @override
  String get land => '无潮水';

  @override
  String groupConfigN(int n) {
    return '第$n组配置';
  }

  @override
  String get globalParameters => '全局参数';

  @override
  String get timePerGrid => '传输耗时（秒/格）';

  @override
  String get damagePerSecond => '每秒伤害';

  @override
  String get pipe => '管道';

  @override
  String get stageMismatch => '地图类型不匹配';

  @override
  String get currentStageNotPirate => '当前地图类型并非海盗港湾，此模块可能在游戏中可能无法生效，甚至导致闪退';

  @override
  String get plankRows => '甲板行数配置';

  @override
  String get plankRowsDeepSea => '海底世界甲板行数配置';

  @override
  String get selectedRows => '已选择的行：';

  @override
  String get selectedRowsLabel => '已选择的行数：';

  @override
  String get indexLabel => '索引';

  @override
  String get selectWeatherType => '选择天气类型';

  @override
  String get counts => '数量控制';

  @override
  String get initial => '初始数量 (InitialPotionCount)';

  @override
  String get max => '最大数量 (MaxPotionCount)';

  @override
  String get spawnTimerShort => '生成时间间隔 (PotionSpawnTimer)';

  @override
  String get minSec => '最小间隔（秒）';

  @override
  String get maxSec => '最大间隔（秒）';

  @override
  String get potionTypes => '药水种类列表 (PotionTypes)';

  @override
  String get noPotionTypes => '暂无配置，请添加药水类型';

  @override
  String get ignoreGravestoneSubtitle => '开启后裂缝可无视障碍物生成';

  @override
  String get thisPortalSpawns => '该裂缝将生成以下僵尸：';

  @override
  String startEndFormat(int sx, int sy, int ex, int ey) {
    return '起点：($sx, $sy)  终点：($ex, $ey)';
  }

  @override
  String indexN(int n) {
    return '索引：$n';
  }

  @override
  String get noItemsAddHint => '暂无物品。可添加植物、僵尸或道具。';

  @override
  String get zombieTypeSpiderZombieName => '僵尸代号 (SpiderZombieName)';

  @override
  String get noneSelected => '未选择';

  @override
  String get totalSpiderCount => '总数量 (SpiderCount)';

  @override
  String get perBatchGroupSize => '每批数量 (GroupSize)';

  @override
  String get fallTime => '降落耗时（秒）';

  @override
  String get waveStartMessageLabel => '红色字幕警告信息 (WaveStartMessage)';

  @override
  String get optionalWarningText => '空降开始时在屏幕中央显示的红字警告，不支持输入中文';

  @override
  String rowNShort(int n) {
    return '第$n行';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return '权重：$weight，最大：$max';
  }

  @override
  String get random => '随机';

  @override
  String get noChallengesConfigured => '暂未配置挑战';

  @override
  String get whiteListBlackListHint =>
      '白名单为空时不作限制。未添加平行宇宙模块时，平行宇宙植物加入白名单无效。黑名单为额外禁用植物，优先级高于白名单。';

  @override
  String get conveyorBeltHelpIntro => '传送带模式会按照设定的权重随机生成卡牌。需要配置植物池以及刷新延迟数据。';

  @override
  String get conveyorBeltHelpPool =>
      '某种植物出现的概率为这种植物的权重占所有植物权重的比例。可以通过设置两个阈值动态调整植物的权重';

  @override
  String get conveyorBeltHelpDropDelay =>
      '控制卡片生成的间隔时间。可以根据挤压的植物数量调整传送间隔。通常植物积压越多，生成越慢。';

  @override
  String get conveyorBeltHelpSpeed =>
      '控制卡片在传送带上移动的物理速度，标准速度为100。可以根据积压数量进行分段变速。';

  @override
  String get cannotAddEliteZombies => '无法添加精英僵尸';

  @override
  String get eliteZombiesNotAllowed => '此处不允许使用精英僵尸';

  @override
  String fixToAlias(Object alias) {
    return '修复至 $alias';
  }

  @override
  String editPresetZombie(Object name) {
    return '编辑预设僵尸：$name';
  }

  @override
  String get missingZombossMechModule => '缺少 ZombossBattleModuleProperties';

  @override
  String get missingZombossBattleModule =>
      '缺少 ZombossLastStandMinigameProperties';

  @override
  String get challengeNoConfig => '此挑战不支持配置。';

  @override
  String get maxPotionCount => '最大药水数量';

  @override
  String potionTypesConfigured(int count) {
    return '药水种类：已配置 $count 个';
  }

  @override
  String pipelinesCount(int count) {
    return '管道：$count';
  }

  @override
  String windN(int n) {
    return '寒风 #$n';
  }

  @override
  String get zombieList => '僵尸列表';

  @override
  String get positionPoolSpawnPositions => '候选位置池 (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect => '点击格子以选中/取消选中，选中的格子即为可能的生成点';

  @override
  String get gravestonePool => '物品池 (GravestonePool)';

  @override
  String get removePlants => '移除植物';

  @override
  String get current => '当前';

  @override
  String get eliteZombiesUseDefaultLevel => '精英僵尸使用默认等级。';

  @override
  String get basicParameters => '基本参数';

  @override
  String get zombieSpawnWaitSec => '僵尸生成延迟（秒）';

  @override
  String get gridTypes => '障碍物类型';

  @override
  String zombiesCount(int count) {
    return '僵尸（$count）';
  }

  @override
  String get eventGraveSpawnSubtitle => '事件类型：障碍物出怪';

  @override
  String get eventStormSpawnSubtitle => '事件类型：风暴突袭';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      '从波次开始到僵尸生成的时间间隔，如果计时尚未结束就已经进入下一波，则不会出怪。';

  @override
  String get eventHelpStormOverview =>
      '生成沙尘暴或暴风雪将僵尸快速传送到前线，可以分组出现。极寒风暴出现于回忆之旅，可以冻结经过的植物。';

  @override
  String get eventHelpStormColumnRange =>
      '场地左边界为0列，右边界为9列（海底世界地图为10列）。起始列数要小于结束列数，否则风暴不会生成。';

  @override
  String get eventHelpStormZombieLevels =>
      '风暴内僵尸的阶级和所在行不能独立设置。因此编辑器内的僵尸阶级设置是无效的，阶级默认随地图阶级序列。';

  @override
  String get spawnParameters => '生成参数';

  @override
  String get sandstorm => '沙尘暴';

  @override
  String get snowstorm => '暴风雪';

  @override
  String get excoldStorm => '极寒风暴';

  @override
  String get columnStart => '起始列 (ColumnStart)';

  @override
  String get columnEnd => '结束列 (ColumnEnd)';

  @override
  String applyBatchLevelContent(int level) {
    return '将本波次所有僵尸设为$level阶（精英僵尸不受影响）';
  }

  @override
  String get randomRow => '随机行';

  @override
  String levelFormat(int level) {
    return '等级：$level';
  }

  @override
  String get levelAccount => '等级：账户';

  @override
  String levelDisplay(Object value) {
    return '等级：$value';
  }

  @override
  String get eventStandardSpawnTitle => '普通出怪事件说明';

  @override
  String get eventGroundSpawnTitle => '地下突袭事件说明';

  @override
  String get eventHelpStandardOverview =>
      '最基础的生成僵尸事件。可以配置每一只僵尸的阶数和行号，0阶表示随地图阶级，庭院模式下即为1阶。\n掉落物默认情况下配置的是携带能量豆的僵尸个数，启用掉落植物功能后会随机从配置的植物库里掉落植物卡片。';

  @override
  String get eventHelpStandardRow => '僵尸可出现在第1–5行中的任意一行，或随机选择一行出现。';

  @override
  String get eventHelpStandardRowDeepSea => '僵尸可出现在第1–6行中的任意一行，或随机选择一行出现。';

  @override
  String get warningStageSwitchedTo5Rows =>
      '当前关卡的地图只有5行，但部分数据引用了第6行。这些对象在关卡中可能无法正确显示。';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return '部分对象在场外（场地范围为$rows×$cols）。';
  }

  @override
  String get izombieModeTitle => '我是僵尸模式';

  @override
  String get izombieModeSubtitle => '启用后将转变为放置僵尸的玩法，选卡方式将被锁定';

  @override
  String get reverseZombieFactionTitle => '反转僵尸阵营';

  @override
  String get reverseZombieFactionSubtitle => '启用后放置的僵尸为植物阵营，可用于ZVZ';

  @override
  String get initialWeight => '初始权重';

  @override
  String get plantLevelLabel => '植物等级';

  @override
  String get missingIntroModule => '模块缺失警告';

  @override
  String get missingIntroModuleHint =>
      '关卡未检测到僵王机甲转场模块 (ZombossBattleIntro)，可能无法正常运行，请添加转场模块后重新选择机甲。';

  @override
  String get zombossMechType => '僵王机甲类型';

  @override
  String get unknownZombossMech => '未知僵王机甲';

  @override
  String get zombossMechSelection => '僵王机甲选择';

  @override
  String get zombossMechBaseLabel => '基础机甲';

  @override
  String get zombossMechBaseHint => '机甲僵王家族（埃及、未来、回忆之旅机器人等）。更改此项会更新下方可选变体。';

  @override
  String get zombossMechVariationLabel => '变体';

  @override
  String get zombossMechVariationHint =>
      '关卡中使用的具体机甲类型（ZombossMechType），选项取决于上方选择的基础机甲。阶段数与出现位置会自动同步。';

  @override
  String get zombossBattleSelection => '僵王选择';

  @override
  String get zombossBattleBaseLabel => '基础僵王';

  @override
  String get zombossBattleBaseHint => '僵王家族（功夫大刀、秦始皇等）。更改此项会自动更新资源组。';

  @override
  String get zombossBattleVariationLabel => '变体';

  @override
  String get zombossBattleVariationHint =>
      '关卡中使用的具体僵王类型（ZombossTypeName），选项取决于上方选择的基础僵王。';

  @override
  String get zombossBattleStartingSunLabel => '初始阳光 (StartingSun)';

  @override
  String get zombossBattleStartingSunHint => '战斗开始时的阳光数量。';

  @override
  String get zombossBattleStartingPlantfoodLabel => '初始能量豆 (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint => '战斗开始时的能量豆数量。';

  @override
  String get zombossBattleInitialGridColLabel => '出现列 (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint => '僵王出现的网格列。';

  @override
  String get zombossBattleInitialGridRowLabel => '出现行 (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint => '僵王出现的网格行。';

  @override
  String get zombossBattleStartStageIndexLabel =>
      '起始阶段 (ZombossStartStageIndex)';

  @override
  String get zombossBattleStartStageIndexHint => '战斗从第几阶段开始（0 为第一阶段）。';

  @override
  String get zombossBattleSkipPlantingLabel => '跳过种植阶段 (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint => '启用后，僵王战前不进行种植/setup 阶段。';

  @override
  String get parameters => '关卡参数';

  @override
  String get reservedColumnCount => '预留列';

  @override
  String get reservedColumnCountHint => '表示右边预留不能种植植物的列数，通常预留两列以上';

  @override
  String get protectedList => '保护目标列表';

  @override
  String get plantLevelsFollowGlobal => '此模块中的植物随玩家账号阶级，可以使用全局阶级定义模块统一等级。';

  @override
  String get protectPlantsOverview => '定义关卡中必须保护的植物。如果这些植物被僵尸吃掉或摧毁，关卡失败。';

  @override
  String get protectPlantsAutoCount => '软件会自动跟随您添加的植物数量更新需要保护的植物数量。';

  @override
  String get protectItemsOverview => '定义关卡中必须保护的物品。这些物品被破坏会导致关卡失败。';

  @override
  String get protectItemsAutoCount => '软件会自动跟随您添加的物品数量更新需要保护的障碍物数量。';

  @override
  String positionsCount(int count) {
    return '候选位置数：$count';
  }

  @override
  String totalItemsCount(int count) {
    return '待生成物品总数：$count';
  }

  @override
  String get itemCountExceedsPositionsWarning => '警告：物品总数超过了候选位置数，部分物品将无法生成！';

  @override
  String get gravestoneBlockedInfo =>
      '此事件中墓碑这类和植物冲突的障碍物会因为植物阻挡而无法生成，强制生成需要采用投放药水事件等其它方法。';

  @override
  String get enterConditionValue => '输入条件值';

  @override
  String get customInputHint => '自定义输入需准确无误';

  @override
  String get presetConditions => '预设条件';

  @override
  String get selectFromPresetHint => '从预设条件列表中选择';

  @override
  String get conveyorCardPool => '传送带卡片池';

  @override
  String get toolCardsUseFixedLevel => '工具卡默认固定等级，无需修改';

  @override
  String get maxLimits => '上限控制 (Max Limits)';

  @override
  String get maxCountThreshold => '最大数量阈值';

  @override
  String get weightFactor => '达标后权重倍率';

  @override
  String get minLimits => '下限控制 (Min Limits)';

  @override
  String get minCountThreshold => '最小数量阈值';

  @override
  String get followAccountLevel => 'Level 0 follows the player’s account level';

  @override
  String get enablePointSpawning => '启用点数出怪';

  @override
  String get pointSpawningEnabledDesc => '已启用 (使用额外点数出怪)';

  @override
  String get pointSpawningDisabledDesc => '未启用 (仅使用波次事件)';

  @override
  String get pointSettings => '点数分配设置';

  @override
  String get startingWave => '起始波次 (StartingWave)';

  @override
  String get startingPoints => '起始点数 (StartingPoints)';

  @override
  String get pointIncrement => '每波点数增量 (PointIncrementPerWave)';

  @override
  String get zombiePool => '僵尸池 (ZombiePool)';

  @override
  String plantLevelsCount(int count) {
    return '植物等级：$count';
  }

  @override
  String lvN(int n) {
    return '$n阶';
  }

  @override
  String get pennyClassroom => '潘妮课堂模块';

  @override
  String get protectGridItems => '保护物品挑战';

  @override
  String get waveManagerHelpOverview =>
      '波次管理器是波次事件容器的前置定义。只有添加了波次管理器模块，软件才会开放波次事件编辑入口。';

  @override
  String get waveManagerHelpPoints =>
      '点数出怪会根据僵尸消耗的点数在有效波次中额外刷新僵尸。常规波次点数上限为60000，旗帜波点数会变为2.5倍。点数为正数时，出怪使用的僵尸从僵尸池中选取。在波次容器编辑页面内可查看每种僵尸的出现期望。点数为负数时，会从自然出怪事件中扣除相应点数的僵尸。注意点数出怪池不应该写精英怪以及自定义僵尸。';

  @override
  String get pointsSection => '点数出怪';

  @override
  String get globalPlantLevelsOverview =>
      '此模块用于定义植物的全局等级。它通常优于种子库中的等级设置，且可以针对特定植物单独设置等级。';

  @override
  String get globalPlantLevelsScope => '设置的等级将应用于关卡内玩家使用的该种植物，包括保护植物、卡片掉落等。';

  @override
  String mustProtectCountFormat(int count) {
    return '需保护数量：$count';
  }

  @override
  String get noWaveManagerPropsFound => '未找到波次管理器 (WaveManagerProperties) 模块。';

  @override
  String get itemsSortedByRow => '当前格子中的物品';

  @override
  String get eventStormSpawn => '事件类型：风暴突袭';

  @override
  String get stormEvent => '风暴突袭事件说明';

  @override
  String get makeCustom => '设为自定义';

  @override
  String get zombieLevelsBody =>
      '风暴内僵尸的阶级和所在行不能独立设置。因此编辑器内的僵尸阶级设置是无效的，阶级默认随地图阶级序列。';

  @override
  String get batchLevel => '批量设置等级';

  @override
  String get start => '起始';

  @override
  String get end => '结束';

  @override
  String get backgroundMusicLevelJam => '魔音音乐切换 (LevelJam)';

  @override
  String get onlyAppliesRockEra => '此事件触发时切换背景音乐，仅对摇滚年代地图有效。';

  @override
  String get appliesToAllNonElite => '将本波次所有僵尸设为指定等级（精英僵尸不受影响，保持默认等级）';

  @override
  String get dropConfigPlants => '掉落物配置（植物卡片）';

  @override
  String get dropConfigPlantFood => '掉落物配置（能量豆）';

  @override
  String get zombiesCarryingPlants => '携带植物卡片的僵尸数量';

  @override
  String get zombiesCarryingPlantFood => '携带能量豆的僵尸数量';

  @override
  String get descriptiveName => '提示名称 (DescriptiveName)';

  @override
  String get count => '数量 (Count)';

  @override
  String get targetDistance =>
      '花坛距离 (TargetDistance)，数值代表从左边线起的列数，数值越大离房屋越远，可输入小数';

  @override
  String get targetSun => '目标阳光 (TargetSun)';

  @override
  String get maximumSun => '阳光限额 (MaximumSun)';

  @override
  String get holdoutSeconds => '保持时间 (HoldoutSeconds)';

  @override
  String get zombiesToKill => '击杀个数 (ZombiesToKill)';

  @override
  String get timeSeconds => '时间限制（秒）';

  @override
  String get speedModifier => '增幅倍率 (SpeedModifier)，填入0.5则代表僵尸移速获得50%的增幅';

  @override
  String get sunModifier => '降低倍率 (SunModifier)，填入0.2则代表阳光获取降低20%';

  @override
  String get maximumPlantsLost => '植物损失上限 (MaximumPlantsLost)';

  @override
  String get maximumPlants => '植物数量上限 (Maximum Plants)';

  @override
  String get targetScore => '目标分数 (targetScore)';

  @override
  String get plantBombRadius => '植物爆炸半径';

  @override
  String get plantType => '植物类型';

  @override
  String get gridX => '列数';

  @override
  String get gridY => '行数';

  @override
  String get noCardsYetAddPlants => '暂无卡片，请添加植物或工具卡';

  @override
  String get mustProtectCountAll => '必须保护的数量（0表示全部保护）：';

  @override
  String get mustProtectCount => '必须保护的数量 (MustProtectCount)';

  @override
  String get gridItemType => '物品类型';

  @override
  String get zombieBombRadius => '僵尸爆炸半径';

  @override
  String get plantDamage => '对植物伤害';

  @override
  String get zombieDamage => '对僵尸伤害';

  @override
  String get initialPotionCount => '初始药水数量 (InitialPotionCount)';

  @override
  String get operationTimePerGrid => '传输耗时（秒/格）';

  @override
  String get levelLabel => '等级：';

  @override
  String get mistParameters => '迷雾参数';

  @override
  String get sunDropParameters => '阳光掉落参数';

  @override
  String get initialDropDelay => '首次掉落延迟 (InitialSunDropDelay)';

  @override
  String get baseCountdown => '初始掉落间隔 (SunCountdownBase)';

  @override
  String get maxCountdown => '最大掉落间隔 (SunCountdownMax)';

  @override
  String get countdownRange => '间隔浮动范围 (SunCountdownRange)';

  @override
  String get increasePerSun => '单次增加间隔 (SunCountdownIncreasePurSun)';

  @override
  String get inflationParams => '通货膨胀参数';

  @override
  String get baseCostIncreaseLabel => '每次增加消耗 (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel => '最大增长次数，目前游戏只能读取默认值10次';

  @override
  String get selectGroup => '选择组';

  @override
  String get gridTapAddRemove => '网格（点击添加/更改，长按移除）';

  @override
  String get sunBombHelpOverview => '简要介绍';

  @override
  String get sunBombHelpBody =>
      '本模块是未来世界小游戏太阳风暴的必要模块，使用后天降阳光会变为紫色可引爆的阳光炸弹。阳光炸弹对不同阵营的杀伤可以区别填写。';

  @override
  String get bombProperties => '炸药桶模块';

  @override
  String get bombPropertiesHelpBody =>
      '本模块是配置功夫世界炸药桶小游戏的必要模块，使用后炸药桶会出现在小推车的位置，并引出一条可点燃的引线。若有火星沿着引线到达炸药桶处，炸药桶会爆炸，摧毁以自身为中心3×3范围内的植物。';

  @override
  String get bombPropertiesHelpFuse => '引线长度';

  @override
  String get bombPropertiesHelpFuseBody =>
      '引线长度按行设置，从第1行开始，自上而下，每行代表数组中的一个值，数值表示引线向右延伸的格数。标准地图共有5行，海底世界地图共有6行，打开本界面时，数组长度会自动适配当前地图。';

  @override
  String get bombPropertiesFlameSpeed => '引线燃烧速度 (FlameSpeed)';

  @override
  String get bombPropertiesFuseLengths => '引线长度 (FuseLengths)';

  @override
  String get bombPropertiesFuseLengthsHint => '按行设置引线向右延伸的格数，每行一个值';

  @override
  String get bombPropertiesFuseLength => '引线长度';

  @override
  String get damage => '爆炸伤害 (Damage)';

  @override
  String get explosionRadius => '爆炸半径 (ExplosionRadius)';

  @override
  String get plantRadius => '植物爆炸半径';

  @override
  String get zombieRadius => '僵尸爆炸半径';

  @override
  String get radiusPixelsHint => '爆炸半径单位为像素，1格约60像素';

  @override
  String get enterMaxSunHint => '输入关卡阳光上限（如 9900）';

  @override
  String get optionalLabelHint => '可选标签';

  @override
  String get imageResourceIdHint => 'IMAGE_... 资源 ID';

  @override
  String get enterStartingPlantfoodHint => '输入初始能量豆数量（0个及以上）';

  @override
  String get threshold => '阈值';

  @override
  String get delay => '延迟';

  @override
  String get seedBankLetsPlayersChoose =>
      '种子库可以允许玩家选择已有的植物，在庭院模式下可以定义全局阶级且实现全植物可用。当选择模式是预选时，将选卡模块放在传送带前面可以让传送带植物消耗阳光种植，放在后面可以让预选卡种植不消耗阳光。';

  @override
  String get iZombieModePresetHint =>
      '启用我是僵尸模式后，需要预设关卡的可用僵尸。此时选卡模式强制为预选。如果关卡中同时存在植物卡槽模式和僵尸卡槽模式，需将卡槽锁定至相同阶级。';

  @override
  String get invalidIdsHint =>
      '非法的代号在卡槽中会空缺。在植物模式下僵尸代号非法，反之亦然。可以用此特点在关卡里创建两个种子库，拼接两种模式的卡槽。注意要将僵尸卡槽置于前面。';

  @override
  String get seedBankIZombie => '种子库（我是僵尸）';

  @override
  String get basicRules => '基础规则';

  @override
  String get selectionMethod => '选卡模式';

  @override
  String get emptyList => '列表为空';

  @override
  String get plantsAvailableAtStart => '开局自带的植物';

  @override
  String get presetPlantListReorderHint => '长按 ⋮⋮ 手柄并拖动以调整顺序。';

  @override
  String get presetPlantListReorderHintDesktop => '拖动 ⋮⋮ 手柄以调整顺序。';

  @override
  String get whiteListDescription => '仅允许选择这些植物（空则不限制）';

  @override
  String get blackListDescription => '禁止选择这些植物';

  @override
  String get availableZombiesDescription => '我是僵尸模式下供玩家使用的僵尸';

  @override
  String get izombieCardSlotsHint =>
      '只有部分僵尸在我是僵尸模式 (IZ) 中有对应的卡槽和阳光消耗，这些僵尸可以在僵尸选择界面的「其他分类」中找到。';

  @override
  String get seedBankPresetModeHint => '预选模式会立刻进入游戏，与卡片数量无关。';

  @override
  String get seedBankPlantLevelLabel => '植物阶级 (0-5)';

  @override
  String get seedBankSlotCountLabel => '卡槽数量 (0-9)';

  @override
  String get seedBankCourtyardSlotsHint => '庭院模式忽略卡槽数量。选卡模式固定 8 个卡槽。';

  @override
  String get seedBankAddGridItemsTitle => '添加网格物品';

  @override
  String get seedBankAddGridItemsSubtitle => '将网格物品追加到 PresetPlantList，可重复添加。';

  @override
  String seedBankGridItemCount(int count) {
    return '已在预选列表中：$count 个';
  }

  @override
  String get starChallengeSelectConditions => '选择状态';

  @override
  String get starChallengeEditConditions => '编辑状态';

  @override
  String get selectToolCard => '选择工具卡';

  @override
  String get searchGridItems => '搜索障碍物';

  @override
  String get searchStatues => '搜索复兴雕像或原石像';

  @override
  String get noItems => '无物品';

  @override
  String get addedToFavorites => '已添加至收藏';

  @override
  String get removedFromFavorites => '已从收藏移除';

  @override
  String selectedCountTapToSearch(int count) {
    return '已选 $count，点击搜索';
  }

  @override
  String get noFavoritesLongPress => '暂无收藏，长按图标即可收藏';

  @override
  String get gridItemCategoryAll => '全部物品';

  @override
  String get gridItemCategoryScene => '场景布置';

  @override
  String get gridItemCategoryTrap => '互动陷阱';

  @override
  String get gridItemCategorySpawnableObjects => '生成物品';

  @override
  String get sunDropperConfigTitle => '阳光掉落配置';

  @override
  String get customLocalParams => '自定义本地参数';

  @override
  String get currentModeLocal => '当前: 本地编辑 (@CurrentLevel)';

  @override
  String get currentModeSystem => '当前: 系统默认 (@LevelModules)';

  @override
  String get paramAdjust => '参数调节';

  @override
  String get firstDropDelay => '首次掉落延迟 (InitialSunDropDelay)';

  @override
  String get initialDropInterval => '初始掉落间隔 (SunCountdownBase)';

  @override
  String get maxDropInterval => '最大掉落间隔 (SunCountdownMax)';

  @override
  String get intervalFloatRange => '间隔浮动范围 (SunCountdownRange)';

  @override
  String get sunDropperHelpTitle => '阳光掉落模块说明';

  @override
  String get sunDropperHelpIntro => '本模块用于配置关卡中的天降阳光参数，若是黑夜地图可考虑不添加此模块。';

  @override
  String get sunDropperHelpParams => '参数配置';

  @override
  String get sunDropperHelpParamsBody =>
      '常规情况下，本模块使用在游戏文件里的定义，也可以选择打开自定义开关对详细参数进行编辑。';

  @override
  String get noZombossMechFound => '未找到僵王机甲';

  @override
  String get noZombossBattleFound => '未找到僵王数据';

  @override
  String get searchChallengeNameOrCode => '搜索挑战名称或代码';

  @override
  String get deleteChallengeTitle => '删除挑战？';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return '确定要移除「$name」吗？本地挑战数据将永久删除。';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return '确定要移除对「$name」的引用吗？挑战仍将保留在关卡模块 (LevelModules) 中。';
  }

  @override
  String get missingModulesRecommended => '关卡可能无法正常运行。建议添加以下模块：';

  @override
  String get recommendedTunnelDefendTitle => '强烈建议添加「地宫坑道」模块';

  @override
  String get recommendedTunnelDefendBody =>
      '地宫秘境场地中的地砖需通过「地宫坑道」模块铺设。若未添加该模块，场地可能会显得较为空旷。';

  @override
  String get itemListRowFirst => '当前格子中的物品';

  @override
  String get railcartCowboy => '西部矿车';

  @override
  String get railcartFuture => '未来矿车';

  @override
  String get railcartEgypt => '埃及矿车';

  @override
  String get railcartPirate => '海盗矿车';

  @override
  String get railcartWorldcup => '世界杯矿车';

  @override
  String get clearUnusedTitle => '清除未使用对象？';

  @override
  String get clearUnusedMessage =>
      '将永久删除关卡文件中所有未使用的对象，包括自定义僵尸、其属性及任何其他未被引用的数据。此操作不可撤销。确定继续？';

  @override
  String get clearUnusedNone => '未找到未使用的对象。';

  @override
  String clearUnusedDone(int count) {
    return '已移除 $count 个未使用对象。';
  }

  @override
  String get lawnMowerTitle => '小推车样式设置';

  @override
  String get lawnMowerNotes => '注意事项';

  @override
  String get lawnMowerHelpOverview => '本模块用于控制关卡中小推车的样式外观，注意在庭院框架下小推车模块无效。';

  @override
  String get lawnMowerHelpNotes => '小推车模块通常直接引用自 LevelModules，无需在关卡内自定义参数。';

  @override
  String get lawnMowerSelectType => '选择小推车类型';

  @override
  String get zombieRushTitle => '关卡计时模块';

  @override
  String get zombieRushHelpOverview => '僵尸清除计划里的倒计时模块，在倒计时结束后关卡会结束进行结算。';

  @override
  String get zombieRushHelpNotes => '注意事项';

  @override
  String get zombieRushHelpIncompat =>
      '潘追的计时器模块和庭院不兼容会闪退，所以软件推荐使用僵尸清除计划里的计时模块。';

  @override
  String get zombieRushTimeSettings => '时间设置';

  @override
  String get levelCountdown => '关卡倒计时（秒）';

  @override
  String get tunnelDefendTitle => '地宫坑道设置';

  @override
  String get tunnelDefendHelpOverview => '使用本模块在关卡里添加地宫秘境的地道，部分僵尸与植物的交互会被地道影响。';

  @override
  String get tunnelDefendHelpUsage => '使用说明';

  @override
  String get tunnelDefendHelpUsageBody =>
      '先在下方列表中选择一个地道组件，在上方网格中点击即可放置。点击已有的相同组件可将其移除，点击不同的组件可直接替换。';

  @override
  String get tunnelDefendSelectComponent => '选择组件';

  @override
  String get tunnelDefendPlacedCount => '已放置组件';

  @override
  String get tunnelDefendClearAll => '清空全部';

  @override
  String get tunnelDefendClearConfirmTitle => '确定要清空全部地道组件吗？';

  @override
  String get tunnelDefendClearConfirmMessage => '将移除场上所有已放置的地道组件，此操作不可撤销。';

  @override
  String get tunnelDefendPathOutsideLawn => '场地外的路径组件：';

  @override
  String get tunnelDefendDeleteOutside => '删除场地外的路径组件';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle => '确定要删除场地外的路径组件吗？';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      '将移除 5×9 场地之外的路径组件，此操作不可撤销。';

  @override
  String get tunnelDefendTileStylePreset => '地砖样式预设';

  @override
  String get tunnelDefendTileStylePart1 => '地宫遗迹（第一章）';

  @override
  String get tunnelDefendTileStylePart2 => '地宫镇魂（第二章）';

  @override
  String get tunnelDefendSequenceInterval =>
      '坑道序列间隔 (TunnelSequenceInterval，秒)';

  @override
  String get tunnelDefendHelpSequenceInterval => '序列间隔';

  @override
  String get tunnelDefendHelpSequenceIntervalBody => '坑道序列步骤之间的延迟。数值越小，路径出现越快。';

  @override
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties =>
      '最终阶段限时挑战';

  @override
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties =>
      '僵王最终阶段的限时击杀挑战';

  @override
  String get finalStageTimeLimitedChallengeTitle => '最终阶段限时挑战';

  @override
  String get finalStageTimeLimitedChallengeHelpTitle => '最终阶段限时挑战模块说明';

  @override
  String get finalStageTimeLimitedChallengeHelpIntro =>
      '为僵王最终阶段添加限时击杀挑战（常用于秦始皇僵王战）。';

  @override
  String get finalStageTimeLimitedChallengeHelpParams => '参数配置';

  @override
  String get finalStageTimeLimitedChallengeHelpParamsBody =>
      '默认使用 LevelModules 中的定义（RTID(FinalStageTimeLimitedChallenge@LevelModules)）。可启用自定义本地参数，在 @CurrentLevel 下编写独立配置。';

  @override
  String get finalStageTimeLimitedChallengeTimeLimit =>
      '僵王限时 (ZombossTimeLimit，秒)';

  @override
  String get moduleTitle_LawnMowerProperties => '小推车';

  @override
  String get moduleDesc_LawnMowerProperties => '关卡小推车样式';

  @override
  String get moduleTitle_TunnelDefendModuleProperties => '地宫坑道';

  @override
  String get moduleDesc_TunnelDefendModuleProperties => '设置地宫秘境的坑道及地砖样式';

  @override
  String get moduleTitle_WitchModuleProperties => '女巫登场';

  @override
  String get moduleDesc_WitchModuleProperties => '惊吓巫婆周期性掠过场地，泼洒魔法药剂';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties => '格列佛隧道';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      '在场地上预置可以使经过单位变大变小的隧道';

  @override
  String get witchModuleTitle => '女巫登场设置';

  @override
  String get witchModuleHelpTitle => '女巫登场模块说明';

  @override
  String get witchModuleHelpIntro =>
      '使用本模块会为关卡添加2名惊吓巫婆。关卡开始后，惊吓巫婆会从场地左侧或右侧随机选择一行突入，骑着魔法扫帚快速掠过场地，并在沿途随机洒下魔法药剂，随后每隔一段时间返回场地，重复上述操作。\n不同药剂拥有不同效果：橙色爆炸药剂会对落点周围3×3范围造成百分比伤害；绿色变形药剂会将单格植物变为羊、青蛙或鸡中的一种，也有概率将其变为高坚果卡片；蓝色亡灵药剂会在持续时间内不断复活落点周围3×3范围内死亡的僵尸；红色狂化药剂会为僵尸提供生命值和移动速度加成。\n惊吓巫婆无法被植物攻击。使用高坚果可以将其撞离场地；若高坚果释放过能量豆大招，则会直接将巫婆撞碎，使其不再出现。';

  @override
  String get witchModuleHelpParams => '参数配置';

  @override
  String get witchModuleHelpParamsBody =>
      '常规情况下，本模块使用在游戏文件里的定义，也可以选择打开自定义开关，对巫婆出现的间隔进行编辑。';

  @override
  String get witchModuleSpawnInterval => '女巫出现间隔 (WitchSpawnInterval，单位：秒)';

  @override
  String get gulliverTunnelTitle => '格列佛隧道';

  @override
  String get gulliverTunnelHelpOverview =>
      '本模块用于放置关卡开始前场地上的格列佛隧道。根据朝向不同，格列佛隧道分为两种：小口朝右、大口朝左，以及小口朝左、大口朝右。\n从小口进入的小鬼僵尸会变为巨型小鬼僵尸，拥有更高血量；从大口进入的常规僵尸会变为小小僵尸，移速更快，且可以躲避部分较高的平射子弹。\n植物的平射子弹也可进入大口，在被缩小后从小口射出，伤害降低；抛投子弹可越过隧道直接攻击僵尸。';

  @override
  String get gulliverTunnelHelpUsage => '使用说明';

  @override
  String get gulliverTunnelHelpUsageBody =>
      '先在下方选择隧道的朝向，然后点击网格放置。再次点击已有隧道的格可将其移除；选择不同朝向后点击已有隧道的格可以替换其朝向。';

  @override
  String get gulliverTunnelOrientationBigOnLeft => '小口朝右，大口朝左';

  @override
  String get gulliverTunnelOrientationBigOnRight => '小口朝左，大口朝右';

  @override
  String get gulliverTunnelPlacedCount => '已放置';

  @override
  String get gulliverTunnelClearAll => '清空全部';

  @override
  String get gulliverTunnelClearConfirmTitle => '确定要清空全部格列佛隧道吗？';

  @override
  String get gulliverTunnelClearConfirmMessage => '将移除场上所有已放置的格列佛隧道，此操作不可撤销。';

  @override
  String get gulliverTunnelSelectOrientation => '选择隧道朝向';

  @override
  String get gulliverTunnelOutsideLawn => '场地外的隧道：';

  @override
  String get gulliverTunnelDeleteOutside => '删除场地外的隧道';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle => '确定要删除场地外的隧道吗？';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      '将移除 5×9 场地之外的格列佛隧道，此操作不可撤销。';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => '主题配置';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      '为关卡配置来自潘妮的追击、回忆之旅等模式的主题效果';

  @override
  String get riftThemeModuleTitle => '主题配置';

  @override
  String get riftThemeHelpTitle => '主题配置模块说明';

  @override
  String get riftThemeHelpOverview =>
      '本模块用于为关卡添加主题列表。主题是在潘妮的追击、回忆之旅、时空秘境等模式中出现的全局机制，不同的主题有着不同的效果。各主题的详细说明请参阅创辅文件。';

  @override
  String get riftThemeHelpUsage => '使用说明';

  @override
  String get riftThemeHelpUsageBody =>
      '点击右下角按钮打开主题选择界面。点击主题可将其加入或移出主题列表。全部设置完成后，再次点击右下角按钮确认，即可完成添加。主题将在关卡中按照列表顺序依次生效。';

  @override
  String get riftThemeHelpUnique => '添加规范';

  @override
  String get riftThemeHelpUniqueBody => '每个主题最多在列表中添加一次。添加过多主题可能造成关卡闪退。';

  @override
  String get riftThemeEmpty => '尚未选择主题。点击右下角按钮选择主题。';

  @override
  String get riftThemeAddTheme => '添加主题';

  @override
  String get riftThemeSelectThemes => '选择主题';

  @override
  String get riftThemeSelectTheme => '主题';

  @override
  String get riftThemeSearchPlaceholder => '搜索主题名称或代码名';

  @override
  String get riftThemeAlreadyAdded => '已添加';

  @override
  String get riftThemeNoSearchResults => '没有匹配的主题';

  @override
  String get riftThemeAllUsedTitle => '已添加全部主题';

  @override
  String get riftThemeAllUsedMessage => '所有列表中主题均已添加。每个主题只能添加一次。';

  @override
  String get moduleTitle_ZombieRushModuleProperties => '关卡倒计时';

  @override
  String get moduleDesc_ZombieRushModuleProperties => '倒计时结束后关卡直接结算';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => '斗转星移';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties => '配置一代传送门的生成情况';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => '猜猜我是谁';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties => '配置魔术帽的召唤情况，开启后可选择魔术帽';

  @override
  String get pvz1CopycatsModuleTitle => '猜猜我是谁';

  @override
  String get pvz1CopycatsSectionParams => '参数配置';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel => '召唤僵尸权重 (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      '单次召唤时出现僵尸的概率（范围为0-1），用1减去该值即可得到植物出现的概率。';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      '召唤植物阶级 (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel => '魔术帽召唤出的植物的阶级。';

  @override
  String get pvz1CopycatsSectionPlantBlackList => '植物黑名单 (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      '每种魔术帽都有独立的可召唤植物列表，列表不受黑名单影响，因此修改黑名单没有意义。';

  @override
  String get pvz1CopycatsSectionZombieWhiteList => '僵尸白名单 (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList => '魔术帽仅会召唤白名单中的僵尸。';

  @override
  String get pvz1CopycatsHelpTip =>
      '添加此模块后，不要忘记在种子库或传送带模块中预选魔术帽。长按或右键点击选择植物界面的魔术帽，可以预览该魔术帽可能召唤的植物。';

  @override
  String get pvz1CopycatsHelpOverview =>
      '本模块用于配置卡槽中可种植的魔术帽的召唤情况，常用于回忆之旅小游戏“猜猜我是谁”关卡。缺少该模块时，魔术帽将无法正常召唤。不同种类的魔法帽有着不同的阳光消耗和冷却时间。魔术帽种下后会在片刻内变为随机的植物或僵尸。\n植物从魔术帽自身的植物列表中选择，僵尸仅会从白名单中选择。植物或僵尸列表中各项的出现权重无法单独设置。';

  @override
  String get pvz1CopycatsHelpFieldsTitle => '参数介绍';

  @override
  String get pvz1CopycatsPlantListEmpty => '黑名单为空';

  @override
  String get pvz1CopycatsZombieListEmpty => '白名单为空';

  @override
  String get pvz1CopycatsAddPlant => '向黑名单添加植物';

  @override
  String get pvz1CopycatsAddZombie => '向白名单添加僵尸';

  @override
  String get magicHatSpawnPreviewTitle => '魔术帽可能召唤的植物';

  @override
  String get magicHatSpawnPreviewEmpty => '没有符合黑名单条件的植物。';

  @override
  String get pvz1PassageModuleTitle => '斗转星移';

  @override
  String get pvz1PassageSectionParams => '传送门参数';

  @override
  String get pvz1PassageHelpOverview =>
      '本模块用于配置一代风格的传送门，常用于回忆之旅小游戏“斗转星移”关卡。传送门成对出现，影响植物子弹和僵尸的运动轨迹，每隔一段时间会改变位置。注意传送门不会影响植物的索敌范围，即植物不会主动攻击前方传送门另一端的僵尸，只会在本行有僵尸时发动攻击。';

  @override
  String get pvz1PassageHelpFieldsTitle => '参数介绍';

  @override
  String get pvz1PassageFieldGroupAmount => '传送门种类 (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      '关卡中出现的传送门种类数。一代风格的传送门共有两种：方形和圆形。若设为1，则只会出现方形传送门；设为2时，方形传送门和圆形传送门会同时出现；设为3及以上时，多余的传送门种类会显示为阳光贴图，这些传送门不会刷新位置，但仍然可以传送僵尸。';

  @override
  String get pvz1PassageFieldPassageAmount => '每组传送门数量 (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      '每一组内传送门的数量。例如，设为2时，每种类型各有2个传送门。传送门的总数不能超过生成区域内的格子数。如果同一类型中存在多个可传送的传送门，僵尸会始终传送到指定的那个传送门。';

  @override
  String get pvz1PassageFieldGridXMin => '最小生成列数 (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return '传送门可出现的最左列。场地左边界为0列，右边界为$maxIndex列。最小生成列数必须小于最大生成列数。';
  }

  @override
  String get pvz1PassageFieldGridXMax => '最大生成列数 (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return '传送门可出现的最右列。场地左边界为0列，右边界为$maxIndex列。最大生成列数必须大于最小生成列数。';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      '同僵尸传送最短间隔 (transferCooldown，单位：秒)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      '同一只僵尸两次传送之间的最短时间。如果时间设置过短，僵尸在传送后未能在间隔内离开传送门所在格，则会在间隔结束后再次被传送回原传送门。';

  @override
  String get pvz1PassageFieldRefreshTime => '传送门位置刷新间隔 (refreshTime，单位：秒)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      '传送门重新生成位置的间隔。位置生成是逐个进行的，即每次刷新只会改变同一类型中的一个传送门的位置。';

  @override
  String get pvz1PassagePortalSpawnPreview => '传送门生成列预览';

  @override
  String get pvz1PassageHelpPreview => '生成范围预览预览';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return '橙色高亮区域表示传送门可能出现在哪些列。当前场地的列范围为 0–$maxIndex（包含场地两侧的边界）。本模块无法限制传送门生成行的范围。';
  }

  @override
  String get moduleWaveIndexZeroBasedHint => '这里0是第1波，以此类推';

  @override
  String get moduleWaveFieldZeroBased => '波次 (从0开始计数)';

  @override
  String get appearanceLabel => '出场';

  @override
  String get airDropShipGroupLabel => '组';

  @override
  String get moduleTitle_RenaiModuleProperties => '复兴时代模块';

  @override
  String get moduleDesc_RenaiModuleProperties => '启用复兴圆环和昼夜更替功能，配置复兴雕像和原石像';

  @override
  String get renaiModuleTitle => '复兴时代模块';

  @override
  String get renaiModuleHelpTitle => '复兴时代模块说明';

  @override
  String get renaiModuleHelpOverview => '简要介绍';

  @override
  String get renaiModuleHelpOverviewBody =>
      '此模块用于使复兴圆环响应启动按钮，设置昼夜更替的波次，并在夜幕降临时按配置复活雕像、原石像及生成障碍物，通常在复兴时代地图使用。';

  @override
  String get renaiModuleHelpStatues => '部分功能介绍';

  @override
  String get renaiModuleHelpStatuesBody =>
      '初始障碍物指关卡开始时场上已存在的雕像和原石像，会在指定波次复活成为僵尸。夜间障碍物指黑夜开始后生成的障碍物，生成时若目标格上已有植物，则不会生成。黑夜开始的波次在代码中从0开始计数（如第1波入夜为0，第2波入夜为1）。';

  @override
  String get renaiModuleEnableNight => '启用昼夜更替功能';

  @override
  String get renaiModuleEnableNightSubtitle => '允许设置夜幕降临的波次和夜间障碍物';

  @override
  String get renaiModuleNightStart => '黑夜开始波次';

  @override
  String get renaiModuleDayStatues => '初始障碍物';

  @override
  String get renaiModuleNightStatues => '夜间障碍物';

  @override
  String get renaiModuleNightStatuesDisabledHint => '请先启用昼夜更替功能';

  @override
  String get renaiModuleAddStatue => '添加雕像';

  @override
  String get renaiModuleCarveWave => '雕像复活波次';

  @override
  String get renaiModuleStatuesInCell => '当前格子中的物品';

  @override
  String get renaiModuleExpectationLabel => '夜幕降临事件';

  @override
  String get renaiModuleNightStarts => '黑夜开始';

  @override
  String get renaiModuleStatueCarve => '雕像复活';

  @override
  String get moduleTitle_DropShipProperties => '运兵艇突袭';

  @override
  String get moduleDesc_DropShipProperties => '将飞行小鬼僵尸空投至场地';

  @override
  String get airDropShipModuleTitle => '运兵艇突袭';

  @override
  String get airDropShipModuleHelpTitle => '运兵艇突袭模块说明';

  @override
  String get airDropShipModuleHelpOverview => '简要介绍';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      '此模块用于配置关卡中随波次出现的运兵艇，常见于天空之城关卡。运兵艇不会受到攻击，指定数量的飞行小鬼僵尸会从中依次降落到指定投放区域内的位置。';

  @override
  String get airDropShipModuleHelpImps => '参数介绍';

  @override
  String get airDropShipModuleHelpImpsBody =>
      '运兵艇的出现波次从0开始计数，如第1波登场填0，第2波登场填1。运兵艇至少会投放1只飞行小鬼僵尸，因此额外小鬼数量填写的是在这1只的基础上，该波次额外投放的小鬼数量。';

  @override
  String get airDropShipModuleAppearWaves => '出现波次（Wave, 从0开始计数）';

  @override
  String get airDropShipModuleAppearances => '投放组';

  @override
  String get airDropShipModuleExtraImpCount => '额外小鬼数量 (Imp)';

  @override
  String get airDropShipModuleDropArea => '投放区域';

  @override
  String get airDropShipModuleDropAreaPreview => '投放区域预览';

  @override
  String get airDropShipModuleExpectationLabel => '空投小鬼';

  @override
  String get airDropShipModuleImpLevel => '小鬼等级 (ImpLv)';

  @override
  String get airDropShipModuleRowMin => '起始行';

  @override
  String get airDropShipModuleRowMax => '结束行';

  @override
  String get airDropShipModuleColMin => '起始列';

  @override
  String get airDropShipModuleColMax => '结束列';

  @override
  String get openModuleSettings => '打开模块设置';

  @override
  String get moduleTitle_GlacierModuleProperties => '冰川召唤';

  @override
  String get moduleDesc_GlacierModuleProperties => '冰河僵王冰川障碍物召唤僵尸的权重（从左起共 6 列）';

  @override
  String get glacierModuleTitle => '冰川模块';

  @override
  String get glacierModuleHelpTitle => '冰川模块说明';

  @override
  String get glacierModuleHelpOverviewBody =>
      '配置冰河僵王破坏冰川障碍物时召唤的僵尸种类与权重。请放在关卡开头 Modules 列表中；未配置则冰川不会召唤僵尸。';

  @override
  String get glacierModuleHelpColumnsTitle => '列与条目';

  @override
  String get glacierModuleHelpColumnsBody =>
      'ZombieSpawnData 必须恰好 6 个元素，从最左第 1 列起每列一项。每列内为加权列表：TypeName（僵尸种类）、Weight（权重）、Level（等级 0–10）。';

  @override
  String get glacierModuleHelpRequirementsTitle => '使用条件';

  @override
  String get glacierModuleHelpRequirementsBody =>
      '须与僵王战斗模块同时使用，且所选僵王为冰河机甲变体（zombossmech_iceage 及其变体）时才会生效。';

  @override
  String get glacierModuleCompatibilityWarning =>
      '此模块须与僵王战斗模块一起使用，且僵王须为冰河机甲（zombossmech_iceage）。请添加或修正相关设置，冰川障碍物才能召唤僵尸。';

  @override
  String glacierModuleColumn(int columnIndex) {
    return '第 $columnIndex 列（自左）';
  }

  @override
  String glacierModuleEntryCount(int count) {
    return '$count 条';
  }

  @override
  String glacierModuleEntryLabel(int index) {
    return '条目 $index';
  }

  @override
  String get glacierModuleNoEntries => '此列暂无僵尸条目。';

  @override
  String get glacierModuleAddEntry => '添加僵尸条目';

  @override
  String get glacierModuleSelectZombie => '选择僵尸';

  @override
  String get glacierModuleEmptyType => '未选择僵尸';

  @override
  String get glacierModuleWeight => '权重';

  @override
  String get glacierModuleWeightTooltip => '该僵尸在本列的相对召唤权重。';

  @override
  String get glacierModuleLevel => '等级（0–10）';

  @override
  String get glacierModuleLevelTooltip => '僵尸等级，范围 0 至 10。';

  @override
  String get moduleTitle_HeianWindModuleProperties => '平安神风';

  @override
  String get moduleDesc_HeianWindModuleProperties => '推动僵尸平移并击飞植物的风';

  @override
  String get heianWindModuleTitle => '平安神风设置';

  @override
  String get heianWindModuleHelpTitle => '平安神风模块说明';

  @override
  String get heianWindModuleHelpOverview => '简要介绍';

  @override
  String get heianWindModuleHelpOverviewBody =>
      '此模块用于在指定波次召唤神风，常见于平安时代关卡。神风会推动覆盖范围内指定数量的中小体型僵尸平移一段距离。一个波次内所有神风结束后，该波次中被单行神风作用过的行会生成旋风，一行最多只会生成一道旋风。旋风会裹挟遇到的僵尸前进，并在接触植物时将其击飞，随后消失。';

  @override
  String get heianWindModuleHelpDistance => '平移距离';

  @override
  String get heianWindModuleHelpDistanceBody =>
      '1格等于50距离。距离为负值时，神风推动僵尸向左平移；距离为正值时，神风推动僵尸向右平移。';

  @override
  String get heianWindModuleHelpRow => '覆盖范围';

  @override
  String get heianWindModuleHelpRowBody =>
      '神风的出现波次从0开始计数，如第1波降临填0，第2波降临填1。神风的作用行也从0开始计数，除了可以指定作用在单独一行外，也可以设为-1，使神风作用于全屏；此时不会生成旋风。';

  @override
  String get heianWindModuleWaves => '神风的出现波次 (WaveNumber，从0开始计数)';

  @override
  String get heianWindModuleAppearances => '召唤批次';

  @override
  String get heianWindModuleWindDelay => '神风生成间隔 (WindDelay, 单位：秒)';

  @override
  String get heianWindModuleWindEntries => '神风具体配置';

  @override
  String get heianWindModuleAddWind => '添加神风';

  @override
  String get heianWindModuleRow => '单行神风 (从0开始计数)';

  @override
  String get heianWindModuleAllRows => '全屏大风 (-1)';

  @override
  String get heianWindModuleAffectZombies => '影响僵尸数量 (AffectZombies)';

  @override
  String get heianWindModuleDistance => '僵尸平移距离 (Distance，1格=50距离)';

  @override
  String get heianWindModuleMoveTime => '僵尸平移时间 (MoveTime，单位：秒)';

  @override
  String get heianWindModuleExpectationLabel => '神风配置';

  @override
  String get jsonViewerModeReading => '（纯文本视图）';

  @override
  String get jsonViewerModeObjectReading => '（结构化视图）';

  @override
  String get jsonViewerModeEdit => '（编辑模式）';

  @override
  String get tooltipAboutModule => '关于此模块';

  @override
  String get tooltipAboutEvent => '关于此事件';

  @override
  String get tooltipSave => '保存';

  @override
  String get tooltipEdit => '编辑';

  @override
  String get tooltipClose => '关闭';

  @override
  String get tooltipToggleObjectView => '切换纯文本/结构化视图';

  @override
  String get tooltipClearUnused => '清除未使用对象';

  @override
  String get tooltipJsonViewer => '查看/编辑 JSON文件';

  @override
  String get tooltipAdd => '添加';

  @override
  String get tooltipDecrease => '减少';

  @override
  String get tooltipIncrease => '增加';

  @override
  String get bungeeWaveEventTitle => '蹦极投放事件';

  @override
  String get bungeeWaveEventHelpTitle => '蹦极投放事件说明';

  @override
  String get bungeeWaveEventHelpOverview =>
      '在关卡中设置蹦极僵尸投放僵尸的种类与位置，单个事件只能投放一只僵尸。';

  @override
  String get bungeeWaveEventHelpGrid => '坐标说明';

  @override
  String get bungeeWaveEventHelpGridBody => '在下方网格中点击，即可设置蹦极僵尸的落点位置。';

  @override
  String get bungeeWaveCurrentTarget => '当前目标';

  @override
  String get bungeeWaveCol => 'Col';

  @override
  String get bungeeWaveRow => 'Row';

  @override
  String get bungeeWavePropertiesConfig => '属性配置';

  @override
  String get bungeeWaveZombieLevel => '僵尸等级 (Level)';

  @override
  String get bungeeWaveRoofWarning => '注意在屋顶地图中蹦极投放事件被叶子保护伞拦截后有可能直接触发食脑，请谨慎使用。';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => '追击阳光掉落';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps => '击败僵尸掉落阳光';

  @override
  String get zombieSunDropTitle => '僵尸掉落阳光配置';

  @override
  String get zombieSunDropHelpTitle => '僵尸掉落阳光说明';

  @override
  String get zombieSunDropHelpOverview =>
      '此模块用于设置特定僵尸在关卡中掉落的阳光数值，用于追击第五关。该模块的副作用是让阳光铲失效。';

  @override
  String get zombieSunDropHelpValues => '数值设置';

  @override
  String get zombieSunDropHelpValuesBody =>
      '10个整数对应僵尸在1到10阶时的掉落的阳光，若阶级超过6则使用1阶的数据。';

  @override
  String get zombieSunDropEmpty => '暂无配置，点击右下角添加';

  @override
  String get zombieSunDropDefaultDrop => '默认掉落';

  @override
  String get zombieSunDropSun => '阳光';

  @override
  String get zombieSunDropEditTitle => '编辑具体数值';

  @override
  String get zombieSunDropEditHint => '配置该僵尸在不同阶级的阳光掉落量，若超过6阶则使用1阶数值';

  @override
  String get zombieSunDropTier => '阶级';

  @override
  String get moduleTitle_PickupCollectableTutorialProperties => '捡取教程';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties => '击败特定僵尸弹出对话教程';

  @override
  String get pickupCollectableTutorialTitle => '捡取教程属性';

  @override
  String get pickupCollectableTutorialHelpTitle => '捡取教程说明';

  @override
  String get pickupCollectableTutorialHelpBasic => '基本描述';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      '用于配置掉落特定物品的僵尸，以及捡取前后的文字提示引导。在关卡中首次击杀该种类的僵尸（含自定义僵尸）会弹出对话框。';

  @override
  String get pickupCollectableTutorialHelpDialogs => '对话提示';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      '在捡起掉落物前后都会弹出对话框提示，对话会延缓关卡的进程，阻碍下一波刷新。';

  @override
  String get pickupCollectableTutorialCoreConfig => '核心配置';

  @override
  String get pickupCollectableTutorialZombieLabel => '携带物品的僵尸';

  @override
  String get pickupCollectableTutorialLootType => '掉落物品类型';

  @override
  String get pickupCollectableTutorialGuideText => '引导文本';

  @override
  String get pickupCollectableTutorialPickupAdvice => '捡取前提示 (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      '捡取后提示 (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => '未设置';

  @override
  String get pickupCollectableLootGoldCoin => '金币';

  @override
  String get invalidRtonMagic => 'RTON 文件无效，文件开头应为「RTON」。';

  @override
  String get invalidRtonVersion => 'RTON 版本无效（应为 1）。';

  @override
  String get invalidRtonEnd => 'RTON 文件无效，应以「DONE」结尾。';

  @override
  String get invalidRtonArrayEnd => '无效的RTON 数组分隔符。';

  @override
  String get invalidRtid => '无效的 RTID 值。';

  @override
  String get invalidValueType => 'RTON 不支持该值类型。';

  @override
  String get musicSuffix => '音乐模块';

  @override
  String get ambientAudioSuffix => '背景环境白噪音';

  @override
  String get selectMusicSuffix => '选择音乐模块';

  @override
  String get searchMusicSuffix => '搜索名称或代码名';

  @override
  String get noMusicSuffixFound => '未找到音乐模块';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => '自定义';

  @override
  String get editCustomZombossMech => '编辑';

  @override
  String get customZombossMechProperties => '自定义 ZombossMech 属性';

  @override
  String get customZombossMechScalars => '常规';

  @override
  String get customZombossMechStages => '战斗阶段';

  @override
  String get customZombossMechEditHint => '编辑关卡内 memo（自定义）机甲变体的属性表。';

  @override
  String get zombossMechMinColumn => '最小列';

  @override
  String get zombossMechMaxColumn => '最大列';

  @override
  String get zombossMechStageActions => '动作';

  @override
  String get zombossMechActions => '动作';

  @override
  String get zombossMechPropertiesLabel => '属性';

  @override
  String get zombossMechAliasLabel => '别名';

  @override
  String get zombossMechDeletePhase => '删除阶段';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return '删除第 $number 阶段？';
  }

  @override
  String get zombossMechDeletePhaseMessage => '将移除此阶段及其动作列表，且无法撤销。';

  @override
  String get zombossMechPhasesHelp =>
      '每个阶段包含生命值、按顺序执行的动作列表（自上而下），以及可选的撤退动作（若机甲支持）。';

  @override
  String get zombossMechAddAction => '添加动作';

  @override
  String get zombossMechNoStageActions => '暂无动作';

  @override
  String get zombossMechSelectAction => '选择动作';

  @override
  String get zombossMechSelectRetreatAction => '选择撤退动作';

  @override
  String get zombossMechCreateCustomAction => '新建自定义动作';

  @override
  String get zombossMechEditCustomAction => '编辑自定义动作';

  @override
  String get zombossMechActionCategoryAll => '全部';

  @override
  String get zombossMechActionCategoryMovement => '移动';

  @override
  String get zombossMechActionCategoryAttack => '攻击';

  @override
  String get zombossMechActionCategorySpecial => '特殊';

  @override
  String get zombossMechActionCategorySpawn => '召唤';

  @override
  String get zombossMechActionCategoryRetreat => '撤退';

  @override
  String get zombossMechNoActionsFound => '未找到动作';

  @override
  String get zombossMechCustomActionLabel => '自定义（CurrentLevel）';

  @override
  String get zombossMechActionAliasHint =>
      '用于 RTID(别名@CurrentLevel) 的代号，可稍后修改；本属性表中的引用会自动更新。';

  @override
  String get zombossMechActionBaseObjclass => '基础 objclass';

  @override
  String get zombossMechEditRetreatAction => '选择撤退动作';

  @override
  String get zombossMechAddZombie => '添加僵尸';

  @override
  String get zombossMechPickZombie => '选择僵尸';

  @override
  String get zombossMechNoZombiesInList => '列表中暂无僵尸';

  @override
  String get zombossMechCatalogActionReadOnly => '内置动作无法在此编辑。请创建自定义动作以修改僵尸列表。';

  @override
  String get zombossMechRetreatDisabled => '已禁用';

  @override
  String get zombossMechOpenGlacierModule => '打开冰川模块设置';

  @override
  String get zombossMechRobotSpawnRow => '行';

  @override
  String get zombossMechRobotSpawnRowRandom => '随机 (-1)';

  @override
  String get zombossMechRobotSpawnLevel => '等级';

  @override
  String get zombossMechRobotSpawnWeight => '权重';

  @override
  String get zombossMechRobotSpawnPlantfood => '植物食物';

  @override
  String get zombossMechRetreatAction => '撤退动作';

  @override
  String zombossMechPhaseNumber(int number) {
    return '第 $number 阶段';
  }

  @override
  String get zombossMechAddPhase => '添加阶段';

  @override
  String get zombossMechRemovePhase => '移除阶段';

  @override
  String get zombossMechHitPoints => '生命值';

  @override
  String get continueAnyway => '仍然继续';

  @override
  String get armrackModuleTitle => '兵器架';

  @override
  String get armrackModuleHelpTitle => '兵器架模块说明';

  @override
  String get armrackModuleHelpOverview => '简要介绍';

  @override
  String get armrackModuleHelpOverviewBody =>
      '在第一波于场上放置兵器架。此模块用于让兵器架在编辑器和游戏中正常显示，避免出现错误的阳光贴图。';

  @override
  String get armrackModuleHelpPlacement => '放置方式';

  @override
  String get armrackModuleHelpPlacementBody =>
      '选择兵器架类型后点击格子放置（每格仅一个）。桌面端右键或移动端长按可删除该格兵器架。';

  @override
  String get armrackModuleHelpWaveLimit => '波次限制';

  @override
  String get armrackModuleHelpWaveLimitBody =>
      '由于游戏限制，仅第一波配置在游戏中生效。仍可在此编辑其他波次组并保存到关卡文件，但只有第一波会显示在波次时间轴。';

  @override
  String get armrackModuleTypePalette => '兵器架类型';

  @override
  String get armrackModuleExpectationLabel => '兵器架';

  @override
  String get armrackModuleIgnoredWaveOverridesWarning =>
      '此关卡包含第一波以外的兵器架配置。这些配置会保留，但不会显示在波次时间轴中，因为游戏仅应用第一波。';

  @override
  String armrackModuleRequiredMessage(String moduleName) {
    return '为使兵器架正常显示且不出现阳光贴图，需要添加「$moduleName」模块。';
  }

  @override
  String get energyGridModuleTitle => '太极瓷砖';

  @override
  String get energyGridModuleHelpTitle => '太极瓷砖模块说明';

  @override
  String get energyGridModuleHelpOverview => '简要介绍';

  @override
  String get energyGridModuleHelpOverviewBody =>
      '在第一波于场上放置太极瓷砖。此模块用于让太极瓷砖在编辑器和游戏中正常显示。';

  @override
  String get energyGridModuleHelpPlacement => '放置方式';

  @override
  String get energyGridModuleHelpPlacementBody =>
      '点击空格放置太极瓷砖（每格仅一个）。桌面端右键或移动端长按可删除。';

  @override
  String get energyGridModuleHelpWaveLimit => '波次限制';

  @override
  String get energyGridModuleHelpWaveLimitBody =>
      '由于游戏限制，仅第一波配置在游戏中生效。仍可在此编辑其他波次组并保存到关卡文件，但只有第一波会显示在波次时间轴。';

  @override
  String get energyGridModuleTapToPlace => '点击空格放置太极瓷砖。';

  @override
  String get energyGridModuleExpectationLabel => '太极瓷砖';

  @override
  String get energyGridModuleIgnoredWaveOverridesWarning =>
      '此关卡包含第一波以外的太极瓷砖配置。这些配置会保留，但不会显示在波次时间轴中，因为游戏仅应用第一波。';

  @override
  String get energyGridModuleWarningMessage =>
      '由于游戏端问题，生成的太极瓷砖可能显示为紫色 X 标记，这不影响实际功能。若希望正常显示，建议重启游戏。同时需要太极瓷砖模块才能正确显示。仍然继续？';

  @override
  String get gridOverrideModuleAppearances => '波次组';

  @override
  String get gridOverrideModuleWaveFieldOneBased => '波次（1 = 第一波，2 = 第二波，…）';

  @override
  String get gridOverrideModuleTimelineNote => '仅第一波条目会显示在波次时间轴中。';
}
