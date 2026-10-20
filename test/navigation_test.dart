import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app_ui/main.dart';

void main() {
  testWidgets('Переход с экрана входа по четырём вкладкам', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HealthUiApp());
    expect(find.text('ANVIA'), findsOneWidget);
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(find.text('Создать аккаунт'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.ensureVisible(find.text('Продолжить к настройке'));
    await tester.tap(find.text('Продолжить к настройке'));
    await tester.pumpAndSettle();
    expect(find.text('Настройка профиля'), findsOneWidget);
    await tester.ensureVisible(find.text('Открыть главную'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть главную'));
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
}
