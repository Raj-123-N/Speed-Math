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

PracticeQuestion _n(String prompt, num answer, Random random) =>
    PracticeQuestion(prompt: prompt, answer: _format(answer), options: _numOpts(answer, random), inputHint: 'Answer');

PracticeQuestion generateSeries(PracticeConfig c, Random random) {
  final start = _between(1, 20, random), step = _between(2, 10, random);
  final mode = random.nextInt(3);
  if (mode == 0) {
    final v = List.generate(4, (i) => start + i * step);
    return _n('${v.join(', ')}, ?', v.last + step, random);
  }
  if (mode == 1) {
    final v = List.generate(4, (i) => start * pow(2, i).toInt());
    return _n('${v.join(', ')}, ?', v.last * 2, random);
  }
  final v = List.generate(4, (i) => start + i * i);
  return _n('${v.join(', ')}, ?', v.last + 9, random);
}

PracticeQuestion generateAP(PracticeConfig c, Random random) {
  final a = _between(1, 20, random), d = _between(2, 10, random), n = _between(5, 20, random);
  return _n('AP: a=$a, d=$d. Term $n = ?', a + (n - 1) * d, random);
}

PracticeQuestion generateGP(PracticeConfig c, Random random) {
  final a = _between(1, 5, random), r = _between(2, 4, random), n = _between(3, 7, random);
  return _n('GP: a=$a, r=$r. Term $n = ?', a * pow(r, n - 1), random);
}

PracticeQuestion generatePatterns(PracticeConfig c, Random random) {
  final n = _between(2, 10, random);
  final values = List.generate(4, (i) => (n + i) * (n + i + 1));
  return _n('${values.join(', ')}, ?', (n + 4) * (n + 5), random);
}
