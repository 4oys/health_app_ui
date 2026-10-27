import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../health/domain/calculations.dart';
import '../../health/domain/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.entries,
    required this.activity,
    required this.date,
    required this.waterMl,
    required this.onAddWater,
    required this.onUndoWater,
    this.healthConnected = false,
    this.healthSyncEnabled = false,
  });
  final UserProfile user;
  final List<FoodEntry> entries;
  final ActivityRecord activity;
  final bool healthConnected;
  final bool healthSyncEnabled;
  final DateTime date;
  final int waterMl;
  final ValueChanged<int> onAddWater;
  final VoidCallback onUndoWater;

  @override
  Widget build(BuildContext context) {
    final kcal = entries.fold<double>(0, (sum, e) => sum + e.kcal).round();
    final remaining = HealthCalculations.remainingCalories(
      user.calorieTarget,
      entries,
      burnedCalories: activity.burnedCalories,
    );
    final macroScale = user.calorieTarget / 2200;
    final weekday = [
      'ПОНЕДЕЛЬНИК',
      'ВТОРНИК',
      'СРЕДА',
      'ЧЕТВЕРГ',
      'ПЯТНИЦА',
      'СУББОТА',
      'ВОСКРЕСЕНЬЕ',
    ][date.weekday - 1];
    final month = [
      'ЯНВАРЯ',
      'ФЕВРАЛЯ',
      'МАРТА',
      'АПРЕЛЯ',
      'МАЯ',
      'ИЮНЯ',
      'ИЮЛЯ',
      'АВГУСТА',
      'СЕНТЯБРЯ',
      'ОКТЯБРЯ',
      'НОЯБРЯ',
      'ДЕКАБРЯ',
    ][date.month - 1];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      children: [
        Text(
          '$weekday, ${date.day} $month',
          style: const TextStyle(
            color: AppColors.green,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Привет, ${user.name}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        Text(
          healthConnected
              ? '●  Данные системы здоровья'
              : healthSyncEnabled
              ? '●  Синхронизация включена, данных за день нет'
              : '●  Пример данных активности',
          style: const TextStyle(fontSize: 11, color: AppColors.green),
        ),
        const SizedBox(height: 20),
        WhiteCard(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Баланс энергии',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _Badge('Норма ${user.calorieTarget} ккал'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _EnergyValue(value: '$kcal', label: 'Съедено'),
                  ),
                  SizedBox(
                    width: 154,
                    height: 154,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size.square(154),
                          painter: _EnergyArcPainter(
                            progress: HealthCalculations.progress(
                              kcal,
                              user.calorieTarget + activity.burnedCalories,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${remaining.abs()}',
                                style: const TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            Text(
                              remaining < 0 ? 'Сверх нормы' : 'Осталось',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _EnergyValue(
                      value: '${activity.burnedCalories}',
                      label: 'Сожжено',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.pale),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Macro(
                    'Углеводы',
                    HealthCalculations.totalCarbs(entries),
                    260 * macroScale,
                  ),
                  _Macro(
                    'Белки',
                    HealthCalculations.totalProtein(entries),
                    140 * macroScale,
                  ),
                  _Macro(
                    'Жиры',
                    HealthCalculations.totalFat(entries),
                    70 * macroScale,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: WhiteCard(
                child: SizedBox(
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.favorite, color: Colors.red),
                          Text('Пульс', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: activity.heartRate == 0
                                  ? '—'
                                  : '${activity.heartRate}',
                              style: const TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const TextSpan(
                              text: ' уд/мин',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '━━━━╱╲╱╲━━━━',
                        style: TextStyle(color: AppColors.green),
                      ),
                      Text(
                        healthConnected
                            ? 'Последнее измерение'
                            : healthSyncEnabled
                            ? 'Данных пока нет'
                            : 'В покое: 64 уд/мин',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WhiteCard(
                child: SizedBox(
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.directions_walk, color: AppColors.green),
                          Flexible(
                            child: Text(
                              'Активность',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${activity.steps} шагов',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: HealthCalculations.progress(
                          activity.steps,
                          10000,
                        ),
                        color: AppColors.green,
                        backgroundColor: AppColors.pale,
                      ),
                      const Text(
                        'Цель: 10 000 шагов',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, color: AppColors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Вода за день',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$waterMl / 2000 мл',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (waterMl / 2000).clamp(0.0, 1.0),
                minHeight: 9,
                color: AppColors.blue,
                backgroundColor: AppColors.pale,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 6),
              const Text(
                'Цель на день: 2 л',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton(
                    onPressed: () => onAddWater(250),
                    child: const Text('+ 250 мл'),
                  ),
                  OutlinedButton(
                    onPressed: () => onAddWater(500),
                    child: const Text('+ 500 мл'),
                  ),
                  if (waterMl > 0)
                    IconButton(
                      onPressed: onUndoWater,
                      tooltip: 'Убрать 250 мл',
                      icon: const Icon(Icons.undo),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.pale,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.green,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EnergyValue extends StatelessWidget {
  const _EnergyValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
      ),
    ],
  );
}

class _EnergyArcPainter extends CustomPainter {
  const _EnergyArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(9, 9, size.width - 18, size.height - 18);
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final track = Paint()
      ..color = AppColors.pale
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, track);
    if (progress <= 0) return;
    final fill = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _EnergyArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.value, this.target);
  final String label;
  final double value;
  final double target;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: HealthCalculations.progress(value, target),
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            color: AppColors.green,
            backgroundColor: AppColors.pale,
          ),
          const SizedBox(height: 6),
          Text(
            '${value.round()} / ${target.round()} г',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    ),
  );
}
