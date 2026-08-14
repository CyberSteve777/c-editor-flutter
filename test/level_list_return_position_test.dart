import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/data/repository/level_repository_base.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('level return target is session-only navigation state', () async {
    final navigation = AppNavigationCubit();
    addTearDown(navigation.close);

    navigation.openLevel('level.json', r'C:\levels\world\level.json');
    navigation.backToLevelList();

    expect(navigation.state.lastOpenedLevelPath, r'C:\levels\world\level.json');
    expect(navigation.state.screen, AppScreen.levelList);

    final restartedNavigation = AppNavigationCubit();
    addTearDown(restartedNavigation.close);
    expect(restartedNavigation.state.lastOpenedLevelPath, isEmpty);
  });

  test('builds native breadcrumbs to the returned level directory', () {
    final stack = levelListPathStackFor(
      rootPath: r'C:\levels',
      rootName: 'levels',
      levelPath: r'C:\levels\worlds\egypt\level.json',
    );

    expect(stack.map((item) => item.name), ['levels', 'worlds', 'egypt']);
    expect(stack.last.path, r'C:\levels\worlds\egypt');
  });

  test('builds web breadcrumbs and rejects targets outside the library', () {
    final webStack = levelListPathStackFor(
      rootPath: 'web://',
      rootName: 'My Workspace',
      levelPath: 'web://worlds/egypt/level.json',
    );
    expect(webStack.map((item) => item.path), [
      'web://',
      'web://worlds',
      'web://worlds/egypt',
    ]);

    final outsideStack = levelListPathStackFor(
      rootPath: r'C:\levels',
      rootName: 'levels',
      levelPath: r'C:\other\level.json',
    );
    expect(outsideStack, [(name: 'levels', path: r'C:\levels')]);
  });

  test('return offset follows the target current sorted index', () {
    final items = [
      FileItem(
        name: 'folder',
        path: r'C:\levels\folder',
        isDirectory: true,
        lastModified: 0,
        size: 0,
      ),
      FileItem(
        name: 'newest.json',
        path: r'C:\levels\newest.json',
        isDirectory: false,
        lastModified: 3,
        size: 1,
      ),
      FileItem(
        name: 'opened.json',
        path: r'C:\levels\opened.json',
        isDirectory: false,
        lastModified: 2,
        size: 1,
      ),
    ];

    expect(
      levelListOffsetForIndex(
        items,
        2,
        folderExtent: 80,
        fileExtent: 64,
      ),
      160,
    );
  });
}
