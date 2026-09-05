import 'dart:math';

import '../../models/practice_models.dart';

List<String> _textOptions(String answer, Random random) {
  const pool = {'1/2': 0.5, '1/4': 0.25, '3/8': 0.375, '5/8': 0.625, '7/20': 0.35, '9/25': 0.36};
  final values = <String>{answer};
  for (final k in pool.keys) {
    if (k != answer) values.add(k);
    if (values.length == 4) break;
  }
  while (values.length < 4) values.add('1/${values.length + 3}');
  return values.toList()..shuffle(random);
}

PracticeQuestion generateFraction(PracticeComplexity complexity, Random random) {
  const pool = <String, double>{
    '1/2': 0.5,
    '1/4': 0.25,
    '3/8': 0.375,
    '5/8': 0.625,
    '7/20': 0.35,
    '9/25': 0.36,
  };
  final key = pool.keys.elementAt(random.nextInt(pool.length));
  return PracticeQuestion(
    prompt: '$key = decimal?',
    answer: pool[key].toString(),
    options: _textOptions(key, random),
    inputHint: 'Decimal',
  );
}
