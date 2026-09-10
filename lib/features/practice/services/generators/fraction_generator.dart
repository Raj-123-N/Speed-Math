import 'dart:math';

import '../../models/practice_models.dart';

const Map<String, double> _fractionPool = {
  '1/2': 0.5,
  '1/4': 0.25,
  '3/4': 0.75,
  '1/5': 0.2,
  '2/5': 0.4,
  '3/5': 0.6,
  '4/5': 0.8,
  '1/8': 0.125,
  '3/8': 0.375,
  '5/8': 0.625,
  '7/8': 0.875,
  '7/20': 0.35,
  '9/25': 0.36,
  '1/10': 0.1,
  '3/10': 0.3,
  '7/10': 0.7,
  '9/10': 0.9,
};

List<String> _pickOptions(String answer, List<String> allChoices, Random random) {
  final values = <String>{answer};
  final shuffled = List<String>.from(allChoices)..shuffle(random);
  for (final choice in shuffled) {
    if (choice != answer) values.add(choice);
    if (values.length == 4) break;
  }
  return values.toList()..shuffle(random);
}

PracticeQuestion generateFraction(PracticeComplexity complexity, Random random) {
  final entry = _fractionPool.entries.elementAt(random.nextInt(_fractionPool.length));
  final fractionStr = entry.key;
  final decimalStr = entry.value.toString();

  final askDecimal = random.nextBool();
  if (askDecimal) {
    final allDecimals = _fractionPool.values.map((v) => v.toString()).toList();
    return PracticeQuestion(
      prompt: '$fractionStr in decimal = ?',
      answer: decimalStr,
      options: _pickOptions(decimalStr, allDecimals, random),
      inputHint: 'Decimal',
    );
  } else {
    final allFractions = _fractionPool.keys.toList();
    return PracticeQuestion(
      prompt: '$decimalStr as fraction = ?',
      answer: fractionStr,
      options: _pickOptions(fractionStr, allFractions, random),
      inputHint: 'Fraction (e.g. 1/2)',
    );
  }
}
