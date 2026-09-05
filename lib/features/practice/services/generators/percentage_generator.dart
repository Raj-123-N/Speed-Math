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

PracticeQuestion generatePercentage(PracticeConfig c, Random random) {
  final pct = [5, 10, 12, 15, 20, 25, 30, 40, 50, 75][random.nextInt(10)];
  final base = _between(20, max(20, 1000 ~/ pct * 10), random);
  return PracticeQuestion(
    prompt: '$pct% of $base = ?',
    answer: _format(base * pct / 100),
    options: _numberOptions(base * pct / 100, random),
    inputHint: 'Answer',
  );
}
