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

/// Tables generator — strictly constrained to [tableStart, tableEnd].
///
/// Sequential: walks ALL (table × multiplier) pairs systematically before
/// any repeat. Optionally shuffles the order list once when first built.
/// Random: picks a random table in [tableStart, tableEnd] AND a random
/// multiplier in [1, multiplierMax].
PracticeQuestion generateTables(
  PracticeConfig c,
  Random random,
  Map<String, int> tableCursor,
  Map<String, List<int>> tableOrders,
) {
  final start = min(c.tableStart, c.tableEnd).clamp(1, 100);
  final end = max(c.tableStart, c.tableEnd).clamp(1, 100);
  final maxMultiplier = c.multiplierMax.clamp(1, 20);
  final key =
      'tbl:$start-$end:$maxMultiplier:${c.tableOrder}:${c.shuffleSequential}';

  late final int table;
  late final int multiplier;

  if (c.tableOrder == TableOrder.sequential) {
    final order = tableOrders.putIfAbsent(key, () {
      final pairCount = (end - start + 1) * maxMultiplier;
      final list = List.generate(pairCount, (index) => index);
      if (c.shuffleSequential) list.shuffle(random);
      return list;
    });
    final cursor = tableCursor[key] ?? 0;
    final pair = order[cursor % order.length];
    tableCursor[key] = cursor + 1;
    table = start + pair ~/ maxMultiplier;
    multiplier = pair % maxMultiplier + 1;
  } else {
    table = _between(start, end, random);
    multiplier = _between(1, maxMultiplier, random);
  }

  return PracticeQuestion(
    prompt: '$table × $multiplier = ?',
    answer: _format(table * multiplier),
    options: _numberOptions(table * multiplier, random),
    inputHint: 'Product',
  );
}
