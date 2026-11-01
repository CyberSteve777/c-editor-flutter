import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('editor version and check button use the same font size', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'C-Editor',
      packageName: 'c_editor',
      version: '1.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AboutScreen(onBack: () {}),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('aboutCheckForUpdates'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    final version = find.textContaining('1.1.0');
    expect(version, findsOneWidget);
    final label = find.descendant(of: button, matching: find.text('检测更新'));
    final versionSize = tester.widget<Text>(version).style?.fontSize;
    final buttonSize = DefaultTextStyle.of(
      tester.element(label),
    ).style.fontSize;
    expect(buttonSize, versionSize);
    expect(tester.takeException(), isNull);
  });
  test('Chinese About copy keeps added features and enriches instructions', () {
    final l10n = lookupAppLocalizations(const Locale('zh'));

    expect(l10n.feature1, contains('实现快速配置'));
    expect(l10n.feature2, contains('等多种模式'));
    expect(l10n.feature3, contains('自定义僵尸'));
    expect(l10n.feature3, contains('自定义地图'));
    expect(l10n.feature3, contains('自定义僵王机甲'));
    expect(l10n.feature4, contains('预防关卡闪退'));
    expect(l10n.feature5, contains('植物、僵尸和障碍物图标'));

    for (final usage in [l10n.usageTextDesktop, l10n.usageTextMobile]) {
      expect(usage, contains('使用下方按钮'));
      expect(usage, isNot(contains('使用右下角按钮')));
      expect(usage, contains('“添加新模块”'));
      expect(usage, contains('自动回写到原 JSON 文件'));
      expect(usage, contains('.cplugin'));
      expect(usage, contains('URL'));
      expect(usage, contains('开启或禁用'));
      expect(usage, isNot(contains('QQ群')));
    }
    expect(l10n.discordInviteLabel, isEmpty);
  });

  test('English and Russian About copy includes the expanded feature set', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ru = lookupAppLocalizations(const Locale('ru'));

    expect(en.feature3, contains('custom lawns'));
    expect(en.feature3, contains('custom Zomboss mechs'));
    expect(en.feature5, contains('Resource previews'));
    expect(en.usageTextMobile, contains('button below'));
    expect(en.usageTextMobile, contains('.cplugin'));

    expect(ru.feature3, contains('мехами Зомбосса'));
    expect(ru.feature5, contains('Предпросмотр ресурсов'));
    expect(ru.usageTextMobile, contains('кнопку ниже'));
    expect(ru.usageTextMobile, contains('.cplugin'));
  });
}
