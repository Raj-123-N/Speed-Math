import 'dart:math';

import '../../models/practice_models.dart';

int _between(int minValue, int maxValue, Random random) =>
    minValue + random.nextInt(maxValue - minValue + 1);

String _format(num value) {
  if (value.isFinite && value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

List<String> _numOpts(num answer, Random random) {
  final values = <num>{answer};
  final spread = max(1, answer.abs() < 10 ? 1 : answer.abs() ~/ 10);
  var g = 0;
  while (values.length < 4 && g++ < 100) values.add(answer + _between(-spread * 3, spread * 3, random));
  while (values.length < 4) values.add(answer + values.length);
  return values.map(_format).toList()..shuffle(random);
}

PracticeQuestion _n(String prompt, num answer, Random random, {String hint = 'Answer'}) =>
    PracticeQuestion(prompt: prompt, answer: _format(answer), options: _numOpts(answer, random), inputHint: hint);

PracticeQuestion generateLinear(PracticeConfig c, Random random) {
  final x = _between(1, 20, random), m = _between(2, 8, random), b = _between(1, 15, random);
  return _n('${m}x + $b = ${m * x + b}; x = ?', x, random, hint: 'Value of x');
}

PracticeQuestion generateQuadratic(PracticeConfig c, Random random) {
  final a = _between(1, 8, random), b = _between(1, 8, random);
  return _n('x² − ${a + b}x + ${a * b} = 0; smaller root = ?', min(a, b), random, hint: 'Value of x');
}

PracticeQuestion generateCubic(PracticeConfig c, Random random) {
  final x = _between(2, 8, random);
  return _n('x³ = ${x * x * x}; x = ?', x, random, hint: 'Value of x');
}

PracticeQuestion generatePolynomials(PracticeConfig c, Random random) {
  final root = _between(-6, 6, random), x = _between(1, 8, random);
  return _n('For p(x)=x²−${2 * root}x+${root * root}, p($x)=?', (x - root) * (x - root), random);
}

PracticeQuestion generateEquationMix(PracticeConfig c, Random random) =>
    random.nextBool() ? generateLinear(c, random) : generateQuadratic(c, random);
