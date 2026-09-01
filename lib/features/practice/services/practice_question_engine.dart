import 'dart:math';
import '../models/practice_models.dart';

class PracticeQuestionEngine {
  PracticeQuestionEngine({Random? random}) : _random = random ?? Random();
  final Random _random;
  final Set<String> _recent = <String>{};
  final Map<String, int> _tableCursor = <String, int>{};

  PracticeQuestion next(PracticeConfig config) {
    PracticeQuestion question;
    var guard = 0;
    do { question = _generate(config); guard++; } while (_recent.contains(question.prompt) && guard < 50);
    _recent.add(question.prompt);
    while (_recent.length > 32) _recent.remove(_recent.first);
    return question;
  }

  PracticeQuestion _generate(PracticeConfig c) {
    switch (c.pattern) {
      case PracticePattern.arithmetic: return _arithmetic(c);
      case PracticePattern.multiplication: return _multiplication(c);
      case PracticePattern.division: return _division(c);
      case PracticePattern.tables: return _table(c);
      case PracticePattern.recall: return _recall(c);
      case PracticePattern.generic: return _generic(c);
    }
  }

  int _maxForDigits(int digits) => pow(10, digits).toInt() - 1;
  int _number(int digits) {
    final min = digits == 1 ? 1 : pow(10, digits - 1).toInt();
    return min + _random.nextInt(_maxForDigits(digits) - min + 1);
  }

  PracticeQuestion _arithmetic(PracticeConfig c) {
    final subtraction = c.category.operation == MathOperation.subtraction;
    final count = c.terms.clamp(2, 6);
    final values = List<int>.generate(count, (_) => _number(c.rhsDigits));
    values[0] = _number(c.lhsDigits);
    if (subtraction) {
      values.sort((a, b) => b.compareTo(a));
      final answer = values.skip(1).fold(values.first, (a, b) => a - b);
      return _withOptions('${values.join(' − ')} = ?', '$answer');
    }
    return _withOptions('${values.join(' + ')} = ?', '${values.fold(0, (a, b) => a + b)}');
  }

  PracticeQuestion _multiplication(PracticeConfig c) {
    final a = _number(c.lhsDigits), b = _number(c.rhsDigits);
    return _withOptions('$a × $b = ?', '${a * b}');
  }

  PracticeQuestion _division(PracticeConfig c) {
    final divisor = _number(c.rhsDigits), quotient = _number(c.lhsDigits);
    return _withOptions('${divisor * quotient} ÷ $divisor = ?', '$quotient');
  }

  PracticeQuestion _table(PracticeConfig c) {
    final key = '${c.category.id}:${c.tableStart}-${c.tableEnd}:${c.multiplierMax}:${c.tableOrder}:${c.shuffleSequential}';
    int table;
    if (c.tableOrder == TableOrder.sequential) {
      final range = c.tableEnd - c.tableStart + 1;
      final cursor = _tableCursor[key] ?? 0;
      final order = List<int>.generate(range, (i) => c.tableStart + i);
      if (c.shuffleSequential) order.shuffle(_random);
      table = order[cursor % range];
      _tableCursor[key] = cursor + 1;
    } else {
      table = c.tableStart + _random.nextInt(c.tableEnd - c.tableStart + 1);
    }
    final multiplier = 1 + _random.nextInt(c.multiplierMax);
    return _withOptions('$table × $multiplier = ?', '${table * multiplier}');
  }

  PracticeQuestion _recall(PracticeConfig c) {
    final n = _number(c.lhsDigits.clamp(1, 3));
    switch (c.category.operation) {
      case MathOperation.square: return _withOptions('$n² = ?', '${n * n}');
      case MathOperation.cube: return _withOptions('$n³ = ?', '${n * n * n}');
      case MathOperation.squareRoot: final r = 1 + _random.nextInt(100); return _withOptions('√${r * r} = ?', '$r');
      case MathOperation.cubeRoot: final r = 1 + _random.nextInt(20); return _withOptions('∛${r * r * r} = ?', '$r');
      case MathOperation.percentage:
        final pct = [5, 10, 15, 20, 25, 50][_random.nextInt(6)], base = [40, 80, 120, 200, 400][_random.nextInt(5)];
        return _withOptions('$pct% of $base = ?', '${base * pct ~/ 100}');
      case MathOperation.fraction:
        const f = ['1/2', '1/4', '3/4', '1/5', '2/5'], a = ['0.5', '0.25', '0.75', '0.2', '0.4'];
        final i = _random.nextInt(f.length); return _withOptions('${f[i]} = decimal ?', a[i]);
      default: return _generic(c);
    }
  }

  PracticeQuestion _generic(PracticeConfig c) {
    final scale = switch (c.complexity) { PracticeComplexity.easy => 1, PracticeComplexity.medium => 2, PracticeComplexity.hard => 4 };
    final a = 1 + _random.nextInt(20 * scale), b = 1 + _random.nextInt(20 * scale);
    switch (c.category.operation) {
      case MathOperation.bodmas:
      case MathOperation.simplification: return _withOptions('$a + $b × 2 = ?', '${a + b * 2}');
      case MathOperation.series:
        final step = 2 + _random.nextInt(4 * scale), values = List.generate(4, (i) => a + i * step);
        return _withOptions('${values.join(', ')}, ?', '${values.last + step}');
      case MathOperation.linearEquation:
        final x = 1 + _random.nextInt(10 * scale), m = 2 + _random.nextInt(6), k = m * x + 1;
        return _withOptions('${m}x + 1 = $k,  x = ?', '$x');
      case MathOperation.quadraticEquation:
        final x = 1 + _random.nextInt(4 * scale), bb = 2 * x, cc = x * x;
        return _withOptions('x² − ${bb}x + $cc = 0; positive x = ?', '$x');
      case MathOperation.cubicEquation:
        final x = 1 + _random.nextInt(3 * scale); return _withOptions('x³ = ${x * x * x}; x = ?', '$x');
      case MathOperation.unitDigit:
        final base = 2 + _random.nextInt(8), exponent = 3 + _random.nextInt(10 * scale);
        return _withOptions('Unit digit of $base^$exponent = ?', '${pow(base, exponent).toInt() % 10}');
      case MathOperation.powers:
      case MathOperation.exponents:
        final base = 2 + _random.nextInt(8), exp = 2 + _random.nextInt(3 * scale);
        return _withOptions('$base^$exp = ?', '${pow(base, exp).toInt()}');
      default: return _withOptions('$a + $b = ?', '${a + b}');
    }
  }

  PracticeQuestion _withOptions(String prompt, String answer) {
    final value = double.tryParse(answer);
    if (value == null) return PracticeQuestion(prompt: prompt, answer: answer);
    final delta = value.abs() < 10 ? 1 : max(1, value.abs().round() ~/ 10);
    final candidates = <String>{answer};
    while (candidates.length < 4) candidates.add('${value.round() + _random.nextInt(delta * 4 + 1) - delta * 2}');
    final options = candidates.toList()..shuffle(_random);
    return PracticeQuestion(prompt: prompt, answer: answer, options: options);
  }
}
