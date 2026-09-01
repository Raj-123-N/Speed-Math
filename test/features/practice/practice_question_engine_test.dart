import 'package:flutter_test/flutter_test.dart';
import 'package:speed_math/core/models/quiz_category.dart';
import 'package:speed_math/features/practice/models/practice_models.dart';
import 'package:speed_math/features/practice/services/practice_question_engine.dart';

void main() {
  PracticeConfig configFor(MathOperation operation, {
    PracticePattern? pattern,
    PracticeComplexity complexity = PracticeComplexity.medium,
  }) {
    final category = QuizCategory(
      id: 'test-${operation.name}',
      name: operation.name,
      operation: operation,
      section: PracticeSection.miscellaneous,
    );
    return PracticeConfig(
      category: category,
      pattern: pattern ?? PracticePattern.generic,
      complexity: complexity,
      questions: 10,
      valueStart: 1,
      valueEnd: 50,
    );
  }

  test('generates correct answers for repeatable arithmetic practice', () {
    final engine = PracticeQuestionEngine();
    final config = configFor(MathOperation.addition, pattern: PracticePattern.arithmetic);

    for (var i = 0; i < 20; i++) {
      final question = engine.next(config);
      expect(question.answer, isNotEmpty);
      expect(question.options.length, 4);
      expect(question.options, contains(question.answer));
    }
  });

  test('generates table practice inside the selected table range', () {
    final engine = PracticeQuestionEngine();
    final category = QuizCategory(
      id: 'tables',
      name: 'Tables',
      operation: MathOperation.table,
      section: PracticeSection.quickRecall,
    );
    final config = PracticeConfig(
      category: category,
      pattern: PracticePattern.tables,
      tableStart: 7,
      tableEnd: 9,
      multiplierMax: 10,
      tableOrder: TableOrder.sequential,
    );

    for (var i = 0; i < 12; i++) {
      final prompt = engine.next(config).prompt;
      final match = RegExp(r'^(\d+) × (\d+) = \?$').firstMatch(prompt);
      expect(match, isNotNull);
      final table = int.parse(match!.group(1)!);
      final multiplier = int.parse(match.group(2)!);
      expect(table, inInclusiveRange(7, 9));
      expect(multiplier, inInclusiveRange(1, 10));
    }
  });

  test('uses recall range for square practice', () {
    final engine = PracticeQuestionEngine();
    final config = configFor(MathOperation.square, pattern: PracticePattern.recall);

    for (var i = 0; i < 10; i++) {
      final question = engine.next(config);
      final match = RegExp(r'^(\d+)² = \?$').firstMatch(question.prompt);
      expect(match, isNotNull);
      final value = int.parse(match!.group(1)!);
      expect(value, inInclusiveRange(1, 50));
      expect(int.parse(question.answer), value * value);
    }
  });

  test('produces four distinct MCQ options', () {
    final engine = PracticeQuestionEngine();
    final config = configFor(MathOperation.bodmas);

    for (var i = 0; i < 20; i++) {
      final options = engine.next(config).options;
      expect(options, hasLength(4));
      expect(options.toSet(), hasLength(4));
    }
  });
}
