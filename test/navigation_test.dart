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

  testWidgets('Регистрация работает без ввода почты и пароля', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const HealthUiApp());
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    expect(find.text('Создать аккаунт'), findsOneWidget);
    expect(find.text('Электронная почта'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
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
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Выйти из аккаунта'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Выйти из аккаунта'));
    await tester.pumpAndSettle();
    expect(find.text('Начать'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Вход работает без ввода почты и пароля', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const HealthUiApp());
    await tester.tap(find.text('У меня уже есть аккаунт'));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Войти'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
