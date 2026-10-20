import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app_ui/main.dart';

void main() {
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Приложение открывается без ввода данных', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const HealthUiApp());
    expect(find.text('ANVIA'), findsOneWidget);
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final index in [1, 2, 3, 0]) {
      await tester.tap(find.byType(NavigationDestination).at(index));
      await tester.pumpAndSettle();
      expect(
        find.text(['Главная', 'Дневник', 'Аналитика', 'Профиль'][index]),
        findsWidgets,
      );
    }
  });

  testWidgets('Настройка профиля работает без ввода данных', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const HealthUiApp());
    await tester.tap(find.text('Настроить профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Как к вам обращаться?'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Настройка профиля'), findsOneWidget);
    await tester.ensureVisible(find.text('Открыть главную'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть главную'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
