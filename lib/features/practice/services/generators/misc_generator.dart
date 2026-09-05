import 'dart:math';

import '../../models/practice_models.dart';

int _between(int minValue, int maxValue, Random random) =>
    minValue + random.nextInt(maxValue - minValue + 1);

String _format(num value) {
  if (value.isFinite && value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value
      .toStringAsFixed(4)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

List<String> _numOpts(num answer, Random random) {
  final values = <num>{answer};
  final spread = max(1, answer.abs() < 10 ? 1 : answer.abs() ~/ 10);
  var g = 0;
  while (values.length < 4 && g++ < 100) {
    values.add(answer + _between(-spread * 3, spread * 3, random));
  }
  while (values.length < 4) {
    values.add(answer + values.length);
  }
  return values.map(_format).toList()..shuffle(random);
}

PracticeQuestion _n(String prompt, num answer, Random random,
        {String hint = 'Answer'}) =>
    PracticeQuestion(
      prompt: prompt,
      answer: _format(answer),
      options: _numOpts(answer, random),
      inputHint: hint,
    );

int _powMod(int base, int exponent, int mod) {
  var result = 1;
  var b = base % mod;
  var e = exponent;
  while (e > 0) {
    if (e.isOdd) result = (result * b) % mod;
    b = (b * b) % mod;
    e ~/= 2;
  }
  return result;
}

/// BODMAS generator with progressive complexity:
/// Easy: a + b × c
/// Medium: (a + b) × c − d
/// Hard: (a × b) + (c × d) − e
PracticeQuestion generateBODMAS(PracticeConfig c, Random random) {
  switch (c.complexity) {
    case PracticeComplexity.easy:
      final a = _between(2, 15, random);
      final b = _between(2, 12, random);
      final d = _between(2, 8, random);
      return _n('$a + $b × $d = ?', a + b * d, random);

    case PracticeComplexity.medium:
      final a = _between(2, 15, random);
      final b = _between(2, 12, random);
      final multiplier = _between(2, 6, random);
      final d = _between(1, 20, random);
      final ans = (a + b) * multiplier - d;
      return _n('($a + $b) × $multiplier − $d = ?', ans, random);

    case PracticeComplexity.hard:
      final a = _between(3, 12, random);
      final b = _between(2, 10, random);
      final d = _between(2, 8, random);
      final e = _between(2, 6, random);
      final sub = _between(1, 15, random);
      final ans = (a * b) + (d * e) - sub;
      return _n('($a × $b) + ($d × $e) − $sub = ?', ans, random);
  }
}

/// Simplification generator with algebraic and arithmetic patterns
PracticeQuestion generateSimplification(PracticeConfig c, Random random) {
  final mode = random.nextInt(3);
  if (mode == 0) {
    final a = _between(10, 50, random);
    final b = _between(2, 10, random);
    return _n('($a + $b) × 2 − $b = ?', (a + b) * 2 - b, random);
  } else if (mode == 1) {
    // (a² - b²) / (a - b) = a + b
    final a = _between(11, 40, random);
    final b = _between(2, a - 1, random);
    final numerator = a * a - b * b;
    final denominator = a - b;
    return _n('($numerator) ÷ $denominator = ?', a + b, random);
  } else {
    final a = _between(5, 25, random);
    final factor = _between(3, 9, random);
    final sub = _between(2, 10, random);
    return _n('$a × $factor − $sub × $factor = ?', (a - sub) * factor, random);
  }
}

/// Unit Digit generator — unit digit of base^exponent
PracticeQuestion generateUnitDigit(PracticeConfig c, Random random) {
  final base = _between(2, 99, random);
  final exponent = _between(2, 100, random);
  final unitDigit = _powMod(base, exponent, 10);
  return _n('Unit digit of $base^$exponent = ?', unitDigit, random,
      hint: 'Unit digit');
}

/// Powers & Exponents generator
PracticeQuestion generatePowers(PracticeConfig c, Random random) {
  switch (c.complexity) {
    case PracticeComplexity.easy:
      if (random.nextBool()) {
        final exp = _between(1, 10, random);
        return _n('2^$exp = ?', pow(2, exp), random);
      } else {
        final exp = _between(1, 5, random);
        return _n('3^$exp = ?', pow(3, exp), random);
      }

    case PracticeComplexity.medium:
      final base = _between(2, 9, random);
      final exp = _between(2, 4, random);
      return _n('$base^$exp = ?', pow(base, exp), random);

    case PracticeComplexity.hard:
      final base = _between(2, 12, random);
      final exp = _between(2, 5, random);
      return _n('$base^$exp = ?', pow(base, exp), random);
  }
}

/// Mental Multiplication generator
PracticeQuestion generateMentalMultiplication(PracticeConfig c, Random random) {
  final multipliers = [10, 20, 25, 50, 100, 11];
  final multiplier = multipliers[random.nextInt(multipliers.length)];
  final n = _between(10, 99, random);
  return _n('$n × $multiplier = ?', n * multiplier, random, hint: 'Product');
}

/// Fast Division generator — always integer exact
PracticeQuestion generateFastDivision(PracticeConfig c, Random random) {
  final divisors = [2, 3, 4, 5, 8, 9, 10, 11, 20, 25, 50, 100, 125, 250, 500];
  final divisor = divisors[random.nextInt(divisors.length)];
  final quotient = _between(5, 100, random);
  final dividend = quotient * divisor;
  return _n('$dividend ÷ $divisor = ?', quotient, random, hint: 'Quotient');
}
