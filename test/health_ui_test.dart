import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app_ui/features/diary/presentation/diary_screen.dart';
import 'package:health_app_ui/features/dashboard/presentation/dashboard_screen.dart';
import 'package:health_app_ui/features/health/domain/models.dart';
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
    await Scrollable.ensureVisible(
      tester.element(find.text('+ 250 мл')),
      alignment: 0.7,
    );
    await tester.pumpAndSettle();
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

  testWidgets('Баланс энергии учитывает еду и сожжённые калории', (
    tester,
  ) async {
    phoneSize(tester);
    final day = DateTime(2026, 10, 27);
    const product = Product(
      id: 3,
      name: 'Продукт для проверки',
      kcal: 500,
      protein: 20,
      fat: 10,
      carbs: 60,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardScreen(
            user: const UserProfile(calorieTarget: 2200),
            entries: [
              FoodEntry(
                id: 1,
                product: product,
                meal: 'Обед',
                grams: 100,
                date: day,
              ),
            ],
            activity: ActivityRecord(
              date: day,
              steps: 0,
              heartRate: 0,
              sleepMinutes: 0,
              burnedCalories: 120,
            ),
            date: day,
            waterMl: 0,
            onAddWater: (_) {},
            onUndoWater: () {},
          ),
        ),
      ),
    );

    expect(find.text('Баланс энергии'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('1820'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Съедено'), findsOneWidget);
    expect(find.text('Сожжено'), findsOneWidget);
    expect(find.text('Осталось'), findsOneWidget);
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

  testWidgets('Приёмы пищи показаны в порядке добавления', (tester) async {
    phoneSize(tester);
    final day = DateTime(2026, 10, 27);
    const product = Product(
      id: 1,
      name: 'Овсяная каша',
      kcal: 112,
      protein: 3.6,
      fat: 4,
      carbs: 15.2,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiaryScreen(
            entries: [
              FoodEntry(
                id: 1,
                product: product,
                meal: 'Перекус',
                grams: 100,
                date: day,
              ),
              FoodEntry(
                id: 2,
                product: product,
                meal: 'Завтрак',
                grams: 100,
                date: day,
              ),
            ],
            catalog: const [product],
            date: day,
            onDateSelected: (_) {},
            onAddEntry: (_) {},
            onDeleteMeal: (_) {},
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Перекус')).dy,
      lessThan(tester.getTopLeft(find.text('Завтрак')).dy),
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
    expect(find.byTooltip('Удалить продукт Овсяная каша'), findsNothing);
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

  testWidgets('Повторное добавление продукта не дублирует каталог', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Добавить приём пищи'));
      await tester.pumpAndSettle();
      final chickenInPicker = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Куриная грудка'),
      );
      expect(chickenInPicker, findsOneWidget);
      await tester.tap(chickenInPicker);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Добавить приём пищи'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Куриная грудка'),
      ),
      findsOneWidget,
    );
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
