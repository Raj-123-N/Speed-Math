import 'package:flutter_test/flutter_test.dart';
import 'package:speed_math/core/models/quiz_category.dart';
import 'package:speed_math/features/practice/models/practice_models.dart';
import 'package:speed_math/features/practice/services/practice_question_engine.dart';

void main() {
  final tableCategory = QuizCategory.quickRecall.firstWhere((c) => c.operation == MathOperation.table);
  final divisionCategory = QuizCategory.basics.firstWhere((c) => c.operation == MathOperation.division);
  final squareCategory = QuizCategory.quickRecall.firstWhere((c) => c.operation == MathOperation.square);
  final cubeCategory = QuizCategory.quickRecall.firstWhere((c) => c.operation == MathOperation.cube);
  final squareRootCategory = QuizCategory.quickRecall.firstWhere((c) => c.operation == MathOperation.squareRoot);
  final cubeRootCategory = QuizCategory.quickRecall.firstWhere((c) => c.operation == MathOperation.cubeRoot);

  test('Table 2 sequential practice walks multipliers in order', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
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
    final config = PracticeConfig(
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

  test('Division always generates clean integer problems with matching answer', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: divisionCategory,
      pattern: PracticePattern.division,
      lhsDigits: 2,
      rhsDigits: 1,
    );

    for (int i = 0; i < 50; i++) {
      final q = engine.next(config);
      // prompt format: "A ÷ B = ?"
      final match = RegExp(r'^(\d+)\s*÷\s*(\d+)\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull, reason: 'Prompt should match "A ÷ B = ?"');
      final dividend = int.parse(match!.group(1)!);
      final divisor = int.parse(match.group(2)!);
      final quotient = int.parse(q.answer);

      expect(dividend % divisor, 0, reason: 'Dividend must be evenly divisible by divisor');
      expect(dividend ~/ divisor, quotient, reason: 'Quotient must match answer');
    }
  });

  test('Squares strictly respects valueStart and valueEnd range', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: squareCategory,
      pattern: PracticePattern.recall,
      valueStart: 10,
      valueEnd: 15,
    );

    for (int i = 0; i < 30; i++) {
      final q = engine.next(config);
      // prompt format: "N² = ?"
      final match = RegExp(r'^(\d+)²\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final n = int.parse(match!.group(1)!);
      expect(n, greaterThanOrEqualTo(10));
      expect(n, lessThanOrEqualTo(15));
      expect(int.parse(q.answer), n * n);
    }
  });

  test('Squares with single value produces only that question', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: squareCategory,
      pattern: PracticePattern.recall,
      valueStart: 12,
      valueEnd: 12,
    );

    for (int i = 0; i < 10; i++) {
      final q = engine.next(config);
      expect(q.prompt, '12² = ?');
      expect(q.answer, '144');
    }
  });

  test('Cubes strictly respects range [valueStart, valueEnd]', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: cubeCategory,
      pattern: PracticePattern.recall,
      valueStart: 4,
      valueEnd: 8,
    );

    for (int i = 0; i < 25; i++) {
      final q = engine.next(config);
      final match = RegExp(r'^(\d+)³\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final n = int.parse(match!.group(1)!);
      expect(n, greaterThanOrEqualTo(4));
      expect(n, lessThanOrEqualTo(8));
      expect(int.parse(q.answer), n * n * n);
    }
  });

  test('Square roots strictly respects range [valueStart, valueEnd]', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: squareRootCategory,
      pattern: PracticePattern.recall,
      valueStart: 5,
      valueEnd: 9,
    );

    for (int i = 0; i < 25; i++) {
      final q = engine.next(config);
      final match = RegExp(r'^√(\d+)\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final square = int.parse(match!.group(1)!);
      final root = int.parse(q.answer);
      expect(root, greaterThanOrEqualTo(5));
      expect(root, lessThanOrEqualTo(9));
      expect(root * root, square);
    }
  });

  test('Cube roots strictly respects range [valueStart, valueEnd]', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: cubeRootCategory,
      pattern: PracticePattern.recall,
      valueStart: 3,
      valueEnd: 7,
    );

    for (int i = 0; i < 25; i++) {
      final q = engine.next(config);
      final match = RegExp(r'^∛(\d+)\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final cube = int.parse(match!.group(1)!);
      final root = int.parse(q.answer);
      expect(root, greaterThanOrEqualTo(3));
      expect(root, lessThanOrEqualTo(7));
      expect(root * root * root, cube);
    }
  });
}
