import 'dart:math';

import '../../../core/models/quiz_category.dart';
import '../models/practice_models.dart';

/// Generates repeatable, topic-specific practice questions.
///
/// Practice is deliberately separate from Quiz/Challenge: every generator can
/// be run repeatedly with configurable difficulty and input mode.
class PracticeQuestionEngine {
  PracticeQuestionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<String> _recent = [];
  final Map<String, int> _tableCursor = {};
  final Map<String, List<int>> _tableOrders = {};

  PracticeQuestion next(PracticeConfig config) {
    var question = _generate(config);
    var guard = 0;
    while (_recent.contains(question.prompt) && guard++ < 40) {
      question = _generate(config);
    }
    _recent.add(question.prompt);
    if (_recent.length > 50) _recent.removeAt(0);
    return question;
  }

  PracticeQuestion _generate(PracticeConfig c) {
    switch (c.pattern) {
      case PracticePattern.arithmetic:
        return _arithmetic(c);
      case PracticePattern.multiplication:
        return _multiplication(c);
      case PracticePattern.division:
        return _division(c);
      case PracticePattern.tables:
        return _tables(c);
      case PracticePattern.recall:
        return _recall(c);
      case PracticePattern.generic:
        return _topic(c);
    }
  }

  PracticeQuestion _topic(PracticeConfig c) {
    switch (c.category.operation) {
      case MathOperation.numberSystem: return _numberSystem(c);
      case MathOperation.placeValue: return _placeValue(c);
      case MathOperation.factorsMultiples: return _factors(c);
      case MathOperation.divisibility: return _divisibility(c);
      case MathOperation.remainders: return _remainders(c);
      case MathOperation.averages: return _averages(c);
      case MathOperation.ratioProportion: return _ratio(c);
      case MathOperation.profitLossDiscount: return _profitLoss(c);
      case MathOperation.simpleCompoundInterest: return _interest(c);
      case MathOperation.mixtureAlligation: return _mixture(c);
      case MathOperation.partnership: return _partnership(c);
      case MathOperation.ages: return _ages(c);
      case MathOperation.timeWork: return _timeWork(c);
      case MathOperation.pipesCisterns: return _pipes(c);
      case MathOperation.speedDistance: return _speedDistance(c);
      case MathOperation.trains: return _trains(c);
      case MathOperation.boatsStreams: return _boats(c);
      case MathOperation.series: return _series(c);
      case MathOperation.arithmeticProgression: return _ap(c);
      case MathOperation.geometricProgression: return _gp(c);
      case MathOperation.sequencesPatterns: return _patterns(c);
      case MathOperation.polynomials: return _polynomials(c);
      case MathOperation.geometryBasics: return _geometry(c);
      case MathOperation.mensuration2d: return _mensuration2d(c);
      case MathOperation.mensuration3d: return _mensuration3d(c);
      case MathOperation.pythagorean: return _pythagorean(c);
      case MathOperation.trigonometry: return _trigonometry(c);
      case MathOperation.permutationCombination: return _pnC(c);
      case MathOperation.probability: return _probability(c);
      case MathOperation.dataInterpretation: return _dataInterpretation(c);
      case MathOperation.statistics: return _statistics(c);
      case MathOperation.mentalMultiplication: return _mentalMultiplication(c);
      case MathOperation.fastDivision: return _fastDivision(c);
      case MathOperation.bodmas: return _bodmas(c);
      case MathOperation.simplification: return _simplification(c);
      case MathOperation.linearEquation: return _linear(c);
      case MathOperation.quadraticEquation: return _quadratic(c);
      case MathOperation.cubicEquation: return _cubic(c);
      case MathOperation.unitDigit: return _unitDigit(c);
      case MathOperation.powers:
      case MathOperation.exponents: return _powers(c);
      case MathOperation.algebra: return _equationMix(c);
      case MathOperation.percentage: return _percentage(c);
      case MathOperation.fraction: return _fraction(c.complexity);
      case MathOperation.square: return _square(c);
      case MathOperation.cube: return _cube(c);
      case MathOperation.squareRoot: return _squareRoot(c);
      case MathOperation.cubeRoot: return _cubeRoot(c);
      case MathOperation.addition: return _arithmetic(c);
      case MathOperation.subtraction: return _arithmetic(c);
      case MathOperation.multiplication: return _multiplication(c);
      case MathOperation.division: return _division(c);
      case MathOperation.table: return _tables(c);
      case MathOperation.diAddition: return _dataInterpretation(c);
      case MathOperation.quickRecallWorkout: return _quickRecallWorkout(c);
      case MathOperation.basicsWorkout: return _basicsWorkout(c);
      case MathOperation.mixAdvance: return _advancedMix(c);
      case MathOperation.miscellaneousMix: return _miscellaneousMix(c);
    }
  }

  int _scale(PracticeComplexity c) => switch (c) {
        PracticeComplexity.easy => 1,
        PracticeComplexity.medium => 2,
        PracticeComplexity.hard => 4,
      };

  int _between(int minValue, int maxValue) =>
      minValue + _random.nextInt(maxValue - minValue + 1);

  int _number(int digits) {
    final d = digits.clamp(1, 5);
    final minValue = d == 1 ? 1 : pow(10, d - 1).toInt();
    final maxValue = pow(10, d).toInt() - 1;
    return _between(minValue, maxValue);
  }

  PracticeQuestion _arithmetic(PracticeConfig c) {
    final n = c.terms.clamp(2, 6);
    final values = List.generate(n, (i) => _number(i == 0 ? c.lhsDigits : c.rhsDigits));
    if (c.category.operation == MathOperation.subtraction) {
      final first = values.first;
      var remainder = first;
      for (var i = 1; i < values.length; i++) {
        values[i] = min(values[i], max(1, remainder ~/ (values.length - i)));
        remainder -= values[i];
      }
      return _numeric('${values.join(' − ')} = ?', remainder);
    }
    return _numeric('${values.join(' + ')} = ?', values.fold(0, (a, b) => a + b));
  }

  PracticeQuestion _multiplication(PracticeConfig c) {
    final a = _number(c.lhsDigits), b = _number(c.rhsDigits);
    return _numeric('$a × $b = ?', a * b);
  }

  PracticeQuestion _division(PracticeConfig c) {
    final divisor = _number(c.rhsDigits), quotient = _number(c.lhsDigits);
    return _numeric('${divisor * quotient} ÷ $divisor = ?', quotient);
  }

  PracticeQuestion _tables(PracticeConfig c) {
    final start = min(c.tableStart, c.tableEnd).clamp(1, 100);
    final end = max(c.tableStart, c.tableEnd).clamp(1, 100);
    final maxMultiplier = c.multiplierMax.clamp(1, 20);
    final key = '${c.category.id}:$start-$end:$maxMultiplier:${c.tableOrder}:${c.shuffleSequential}';

    late final int table;
    late final int multiplier;

    if (c.tableOrder == TableOrder.sequential) {
      // Sequential mode walks the complete Cartesian product of table numbers
      // and multipliers before repeating. This makes practice predictable and
      // ensures a table range such as 2–3 with ×1–2 yields 2×1, 2×2, 3×1, 3×2.
      final order = _tableOrders.putIfAbsent(key, () {
        final pairCount = (end - start + 1) * maxMultiplier;
        final list = List.generate(pairCount, (index) => index);
        if (c.shuffleSequential) list.shuffle(_random);
        return list;
      });
      final cursor = _tableCursor[key] ?? 0;
      final pair = order[cursor % order.length];
      _tableCursor[key] = cursor + 1;
      table = start + pair ~/ maxMultiplier;
      multiplier = pair % maxMultiplier + 1;
    } else {
      table = _between(start, end);
      multiplier = _between(1, maxMultiplier);
    }

    return _numeric('$table × $multiplier = ?', table * multiplier);
  }

  PracticeQuestion _recall(PracticeConfig c) {
    switch (c.category.operation) {
      case MathOperation.square: return _square(c);
      case MathOperation.cube: return _cube(c);
      case MathOperation.squareRoot: return _squareRoot(c);
      case MathOperation.cubeRoot: return _cubeRoot(c);
      case MathOperation.percentage: return _percentage(c);
      case MathOperation.fraction: return _fraction(c.complexity);
      default: return _topic(c);
    }
  }

  PracticeQuestion _square(PracticeConfig c) {
    final n = _between(2, 30 * _scale(c.complexity));
    return _numeric('$n² = ?', n * n);
  }

  PracticeQuestion _cube(PracticeConfig c) {
    final n = _between(2, 12 * _scale(c.complexity));
    return _numeric('$n³ = ?', n * n * n);
  }

  PracticeQuestion _squareRoot(PracticeConfig c) {
    final n = _between(2, 40 * _scale(c.complexity));
    return _numeric('√${n * n} = ?', n);
  }

  PracticeQuestion _cubeRoot(PracticeConfig c) {
    final n = _between(2, 15 * _scale(c.complexity));
    return _numeric('∛${n * n * n} = ?', n);
  }

  PracticeQuestion _numberSystem(PracticeConfig c) {
    final n = _between(-100 * _scale(c.complexity), 100 * _scale(c.complexity));
    switch (_random.nextInt(3)) {
      case 0:
        return _text('$n is ___', n.isEven ? 'even' : 'odd');
      case 1:
        return _text('$n is ___', n >= 0 ? 'non-negative' : 'negative');
      default:
        return _numeric('|$n| = ?', n.abs());
    }
  }

  PracticeQuestion _placeValue(PracticeConfig c) {
    final n = _between(1000, 999999);
    final s = n.toString();
    final index = _between(0, s.length - 1);
    final digit = int.parse(s[index]);
    final place = s.length - index - 1;
    return _numeric('Place value of digit $digit in $n = ?', digit * pow(10, place).toInt());
  }

  PracticeQuestion _factors(PracticeConfig c) {
    final a = _between(12, 80 * _scale(c.complexity));
    final b = _between(12, 80 * _scale(c.complexity));
    final mode = _random.nextInt(3);
    if (mode == 0) return _numeric('HCF($a, $b) = ?', _gcd(a, b));
    if (mode == 1) return _numeric('LCM($a, $b) = ?', _lcm(a, b));
    final n = _between(12, 100 * _scale(c.complexity));
    return _numeric('Number of positive factors of $n = ?', _factorCount(n));
  }

  PracticeQuestion _divisibility(PracticeConfig c) {
    final d = [2, 3, 4, 5, 6, 8, 9, 10, 11][_random.nextInt(9)];
    final n = _between(1000, 999999);
    return _text('Is $n divisible by $d?', n % d == 0 ? 'Yes' : 'No');
  }

  PracticeQuestion _remainders(PracticeConfig c) {
    final base = _between(2, 20), exponent = _between(2, 12 * _scale(c.complexity));
    final mod = _between(2, 12);
    return _numeric('$base^$exponent mod $mod = ?', _powMod(base, exponent, mod));
  }

  PracticeQuestion _averages(PracticeConfig c) {
    final count = _between(3, 7), average = _between(8, 40 * _scale(c.complexity));
    final delta = _between(1, 10);
    if (_random.nextBool()) {
      return _numeric('$count values average $average. Add $delta to one value. New average = ?', average + delta / count);
    }
    return _numeric('Total of $count values with average $average = ?', count * average);
  }

  PracticeQuestion _ratio(PracticeConfig c) {
    final a = _between(2, 12), b = _between(2, 15), total = (a + b) * _between(2, 12);
    final larger = max(a, b);
    return _numeric('Divide $total in ratio $a:$b. Larger share = ?', larger * total ~/ (a + b));
  }

  PracticeQuestion _percentage(PracticeConfig c) {
    final pct = [5, 10, 12, 15, 20, 25, 30, 40, 50, 75][_random.nextInt(10)];
    final base = _between(20, max(20, 1000 ~/ pct * 10));
    return _numeric('$pct% of $base = ?', base * pct / 100);
  }

  PracticeQuestion _profitLoss(PracticeConfig c) {
    final cp = _between(50, 1000 * _scale(c.complexity));
    final pct = _between(5, 30);
    if (_random.nextBool()) return _numeric('CP $cp, profit $pct%. SP = ?', cp * (100 + pct) / 100);
    return _numeric('CP $cp, loss $pct%. SP = ?', cp * (100 - pct) / 100);
  }

  PracticeQuestion _interest(PracticeConfig c) {
    final p = _between(100, 2000 * _scale(c.complexity));
    final r = _between(2, 12), t = _between(1, 4);
    if (_random.nextBool()) return _numeric('SI on $p at $r% for $t years = ?', p * r * t / 100);
    return _numeric('Amount with CI: $p at $r% for $t years = ?', p * pow(1 + r / 100, t));
  }

  PracticeQuestion _mixture(PracticeConfig c) {
    final low = _between(10, 30);
    final high = _between(low + 10, 70);
    final target = _between(low + 2, high - 2);
    final lowParts = high - target;
    final highParts = target - low;
    return _text('Mix $low% and $high% to get $target%. Ratio low:high = ?', '$lowParts:$highParts');
  }

  PracticeQuestion _partnership(PracticeConfig c) {
    final capitalA = _between(2, 10);
    final capitalB = _between(2, 12);
    final monthsA = _between(3, 12);
    final monthsB = _between(3, 12);
    final shareA = capitalA * monthsA;
    final shareB = capitalB * monthsB;
    final gcd = _gcd(shareA, shareB);
    return _text('Profit-sharing ratio A:B for $capitalA×$monthsA and $capitalB×$monthsB = ?', '${shareA ~/ gcd}:${shareB ~/ gcd}');
  }

  PracticeQuestion _ages(PracticeConfig c) {
    final younger = _between(8, 25), gap = _between(3, 15), years = _between(2, 8);
    return _numeric('$years years later, older age if current younger=$younger and gap=$gap = ?', younger + gap + years);
  }

  PracticeQuestion _timeWork(PracticeConfig c) {
    final a = _between(4, 12), b = _between(4, 15);
    return _numeric('A takes $a days, B takes $b days. Together: days?', a * b / (a + b));
  }

  PracticeQuestion _pipes(PracticeConfig c) {
    final fill = _between(4, 12), drain = _between(fill + 2, 20);
    return _numeric('Pipe fills in $fill h, leak drains in $drain h. Net fill time?', fill * drain / (drain - fill));
  }

  PracticeQuestion _speedDistance(PracticeConfig c) {
    final speed = _between(20, 90), time = _between(2, 6);
    return _numeric('Distance at $speed km/h for $time h = ?', speed * time);
  }

  PracticeQuestion _trains(PracticeConfig c) {
    final length = _between(80, 300), platform = _between(100, 500), speed = _between(10, 60);
    return _numeric('Train $length m crosses $platform m platform at $speed m/s. Time = ?', (length + platform) / speed);
  }

  PracticeQuestion _boats(PracticeConfig c) {
    final downstream = _between(10, 30), upstream = _between(4, downstream - 2);
    return _numeric('Downstream $downstream km/h, upstream $upstream km/h. Still-water speed = ?', (downstream + upstream) / 2);
  }

  PracticeQuestion _series(PracticeConfig c) {
    final start = _between(1, 20), step = _between(2, 10);
    final mode = _random.nextInt(3);
    if (mode == 0) {
      final v = List.generate(4, (i) => start + i * step);
      return _numeric('${v.join(', ')}, ? ', v.last + step);
    }
    if (mode == 1) {
      final v = List.generate(4, (i) => start * pow(2, i).toInt());
      return _numeric('${v.join(', ')}, ?', v.last * 2);
    }
    final v = List.generate(4, (i) => start + i * i);
    return _numeric('${v.join(', ')}, ?', v.last + 9);
  }

  PracticeQuestion _ap(PracticeConfig c) {
    final a = _between(1, 20), d = _between(2, 10), n = _between(5, 20);
    return _numeric('AP: a=$a, d=$d. Term $n = ?', a + (n - 1) * d);
  }

  PracticeQuestion _gp(PracticeConfig c) {
    final a = _between(1, 5), r = _between(2, 4), n = _between(3, 7);
    return _numeric('GP: a=$a, r=$r. Term $n = ?', a * pow(r, n - 1));
  }

  PracticeQuestion _patterns(PracticeConfig c) {
    final n = _between(2, 10);
    final values = List.generate(4, (i) => (n + i) * (n + i + 1));
    return _numeric('${values.join(', ')}, ?', (n + 4) * (n + 5));
  }

  PracticeQuestion _polynomials(PracticeConfig c) {
    final root = _between(-6, 6);
    final x = _between(1, 8);
    return _numeric('For p(x)=x²−${2 * root}x+${root * root}, p($x)=?', (x - root) * (x - root));
  }

  PracticeQuestion _geometry(PracticeConfig c) {
    final a = _between(30, 100), b = _between(20, 80);
    if (a + b >= 180) return _geometry(c);
    return _numeric('Triangle angles: $a°, $b°, third angle = ?', 180 - a - b);
  }

  PracticeQuestion _mensuration2d(PracticeConfig c) {
    final w = _between(3, 20), h = _between(3, 20);
    return _numeric('Rectangle $w × $h. Area = ?', w * h);
  }

  PracticeQuestion _mensuration3d(PracticeConfig c) {
    final r = _between(2, 10), h = _between(3, 15);
    return _numeric('Cylinder r=$r, h=$h. Volume / π = ?', r * r * h);
  }

  PracticeQuestion _pythagorean(PracticeConfig c) {
    const triples = <List<int>>[[3, 4, 5], [5, 12, 13], [6, 8, 10], [8, 15, 17], [9, 12, 15], [12, 16, 20]];
    final triple = triples[_random.nextInt(triples.length)];
    return _numeric('Right triangle legs ${triple[0]} and ${triple[1]}. Hypotenuse = ?', triple[2]);
  }

  PracticeQuestion _trigonometry(PracticeConfig c) {
    const pool = <String, num>{'sin 30°': .5, 'cos 60°': .5, 'tan 45°': 1, 'sin 90°': 1, 'cos 0°': 1, 'tan 0°': 0};
    final prompt = pool.keys.elementAt(_random.nextInt(pool.length));
    return _numeric('$prompt = ?', pool[prompt]!);
  }

  PracticeQuestion _pnC(PracticeConfig c) {
    final n = _between(4, 10), r = _between(2, min(5, n));
    final usePermutation = _random.nextBool();
    final value = usePermutation ? _nPr(n, r) : _nCr(n, r);
    return _numeric('${usePermutation ? 'nPr' : 'nCr'}($n,$r) = ?', value);
  }

  PracticeQuestion _probability(PracticeConfig c) {
    final red = _between(1, 8), blue = _between(1, 8);
    return _numeric('Bag has $red red and $blue blue. P(red) = ?', red / (red + blue));
  }

  PracticeQuestion _dataInterpretation(PracticeConfig c) {
    final rows = List.generate(4, (_) => _between(20, 150));
    final total = rows.fold(0, (a, b) => a + b);
    return _numeric('Data values ${rows.join(', ')}. Total = ?', total);
  }

  PracticeQuestion _statistics(PracticeConfig c) {
    final values = List.generate(5, (_) => _between(5, 50))..sort();
    return _numeric('Sorted data ${values.join(', ')}. Median = ?', values[2]);
  }

  PracticeQuestion _mentalMultiplication(PracticeConfig c) {
    final base = _random.nextBool() ? 100 : 50;
    final n = _between(10, 99);
    if (base == 100) return _numeric('$n × 100 = ?', n * 100);
    return _numeric('$n × 50 = ?', n * 50);
  }

  PracticeQuestion _fastDivision(PracticeConfig c) {
    final q = _between(5, 100), d = [4, 5, 10, 20, 25, 50][_random.nextInt(6)];
    return _numeric('${q * d} ÷ $d = ?', q);
  }

  PracticeQuestion _bodmas(PracticeConfig c) {
    final a = _between(2, 12), b = _between(2, 12), d = _between(2, 8);
    return _numeric('$a + $b × $d = ?', a + b * d);
  }

  PracticeQuestion _simplification(PracticeConfig c) {
    final a = _between(10, 50), b = _between(2, 10);
    return _numeric('($a + $b) × 2 − $b = ?', (a + b) * 2 - b);
  }

  PracticeQuestion _linear(PracticeConfig c) {
    final x = _between(1, 20), m = _between(2, 8), b = _between(1, 15);
    return _numeric('${m}x + $b = ${m * x + b}; x = ?', x, inputHint: 'Value of x');
  }

  PracticeQuestion _quadratic(PracticeConfig c) {
    final a = _between(1, 8), b = _between(1, 8);
    return _numeric('x² − ${a + b}x + ${a * b} = 0; smaller root = ?', min(a, b), inputHint: 'Value of x');
  }

  PracticeQuestion _cubic(PracticeConfig c) {
    final x = _between(2, 8);
    return _numeric('x³ = ${x * x * x}; x = ?', x, inputHint: 'Value of x');
  }

  PracticeQuestion _unitDigit(PracticeConfig c) {
    final base = _between(2, 9), exponent = _between(2, 40);
    return _numeric('Unit digit of $base^$exponent = ?', _powMod(base, exponent, 10));
  }

  PracticeQuestion _powers(PracticeConfig c) {
    final base = _between(2, 8), exp = _between(2, 5);
    return _numeric('$base^$exp = ?', pow(base, exp));
  }

  PracticeQuestion _equationMix(PracticeConfig c) => _random.nextBool() ? _linear(c) : _quadratic(c);

  PracticeQuestion _fraction(PracticeComplexity complexity) {
    const pool = {'1/2': .5, '1/4': .25, '3/8': .375, '5/8': .625, '7/20': .35, '9/25': .36};
    final key = pool.keys.elementAt(_random.nextInt(pool.length));
    return _numeric('$key = decimal ?', pool[key]!);
  }

  PracticeQuestion _quickRecallWorkout(PracticeConfig c) {
    final generators = <PracticeQuestion Function()>[
      () => _square(c), () => _cube(c), () => _percentage(c), () => _multiplication(c),
    ];
    return generators[_random.nextInt(generators.length)]();
  }

  PracticeQuestion _basicsWorkout(PracticeConfig c) {
    final generators = <PracticeQuestion Function()>[
      () => _arithmetic(c), () => _multiplication(c), () => _division(c), () => _percentage(c),
    ];
    return generators[_random.nextInt(generators.length)]();
  }

  PracticeQuestion _advancedMix(PracticeConfig c) {
    final generators = <PracticeQuestion Function()>[
      () => _averages(c), () => _ratio(c), () => _remainders(c), () => _patterns(c),
      () => _quadratic(c), () => _probability(c), () => _dataInterpretation(c),
    ];
    return generators[_random.nextInt(generators.length)]();
  }

  PracticeQuestion _miscellaneousMix(PracticeConfig c) => _advancedMix(c);

  PracticeQuestion _text(String prompt, String answer) => PracticeQuestion(
        prompt: prompt,
        answer: answer,
        options: _textOptions(answer),
        inputHint: 'Answer',
      );

  PracticeQuestion _numeric(String prompt, num answer, {String inputHint = 'Answer'}) {
    final text = _format(answer);
    return PracticeQuestion(prompt: prompt, answer: text, options: _numberOptions(answer), inputHint: inputHint);
  }

  List<String> _textOptions(String answer) {
    final values = <String>{answer};
    const alternatives = ['Yes', 'No', 'even', 'odd', 'negative', 'non-negative', 'positive'];
    for (final value in alternatives) {
      if (value != answer) values.add(value);
      if (values.length == 4) break;
    }
    return values.toList()..shuffle(_random);
  }

  List<String> _numberOptions(num answer) {
    final values = <num>{answer};
    final spread = max(1, answer.abs() < 10 ? 1 : answer.abs() ~/ 10);
    var guard = 0;
    while (values.length < 4 && guard++ < 100) {
      values.add(answer + _between(-spread * 3, spread * 3));
    }
    while (values.length < 4) values.add(answer + values.length);
    return values.map(_format).toList()..shuffle(_random);
  }

  String _format(num value) {
    if (value.isFinite && value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a;
  }

  int _lcm(int a, int b) => (a ~/ _gcd(a, b)) * b;

  int _factorCount(int n) {
    var count = 0;
    for (var i = 1; i * i <= n; i++) {
      if (n % i == 0) count += i * i == n ? 1 : 2;
    }
    return count;
  }

  int _powMod(int base, int exponent, int mod) {
    var result = 1;
    var b = base % mod;
    var e = exponent;
    while (e > 0) {
      if (e.isOdd) result = result * b % mod;
      b = b * b % mod;
      e ~/= 2;
    }
    return result;
  }

  int _factorial(int n) {
    var result = 1;
    for (var i = 2; i <= n; i++) result *= i;
    return result;
  }

  int _nPr(int n, int r) => _factorial(n) ~/ _factorial(n - r);
  int _nCr(int n, int r) => _nPr(n, r) ~/ _factorial(r);
}
