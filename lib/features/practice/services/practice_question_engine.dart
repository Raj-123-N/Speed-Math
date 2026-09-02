import 'dart:math';
import '../../../core/models/quiz_category.dart';
import '../models/practice_models.dart';

/// Generates fresh questions for repeatable Practice sessions.
class PracticeQuestionEngine {
  PracticeQuestionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<String> _recent = <String>[];
  final Map<String, int> _tableCursor = <String, int>{};
  final Map<String, List<int>> _tableOrders = <String, List<int>>{};

  PracticeQuestion next(PracticeConfig config) {
    var question = _generate(config);
    var attempts = 0;
    while (_recent.contains(question.prompt) && attempts < 40) {
      question = _generate(config);
      attempts++;
    }
    _recent.add(question.prompt);
    if (_recent.length > 40) _recent.removeAt(0);
    return question;
  }

  PracticeQuestion _generate(PracticeConfig c) {
    switch (c.pattern) {
      case PracticePattern.arithmetic: return _arithmetic(c);
      case PracticePattern.multiplication: return _multiplication(c);
      case PracticePattern.division: return _division(c);
      case PracticePattern.tables: return _tables(c);
      case PracticePattern.recall: return _recall(c);
      case PracticePattern.generic: return _generic(c);
    }
  }

  int _scale(PracticeComplexity complexity) {
    switch (complexity) {
      case PracticeComplexity.easy: return 1;
      case PracticeComplexity.medium: return 2;
      case PracticeComplexity.hard: return 4;
    }
  }

  int _maxForDigits(int digits) => pow(10, digits).toInt() - 1;

  int _number(int digits) {
    final safeDigits = digits.clamp(1, 5);
    final minValue = safeDigits == 1 ? 1 : pow(10, safeDigits - 1).toInt();
    final maxValue = _maxForDigits(safeDigits);
    return minValue + _random.nextInt(maxValue - minValue + 1);
  }

  int _between(int minValue, int maxValue) => minValue + _random.nextInt(maxValue - minValue + 1);

  PracticeQuestion _arithmetic(PracticeConfig c) {
    final count = c.terms.clamp(2, 6);
    final left = _number(c.lhsDigits);
    final values = <int>[left];
    for (var i = 1; i < count; i++) {
      values.add(_number(c.rhsDigits));
    }
    if (c.category.operation == MathOperation.subtraction) {
      final maxRhs = max(1, left ~/ max(1, count - 1));
      for (var i = 1; i < values.length; i++) {
        values[i] = min(values[i], maxRhs);
      }
      final answer = values.first - values.skip(1).fold(0, (a, b) => a + b);
      return _numeric('${values.join(' − ')} = ?', answer);
    }
    return _numeric('${values.join(' + ')} = ?', values.fold(0, (a, b) => a + b));
  }

  PracticeQuestion _multiplication(PracticeConfig c) {
    final a = _number(c.lhsDigits), b = _number(c.rhsDigits);
    return _numeric('$a × $b = ?', a * b);
  }

  PracticeQuestion _division(PracticeConfig c) {
    final divisor = _number(c.rhsDigits), quotient = _number(c.lhsDigits);
    return _numeric('${divisor * quotient} ÷ $divisor = ?', quotient);
  }

  PracticeQuestion _tables(PracticeConfig c) {
    final start = min(c.tableStart, c.tableEnd).clamp(1, 100);
    final end = max(c.tableStart, c.tableEnd).clamp(1, 100);
    final key = '${c.category.id}:$start-$end:${c.multiplierMax}:${c.tableOrder}:${c.shuffleSequential}';
    late int table;
    if (c.tableOrder == TableOrder.sequential) {
      final order = _tableOrders.putIfAbsent(key, () {
        final list = List<int>.generate(end - start + 1, (i) => start + i);
        if (c.shuffleSequential) list.shuffle(_random);
        return list;
      });
      final cursor = _tableCursor[key] ?? 0;
      table = order[cursor % order.length];
      _tableCursor[key] = cursor + 1;
    } else {
      table = _between(start, end);
    }
    final multiplier = _between(1, c.multiplierMax.clamp(1, 20));
    return _numeric('$table × $multiplier = ?', table * multiplier);
  }

  PracticeQuestion _recall(PracticeConfig c) {
    final start = min(c.valueStart, c.valueEnd).clamp(1, 1000);
    final end = max(c.valueStart, c.valueEnd).clamp(1, 1000);
    final n = _between(start, end);
    switch (c.category.operation) {
      case MathOperation.square: return _numeric('$n² = ?', n * n);
      case MathOperation.cube: return _numeric('$n³ = ?', n * n * n);
      case MathOperation.squareRoot:
        final r = _between(start, end);
        return _numeric('√${r * r} = ?', r);
      case MathOperation.cubeRoot:
        final r = _between(start, min(end, 100));
        return _numeric('∛${r * r * r} = ?', r);
      case MathOperation.percentage: return _percentage(c, start, end);
      case MathOperation.fraction: return _fraction(c.complexity);
      default: return _generic(c);
    }
  }

  PracticeQuestion _percentage(PracticeConfig c, int start, int end) {
    final pcts = switch (c.complexity) {
      PracticeComplexity.easy => [5, 10, 20, 25, 50],
      PracticeComplexity.medium => [5, 10, 12, 15, 20, 25, 30, 50, 75],
      PracticeComplexity.hard => [7, 12, 15, 18, 22, 25, 35, 40, 62],
    };
    final pct = pcts[_random.nextInt(pcts.length)];
    final step = 100 ~/ _gcd(pct, 100);
    final baseMin = max(1, ((start + step - 1) ~/ step) * step);
    final baseMax = max(baseMin, (end ~/ step) * step);
    final base = _between(baseMin, baseMax);
    return _numeric('$pct% of $base = ?', base * pct ~/ 100);
  }

  PracticeQuestion _fraction(PracticeComplexity complexity) {
    final pool = switch (complexity) {
      PracticeComplexity.easy => <String, String>{'1/2':'0.5','1/4':'0.25','3/4':'0.75','1/5':'0.2','2/5':'0.4'},
      PracticeComplexity.medium => <String, String>{'3/8':'0.375','5/8':'0.625','7/10':'0.7','3/5':'0.6','7/20':'0.35'},
      PracticeComplexity.hard => <String, String>{'11/20':'0.55','7/16':'0.4375','13/20':'0.65','9/25':'0.36','17/20':'0.85'},
    };
    final key = pool.keys.elementAt(_random.nextInt(pool.length));
    return PracticeQuestion(prompt: '$key = decimal ?', answer: pool[key]!, options: _decimalOptions(pool[key]!), inputHint: 'Decimal answer');
  }

  PracticeQuestion _generic(PracticeConfig c) {
    switch (c.category.operation) {
      case MathOperation.bodmas: return _bodmas(c);
      case MathOperation.simplification: return _simplification(c);
      case MathOperation.series: return _series(c);
      case MathOperation.linearEquation: return _linear(c);
      case MathOperation.quadraticEquation: return _quadratic(c);
      case MathOperation.cubicEquation: return _cubic(c);
      case MathOperation.unitDigit: return _unitDigit(c);
      case MathOperation.powers:
      case MathOperation.exponents: return _powers(c);
      case MathOperation.algebra: return _equationMix(c);
      case MathOperation.trigonometry: return _trigonometry(c);
      case MathOperation.diAddition: return _diAddition(c);
      case MathOperation.quickRecallWorkout: return _quickRecallWorkout(c);
      case MathOperation.basicsWorkout: return _basicsWorkout(c);
      case MathOperation.mixAdvance: return _complexityMix(c);
      case MathOperation.miscellaneousMix: return _miscellaneousMix(c);
      default:
        final a = _between(1, 20 * _scale(c.complexity)), b = _between(1, 20 * _scale(c.complexity));
        return _numeric('$a + $b = ?', a + b);
    }
  }

  PracticeQuestion _bodmas(PracticeConfig c) {
    final s = _scale(c.complexity), a = _between(2, 9 * s), b = _between(2, 9 * s), d = _between(2, 9);
    return _numeric('$a + $b × $d = ?', a + b * d);
  }

  PracticeQuestion _simplification(PracticeConfig c) {
    final s = _scale(c.complexity), a = _between(2, 20 * s), b = _between(2, 10 * s), mode = _random.nextInt(3);
    if (mode == 0) return _numeric('$a × 3 − $b = ?', a * 3 - b);
    if (mode == 1) return _numeric('($a + $b) ÷ 2 = ?', (a + b) ~/ 2);
    return _numeric('$a + $b × 2 = ?', a + b * 2);
  }

  PracticeQuestion _series(PracticeConfig c) {
    final s = _scale(c.complexity), start = _between(1, 20 * s), step = _between(2, 5 * s);
    final mode = _random.nextInt(c.complexity == PracticeComplexity.hard ? 3 : 2);
    if (mode == 0) {
      final values = List.generate(4, (i) => start + i * step);
      return _numeric('${values.join(', ')}, ?', values.last + step);
    }
    if (mode == 1) {
      final values = List.generate(4, (i) => start * pow(2, i).toInt());
      return _numeric('${values.join(', ')}, ?', values.last * 2);
    }
    final values = List.generate(4, (i) => start + i * (i + 1));
    return _numeric('${values.join(', ')}, ?', values.last + 5);
  }

  PracticeQuestion _linear(PracticeConfig c) {
    final s = _scale(c.complexity), x = _between(1, 8 * s), m = _between(2, 7), b = _between(1, 9 * s);
    return _numeric('${m}x + $b = ${m * x + b},  x = ?', x, inputHint: 'Value of x');
  }

  PracticeQuestion _quadratic(PracticeConfig c) {
    final s = _scale(c.complexity), x = _between(1, 3 * s), other = _between(1, 3 * s);
    return _numeric('x² − ${x + other}x + ${x * other} = 0; smaller positive x = ?', min(x, other), inputHint: 'Value of x');
  }

  PracticeQuestion _cubic(PracticeConfig c) {
    final x = _between(1, 4 * _scale(c.complexity));
    return _numeric('x³ = ${x * x * x}; x = ?', x, inputHint: 'Value of x');
  }

  PracticeQuestion _unitDigit(PracticeConfig c) {
    final base = _between(2, 9), exponent = _between(3, 8 * _scale(c.complexity));
    return _numeric('Unit digit of $base^$exponent = ?', _powMod(base, exponent, 10));
  }

  PracticeQuestion _powers(PracticeConfig c) {
    final base = _between(2, c.complexity == PracticeComplexity.hard ? 9 : 6), exp = _between(2, 2 + _scale(c.complexity));
    return _numeric('$base^$exp = ?', pow(base, exp).toInt());
  }

  PracticeQuestion _equationMix(PracticeConfig c) => _random.nextBool() ? _linear(c) : _quadratic(c);

  PracticeQuestion _trigonometry(PracticeConfig c) {
    final pool = c.complexity == PracticeComplexity.easy
        ? const <String, num>{'sin 0°':0,'sin 30°':0.5,'sin 90°':1,'cos 0°':1,'cos 60°':0.5,'tan 0°':0}
        : const <String, num>{'sin 30° × 2':1,'cos 60° × 2':1,'sin 90°':1,'cos 0°':1,'tan 45°':1};
    final prompt = pool.keys.elementAt(_random.nextInt(pool.length));
    return _numeric('$prompt = ?', pool[prompt]!);
  }

  PracticeQuestion _diAddition(PracticeConfig c) {
    final s = _scale(c.complexity), rows = c.complexity == PracticeComplexity.hard ? 5 : 4;
    final values = List.generate(rows, (_) => _between(10, 99 * s));
    return _numeric('DI total: ${values.join(' + ')} = ?', values.fold(0, (a, b) => a + b));
  }

  PracticeQuestion _quickRecallWorkout(PracticeConfig c) {
    final mode = _random.nextInt(4);
    if (mode == 0) { final n = _between(11, 30); return _numeric('$n² = ?', n * n); }
    if (mode == 1) { final a = _between(2, 12), b = _between(2, 12); return _numeric('$a × $b = ?', a * b); }
    if (mode == 2) { final r = _between(2, 20); return _numeric('√${r * r} = ?', r); }
    return _percentage(c, 20, 1000);
  }

  PracticeQuestion _basicsWorkout(PracticeConfig c) {
    final s = _scale(c.complexity), a = _between(10, 99 * s), b = _between(2, 30 * s);
    switch (_random.nextInt(4)) {
      case 0: return _numeric('$a + $b = ?', a + b);
      case 1: final high = max(a, b), low = min(a, b); return _numeric('$high − $low = ?', high - low);
      case 2: return _numeric('$a × $b = ?', a * b);
      default: return _numeric('${a * b} ÷ $a = ?', b);
    }
  }

  PracticeQuestion _complexityMix(PracticeConfig c) {
    final generators = <PracticeQuestion Function()>[() => _bodmas(c), () => _series(c), () => _linear(c), () => _unitDigit(c), () => _powers(c)];
    return generators[_random.nextInt(generators.length)]();
  }

  PracticeQuestion _miscellaneousMix(PracticeConfig c) {
    final generators = <PracticeQuestion Function()>[() => _bodmas(c), () => _simplification(c), () => _series(c), () => _equationMix(c), () => _unitDigit(c)];
    return generators[_random.nextInt(generators.length)]();
  }

  PracticeQuestion _numeric(String prompt, num answer, {String inputHint = 'Answer'}) {
    final text = _formatNumber(answer);
    return PracticeQuestion(prompt: prompt, answer: text, options: _numberOptions(answer), inputHint: inputHint);
  }

  List<String> _numberOptions(num answer) {
    final values = <num>{answer};
    final spread = max(1, answer.abs() < 10 ? 1 : answer.abs() ~/ 10);
    var guard = 0;
    while (values.length < 4 && guard++ < 100) {
      values.add(answer + _between(-spread * 3, spread * 3));
    }
    while (values.length < 4) {
      values.add(answer + values.length);
    }
    final result = values.map(_formatNumber).toList()..shuffle(_random);
    return result;
  }

  List<String> _decimalOptions(String answer) {
    final value = double.parse(answer), values = <String>{answer};
    for (var i = 1; values.length < 4; i++) {
      final candidate = (value + (i.isEven ? i : -i) / 100).toStringAsFixed(4).replaceFirst(RegExp(r'0+\$'), '').replaceFirst(RegExp(r'\.\$'), '');
      values.add(candidate);
    }
    final result = values.toList()..shuffle(_random);
    return result;
  }

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+\$'), '').replaceFirst(RegExp(r'\.\$'), '');
  }

  int _powMod(int base, int exponent, int mod) {
    var result = 1, b = base % mod, e = exponent;
    while (e > 0) {
      if (e.isOdd) result = result * b % mod;
      b = b * b % mod;
      e ~/= 2;
    }
    return result;
  }

  int _gcd(int a, int b) {
    while (b != 0) { final t = a % b; a = b; b = t; }
    return a.abs();
  }
}
