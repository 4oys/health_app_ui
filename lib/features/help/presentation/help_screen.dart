import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Помощь и вопросы'),
      backgroundColor: AppColors.background,
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: const [
          Text(
            'Частые вопросы',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Как пользоваться ANVIA',
            style: TextStyle(color: AppColors.muted),
          ),
          SizedBox(height: 20),
          _HelpQuestion(
            question: 'Как добавить приём пищи?',
            answer:
                'Откройте «Дневник», выберите день и нажмите «Добавить приём пищи». '
                'Затем выберите тип приёма пищи, продукт и укажите его вес.',
          ),
          SizedBox(height: 12),
          _HelpQuestion(
            question: 'Как удалить приём пищи?',
            answer:
                'В дневнике нажмите корзину рядом с названием приёма пищи и '
                'подтвердите удаление. Все продукты в нём тоже будут удалены.',
          ),
          SizedBox(height: 12),
          _HelpQuestion(
            question: 'Как учитывать воду?',
            answer:
                'На главном экране нажмите «+ 250 мл» или «+ 500 мл». '
                'Чтобы убрать 250 мл, нажмите значок отмены.',
          ),
          SizedBox(height: 12),
          _HelpQuestion(
            question: 'Откуда берутся шаги, пульс и сон?',
            answer:
                'Сейчас на экранах показаны примерные значения. Получение '
                'данных из приложений на телефоне пока не подключено.',
          ),
          SizedBox(height: 12),
          _HelpQuestion(
            question: 'Сохраняются ли добавленные записи?',
            answer:
                'Пока записи доступны только во время текущего запуска. '
                'После перезапуска приложения добавленные приёмы пищи и вода сбрасываются.',
          ),
        ],
      ),
    ),
  );
}

class _HelpQuestion extends StatelessWidget {
  const _HelpQuestion({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => WhiteCard(
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(answer, style: const TextStyle(color: AppColors.muted)),
        ),
      ],
    ),
  );
}
