import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app_ui/features/diary/presentation/diary_screen.dart';
import 'package:health_app_ui/main.dart';

void main() {
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openApp(WidgetTester tester) async {
    phoneSize(tester);
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

  testWidgets('Новый день не содержит пустых приёмов пищи', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiaryScreen(
            entries: const [],
            catalog: const [],
            date: DateTime(2026, 10, 27),
            onDateSelected: (_) {},
            onAddEntry: (_) {},
            onDeleteMeal: (_) {},
            onDeleteEntry: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Завтрак'), findsNothing);
    expect(find.text('Обед'), findsNothing);
    expect(find.text('Ужин'), findsNothing);
    expect(find.text('Перекус'), findsNothing);
    expect(find.text('Добавить приём пищи'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Добавить приём пищи')).dy,
      greaterThan(600),
    );
  });

  testWidgets('Запись добавляется после выбора продукта и веса', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Завтрак'), findsOneWidget);
    expect(find.text('Обед'), findsOneWidget);
    expect(find.text('Ужин'), findsNothing);
    expect(find.text('Перекус'), findsNothing);
    await tester.tap(find.text('Добавить приём пищи'));
    await tester.pumpAndSettle();
    expect(find.text('Что вы ели?'), findsOneWidget);
    expect(find.byTooltip('Найти по штрихкоду'), findsOneWidget);
    expect(find.text('Сколько граммов?'), findsNothing);
    await tester.tap(find.text('Своё название'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Своё название'),
      'Поздний завтрак',
    );
    await tester.tap(find.text('Овсяная каша').last);
    await tester.pumpAndSettle();
    expect(find.text('Сколько граммов?'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Сколько граммов?'),
      '150',
    );
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Поздний завтрак'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(find.text('745'), findsOneWidget);
  });

  testWidgets('Поиск по штрихкоду открывает поле ввода', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить приём пищи'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Найти по штрихкоду'));
    await tester.pumpAndSettle();
    expect(find.text('Штрихкод продукта'), findsOneWidget);
    await tester.tap(find.text('Отмена').last);
    await tester.pumpAndSettle();
  });

  testWidgets('Случайно добавленный перекус можно удалить', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить приём пищи'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Перекус'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Овсяная каша').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Перекус'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Удалить приём пищи Перекус'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Перекус'), findsOneWidget);

    await tester.tap(find.byTooltip('Удалить приём пищи Перекус'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.text('Перекус'), findsNothing);
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(find.text('577'), findsOneWidget);
  });

  testWidgets('Последний продукт удаляет пустой приём пищи', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Удалить продукт Овсяная каша'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить продукт?'), findsOneWidget);
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.text('Завтрак'), findsNothing);
    expect(find.text('Обед'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(find.text('297'), findsOneWidget);
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
