import 'package:flutter_test/flutter_test.dart';
import 'package:speed_math/core/models/app_update_info.dart';
import 'package:speed_math/core/services/app_update_service.dart';
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

  test('Single Table practice from 1 to 100 generates exact table questions only', () {
    final engine = PracticeQuestionEngine();
    for (final table in [1, 7, 17, 43, 79, 100]) {
      final config = PracticeConfig(
        category: tableCategory,
        pattern: PracticePattern.tables,
        tableStart: table,
        tableEnd: table,
        multiplierMax: 20,
        tableOrder: TableOrder.random,
      );

      for (int i = 0; i < 20; i++) {
        final q = engine.next(config);
        final match = RegExp(r'^(\d+)\s*×\s*(\d+)\s*=\s*\?$').firstMatch(q.prompt);
        expect(match, isNotNull);
        final parsedTable = int.parse(match!.group(1)!);
        final parsedMultiplier = int.parse(match.group(2)!);
        final answer = int.parse(q.answer);

        expect(parsedTable, table, reason: 'Must test exact single table $table');
        expect(parsedMultiplier, greaterThanOrEqualTo(1));
        expect(parsedMultiplier, lessThanOrEqualTo(20));
        expect(answer, table * parsedMultiplier);
      }
    }
  });

  test('Custom Table Range [23, 37] strictly bounds questions within range', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: tableCategory,
      pattern: PracticePattern.tables,
      tableStart: 23,
      tableEnd: 37,
      multiplierMax: 10,
      tableOrder: TableOrder.random,
    );

    for (int i = 0; i < 50; i++) {
      final q = engine.next(config);
      final match = RegExp(r'^(\d+)\s*×\s*(\d+)\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final table = int.parse(match!.group(1)!);
      final mult = int.parse(match.group(2)!);
      final ans = int.parse(q.answer);

      expect(table, greaterThanOrEqualTo(23));
      expect(table, lessThanOrEqualTo(37));
      expect(mult, greaterThanOrEqualTo(1));
      expect(mult, lessThanOrEqualTo(10));
      expect(ans, table * mult);
    }
  });

  test('Sequential Shuffled table practice covers all pairs without immediate repeats', () {
    final engine = PracticeQuestionEngine();
    final config = PracticeConfig(
      category: tableCategory,
      pattern: PracticePattern.tables,
      tableStart: 17,
      tableEnd: 17,
      multiplierMax: 10,
      tableOrder: TableOrder.sequential,
      shuffleSequential: true,
    );

    final seenMultipliers = <int>{};
    for (int i = 0; i < 10; i++) {
      final q = engine.next(config);
      final match = RegExp(r'^17\s*×\s*(\d+)\s*=\s*\?$').firstMatch(q.prompt);
      expect(match, isNotNull);
      final mult = int.parse(match!.group(1)!);
      expect(seenMultipliers.contains(mult), isFalse, reason: 'Each multiplier 1-10 must appear once in first 10 questions');
      seenMultipliers.add(mult);
    }
    expect(seenMultipliers.length, 10);
  });

  test('toSuperscript converts integers and strings to unicode superscripts', () {
    expect(toSuperscript(0), '⁰');
    expect(toSuperscript(1), '¹');
    expect(toSuperscript(2), '²');
    expect(toSuperscript(3), '³');
    expect(toSuperscript(4), '⁴');
    expect(toSuperscript(5), '⁵');
    expect(toSuperscript(6), '⁶');
    expect(toSuperscript(7), '⁷');
    expect(toSuperscript(8), '⁸');
    expect(toSuperscript(9), '⁹');
    expect(toSuperscript(85), '⁸⁵');
    expect(toSuperscript(-3), '⁻³');
  });

  test('formatMathPrompt replaces caret power notations with superscripts', () {
    expect(formatMathPrompt('2^5 = ?'), '2⁵ = ?');
    expect(formatMathPrompt('7^85 unit digit = ?'), '7⁸⁵ unit digit = ?');
    expect(formatMathPrompt('What is (3^4) * 2^3?'), 'What is (3⁴) * 2³?');
    expect(formatMathPrompt('x^2 - 4 = 0'), 'x² - 4 = 0');
    expect(formatMathPrompt('No caret here 2 x 3 = ?'), 'No caret here 2 x 3 = ?');
  });

  test('Powers and Exponents practice questions use clean unicode superscripts without caret', () {
    final engine = PracticeQuestionEngine();
    final powersCategory = QuizCategory.miscellaneous.firstWhere(
      (c) => c.operation == MathOperation.powers,
    );
    final config = PracticeConfig(
      category: powersCategory,
      pattern: PracticePattern.generic,
    );

    for (int i = 0; i < 20; i++) {
      final q = engine.next(config);
      expect(q.prompt.contains('^'), isFalse, reason: 'Prompts must not use power cap ^');
      // Should contain superscript numbers
      expect(q.prompt.contains(RegExp(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]')), isTrue);
    }
  });

  test('Unit Digit practice questions format powers with superscripts without caret', () {
    final engine = PracticeQuestionEngine();
    final unitDigitCategory = QuizCategory.quickRecall.firstWhere(
      (c) => c.operation == MathOperation.unitDigit,
    );
    final config = PracticeConfig(
      category: unitDigitCategory,
      pattern: PracticePattern.generic,
    );

    for (int i = 0; i < 20; i++) {
      final q = engine.next(config);
      expect(q.prompt.contains('^'), isFalse, reason: 'Unit digit prompt must not use power cap ^');
    }
  });

  test('Fraction generator options always contain the exact answer', () {
    final engine = PracticeQuestionEngine();
    final fractionCategory = QuizCategory.basics.firstWhere(
      (c) => c.operation == MathOperation.fraction,
    );
    final config = PracticeConfig(
      category: fractionCategory,
      pattern: PracticePattern.generic,
    );

    for (int i = 0; i < 30; i++) {
      final q = engine.next(config);
      expect(q.options.contains(q.answer), isTrue,
          reason: 'Options ${q.options} must contain answer ${q.answer}');
    }
  });

  test('Polynomial generator formats negative roots cleanly without double negative', () {
    final engine = PracticeQuestionEngine();
    final polyCategory = QuizCategory.miscellaneous.firstWhere(
      (c) => c.operation == MathOperation.polynomials,
    );
    final config = PracticeConfig(
      category: polyCategory,
      pattern: PracticePattern.generic,
    );

    for (int i = 0; i < 30; i++) {
      final q = engine.next(config);
      expect(q.prompt.contains('−−') || q.prompt.contains('−-') || q.prompt.contains('--'), isFalse,
          reason: 'Polynomial prompt ${q.prompt} must not contain double negatives');
    }
  });

  test('Probability generator produces terminating decimal values and matching options', () {
    final engine = PracticeQuestionEngine();
    final probCategory = QuizCategory.miscellaneous.firstWhere(
      (c) => c.operation == MathOperation.probability,
    );
    final config = PracticeConfig(
      category: probCategory,
      pattern: PracticePattern.generic,
    );

    for (int i = 0; i < 20; i++) {
      final q = engine.next(config);
      expect(q.options.contains(q.answer), isTrue);
      final val = double.tryParse(q.answer);
      expect(val, isNotNull);
      expect(val! >= 0.0 && val <= 1.0, isTrue);
    }
  });

  group('AppUpdateService and AppUpdateInfo tests', () {
    test('isVersionNewer correctly identifies newer semantic versions', () {
      expect(AppUpdateService.isVersionNewer('0.4.0', '0.5.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('0.5.0', '0.5.0'), isFalse);
      expect(AppUpdateService.isVersionNewer('0.5.0', '0.4.0'), isFalse);
      expect(AppUpdateService.isVersionNewer('v0.4.0', 'v0.5.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('0.5.0+4', '0.5.0+5'), isTrue);
      expect(AppUpdateService.isVersionNewer('0.5.0+5', '0.5.0+4'), isFalse);
      expect(AppUpdateService.isVersionNewer('0.5.0', '1.0.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('1.0.0', '0.9.9'), isFalse);
    });

    test('AppUpdateInfo parses assets, size, and highlights cleanly', () {
      final json = {
        'tag_name': 'v0.5.0',
        'name': 'Speed Math v0.5.0 - Custom Ranges & Accuracy',
        'body': '## Release Highlights\n- Custom range 1 to 100\n- Question reporting\n- Update engine',
        'html_url': 'https://github.com/Raj-123-N/Speed-Math/releases/tag/v0.5.0',
        'assets': [
          {
            'name': 'SpeedMath-v0.5.0.apk',
            'size': 22440000,
            'browser_download_url': 'https://github.com/Raj-123-N/Speed-Math/releases/download/v0.5.0/SpeedMath.apk',
            'download_count': 42,
          }
        ],
      };

      final info = AppUpdateInfo.fromJson(
        json: json,
        currentVersion: '0.4.0',
        hasUpdate: true,
      );

      expect(info.latestVersion, '0.5.0');
      expect(info.hasUpdate, isTrue);
      expect(info.hasDirectApk, isTrue);
      expect(info.apkFileName, 'SpeedMath-v0.5.0.apk');
      expect(info.formattedSize, '21.4 MB');
      expect(info.highlights, contains('Custom range 1 to 100'));
      expect(info.highlights, contains('Question reporting'));
      expect(info.highlights, contains('Update engine'));
    });
  });
}


