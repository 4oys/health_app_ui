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
  bool entered = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Здоровье',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: entered
        ? DemoShell(onExit: () => setState(() => entered = false))
        : WelcomeScreen(onContinue: () => setState(() => entered = true)),
  );
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool visible = false;
  bool consent = true;
  Goal goal = Goal.lose;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Center(child: Image.asset('assets/logo.png', width: 72, height: 72)),
          const SizedBox(height: 18),
          Text(
            'Начните заботиться о себе',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ваш путь к здоровым привычкам начинается здесь',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Создать аккаунт',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    hintText: 'Александр',
                  ),
                ),
                const SizedBox(height: 10),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Электронная почта'),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: !visible,
                  decoration: InputDecoration(
                    labelText: 'Придумайте пароль',
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
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ваша цель',
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
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Согласен с условиями использования',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: consent,
                  onChanged: (value) =>
                      setState(() => consent = value ?? false),
                ),
                PrimaryButton(
                  text: 'Продолжить',
                  onPressed: consent ? widget.onContinue : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onContinue,
                    icon: const Icon(Icons.apple),
                    label: const Text('Продолжить с Apple'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Демонстрация интерфейса — аккаунт не создаётся',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key, required this.onExit});
  final VoidCallback onExit;
  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int tab = 0;
  DateTime date = DateTime.now();
  final user = const UserProfile();
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
          const Text('Здоровье', style: TextStyle(fontSize: 11)),
          Text(
            ['Главная', 'Дневник', 'Аналитика', 'Профиль'][tab],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
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
          entries: entries,
          activity: activity,
          date: date,
          onAddFood: () => setState(() => tab = 1),
        ),
        DiaryDemo(entries: entries, date: date),
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
  const DiaryDemo({super.key, required this.entries, required this.date});
  final List<FoodEntry> entries;
  final DateTime date;
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
              Container(
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
              for (final entry in widget.entries.where(
                (item) => item.product.name.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              ))
                ListTile(
                  title: Text(entry.product.name),
                  subtitle: Text(
                    '${entry.product.kcal.toStringAsFixed(0)} ккал / 100 г',
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => demoMessage(context),
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
          text: 'Экспорт отчёта в PDF',
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
                    'Мой путь к здоровью',
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
            const Text('Дефицит калорий · 2200 ккал в день'),
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
        label: const Text('Вернуться к экрану входа'),
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
