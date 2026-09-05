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

/// Division generator — always produces a clean integer answer.
/// LHS digits = quotient (what the user must find).
/// RHS digits = divisor.
/// Dividend = divisor × quotient (derived, always exact).
PracticeQuestion generateDivision(PracticeConfig c, Random random) {
  final divisor = _number(c.rhsDigits, random);   // e.g. 1-digit: 1–9
  final quotient = _number(c.lhsDigits, random);  // e.g. 2-digit: 10–99
  final dividend = divisor * quotient;
  return PracticeQuestion(
    prompt: '$dividend ÷ $divisor = ?',
    answer: _format(quotient),
    options: _numberOptions(quotient, random),
    inputHint: 'Quotient',
  );
}
