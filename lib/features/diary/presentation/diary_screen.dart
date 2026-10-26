import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../health/domain/models.dart';

const _mealKinds = ['Завтрак', 'Обед', 'Ужин', 'Перекус'];
const _customMeal = 'Своё название';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.entries,
    required this.date,
    required this.catalog,
    required this.onDateSelected,
    required this.onAddEntry,
    required this.onDeleteMeal,
  });

  final List<FoodEntry> entries;
  final List<Product> catalog;
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<FoodEntry> onAddEntry;
  final ValueChanged<String> onDeleteMeal;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final expanded = <String>{'Завтрак', 'Обед'};

  Future<void> openEntry({String? meal}) async {
    final entry = await showModalBottomSheet<FoodEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => _AddMealSheet(
        date: widget.date,
        initialMeal: meal,
        catalog: widget.catalog,
      ),
    );
    if (entry == null || !mounted) return;
    widget.onAddEntry(entry);
    setState(() => expanded.add(entry.meal));
  }

  Future<void> deleteMeal(String meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить приём пищи?'),
        content: Text('«$meal» и все продукты в нём будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.onDeleteMeal(meal);
    setState(() => expanded.remove(meal));
  }

  @override
  Widget build(BuildContext context) {
    final presentMeals = widget.entries.map((entry) => entry.meal).toSet();
    final meals = [
      ..._mealKinds.where(presentMeals.contains),
      ...presentMeals.where((meal) => !_mealKinds.contains(meal)),
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
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
                                ][widget.date
                                        .add(Duration(days: offset))
                                        .weekday -
                                    1],
                                style: TextStyle(
                                  color: offset == 0
                                      ? Colors.white
                                      : AppColors.muted,
                                ),
                              ),
                              Text(
                                '${widget.date.add(Duration(days: offset)).day}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: offset == 0
                                      ? Colors.white
                                      : AppColors.ink,
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
              for (final meal in meals) ...[
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
                            IconButton(
                              tooltip: 'Удалить приём пищи $meal',
                              onPressed: () => deleteMeal(meal),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                      if (expanded.contains(meal))
                        for (final entry in widget.entries.where(
                          (item) => item.meal == meal,
                        ))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.product.name),
                            subtitle: Text(
                              '${entry.grams.toStringAsFixed(0)} г · '
                              '${entry.kcal.toStringAsFixed(0)} ккал\n'
                              'Б ${entry.protein.toStringAsFixed(0)} / '
                              'Ж ${entry.fat.toStringAsFixed(0)} / '
                              'У ${entry.carbs.toStringAsFixed(0)} г',
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: PrimaryButton(
            text: 'Добавить приём пищи',
            icon: Icons.add_circle_outline,
            onPressed: openEntry,
          ),
        ),
      ],
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({
    required this.date,
    required this.catalog,
    this.initialMeal,
  });
  final DateTime date;
  final List<Product> catalog;
  final String? initialMeal;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final formKey = GlobalKey<FormState>();
  late String mealKind = widget.initialMeal == null
      ? 'Завтрак'
      : _mealKinds.contains(widget.initialMeal)
      ? widget.initialMeal!
      : _customMeal;
  late final customName = TextEditingController(
    text: _mealKinds.contains(widget.initialMeal)
        ? ''
        : widget.initialMeal ?? '',
  );
  final search = TextEditingController();
  final grams = TextEditingController(text: '100');
  Product? selectedProduct;

  @override
  void dispose() {
    customName.dispose();
    search.dispose();
    grams.dispose();
    super.dispose();
  }

  void selectProduct(Product product) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedProduct = product;
      search.text = product.name;
    });
  }

  Future<void> enterBarcode() async {
    var enteredCode = '';
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Поиск по штрихкоду'),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Штрихкод продукта'),
          onChanged: (value) => enteredCode = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, enteredCode.trim()),
            child: const Text('Найти'),
          ),
        ],
      ),
    );
    if (!mounted || code == null || code.isEmpty) return;
    for (final product in widget.catalog) {
      if (product.barcode.isNotEmpty && product.barcode == code) {
        selectProduct(product);
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('В каталоге нет продукта с таким штрихкодом.'),
      ),
    );
  }

  void save() {
    if (selectedProduct == null || !formKey.currentState!.validate()) return;
    final amount = double.parse(grams.text.trim().replaceAll(',', '.'));
    Navigator.pop(
      context,
      FoodEntry(
        id: DateTime.now().microsecondsSinceEpoch,
        product: selectedProduct!,
        meal: mealKind == _customMeal ? customName.text.trim() : mealKind,
        grams: amount,
        date: widget.date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? widget.catalog
        : widget.catalog
              .where((product) => product.name.toLowerCase().contains(query))
              .toList();
    return Padding(
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
              const SizedBox(height: 16),
              const Text(
                'Как назвать приём пищи?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final kind in [..._mealKinds, _customMeal])
                    ChoiceChip(
                      label: Text(kind),
                      selected: mealKind == kind,
                      onSelected: (_) => setState(() => mealKind = kind),
                    ),
                ],
              ),
              if (mealKind == _customMeal) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: customName,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Своё название'),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Введите название приёма пищи'
                      : null,
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Что вы ели?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: search,
                      onChanged: (_) => setState(() => selectedProduct = null),
                      decoration: const InputDecoration(
                        hintText: 'Найти продукт',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: enterBarcode,
                    tooltip: 'Найти по штрихкоду',
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
              if (selectedProduct == null) ...[
                const SizedBox(height: 8),
                if (matches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Продукт не найден',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  for (final product in matches)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.kcal.toStringAsFixed(0)} ккал на 100 г',
                      ),
                      onTap: () => selectProduct(product),
                    ),
              ] else ...[
                const SizedBox(height: 14),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProduct!.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedProduct!.kcal.toStringAsFixed(0)} ккал на 100 г',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: grams,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Сколько граммов?',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );
                    return amount == null ||
                            !amount.isFinite ||
                            amount <= 0 ||
                            amount > 100000
                        ? 'Укажите вес больше нуля'
                        : null;
                  },
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                text: 'Сохранить',
                onPressed: selectedProduct == null ? null : save,
              ),
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
}
