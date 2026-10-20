import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/health/domain/calculations.dart';
import 'features/health/domain/models.dart';

void main() => runApp(const HealthUiApp());

class HealthUiApp extends StatefulWidget {
  const HealthUiApp({super.key});
  @override
  State<HealthUiApp> createState() => _HealthUiAppState();
}

class _HealthUiAppState extends State<HealthUiApp> {
  int step = 0;
  UserProfile demoUser = const UserProfile();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ANVIA',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: switch (step) {
      0 => WelcomeScreen(
        onStart: () => setState(() => step = 2),
        onSignIn: () => setState(() => step = 1),
      ),
      1 => AccountScreen(
        isRegistration: false,
        onBack: () => setState(() => step = 0),
        onSwitch: () => setState(() => step = 2),
        onContinue: (_) => setState(() => step = 4),
      ),
      2 => AccountScreen(
        isRegistration: true,
        onBack: () => setState(() => step = 0),
        onSwitch: () => setState(() => step = 1),
        onContinue: (name) => setState(() {
          demoUser = demoUser.copyWith(name: name);
          step = 3;
        }),
      ),
      3 => SetupScreen(
        user: demoUser,
        onBack: () => setState(() => step = 2),
        onContinue: (user) => setState(() {
          demoUser = user;
          step = 4;
        }),
      ),
      _ => DemoShell(user: demoUser, onExit: () => setState(() => step = 0)),
    },
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onSignIn,
  });
  final VoidCallback onStart;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Spacer(),
            Image.asset('assets/logo.png', width: 88, height: 88),
            const SizedBox(height: 24),
            Text('ANVIA', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Твой путь к здоровью',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const Spacer(),
            PrimaryButton(text: 'Начать', onPressed: onStart),
            TextButton(
              onPressed: onSignIn,
              child: const Text('У меня уже есть аккаунт'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Демонстрация интерфейса без создания аккаунта',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.isRegistration,
    required this.onBack,
    required this.onSwitch,
    required this.onContinue,
  });
  final bool isRegistration;
  final VoidCallback onBack;
  final VoidCallback onSwitch;
  final ValueChanged<String> onContinue;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: 'Александр');
  final email = TextEditingController();
  final password = TextEditingController();
  bool visible = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: widget.onBack)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          const Text(
            'ANVIA',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isRegistration ? 'Создать аккаунт' : 'Войти',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Демонстрационный режим: данные не отправляются и не сохраняются.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          WhiteCard(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  if (widget.isRegistration) ...[
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Ваше имя'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Введите имя'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Электронная почта',
                    ),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Введите адрес электронной почты'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    obscureText: !visible,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      suffixIcon: IconButton(
                        tooltip: visible ? 'Скрыть пароль' : 'Показать пароль',
                        onPressed: () => setState(() => visible = !visible),
                        icon: Icon(
                          visible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6
                        ? 'Не менее 6 символов'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: widget.isRegistration
                        ? 'Продолжить к настройке'
                        : 'Открыть демо',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        widget.onContinue(name.text.trim());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onSwitch,
            child: Text(
              widget.isRegistration
                  ? 'Уже есть аккаунт? Войти'
                  : 'Нет аккаунта? Создать',
            ),
          ),
        ],
      ),
    ),
  );
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.user,
    required this.onBack,
    required this.onContinue,
  });
  final UserProfile user;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onContinue;
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final formKey = GlobalKey<FormState>();
  final age = TextEditingController(text: '25');
  late final height = TextEditingController(
    text: widget.user.heightCm.toStringAsFixed(0),
  );
  late final weight = TextEditingController(
    text: widget.user.weightKg.toStringAsFixed(1),
  );
  late final target = TextEditingController(
    text: widget.user.targetKg.toStringAsFixed(1),
  );
  Goal goal = Goal.lose;
  String sex = 'Мужской';
  String activityLevel = 'Умеренная';
  @override
  void dispose() {
    age.dispose();
    height.dispose();
    weight.dispose();
    target.dispose();
    super.dispose();
  }

  String? validNumber(String? value) {
    final number = double.tryParse((value ?? '').replaceAll(',', '.'));
    return number == null || number <= 0 || number > 300
        ? 'Введите корректное значение'
        : null;
  }

  double number(TextEditingController controller) =>
      double.parse(controller.text.replaceAll(',', '.'));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: widget.onBack)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text(
            'Настройка профиля',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Эти параметры действуют только во время демонстрации.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          WhiteCard(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: sex,
                    decoration: const InputDecoration(labelText: 'Пол'),
                    items: ['Мужской', 'Женский']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => sex = value ?? sex),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: age,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Возраст, лет',
                    ),
                    validator: (value) {
                      final years = int.tryParse(value ?? '');
                      return years == null || years < 18 || years > 120
                          ? 'Для демо укажите возраст от 18 до 120 лет'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: height,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Рост, см'),
                    validator: validNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Текущий вес, кг',
                    ),
                    validator: validNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Желаемый вес, кг',
                    ),
                    validator: validNumber,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Цель',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final option in Goal.values)
                        ChoiceChip(
                          label: Text(option.title),
                          selected: goal == option,
                          onSelected: (_) => setState(() => goal = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: activityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Уровень активности',
                    ),
                    items:
                        [
                              'Минимальная',
                              'Лёгкая',
                              'Умеренная',
                              'Высокая',
                              'Очень высокая',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => activityLevel = value ?? activityLevel),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Открыть главную',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        widget.onContinue(
                          widget.user.copyWith(
                            heightCm: number(height),
                            weightKg: number(weight),
                            targetKg: number(target),
                            goal: goal,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key, required this.onExit, required this.user});
  final VoidCallback onExit;
  final UserProfile user;
  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int tab = 0;
  DateTime date = DateTime.now();
  UserProfile get user => widget.user;
  late final entries = [
    FoodEntry(
      id: 1,
      product: const Product(
        id: 1,
        name: 'Овсяная каша',
        kcal: 112,
        protein: 3.6,
        fat: 4,
        carbs: 15.2,
      ),
      meal: 'Завтрак',
      grams: 250,
      date: date,
    ),
    FoodEntry(
      id: 2,
      product: const Product(
        id: 2,
        name: 'Куриная грудка',
        kcal: 165,
        protein: 31,
        fat: 3.6,
        carbs: 0,
      ),
      meal: 'Обед',
      grams: 180,
      date: date,
    ),
  ];
  late final activity = ActivityRecord(
    date: date,
    steps: 7632,
    heartRate: 72,
    sleepMinutes: 448,
    deepMinutes: 22,
    remMinutes: 25,
    lightMinutes: 53,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset('assets/logo.png'),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANVIA', style: TextStyle(fontSize: 11)),
          Text(
            ['Главная', 'Дневник', 'Аналитика', 'Профиль'][tab],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        if (tab != 3)
          IconButton(
            tooltip: 'Выбрать дату',
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.green,
            ),
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('ru'),
              );
              if (selected != null) setState(() => date = selected);
            },
          ),
        if (tab != 3)
          IconButton(
            tooltip: 'Профиль',
            icon: const Icon(Icons.person_outline, color: AppColors.green),
            onPressed: () => setState(() => tab = 3),
          ),
      ],
    ),
    body: IndexedStack(
      index: tab,
      children: [
        DashboardScreen(
          user: user,
          entries: entries
              .where((entry) => DateUtils.isSameDay(entry.date, date))
              .toList(),
          activity: activity,
          date: date,
          onAddFood: () => setState(() => tab = 1),
        ),
        DiaryDemo(
          entries: entries
              .where((entry) => DateUtils.isSameDay(entry.date, date))
              .toList(),
          catalog: entries.map((entry) => entry.product).toList(),
          date: date,
          onDateSelected: (value) => setState(() => date = value),
        ),
        AnalyticsDemo(user: user),
        ProfileDemo(user: user, onExit: widget.onExit),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.mint,
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.monitor_heart_outlined),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          label: 'Дневник',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          label: 'Аналитика',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Профиль',
        ),
      ],
    ),
  );
}

class DiaryDemo extends StatefulWidget {
  const DiaryDemo({
    super.key,
    required this.entries,
    required this.date,
    required this.catalog,
    required this.onDateSelected,
  });
  final List<FoodEntry> entries;
  final List<Product> catalog;
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  @override
  State<DiaryDemo> createState() => _DiaryDemoState();
}

class _DiaryDemoState extends State<DiaryDemo> {
  String query = '';
  final expanded = <String>{'Завтрак', 'Обед'};
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
    children: [
      Text(
        'Дневник питания',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 5),
      const Text(
        'Рацион за выбранный день',
        style: TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 66,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var offset = -3; offset <= 3; offset++)
              InkWell(
                onTap: () => widget.onDateSelected(
                  widget.date.add(Duration(days: offset)),
                ),
                child: Container(
                  width: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: offset == 0 ? AppColors.green : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Пн',
                          'Вт',
                          'Ср',
                          'Чт',
                          'Пт',
                          'Сб',
                          'Вс',
                        ][widget.date.add(Duration(days: offset)).weekday - 1],
                        style: TextStyle(
                          color: offset == 0 ? Colors.white : AppColors.muted,
                        ),
                      ),
                      Text(
                        '${widget.date.add(Duration(days: offset)).day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: offset == 0 ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      WhiteCard(
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Поиск продукта',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Сканировать штрихкод',
                  onPressed: () => demoMessage(context),
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ),
            ),
            if (query.isNotEmpty)
              for (final product in widget.catalog.where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()),
              ))
                ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.kcal.toStringAsFixed(0)} ккал · '
                    'Б ${product.protein.toStringAsFixed(0)} / '
                    'Ж ${product.fat.toStringAsFixed(0)} / '
                    'У ${product.carbs.toStringAsFixed(0)} г на 100 г',
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => demoMessage(context),
                ),
            if (query.isNotEmpty &&
                !widget.catalog.any(
                  (product) =>
                      product.name.toLowerCase().contains(query.toLowerCase()),
                ))
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'В демонстрационном каталоге ничего не найдено.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      for (final meal in ['Завтрак', 'Обед', 'Ужин', 'Перекус']) ...[
        WhiteCard(
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(
                  () => expanded.contains(meal)
                      ? expanded.remove(meal)
                      : expanded.add(meal),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      expanded.contains(meal)
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                  ],
                ),
              ),
              if (expanded.contains(meal)) ...[
                for (final entry in widget.entries.where(
                  (item) => item.meal == meal,
                ))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.product.name),
                    subtitle: Text(
                      '${entry.grams.toStringAsFixed(0)} г · '
                      'Б ${entry.protein.toStringAsFixed(0)} / '
                      'Ж ${entry.fat.toStringAsFixed(0)} / '
                      'У ${entry.carbs.toStringAsFixed(0)} г',
                    ),
                    trailing: Text('${entry.kcal.toStringAsFixed(0)} ккал'),
                  ),
                TextButton.icon(
                  onPressed: () => demoMessage(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить продукт'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class AnalyticsDemo extends StatefulWidget {
  const AnalyticsDemo({super.key, required this.user});
  final UserProfile user;
  @override
  State<AnalyticsDemo> createState() => _AnalyticsDemoState();
}

class _AnalyticsDemoState extends State<AnalyticsDemo> {
  int period = 1;
  @override
  Widget build(BuildContext context) {
    final bmi = HealthCalculations.bmi(
      widget.user.weightKg,
      widget.user.heightCm,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      children: [
        Text(
          'Аналитика и здоровье',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Индекс массы тела',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
              Text(HealthCalculations.bmiStatus(bmi)),
              const SizedBox(height: 10),
              const LinearProgressIndicator(value: 0.48, minHeight: 8),
            ],
          ),
        ),
        const SizedBox(height: 14),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Динамика веса',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  for (var index = 0; index < 4; index++)
                    ChoiceChip(
                      label: Text(['1 Нед', '1 Мес', '3 Мес', 'Год'][index]),
                      selected: period == index,
                      onSelected: (_) => setState(() => period = index),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(painter: WeightLinePainter()),
              ),
              Text(
                'Текущий вес: ${widget.user.weightKg.toStringAsFixed(1)} кг',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фазы сна',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: Text('Глубокий\n22%')),
                  Expanded(child: Text('Быстрый\n25%')),
                  Expanded(child: Text('Лёгкий\n53%')),
                ],
              ),
              const SizedBox(height: 12),
              const LinearProgressIndicator(value: 0.53, minHeight: 10),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          text: 'Отчёт о показателях здоровья',
          onPressed: () => demoMessage(context),
        ),
      ],
    );
  }
}

class WeightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()..color = AppColors.pale;
    for (var row = 0; row < 4; row++) {
      final y = size.height * row / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }
    final points = [0.78, 0.68, 0.63, 0.44, 0.34];
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = Offset(
        size.width * index / (points.length - 1),
        size.height * points[index],
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 4, Paint()..color = AppColors.green);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileDemo extends StatefulWidget {
  const ProfileDemo({super.key, required this.user, required this.onExit});
  final UserProfile user;
  final VoidCallback onExit;
  @override
  State<ProfileDemo> createState() => _ProfileDemoState();
}

class _ProfileDemoState extends State<ProfileDemo> {
  bool health = false;
  bool notifications = true;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
    children: [
      Text('Мой профиль', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      WhiteCard(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 29,
              backgroundColor: AppColors.mint,
              child: Icon(
                Icons.person_outline,
                size: 32,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'ANVIA · Твой путь к здоровью',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: MetricCard(
              'Рост',
              '${widget.user.heightCm.toStringAsFixed(0)} см',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MetricCard(
              'Вес',
              '${widget.user.weightKg.toStringAsFixed(1)} кг',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MetricCard(
              'Цель',
              '${widget.user.targetKg.toStringAsFixed(0)} кг',
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      WhiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Моя программа',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(widget.user.goal.title)),
            Text('${widget.user.calorieTarget} ккал в день · пример нормы'),
          ],
        ),
      ),
      const SizedBox(height: 14),
      WhiteCard(
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Данные здоровья'),
              value: health,
              onChanged: (value) => setState(() => health = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Уведомления'),
              value: notifications,
              onChanged: (value) => setState(() => notifications = value),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: widget.onExit,
        icon: const Icon(Icons.logout),
        label: const Text('Вернуться к приветствию'),
      ),
    ],
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard(this.title, this.value, {super.key});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => WhiteCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

void demoMessage(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(
      const SnackBar(
        content: Text('Эта функция появится на следующем этапе проекта'),
      ),
    );
