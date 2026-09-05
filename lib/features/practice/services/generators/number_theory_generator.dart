import 'dart:math';

import '../../models/practice_models.dart';

int _between(int minValue, int maxValue, Random random) =>
    minValue + random.nextInt(maxValue - minValue + 1);

int _scale(PracticeComplexity c) => switch (c) {
      PracticeComplexity.easy => 1,
      PracticeComplexity.medium => 2,
      PracticeComplexity.hard => 4,
    };

String _format(num value) {
  if (value.isFinite && value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value
      .toStringAsFixed(4)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

List<String> _numberOptions(num answer, Random random) {
  final values = <num>{answer};
  final spread = max(1, answer.abs() < 10 ? 1 : answer.abs() ~/ 10);
  var guard = 0;
  while (values.length < 4 && guard++ < 100) {
    values.add(answer + _between(-spread * 3, spread * 3, random));
  }
  while (values.length < 4) values.add(answer + values.length);
  return values.map(_format).toList()..shuffle(random);
}

List<String> _textOptions(String answer, Random random) {
  final values = <String>{answer};
  const alternatives = ['Yes', 'No', 'even', 'odd', 'negative', 'non-negative', 'positive'];
  for (final v in alternatives) {
    if (v != answer) values.add(v);
    if (values.length == 4) break;
  }
  return values.toList()..shuffle(random);
}

PracticeQuestion _text(String prompt, String answer, Random random) => PracticeQuestion(
      prompt: prompt,
      answer: answer,
      options: _textOptions(answer, random),
      inputHint: 'Answer',
    );

PracticeQuestion _numeric(String prompt, num answer, Random random,
        {String inputHint = 'Answer'}) =>
    PracticeQuestion(
      prompt: prompt,
      answer: _format(answer),
      options: _numberOptions(answer, random),
      inputHint: inputHint,
    );

int _gcd(int a, int b) {
  a = a.abs(); b = b.abs();
  while (b != 0) { final t = a % b; a = b; b = t; }
  return a;
}

int _factorCount(int n) {
  var count = 0;
  for (var i = 1; i * i <= n; i++) {
    if (n % i == 0) count += i * i == n ? 1 : 2;
  }
  return count;
}

int _powMod(int base, int exponent, int mod) {
  var result = 1; var b = base % mod; var e = exponent;
  while (e > 0) {
    if (e.isOdd) result = result * b % mod;
    b = b * b % mod; e ~/= 2;
  }
  return result;
}

PracticeQuestion generateNumberSystem(PracticeConfig c, Random random) {
  final n = _between(-100 * _scale(c.complexity), 100 * _scale(c.complexity), random);
  switch (random.nextInt(3)) {
    case 0: return _text('$n is ___', n.isEven ? 'even' : 'odd', random);
    case 1: return _text('$n is ___', n >= 0 ? 'non-negative' : 'negative', random);
    default: return _numeric('|$n| = ?', n.abs(), random);
  }
}

PracticeQuestion generatePlaceValue(PracticeConfig c, Random random) {
  final n = _between(1000, 999999, random);
  final s = n.toString();
  final index = _between(0, s.length - 1, random);
  final digit = int.parse(s[index]);
  final place = s.length - index - 1;
  return _numeric('Place value of digit $digit in $n = ?', digit * pow(10, place).toInt(), random);
}

PracticeQuestion generateFactors(PracticeConfig c, Random random) {
  final a = _between(12, 80 * _scale(c.complexity), random);
  final b = _between(12, 80 * _scale(c.complexity), random);
  final mode = random.nextInt(3);
  if (mode == 0) return _numeric('HCF($a, $b) = ?', _gcd(a, b), random);
  if (mode == 1) return _numeric('LCM($a, $b) = ?', (a ~/ _gcd(a, b)) * b, random);
  final n = _between(12, 100 * _scale(c.complexity), random);
  return _numeric('Number of positive factors of $n = ?', _factorCount(n), random);
}

PracticeQuestion generateDivisibility(PracticeConfig c, Random random) {
  final d = [2, 3, 4, 5, 6, 8, 9, 10, 11][random.nextInt(9)];
  final n = _between(1000, 999999, random);
  return _text('Is $n divisible by $d?', n % d == 0 ? 'Yes' : 'No', random);
}

PracticeQuestion generateRemainders(PracticeConfig c, Random random) {
  final base = _between(2, 20, random);
  final exponent = _between(2, 12 * _scale(c.complexity), random);
  final mod = _between(2, 12, random);
  return _numeric('$base^$exponent mod $mod = ?', _powMod(base, exponent, mod), random);
}
