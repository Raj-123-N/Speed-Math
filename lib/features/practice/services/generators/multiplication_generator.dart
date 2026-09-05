import 'dart:math';

import '../../models/practice_models.dart';

int _between(int minValue, int maxValue, Random random) =>
    minValue + random.nextInt(maxValue - minValue + 1);

int _number(int digits, Random random) {
  final d = digits.clamp(1, 5);
  final minValue = d == 1 ? 1 : pow(10, d - 1).toInt();
  final maxValue = pow(10, d).toInt() - 1;
  return _between(minValue, maxValue, random);
}

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
  while (values.length < 4) {
    values.add(answer + values.length);
  }
  return values.map(_format).toList()..shuffle(random);
}

PracticeQuestion generateMultiplication(PracticeConfig c, Random random) {
  final a = _number(c.lhsDigits, random);
  final b = _number(c.rhsDigits, random);
  return PracticeQuestion(
    prompt: '$a × $b = ?',
    answer: _format(a * b),
    options: _numberOptions(a * b, random),
    inputHint: 'Product',
  );
}
