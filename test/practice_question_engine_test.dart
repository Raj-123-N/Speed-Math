import 'package:flutter_test/flutter_test.dart';
import '../lib/core/models/quiz_category.dart';
import '../lib/features/practice/models/practice_models.dart';
import '../lib/features/practice/services/practice_question_engine.dart';

void main() {
  const tableCategory = QuizCategory.quickRecall[4];

  test('Table 2 sequential practice walks multipliers in order', () {
    final engine = PracticeQuestionEngine();
    const config = PracticeConfig(
      category: tableCategory,
      pattern: PracticePattern.tables,
      questions: 10,
      tableStart: 2,
      tableEnd: 2,
      multiplierMax: 10,
      tableOrder: TableOrder.sequential,
    );

    final prompts = List.generate(10, (_) => engine.next(config).prompt);

    expect(prompts, [
      '2 × 1 = ?',
      '2 × 2 = ?',
      '2 × 3 = ?',
      '2 × 4 = ?',
      '2 × 5 = ?',
      '2 × 6 = ?',
      '2 × 7 = ?',
      '2 × 8 = ?',
      '2 × 9 = ?',
      '2 × 10 = ?',
    ]);
  });

  test('Sequential range completes table pairs before repeating', () {
    final engine = PracticeQuestionEngine();
    const config = PracticeConfig(
      category: tableCategory,
      pattern: PracticePattern.tables,
      tableStart: 2,
      tableEnd: 3,
      multiplierMax: 2,
      tableOrder: TableOrder.sequential,
    );

    final prompts = List.generate(4, (_) => engine.next(config).prompt);

    expect(prompts, [
      '2 × 1 = ?',
      '2 × 2 = ?',
      '3 × 1 = ?',
      '3 × 2 = ?',
    ]);
  });
}
