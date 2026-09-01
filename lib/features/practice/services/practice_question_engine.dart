import 'dart:math';
import '../models/practice_models.dart';

/// Deterministic-enough random question factory with recent-question avoidance.
class PracticeQuestionEngine {
  PracticeQuestionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;
  final Set<String> _recent = <String>{};

  PracticeQuestion next(PracticeConfig config) {
    PracticeQuestion question;
    var guard = 0;
    do {
      question = _generate(config);
      guard++;
    } while (_recent.contains(question.prompt) && guard < 40);
    _recent.add(question.prompt);
    while (_recent.length > 24) {
      _recent.remove(_recent.first);
    }
    return question;
  }

  PracticeQuestion _generate(PracticeConfig c) {
    switch (c.pattern) {
      case PracticePattern.arithmetic:
        return _arithmetic(c);
      case PracticePattern.multiplication:
        return _multiplication(c);
      case PracticePattern.division:
        return _division(c);
      case PracticePattern.tables:
        return _table(c);
      case PracticePattern.recall:
        return _recall(c);
      case PracticePattern.generic:
        return _generic(c);
    }
  }

  int _maxForDigits(int digits) => pow(10, digits).toInt() - 1;
  int _number(int digits) {
    final min = digits == 1 ? 1 : pow(10, digits - 1).toInt();
    return min + _random.nextInt(_maxForDigits(digits) - min + 1);
  }

  PracticeQuestion _arithmetic(PracticeConfig c) {
    final subtraction = c.category.operation == MathOperation.subtraction;
    final values = List<int>.generate(c.terms.clamp(2, 6), (_) => _number(c.lhsDigits));
    if (subtraction) {
      values[0] = _number(c.lhsDigits);
      for (var i = 1; i < values.length; i++) {
        values[i] = _number(c.rhsDigits);
      }
      values.sort((a, b) => b.compareTo(a));
    }
    final expression = values.join(subtraction ? ' − ' : ' + ');
    final answer = subtraction
        ? values.skip(1).fold(values.first, (a, b) => a - b)
        : values.fold(0, (a, b) => a + b);
    return _withOptions('$expression = ?', '$answer');
  }

  PracticeQuestion _multiplication(PracticeConfig c) {
    final a = _number(c.lhsDigits);
    final b = _number(c.rhsDigits);
    return _withOptions('$a × $b = ?', '${a * b}');
  }

  PracticeQuestion _division(PracticeConfig c) {
    final divisor = _number(c.rhsDigits).clamp(1, 99999);
    final quotient = _number(c.lhsDigits);
    final dividend = divisor * quotient;
    return _withOptions('$dividend ÷ $divisor = ?', '$quotient');
  }

  PracticeQuestion _table(PracticeConfig c) {
    final table = c.tableStart + _random.nextInt(c.tableEnd - c.tableStart + 1);
    final multiplier = 1 + _random.nextInt(c.multiplierMax);
    return _withOptions('$table × $multiplier = ?', '${table * multiplier}');
  }

  PracticeQuestion _recall(PracticeConfig c) {
    final op = c.category.operation;
    final n = _number(c.lhsDigits.clamp(1, 3));
    switch (op) {
      case MathOperation.square:
        return _withOptions('$n² = ?', '${n * n}');
      case MathOperation.cube:
        return _withOptions('$n³ = ?', '${n * n * n}');
      case MathOperation.squareRoot:
        final r = 1 + _random.nextInt(100);
        return _withOptions('√${r * r} = ?', '$r');
      case MathOperation.cubeRoot:
        final r = 1 + _random.nextInt(20);
        return _withOptions('∛${r * r * r} = ?', '$r');
      case MathOperation.percentage:
        final pct = [5, 10, 15, 20, 25, 50][_random.nextInt(6)];
        final base = [40, 80, 120, 200, 400][_random.nextInt(5)];
        return _withOptions('$pct% of $base = ?', '${base * pct ~/ 100}');
      case MathOperation.fraction:
        const fractions = ['1/2', '1/4', '3/4', '1/5', '2/5'];
        const values = ['0.5', '0.25', '0.75', '0.2', '0.4'];
        final i = _random.nextInt(fractions.length);
        return _withOptions('${fractions[i]} = decimal ?', values[i]);
      default:
        return _generic(c);
    }
  }

  PracticeQuestion _generic(PracticeConfig c) {
    final a = _number(c.lhsDigits.clamp(1, 4));
    final b = _number(c.rhsDigits.clamp(1, 4));
    switch (c.category.operation) {
      case MathOperation.bodmas:
      case MathOperation.simplification:
        return _withOptions('$a + $b × 2 = ?', '${a + b * 2}');
      case MathOperation.series:
        final step = 2 + _random.nextInt(8);
        final values = List.generate(4, (i) => a + i * step);
        return _withOptions('${values.join(', ')}, ?','$${values.last + step}'.replaceFirst(r'$', ''));
      case MathOperation.linearEquation:
        final x = 1 + _random.nextInt(20);
        final m = 2 + _random.nextInt(8);
        final k = m * x + 1;
        return _withOptions('${m}x + 1 = $k,  x = ?', '$x');
      case MathOperation.quadraticEquation:
        final x = 1 + _random.nextInt(9);
        final b = 2 * x;
        final c0 = x * x;
        return _withOptions('x² − ${b}x + $c0 = 0; positive x = ?', '$x');
      case MathOperation.cubicEquation:
        final x = 1 + _random.nextInt(5);
        return _withOptions('x³ = ${x * x * x}; x = ?', '$x');
      case MathOperation.unitDigit:
        final base = 2 + _random.nextInt(8);
        final exponent = 3 + _random.nextInt(20);
        return _withOptions('Unit digit of $base^$exponent = ?', '${pow(base, exponent).toInt() % 10}');
      case MathOperation.powers:
      case MathOperation.exponents:
        final base = 2 + _random.nextInt(8);
        final exp = 2 + _random.nextInt(4);
        return _withOptions('$base^$exp = ?', '${pow(base, exp).toInt()}');
      default:
        return _withOptions('$a + $b = ?', '${a + b}');
    }
  }

  PracticeQuestion _withOptions(String prompt, String answer) {
    final value = double.tryParse(answer);
    if (value == null) return PracticeQuestion(prompt: prompt, answer: answer);
    final delta = value.abs() < 10 ? 1 : max(1, value.abs().round() ~/ 10);
    final candidates = <String>{answer};
    while (candidates.length < 4) {
      final offset = _random.nextInt(delta * 4 + 1) - delta * 2;
      candidates.add('${value.round() + offset}');
    }
    final options = candidates.toList()..shuffle(_random);
    return PracticeQuestion(prompt: prompt, answer: answer, options: options);
  }
}
