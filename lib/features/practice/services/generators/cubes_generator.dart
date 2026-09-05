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

/// Cubes generator — strictly from [valueStart, valueEnd].
PracticeQuestion generateCubes(PracticeConfig c, Random random) {
  final n = _between(c.valueStart, c.valueEnd, random);
  return PracticeQuestion(
    prompt: '$n³ = ?',
    answer: _format(n * n * n),
    options: _numberOptions(n * n * n, random),
    inputHint: 'Cube',
  );
}
