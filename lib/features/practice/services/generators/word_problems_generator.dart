import 'dart:math';

import '../../models/practice_models.dart';

int _between(int minValue, int maxValue, Random random) =>
    minValue + random.nextInt(maxValue - minValue + 1);

int _scale(PracticeComplexity c) => switch (c) {
      PracticeComplexity.easy => 1,
      PracticeComplexity.medium => 2,
      PracticeComplexity.hard => 4,
    };

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
  while (values.length < 4) values.add(answer + values.length);
  return values.map(_format).toList()..shuffle(random);
}

List<String> _textOptions(String answer, Random random) {
  final values = <String>{answer};
  const alternatives = ['2:3', '3:2', '1:2', '4:3', '5:2', '3:1'];
  for (final v in alternatives) {
    if (v != answer) values.add(v);
    if (values.length == 4) break;
  }
  return values.toList()..shuffle(random);
}

PracticeQuestion _numeric(String prompt, num answer, Random random,
        {String inputHint = 'Answer'}) =>
    PracticeQuestion(
      prompt: prompt,
      answer: _format(answer),
      options: _numberOptions(answer, random),
      inputHint: inputHint,
    );

PracticeQuestion generateAverages(PracticeConfig c, Random random) {
  final count = _between(3, 7, random);
  final average = _between(8, 40 * _scale(c.complexity), random);
  final delta = _between(1, 10, random);
  if (random.nextBool()) {
    return _numeric(
        '$count values average $average. Add $delta to one value. New average = ?',
        average + delta / count,
        random);
  }
  return _numeric('Total of $count values with average $average = ?', count * average, random);
}

PracticeQuestion generateRatio(PracticeConfig c, Random random) {
  final a = _between(2, 12, random);
  final b = _between(2, 15, random);
  final total = (a + b) * _between(2, 12, random);
  final larger = max(a, b);
  return _numeric('Divide $total in ratio $a:$b. Larger share = ?', larger * total ~/ (a + b), random);
}

PracticeQuestion generateProfitLoss(PracticeConfig c, Random random) {
  final cp = _between(50, 1000 * _scale(c.complexity), random);
  final pct = _between(5, 30, random);
  if (random.nextBool()) {
    return _numeric('CP $cp, profit $pct%. SP = ?', cp * (100 + pct) / 100, random);
  }
  return _numeric('CP $cp, loss $pct%. SP = ?', cp * (100 - pct) / 100, random);
}

PracticeQuestion generateInterest(PracticeConfig c, Random random) {
  final p = _between(100, 2000 * _scale(c.complexity), random);
  final r = _between(2, 12, random), t = _between(1, 4, random);
  if (random.nextBool()) {
    return _numeric('SI on $p at $r% for $t years = ?', p * r * t / 100, random);
  }
  return _numeric('Amount with CI: $p at $r% for $t years = ?', p * pow(1 + r / 100, t), random);
}

PracticeQuestion generateMixture(PracticeConfig c, Random random) {
  final low = _between(10, 30, random);
  final high = _between(low + 10, 70, random);
  final target = _between(low + 2, high - 2, random);
  final lowParts = high - target;
  final highParts = target - low;
  final opts = <String>{'$lowParts:$highParts'};
  opts.addAll(['1:2', '2:3', '3:4', '1:3'].where((v) => v != '$lowParts:$highParts'));
  return PracticeQuestion(
    prompt: 'Mix $low% and $high% to get $target%. Ratio low:high = ?',
    answer: '$lowParts:$highParts',
    options: opts.take(4).toList()..shuffle(random),
    inputHint: 'Ratio',
  );
}

PracticeQuestion generatePartnership(PracticeConfig c, Random random) {
  final capitalA = _between(2, 10, random);
  final capitalB = _between(2, 12, random);
  final monthsA = _between(3, 12, random);
  final monthsB = _between(3, 12, random);
  final shareA = capitalA * monthsA;
  final shareB = capitalB * monthsB;
  int gcd(int a, int b) { a = a.abs(); b = b.abs(); while (b != 0) { final t = a % b; a = b; b = t; } return a; }
  final g = gcd(shareA, shareB);
  final answer = '${shareA ~/ g}:${shareB ~/ g}';
  final opts = <String>{answer};
  for (final v in ['1:1', '2:3', '3:2', '4:3', '5:4']) {
    if (v != answer) opts.add(v);
    if (opts.length == 4) break;
  }
  return PracticeQuestion(
    prompt: 'Profit-sharing ratio A:B for $capitalA×$monthsA and $capitalB×$monthsB = ?',
    answer: answer,
    options: opts.toList()..shuffle(random),
    inputHint: 'Ratio A:B',
  );
}

PracticeQuestion generateAges(PracticeConfig c, Random random) {
  final younger = _between(8, 25, random);
  final gap = _between(3, 15, random);
  final years = _between(2, 8, random);
  return _numeric(
      '$years years later, older age if current younger=$younger and gap=$gap = ?',
      younger + gap + years,
      random);
}

PracticeQuestion generateTimeWork(PracticeConfig c, Random random) {
  final a = _between(4, 12, random), b = _between(4, 15, random);
  return _numeric('A takes $a days, B takes $b days. Together: days?', a * b / (a + b), random);
}

PracticeQuestion generatePipes(PracticeConfig c, Random random) {
  final fill = _between(4, 12, random);
  final drain = _between(fill + 2, 20, random);
  return _numeric('Pipe fills in $fill h, leak drains in $drain h. Net fill time?',
      fill * drain / (drain - fill), random);
}

PracticeQuestion generateSpeedDistance(PracticeConfig c, Random random) {
  final speed = _between(20, 90, random), time = _between(2, 6, random);
  return _numeric('Distance at $speed km/h for $time h = ?', speed * time, random);
}

PracticeQuestion generateTrains(PracticeConfig c, Random random) {
  final length = _between(80, 300, random);
  final platform = _between(100, 500, random);
  final speed = _between(10, 60, random);
  return _numeric('Train $length m crosses $platform m platform at $speed m/s. Time = ?',
      (length + platform) / speed, random);
}

PracticeQuestion generateBoats(PracticeConfig c, Random random) {
  final downstream = _between(10, 30, random);
  final upstream = _between(4, downstream - 2, random);
  return _numeric('Downstream $downstream km/h, upstream $upstream km/h. Still-water speed = ?',
      (downstream + upstream) / 2, random);
}
