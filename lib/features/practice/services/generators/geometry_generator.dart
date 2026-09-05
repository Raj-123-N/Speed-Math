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

List<String> _textOpts(String answer, List<String> pool, Random random) {
  final values = <String>{answer};
  for (final v in pool) {
    if (v != answer) values.add(v);
    if (values.length == 4) break;
  }
  return values.toList()..shuffle(random);
}

PracticeQuestion _n(String prompt, num answer, Random random) =>
    PracticeQuestion(prompt: prompt, answer: _format(answer), options: _numOpts(answer, random), inputHint: 'Answer');

PracticeQuestion generateGeometry(PracticeConfig c, Random random) {
  final a = _between(30, 100, random), b = _between(20, 80, random);
  if (a + b >= 180) return generateGeometry(c, random);
  return _n('Triangle angles: $a°, $b°, third angle = ?', 180 - a - b, random);
}

PracticeQuestion generateMensuration2d(PracticeConfig c, Random random) {
  final w = _between(3, 20, random), h = _between(3, 20, random);
  return _n('Rectangle $w × $h. Area = ?', w * h, random);
}

PracticeQuestion generateMensuration3d(PracticeConfig c, Random random) {
  final r = _between(2, 10, random), h = _between(3, 15, random);
  return _n('Cylinder r=$r, h=$h. Volume / π = ?', r * r * h, random);
}

PracticeQuestion generatePythagorean(PracticeConfig c, Random random) {
  const triples = <List<int>>[[3, 4, 5], [5, 12, 13], [6, 8, 10], [8, 15, 17], [9, 12, 15], [12, 16, 20]];
  final triple = triples[random.nextInt(triples.length)];
  return _n('Right triangle legs ${triple[0]} and ${triple[1]}. Hypotenuse = ?', triple[2], random);
}

/// Extended trigonometry — all standard angles for sin, cos, tan, cosec, sec, cot.
PracticeQuestion generateTrigonometry(PracticeConfig c, Random random) {
  const pool = <String, String>{
    'sin 0°': '0',
    'sin 30°': '1/2',
    'sin 45°': '1/√2',
    'sin 60°': '√3/2',
    'sin 90°': '1',
    'cos 0°': '1',
    'cos 30°': '√3/2',
    'cos 45°': '1/√2',
    'cos 60°': '1/2',
    'cos 90°': '0',
    'tan 0°': '0',
    'tan 30°': '1/√3',
    'tan 45°': '1',
    'tan 60°': '√3',
    'tan 90°': 'undefined',
    'cosec 30°': '2',
    'cosec 45°': '√2',
    'cosec 60°': '2/√3',
    'sec 0°': '1',
    'sec 60°': '2',
    'cot 45°': '1',
    'cot 90°': '0',
  };
  const allValues = [
    '0', '1/2', '1/√2', '√3/2', '1', '√3', '1/√3', '2',
    '√2', '2/√3', 'undefined',
  ];
  final prompt = pool.keys.elementAt(random.nextInt(pool.length));
  final answer = pool[prompt]!;
  final opts = _textOpts(answer, allValues, random);
  return PracticeQuestion(
    prompt: '$prompt = ?',
    answer: answer,
    options: opts,
    inputHint: 'Exact value',
  );
}
