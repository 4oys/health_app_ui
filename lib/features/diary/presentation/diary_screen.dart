import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../health/domain/models.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.entries,
    required this.date,
    required this.catalog,
    required this.onDateSelected,
    required this.onAddEntry,
  });

  final List<FoodEntry> entries;
  final List<Product> catalog;
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<FoodEntry> onAddEntry;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String query = '';
  final expanded = <String>{'Завтрак', 'Обед'};

  Future<void> openEntry({String meal = 'Завтрак', Product? product}) async {
    final entry = await showModalBottomSheet<FoodEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) =>
          _AddMealSheet(date: widget.date, initialMeal: meal, product: product),
    );
    if (entry == null || !mounted) return;
    widget.onAddEntry(entry);
    setState(() => expanded.add(entry.meal));
  }

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
      const SizedBox(height: 14),
      PrimaryButton(
        text: 'Добавить приём пищи',
        icon: Icons.add_circle_outline,
        onPressed: openEntry,
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
              decoration: const InputDecoration(
                hintText: 'Поиск продукта',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            if (query.trim().isNotEmpty)
              for (final product in widget.catalog.where(
                (item) => item.name.toLowerCase().contains(
                  query.trim().toLowerCase(),
                ),
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
                  onTap: () => openEntry(product: product),
                ),
            if (query.trim().isNotEmpty &&
                !widget.catalog.any(
                  (product) => product.name.toLowerCase().contains(
                    query.trim().toLowerCase(),
                  ),
                ))
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Ничего не найдено.',
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
                  onPressed: () => openEntry(meal: meal),
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

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({
    required this.date,
    required this.initialMeal,
    this.product,
  });
  final DateTime date;
  final String initialMeal;
  final Product? product;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final formKey = GlobalKey<FormState>();
  late String meal = widget.initialMeal;
  late final name = TextEditingController(text: widget.product?.name ?? '');
  final grams = TextEditingController(text: '100');
  late final kcal = TextEditingController(
    text: widget.product?.kcal.toStringAsFixed(0) ?? '0',
  );
  late final protein = TextEditingController(
    text: widget.product?.protein.toStringAsFixed(1) ?? '0',
  );
  late final fat = TextEditingController(
    text: widget.product?.fat.toStringAsFixed(1) ?? '0',
  );
  late final carbs = TextEditingController(
    text: widget.product?.carbs.toStringAsFixed(1) ?? '0',
  );

  @override
  void dispose() {
    for (final controller in [name, grams, kcal, protein, fat, carbs]) {
      controller.dispose();
    }
    super.dispose();
  }

  double parse(TextEditingController controller) =>
      double.parse(controller.text.trim().replaceAll(',', '.'));

  String? validateNumber(String? value, {bool positive = false}) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (number == null ||
        !number.isFinite ||
        number < 0 ||
        (positive && number == 0) ||
        number > 100000) {
      return positive ? 'Укажите число больше нуля' : 'Укажите число от 0';
    }
    return null;
  }

  Widget numberField(
    String label,
    TextEditingController controller, {
    bool positive = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
    validator: (value) => validateNumber(value, positive: positive),
  );

  void save() {
    if (!formKey.currentState!.validate()) return;
    final id = DateTime.now().microsecondsSinceEpoch;
    Navigator.pop(
      context,
      FoodEntry(
        id: id,
        product: Product(
          id: widget.product?.id ?? id,
          name: name.text.trim(),
          kcal: parse(kcal),
          protein: parse(protein),
          fat: parse(fat),
          carbs: parse(carbs),
        ),
        meal: meal,
        grams: parse(grams),
        date: widget.date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добавить приём пищи',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Укажите значения на 100 г продукта.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: meal,
              decoration: const InputDecoration(labelText: 'Приём пищи'),
              items: ['Завтрак', 'Обед', 'Ужин', 'Перекус']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => meal = value ?? meal),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Название блюда или приёма пищи',
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            numberField('Вес порции, г', grams, positive: true),
            const SizedBox(height: 12),
            numberField('Калории, ккал', kcal),
            const SizedBox(height: 12),
            numberField('Белки, г', protein),
            const SizedBox(height: 12),
            numberField('Жиры, г', fat),
            const SizedBox(height: 12),
            numberField('Углеводы, г', carbs),
            const SizedBox(height: 18),
            PrimaryButton(text: 'Сохранить', onPressed: save),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
