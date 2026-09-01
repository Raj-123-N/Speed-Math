import 'dart:math' as math;
import '../models/revision_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Revision Content Data (Comprehensive Formulas, Reference Rows, Examples & Tips)
// ─────────────────────────────────────────────────────────────────────────────

class RevisionContentData {
  static List<ContentRow> getRows(String id) {
    switch (id) {
      case 'squares':
      case 'all_squares':
        return List.generate(100, (i) => ContentRow(
          label: '${i + 1}',
          value: '${(i + 1) * (i + 1)}',
          display: '${i + 1}\u00B2 = ${(i + 1) * (i + 1)}',
        ));

      case 'cubes':
        return List.generate(100, (i) => ContentRow(
          label: '${i + 1}',
          value: '${(i + 1) * (i + 1) * (i + 1)}',
          display: '${i + 1}\u00B3 = ${(i + 1) * (i + 1) * (i + 1)}',
        ));

      case 'square_roots':
        return List.generate(100, (i) {
          final n = i + 1;
          final root = math.sqrt(n);
          final isPerfect = (root == root.roundToDouble());
          final valueStr = isPerfect ? '${root.toInt()}' : root.toStringAsFixed(3);
          final displayStr = isPerfect ? '\u221A$n = $valueStr' : '\u221A$n \u2248 $valueStr';
          return ContentRow(
            label: '$n',
            value: valueStr,
            display: displayStr,
          );
        });

      case 'cube_roots':
        return List.generate(100, (i) {
          final n = i + 1;
          final root = math.pow(n, 1.0 / 3.0).toDouble();
          final nearestInt = root.round();
          final isPerfect = (nearestInt * nearestInt * nearestInt == n);
          final valueStr = isPerfect ? '$nearestInt' : root.toStringAsFixed(3);
          final displayStr = isPerfect ? '\u221B$n = $valueStr' : '\u221B$n \u2248 $valueStr';
          return ContentRow(
            label: '$n',
            value: valueStr,
            display: displayStr,
          );
        });

      case 'tables':
      case 'all_tables':
        final rows = <ContentRow>[];
        for (int n = 1; n <= 100; n++) {
          for (int m = 1; m <= 10; m++) {
            rows.add(ContentRow(
              label: '$n x $m',
              value: '${n * m}',
              display: '$n \u00D7 $m = ${n * m}',
            ));
          }
        }
        return rows;

      case 'trigonometry':
      case 'trig_full':
        return const [
          ContentRow(label: 'sin 0°', value: '0', display: 'sin 0° = 0'),
          ContentRow(label: 'sin 30°', value: '1/2', display: 'sin 30° = 1/2 = 0.5'),
          ContentRow(label: 'sin 45°', value: '1/\u221A2', display: 'sin 45° = 1/\u221A2 \u2248 0.707'),
          ContentRow(label: 'sin 60°', value: '\u221A3/2', display: 'sin 60° = \u221A3/2 \u2248 0.866'),
          ContentRow(label: 'sin 90°', value: '1', display: 'sin 90° = 1'),
          ContentRow(label: '── cos ──', value: '', display: '', isDivider: true),
          ContentRow(label: 'cos 0°', value: '1', display: 'cos 0° = 1'),
          ContentRow(label: 'cos 30°', value: '\u221A3/2', display: 'cos 30° = \u221A3/2 \u2248 0.866'),
          ContentRow(label: 'cos 45°', value: '1/\u221A2', display: 'cos 45° = 1/\u221A2 \u2248 0.707'),
          ContentRow(label: 'cos 60°', value: '1/2', display: 'cos 60° = 1/2 = 0.5'),
          ContentRow(label: 'cos 90°', value: '0', display: 'cos 90° = 0'),
          ContentRow(label: '── tan ──', value: '', display: '', isDivider: true),
          ContentRow(label: 'tan 0°', value: '0', display: 'tan 0° = 0'),
          ContentRow(label: 'tan 30°', value: '1/\u221A3', display: 'tan 30° = 1/\u221A3 \u2248 0.577'),
          ContentRow(label: 'tan 45°', value: '1', display: 'tan 45° = 1'),
          ContentRow(label: 'tan 60°', value: '\u221A3', display: 'tan 60° = \u221A3 \u2248 1.732'),
          ContentRow(label: 'tan 90°', value: '∞', display: 'tan 90° = ∞'),
          ContentRow(label: '── identities ──', value: '', display: '', isDivider: true),
          ContentRow(label: 'cosec θ', value: '1/sin θ', display: 'cosec θ = 1/sin θ'),
          ContentRow(label: 'sec θ', value: '1/cos θ', display: 'sec θ = 1/cos θ'),
          ContentRow(label: 'cot θ', value: '1/tan θ', display: 'cot θ = 1/tan θ'),
        ];

      case 'fractions':
        final rows = <ContentRow>[];
        // Every proper, reduced fraction for denominator families 2–20.
        for (var denominator = 2; denominator <= 20; denominator++) {
          for (var numerator = 1; numerator < denominator; numerator++) {
            if (_gcd(numerator, denominator) != 1) continue;
            final decimal = numerator / denominator;
            final percentage = decimal * 100;
            rows.add(ContentRow(
              label: '$numerator/$denominator',
              value: decimal.toStringAsFixed(4),
              display: '$numerator/$denominator = ${decimal.toStringAsFixed(4)} (${percentage.toStringAsFixed(2)}%)',
            ));
          }
        }
        return rows;

      case 'pythagorean':
        return const [
          ContentRow(label: 'Set 1', value: '3, 4, 5', display: '3 - 4 - 5'),
          ContentRow(label: 'Set 2', value: '5, 12, 13', display: '5 - 12 - 13'),
          ContentRow(label: 'Set 3', value: '8, 15, 17', display: '8 - 15 - 17'),
          ContentRow(label: 'Set 4', value: '7, 24, 25', display: '7 - 24 - 25'),
          ContentRow(label: 'Set 5', value: '20, 21, 29', display: '20 - 21 - 29'),
          ContentRow(label: 'Set 6', value: '9, 40, 41', display: '9 - 40 - 41'),
          ContentRow(label: 'Set 7', value: '12, 35, 37', display: '12 - 35 - 37'),
          ContentRow(label: 'Set 8', value: '11, 60, 61', display: '11 - 60 - 61'),
          ContentRow(label: 'Set 9', value: '13, 84, 85', display: '13 - 84 - 85'),
          ContentRow(label: 'Set 10', value: '28, 45, 53', display: '28 - 45 - 53'),
        ];

      case 'mensuration_2d':
        return const [
          ContentRow(label: 'Square Area', value: 'a²', display: 'Area = a²,  P = 4a'),
          ContentRow(label: 'Rectangle Area', value: 'l×b', display: 'Area = l×b,  P = 2(l+b)'),
          ContentRow(label: 'Triangle Area', value: '½bh', display: 'Area = ½×b×h'),
          ContentRow(label: "Heron's", value: '√s(s-a)(s-b)(s-c)', display: 's = (a+b+c)/2'),
          ContentRow(label: 'Circle Area', value: 'πr²', display: 'Area = πr²,  C = 2πr'),
          ContentRow(label: 'Parallelogram', value: 'b×h', display: 'Area = b×h'),
          ContentRow(label: 'Trapezium', value: '½(a+b)h', display: 'Area = ½(a+b)×h'),
          ContentRow(label: 'Rhombus', value: '½d₁d₂', display: 'Area = ½×d₁×d₂'),
          ContentRow(label: 'Equilateral △', value: '(√3/4)a²', display: 'Area = (√3/4)×a²'),
        ];

      case 'mensuration_3d':
        return const [
          ContentRow(label: 'Cube Vol', value: 'a³', display: 'V = a³,  TSA = 6a²'),
          ContentRow(label: 'Cuboid Vol', value: 'lbh', display: 'V = l×b×h,  TSA = 2(lb+bh+hl)'),
          ContentRow(label: 'Cylinder Vol', value: 'πr²h', display: 'V = πr²h,  CSA = 2πrh'),
          ContentRow(label: 'Cone Vol', value: '⅓πr²h', display: 'V = ⅓πr²h,  l = √(r²+h²)'),
          ContentRow(label: 'Sphere Vol', value: '4/3πr³', display: 'V = 4/3πr³,  SA = 4πr²'),
          ContentRow(label: 'Hemisphere', value: '2/3πr³', display: 'V = 2/3πr³,  CSA = 2πr²'),
        ];

      case 'arithmetic':
        return const [
          ContentRow(label: 'Simple Interest', value: 'PRT/100', display: 'SI = P × R × T / 100'),
          ContentRow(label: 'Compound Interest', value: 'P(1+R/100)ⁿ-P', display: 'CI = P(1+R/100)ⁿ - P'),
          ContentRow(label: 'Amount', value: 'P+SI', display: 'A = P + SI   or   P(1+R/100)ⁿ'),
          ContentRow(label: 'Profit %', value: '(P/CP)×100', display: 'Profit% = (Profit / CP) × 100'),
          ContentRow(label: 'Loss %', value: '(L/CP)×100', display: 'Loss% = (Loss / CP) × 100'),
          ContentRow(label: 'Selling Price', value: 'CP×(100±P%)/100', display: 'SP = CP × (100+P%) / 100'),
          ContentRow(label: 'Discount', value: 'MP - SP', display: 'Discount = MP - SP'),
          ContentRow(label: 'Discount %', value: '(D/MP)×100', display: 'D% = (Discount / MP) × 100'),
        ];

      case 'ratio_average':
        return const [
          ContentRow(label: 'Average', value: 'Sum/Count', display: 'Average = Sum / Count'),
          ContentRow(label: 'Weighted Avg', value: 'Σwx/Σw', display: 'Weighted Avg = Σ(w×x) / Σw'),
          ContentRow(label: 'Ratio a:b', value: 'mk : nk', display: 'If a:b = m:n → a=mk, b=nk'),
          ContentRow(label: 'Proportion', value: 'ad = bc', display: 'a/b = c/d ⟹ ad = bc'),
          ContentRow(label: 'Mean', value: 'Σx/n', display: 'Mean = Σx / n'),
          ContentRow(label: 'Median', value: 'middle', display: 'Median = middle value (sorted)'),
          ContentRow(label: 'Mode', value: 'most frequent', display: 'Mode = most frequent value'),
        ];

      case 'speed_time_work':
        return const [
          ContentRow(label: 'Speed', value: 'D/T', display: 'Speed = Distance / Time'),
          ContentRow(label: 'Distance', value: 'S×T', display: 'Distance = Speed × Time'),
          ContentRow(label: 'Time', value: 'D/S', display: 'Time = Distance / Speed'),
          ContentRow(label: 'Avg Speed', value: '2ab/(a+b)', display: 'Avg Speed = 2ab/(a+b)  (equal dist)'),
          ContentRow(label: 'Work', value: 'Rate × Time', display: 'Work = Rate × Time'),
          ContentRow(label: 'Rate', value: '1/a per day', display: 'If A finishes in a days → rate = 1/a'),
          ContentRow(label: 'A+B rate', value: '1/a + 1/b', display: 'Combined = 1/a + 1/b'),
          ContentRow(label: 'Pipe net', value: 'Fill−Leak', display: 'Net rate = Fill rate − Drain rate'),
        ];

      case 'algebra_basics':
        return const [
          ContentRow(label: '(a+b)²', value: 'a²+2ab+b²', display: '(a+b)² = a² + 2ab + b²'),
          ContentRow(label: '(a-b)²', value: 'a²-2ab+b²', display: '(a-b)² = a² - 2ab + b²'),
          ContentRow(label: '(a+b)(a-b)', value: 'a²-b²', display: '(a+b)(a-b) = a² - b²'),
          ContentRow(label: '(a+b)³', value: 'a³+3a²b+3ab²+b³', display: '(a+b)³ = a³+3a²b+3ab²+b³'),
          ContentRow(label: '(a-b)³', value: 'a³-3a²b+3ab²-b³', display: '(a-b)³ = a³-3a²b+3ab²-b³'),
          ContentRow(label: 'Quadratic', value: '(-b±√D)/2a', display: 'x = (-b ± √(b²-4ac)) / 2a'),
          ContentRow(label: 'Sum of roots', value: '-b/a', display: 'Sum of roots = -b/a'),
          ContentRow(label: 'Product of roots', value: 'c/a', display: 'Product of roots = c/a'),
          ContentRow(label: 'BODMAS', value: 'B O D M A S', display: 'Brackets → Orders → ÷ → × → + → -'),
        ];

      case 'key_percentages':
        return List.generate(100, (index) {
          final percent = index + 1;
          return ContentRow(
            label: '$percent%',
            value: '$percent/100',
            display: '$percent% = ${percent / 100}',
          );
        });

      case 'powers_roots':
        return [
          // ── Powers of 2 ──
          const ContentRow(label: '2¹', value: '2', display: '2¹ = 2'),
          const ContentRow(label: '2²', value: '4', display: '2² = 4'),
          const ContentRow(label: '2³', value: '8', display: '2³ = 8'),
          const ContentRow(label: '2⁴', value: '16', display: '2⁴ = 16 (Nibble)'),
          const ContentRow(label: '2⁵', value: '32', display: '2⁵ = 32'),
          const ContentRow(label: '2⁶', value: '64', display: '2⁶ = 64'),
          const ContentRow(label: '2⁷', value: '128', display: '2⁷ = 128'),
          const ContentRow(label: '2⁸', value: '256', display: '2⁸ = 256 (1 Byte)'),
          const ContentRow(label: '2⁹', value: '512', display: '2⁹ = 512'),
          const ContentRow(label: '2¹⁰', value: '1024', display: '2¹⁰ = 1024 (1 Kilo/Kibi)'),
          const ContentRow(label: '2¹¹', value: '2048', display: '2¹¹ = 2048'),
          const ContentRow(label: '2¹²', value: '4096', display: '2¹² = 4096 (4K)'),
          const ContentRow(label: 'Powers of 3', value: '', display: '── Powers of 3 ──', isDivider: true),
          const ContentRow(label: '3¹', value: '3', display: '3¹ = 3'),
          const ContentRow(label: '3²', value: '9', display: '3² = 9'),
          const ContentRow(label: '3³', value: '27', display: '3³ = 27'),
          const ContentRow(label: '3⁴', value: '81', display: '3⁴ = 81'),
          const ContentRow(label: '3⁵', value: '243', display: '3⁵ = 243'),
          const ContentRow(label: '3⁶', value: '729', display: '3⁶ = 729 (also 9³ & 27²)'),
          const ContentRow(label: '3⁷', value: '2187', display: '3⁷ = 2187'),
          const ContentRow(label: '3⁸', value: '6561', display: '3⁸ = 6561 (also 81²)'),
          const ContentRow(label: 'Powers of 4 & 5', value: '', display: '── Powers of 4 & 5 ──', isDivider: true),
          const ContentRow(label: '4¹', value: '4', display: '4¹ = 4'),
          const ContentRow(label: '4²', value: '16', display: '4² = 16'),
          const ContentRow(label: '4³', value: '64', display: '4³ = 64'),
          const ContentRow(label: '4⁴', value: '256', display: '4⁴ = 256'),
          const ContentRow(label: '4⁵', value: '1024', display: '4⁵ = 1024'),
          const ContentRow(label: '4⁶', value: '4096', display: '4⁶ = 4096'),
          const ContentRow(label: '5¹', value: '5', display: '5¹ = 5'),
          const ContentRow(label: '5²', value: '25', display: '5² = 25'),
          const ContentRow(label: '5³', value: '125', display: '5³ = 125'),
          const ContentRow(label: '5⁴', value: '625', display: '5⁴ = 625'),
          const ContentRow(label: '5⁵', value: '3125', display: '5⁵ = 3125'),
          const ContentRow(label: '5⁶', value: '15625', display: '5⁶ = 15625'),
          const ContentRow(label: 'Powers of 6 to 9', value: '', display: '── Powers of 6, 7, 8, 9 ──', isDivider: true),
          const ContentRow(label: '6³', value: '216', display: '6³ = 216'),
          const ContentRow(label: '6⁴', value: '1296', display: '6⁴ = 1296 (also 36²)'),
          const ContentRow(label: '6⁵', value: '7776', display: '6⁵ = 7776'),
          const ContentRow(label: '7³', value: '343', display: '7³ = 343'),
          const ContentRow(label: '7⁴', value: '2401', display: '7⁴ = 2401 (also 49²)'),
          const ContentRow(label: '7⁵', value: '16807', display: '7⁵ = 16807'),
          const ContentRow(label: '8³', value: '512', display: '8³ = 512 (also 2⁹)'),
          const ContentRow(label: '8⁴', value: '4096', display: '8⁴ = 4096 (also 2¹²)'),
          const ContentRow(label: '9³', value: '729', display: '9³ = 729 (also 3⁶)'),
          const ContentRow(label: '9⁴', value: '6561', display: '9⁴ = 6561 (also 3⁸)'),
          const ContentRow(label: 'Powers of 10 to 12', value: '', display: '── Powers of 10, 11, 12 ──', isDivider: true),
          const ContentRow(label: '10³', value: '1000', display: '10³ = 1,000 (Thousand)'),
          const ContentRow(label: '10⁴', value: '10000', display: '10⁴ = 10,000 (Ten Thousand)'),
          const ContentRow(label: '10⁵', value: '100000', display: '10⁵ = 100,000 (1 Lakh / 100K)'),
          const ContentRow(label: '10⁶', value: '1000000', display: '10⁶ = 1,000,000 (10 Lakh / 1 Million)'),
          const ContentRow(label: '10⁷', value: '10000000', display: '10⁷ = 10,000,000 (1 Crore / 10 Million)'),
          const ContentRow(label: '10⁸', value: '100000000', display: '10⁸ = 100,000,000 (10 Crore / 100 Million)'),
          const ContentRow(label: '11³', value: '1331', display: '11³ = 1331'),
          const ContentRow(label: '11⁴', value: '14641', display: '11⁴ = 14641 (Pascal Row 4)'),
          const ContentRow(label: '12³', value: '1728', display: '12³ = 1728 (Hardy-Ramanujan near)'),
          const ContentRow(label: '12⁴', value: '20736', display: '12⁴ = 20736'),
          const ContentRow(label: 'Core Laws of Indices', value: '', display: '── Core Laws of Indices ──', isDivider: true),
          const ContentRow(label: 'Product Rule', value: 'aᵐ × aⁿ = aᵐ⁺ⁿ', display: 'Same base multiply: add exponents'),
          const ContentRow(label: 'Quotient Rule', value: 'aᵐ / aⁿ = aᵐ⁻ⁿ', display: 'Same base divide: subtract exponents'),
          const ContentRow(label: 'Power of Power', value: '(aᵐ)ⁿ = aᵐⁿ', display: 'Nested powers: multiply exponents'),
          const ContentRow(label: 'Power of Product', value: '(ab)ⁿ = aⁿbⁿ', display: 'Distribute power across multiplication'),
          const ContentRow(label: 'Power of Quotient', value: '(a/b)ⁿ = aⁿ/bⁿ', display: 'Distribute power across division'),
          const ContentRow(label: 'Zero Exponent', value: 'a⁰ = 1 (a≠0)', display: 'Any non-zero base to power 0 equals 1'),
          const ContentRow(label: 'Negative Exponent', value: 'a⁻ⁿ = 1/aⁿ', display: 'Negative power gives reciprocal'),
          const ContentRow(label: 'Fractional Exponent', value: 'a^(m/n) = ⁿ√(aᵐ)', display: 'Denominator is root, numerator is power'),
          const ContentRow(label: 'Base Equating', value: 'aˣ = aʸ \u21d2 x=y', display: 'Equal bases imply equal exponents'),
          const ContentRow(label: 'Exponent Equating', value: 'xⁿ = yⁿ \u21d2 x=y', display: 'Equal odd exponents imply equal bases'),
          const ContentRow(label: 'Surds & Radicals', value: '', display: '── Surds & Radicals ──', isDivider: true),
          const ContentRow(label: 'Radical Product', value: '√(ab) = √a × √b', display: '√(ab) = √a × √b'),
          const ContentRow(label: 'Radical Quotient', value: '√(a/b) = √a / √b', display: '√(a/b) = √a / √b'),
          const ContentRow(label: 'Nested Radical', value: 'ᵐ√(ⁿ√a) = ᵐⁿ√a', display: 'ᵐ√(ⁿ√a) = ᵐⁿ√a'),
          const ContentRow(label: 'Rationalize Monomial', value: '1/√a = √a/a', display: '1/√a = √a / a'),
          const ContentRow(label: 'Rationalize Binomial', value: '1/(√a±√b)', display: '1/(√a±√b) = (√a∓√b) / (a-b)'),
          const ContentRow(label: 'Infinite Product', value: '√(x√(x...)) = x', display: '√(x√(x√(x... \u221e))) = x'),
          const ContentRow(label: 'Infinite Sum', value: '√(N+√(N+...))', display: 'N=a(a+1) \u21d2 Value is (a+1)'),
          const ContentRow(label: 'Infinite Diff', value: '√(N-√(N-...))', display: 'N=a(a+1) \u21d2 Value is a'),
        ];

      case 'bodmas':
        return const [
          ContentRow(label: 'Order', value: 'B O D M A S', display: 'Brackets → Orders → Division → Multiplication → Addition → Subtraction'),
          ContentRow(label: 'Example', value: '14', display: '6 + 4 × 3 − 4 = 6 + 12 − 4 = 14'),
          ContentRow(label: 'Same rank', value: 'left to right', display: 'For ÷ and ×, or + and −, work left to right'),
        ];

      case 'unit_digit':
        return const [
          ContentRow(label: '2 powers', value: '2,4,8,6', display: 'Unit digits of 2ⁿ repeat every 4'),
          ContentRow(label: '3 powers', value: '3,9,7,1', display: 'Unit digits of 3ⁿ repeat every 4'),
          ContentRow(label: '4 powers', value: '4,6', display: 'Unit digits of 4ⁿ repeat every 2'),
          ContentRow(label: '7 powers', value: '7,9,3,1', display: 'Unit digits of 7ⁿ repeat every 4'),
          ContentRow(label: '8 powers', value: '8,4,2,6', display: 'Unit digits of 8ⁿ repeat every 4'),
          ContentRow(label: '9 powers', value: '9,1', display: 'Unit digits of 9ⁿ repeat every 2'),
        ];

      default:
        return [
          const ContentRow(label: 'Note', value: 'Content coming soon', display: 'Content will be added soon'),
        ];
    }
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final remainder = a % b;
      a = b;
      b = remainder;
    }
    return a;
  }

  static List<String> getExamples(String id) {
    switch (id) {
      case 'squares':
      case 'all_squares':
        return [
          '12² = 144\nTrick: (10+2)² = 100 + 2×10×2 + 4 = 144',
          '25² = 625\nNumbers ending in 5: 2×3=6, append 25 → 625',
          '99² = 9801\nUse (100-1)² = 10000 - 200 + 1 = 9801',
          '35² = 1225\n3×4=12, append 25 → 1225',
        ];
      case 'cubes':
        return [
          '12³ = 1728\n(10+2)³ = 1000 + 600 + 120 + 8 = 1728',
          '9³ = 729\nMemorize: 1,8,27,64,125,216,343,512,729,1000',
          'Near 10: (10+k)³ = 1000 + 300k + 30k² + k³\nE.g. 12³ = 1000+360+120+8 = 1728',
        ];
      case 'square_roots':
        return [
          '√144 = 12\nEstimate: 144 is between 100(10²) and 169(13²) → root is 12',
          '√625 = 25\nEnds in 5 → root ends in 5\n20²=400, 30²=900 → try 25, 25²=625 ✔',
          '√2 ≈ 1.414  √3 ≈ 1.732  √5 ≈ 2.236\nMemorize these for estimation problems',
        ];
      case 'cube_roots':
        return [
          '∛1000 = 10\nPerfect cube unit digit map:\n1→1, 8→2, 7→3, 4→4, 5→5, 6→6, 3→7, 2→8, 9→9, 0→0',
          '∛1728 = 12\nStep 1: units 8 → root ends in 2\nStep 2: left group=1 → 1³=1 → root starts with 1 → 12',
          '∛9261 = 21\nUnits 1→1, left group=9, 2³=8≤9∧3³=27 → tens=2 → 21',
        ];
      case 'trigonometry':
      case 'trig_full':
        return [
          'sin: values for 0°,30°,45°,60°,90° are\n√0/2, √1/2, √2/2, √3/2, √4/2 = 0, ½, 1/√2, √3/2, 1',
          'cos: just reverse of sin order\n1, √3/2, 1/√2, ½, 0',
          'tan = sin/cos\ntan 45° = 1, tan 60° = √3 ≈ 1.732',
        ];
      case 'arithmetic':
        return [
          'SI Example:\n₹1000 at 10% for 2 yrs\nSI = 1000×10×2/100 = ₹200',
          'CI Example:\n₹1000 at 10% for 2 yrs\nA = 1000×(1.1)² = ₹1210, CI = ₹210',
          'Profit Example:\nCP=₹80, SP=₹100\nProfit% = (20/80)×100 = 25%',
        ];
      case 'fractions':
        return [
          'Convert 3/8 to decimal:\n3 ÷ 8 = 0.375  (= 37.5%)',
          'Convert 0.625 to fraction:\n0.625 = 625/1000 = 5/8',
          '1/7 = 0.142857… (repeats every 6 digits)\n2/7=0.285714, 3/7=0.428571',
          '1/3 = 0.333…  2/3 = 0.666…  Recurring fractions memorized saves time!',
          'Key families: halves, thirds, fourths, fifths, eighths are must-know',
        ];
      case 'key_percentages':
        return [
          '10% of X = X/10\n\u21d2 20% = double of 10%\n\u21d2 5% = half of 10%',
          '1/4 = 25%  3/4 = 75%  1/8 = 12.5%  3/8 = 37.5%',
          'To find 15%: find 10% then add half of that\nE.g. 15% of 80 = 8 + 4 = 12',
          'Percentage change = (New−Old)/Old × 100',
        ];
      case 'powers_roots':
        return [
          'Ex 1 (Exponential Equations):\nIf 2^(2x - 1) = 8^(x - 3), find x.\n1) Express in base 2: 2^(2x - 1) = (2³)^(x - 3) = 2^(3x - 9)\n2) Equate powers: 2x - 1 = 3x - 9 \u21d2 x = 8 ✔',
          'Ex 2 (Fractional & Negative Exponents):\nEvaluate (64/125)^(-2/3).\n1) Invert base for negative index: (125/64)^(2/3)\n2) Take cube root: (5/4)²\n3) Square result: 25/16 = 1.5625 ✔',
          'Ex 3 (Comparing Large Powers):\nWhich is larger: 2⁶⁰, 3⁴⁸, 4³⁶, or 5²⁴?\n1) Find HCF of powers (60, 48, 36, 24) = 12\n2) Express with common power 12:\n• 2⁶⁰ = (2⁵)¹² = 32¹²\n• 3⁴⁸ = (3⁴)¹² = 81¹²\n• 4³⁶ = (4³)¹² = 64¹²\n• 5²⁴ = (5²)¹² = 25¹²\n\u21d2 Largest is 3⁴⁸ (81¹²) and Smallest is 5²⁴ (25¹²) ✔',
          'Ex 4 (Rationalizing Complex Surds):\nSimplify 1 / (\u221a7 - \u221a5).\nMultiply numerator & denominator by conjugate (\u221a7 + \u221a5):\n= (\u221a7 + \u221a5) / ((\u221a7)² - (\u221a5)²)\n= (\u221a7 + \u221a5) / 2 ✔',
          'Ex 5 (Infinite Nested Radicals):\nFind the value of \u221a(12 + \u221a(12 + \u221a(12 + ... \u221e))).\nShortcut: Factorize 12 into consecutive integers (n \u00d7 (n+1)): 3 \u00d7 4\nFor (+) sign, the answer is the LARGER factor \u21d2 4 ✔\n(If it had (-) sign, answer would be smaller factor \u21d2 3)',
          'Ex 6 (Infinite Product Surd):\nEvaluate \u221a(7\u221a(7\u221a(7... \u221e))).\nRule: For \u221a(x\u221a(x\u221a(x... \u221e))), the value is always x \u21d2 7 ✔',
        ];
      case 'speed_time_work':
        return [
          'Speed example:\n60 km in 3 hours → Speed = 60÷3 = 20 km/h',
          'Work example:\nA in 4 days, B in 6 days\nTogether = 1/4+1/6 = 5/12 → 2.4 days',
          'Train meeting:\n100km apart, 40 & 60 km/h\nMeet in 100÷100 = 1 hour',
        ];
      default:
        return [
          'Study the Reference tab carefully',
          'Practice related questions in the Quiz section',
          'Revisit daily — spaced repetition improves recall 3×',
        ];
    }
  }

  static List<String> getTips(String id) {
    switch (id) {
      case 'squares':
      case 'all_squares':
        return [
          'Numbers ending in 5:\nn5² → (n×(n+1))25\nE.g. 35² = (3×4)25 = 1225',
          'Difference of squares:\nn² = (n-1)² + 2n - 1\nE.g. 23² = 22²+45 = 529',
          'Near 50:\nIf n = 50+k → n² = 2500+100k+k²\nE.g. 53² = 2500+300+9 = 2809',
          'Memorize 1–25 first, then use algebraic tricks for larger.',
        ];
      case 'cubes':
        return [
          'Memorize cubes 1–10:\n1, 8, 27, 64, 125, 216, 343, 512, 729, 1000',
          'Use (a+b)³ identity:\n12³=(10+2)³=1000+600+120+8=1728',
          'Last digit of n³ maps uniquely to last digit of n',
          'Cube unit digit pattern:\n1→1, 2→8, 3→7, 4→4, 5→5, 6→6, 7→3, 8→2, 9→9, 0→0',
        ];
      case 'square_roots':
        return [
          'Find nearest perfect square to estimate:\n√50≈7.07 (between √49=7 and √64=8)',
          'Unit digit of √(n²) = unit digit of n\n(or 10−n for certain cases)',
          'Know squares 1–25 perfectly to identify perfect squares instantly',
          'Non-perfect: √2≈1.41, √3≈1.73, √5≈2.24, √6≈2.45, √7≈2.65',
        ];
      case 'cube_roots':
        return [
          'Two-step method for 2-digit cube roots:\n1) Unit digit of cube → unique root unit digit\n2) Left group → gives tens digit',
          'Unit digit mapping for cube roots:\n1→1, 8→2, 7→3, 4→4, 5→5, 6→6, 3→7, 2→8, 9→9, 0→0',
          'Memorize cubes 1–10 as anchors for estimation',
          'Any 6-digit perfect cube has a 2-digit root (10–100)',
        ];
      case 'tables':
      case 'all_tables':
        return [
          'Memorize the pattern, not the product!\nFor ×9: digits always sum to 9\n(1×9=9, 2×9=18→1+8=9, 3×9=27→2+7=9)',
          '×9 finger trick: Hold up 10 fingers, fold the Nth\nLeft side = tens, right side = units',
          'Skip counting builds speed:\nFor ×7: 7,14,21,28,35,42,49,56,63,70\nSay them out loud every day!',
          'Even × even = even; odd × odd = odd; even × odd = even',
          'Commutativity: 7×8 = 8×7\nIf you know one, you know both!',
          'Tables above 10:\n12×13 = 10×13 + 2×13 = 130 + 26 = 156',
        ];

      case 'trigonometry':
      case 'trig_full':
        return [
          'sin memory: √0, √1, √2, √3, √4 divided by 2\n= 0, ½, 1/√2, √3/2, 1',
          'cos = sin reversed:\n0°→1, 30°→√3/2, 45°→1/√2, 60°→½, 90°→0',
          'CAST rule: All+Q1, Sin+Q2, Tan+Q3, Cos+Q4',
          'tan = sin/cos — always derive from known values',
        ];
      case 'arithmetic':
        return [
          'Rule of 72:\nYears to double = 72 ÷ rate\nE.g. 8% → 9 years',
          'Successive discounts a% and b%:\nNet = a + b - ab/100',
          'If CP & profit% known:\nSP = CP × (100+P%) / 100',
        ];
      case 'algebra_basics':
        return [
          'BODMAS first: Brackets → Orders → ÷ → × → + → -',
          'a²-b² = (a+b)(a-b) — use to factorize quickly',
          'Discriminant b²-4ac: >0 real roots, =0 equal, <0 no real roots',
          'Sum of roots = -b/a, Product of roots = c/a',
        ];
      case 'fractions':
        return [
          '1/7 = 0.142857\u2026 (6-digit cycle)\n2/7, 3/7\u20266/7 are rotations of the same 6 digits',
          'To compare a/b vs c/d: cross-multiply\na/b > c/d \u21d4 ad > bc',
          'Recurring decimal: 0.\u035e3 = 1/3,  0.\u035e9 = 1,  0.1\u035e6 = 1/6',
          'Denominator families to master first: /2, /3, /4, /5, /8, /10',
          'Adding fractions: find LCM of denominators, then add numerators',
        ];
      case 'key_percentages':
        return [
          '10% rule: divide by 10 — use as building block for all %',
          '50%=1/2,  25%=1/4,  75%=3/4,  20%=1/5,  33.3%\u22481/3',
          'Percentage \u2194 fraction: %\u00f7100 = fraction (e.g. 37.5% = 3/8)',
          'Successive % change: (1+a/100)(1+b/100)\u22121 \u00d7 100% = net change',
          'Profit/Loss % on CP. Discount % on MP. Tax % on SP.',
        ];
      case 'speed_time_work':
        return [
          'Relative speed: same dir = |a-b|, opposite = a+b',
          'Train \u0026 pole: time = length/speed',
          'Efficiency: A=a days, B=b days \u2192 together = ab/(a+b)',
          'Pipes: fill=a hrs, drain=b hrs \u2192 net = ab/(b-a)',
        ];
      case 'powers_roots':
        return [
          'Master Powers of 2 up to 2¹⁰ (1024) & Powers of 3 up to 3⁶ (729). In 80% of exam simplification questions, base conversion to 2, 3, or 5 is the key.',
          'Comparing Large Powers: Find HCF of exponents, write as (Base^(power/HCF))^HCF, and compare inner base values.',
          'Unit Digit Cyclicity Rule:\n• 2, 3, 7, 8 have cyclicity of 4 (divide power by 4, use remainder as power; if rem=0 use power 4).\n• 4 and 9 have cyclicity of 2 (odd/even power).\n• 0, 1, 5, 6 always end with the same digit for ANY positive integer power.',
          'Consecutive Radical Shortcut:\nFor \u221a(N \u00b1 \u221a(N \u00b1 ...)), factorize N = a(a+1).\nIf (+), answer is (a+1). If (-), answer is a.',
          'Fractional Exponent Rule: a^(m/n) means "take the n-th root FIRST, then raise to power m". Taking root first keeps numbers small and easy to compute mentally.',
          'Negative Exponent Sign: Never change the sign of the base! a^(-n) = 1/(aⁿ). For fractions: (a/b)^(-n) = (b/a)ⁿ.',
        ];
      default:
        return [
          'Review the Reference tab to memorize all key values',
          'Practice daily — even 10 minutes improves recall',
          'Test yourself with the Quiz section after studying',
          'Focus on commonly tested exam patterns first',
        ];
    }
  }
}
