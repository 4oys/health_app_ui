import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app_ui/main.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HealthUiApp());
    await tester.tap(find.text('У меня уже есть аккаунт'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Войти'));
    await tester.pumpAndSettle();
  }

  testWidgets('Вода обновляется на главной', (tester) async {
    await openApp(tester);
    await tester.scrollUntilVisible(
      find.text('+ 250 мл'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('+ 250 мл'));
    await tester.pumpAndSettle();
    expect(find.text('250 / 2000 мл'), findsOneWidget);
    await tester.tap(find.text('+ 500 мл'));
    await tester.pumpAndSettle();
    expect(find.text('750 / 2000 мл'), findsOneWidget);
    await tester.tap(find.byTooltip('Убрать 250 мл'));
    await tester.pumpAndSettle();
    expect(find.text('500 / 2000 мл'), findsOneWidget);
  });

  testWidgets('Новая еда сохраняется в дневнике', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить приём пищи'));
    await tester.pumpAndSettle();
    expect(find.text('Название блюда или приёма пищи'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Название блюда или приёма пищи'),
      'Яблоко',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Калории, ккал'),
      '52',
    );
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Добавить приём пищи'), findsOneWidget);
    await tester.ensureVisible(find.text('Яблоко'));
    expect(find.text('Яблоко'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(find.text('629'), findsOneWidget);
  });

  testWidgets('Просмотр сводки открывается без сообщения-заглушки', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Посмотреть сводку здоровья'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Посмотреть сводку здоровья'));
    await tester.pumpAndSettle();
    expect(find.text('Сводка здоровья'), findsOneWidget);
    expect(find.textContaining('ИМТ:'), findsOneWidget);
  });
}
