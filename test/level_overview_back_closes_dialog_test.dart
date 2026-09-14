import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/escape_override.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    while (ModalGate.isOpen) {
      ModalGate.leave();
    }
  });

  testWidgets('Escape closes modal without emptying navigator', (tester) async {
    final navigation = AppNavigationCubit();
    navigation.openLevel('test.json', '/tmp/test.json');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                if (EscapeOverride.tryHandle?.call() == true) return;
                if (ModalGate.tryAbsorb()) return;
                navigation.backToLevelList();
              },
              child: Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        useRootNavigator: true,
                        builder: (ctx) => EscapeClosesModal(
                          child: AlertDialog(
                            title: const Text('Overview'),
                            actions: [
                              TextButton(
                                onPressed: () => safeNavPop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);

    expect(EscapeOverride.tryHandle?.call(), isTrue);
    expect(ModalGate.shouldAbsorbBack, isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    expect(navigation.state.screen, AppScreen.editor);
  });

  testWidgets('Close button pops dialog under PopScope canPop false', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return PopScope(
              canPop: false,
              child: Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        useRootNavigator: true,
                        builder: (ctx) => EscapeClosesModal(
                          child: AlertDialog(
                            title: const Text('Overview'),
                            actions: [
                              TextButton(
                                onPressed: () => safeNavPop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
