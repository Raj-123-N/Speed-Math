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

int _factorial(int n) { var r = 1; for (var i = 2; i <= n; i++) r *= i; return r; }
int _nPr(int n, int r) => _factorial(n) ~/ _factorial(n - r);
int _nCr(int n, int r) => _nPr(n, r) ~/ _factorial(r);

PracticeQuestion generatePnC(PracticeConfig c, Random random) {
  final n = _between(4, 10, random), r = _between(2, min(5, n), random);
  final usePerm = random.nextBool();
  final value = usePerm ? _nPr(n, r) : _nCr(n, r);
  return PracticeQuestion(
    prompt: '${usePerm ? 'nPr' : 'nCr'}($n,$r) = ?',
    answer: _format(value),
    options: _numOpts(value, random),
    inputHint: 'Answer',
  );
}

PracticeQuestion generateProbability(PracticeConfig c, Random random) {
  final red = _between(1, 8, random), blue = _between(1, 8, random);
  return PracticeQuestion(
    prompt: 'Bag has $red red and $blue blue. P(red) = ?',
    answer: _format(red / (red + blue)),
    options: _numOpts(red / (red + blue), random),
    inputHint: 'Probability',
  );
}

PracticeQuestion generateDataInterpretation(PracticeConfig c, Random random) {
  final rows = List.generate(4, (_) => _between(20, 150, random));
  final total = rows.fold(0, (a, b) => a + b);
  return PracticeQuestion(
    prompt: 'Data values ${rows.join(', ')}. Total = ?',
    answer: _format(total),
    options: _numOpts(total, random),
    inputHint: 'Total',
  );
}

PracticeQuestion generateStatistics(PracticeConfig c, Random random) {
  final values = List.generate(5, (_) => _between(5, 50, random))..sort();
  return PracticeQuestion(
    prompt: 'Sorted data ${values.join(', ')}. Median = ?',
    answer: _format(values[2]),
    options: _numOpts(values[2], random),
    inputHint: 'Median',
  );
}
