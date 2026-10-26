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
      find.text('Помощь и вопросы'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Помощь и вопросы')),
      alignment: 1,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Помощь и вопросы'));
    await tester.pumpAndSettle();
    expect(find.text('Частые вопросы'), findsOneWidget);
    await tester.tap(find.text('Как добавить приём пищи?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('выберите тип приёма пищи'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Выйти из аккаунта'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Выйти из аккаунта')),
      alignment: 1,
    );
    await tester.pumpAndSettle();
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

  testWidgets('Профиль показывает выбранную активность без редактирования', (
    tester,
  ) async {
    phoneSize(tester);
    await tester.pumpWidget(const HealthUiApp());
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продолжить к настройке'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Высокая'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Высокая')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Высокая'));
    await Scrollable.ensureVisible(
      tester.element(find.text('Открыть главную')),
      alignment: 0.8,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть главную'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();

    expect(find.text('Высокая'), findsOneWidget);
    expect(find.text('5–6 тренировок в неделю'), findsOneWidget);
    expect(find.text('Идеально для категории'), findsNothing);
    expect(find.text('Взвешивание сегодня'), findsNothing);
    await tester.tap(find.text('Редактировать профиль'));
    await tester.pumpAndSettle();
    expect(
      find.text('Параметры пока доступны только для просмотра'),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Сохранить'), findsNothing);
    expect(find.text('74.2'), findsOneWidget);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.text('74.2 кг'), findsOneWidget);
    expect(find.text('Высокая'), findsOneWidget);
  });
}
