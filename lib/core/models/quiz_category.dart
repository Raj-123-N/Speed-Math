/// Math operation types confirmed from APK icon assets.
enum MathOperation {
  addition,
  subtraction,
  multiplication,
  division,
  percentage,
  square,
  cube,
  squareRoot,
  cubeRoot,
  table,
  trigonometry,
  diAddition,
  mixAdvance,
  fraction,
  algebra,
  simplification,
  bodmas,
  series,
  unitDigit,
  powers,
  quadraticEquation,
  linearEquation,
  cubicEquation,
  miscellaneousMix,
  quickRecallWorkout,
  basicsWorkout,
  exponents,
}

/// A quiz category shown in the practice grid.
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.name,
    required this.operation,
    required this.iconAsset,
    this.isAdvanced = false,
    this.section = PracticeSection.basics,
  });

  final String id;
  final String name;
  final MathOperation operation;
  final String iconAsset;
  final bool isAdvanced;
  final PracticeSection section;

  // ── Miscellaneous ──────────────────────────────────────────────────────────
  static const List<QuizCategory> miscellaneous = [
    QuizCategory(
      id: 'bodmas',
      name: 'BODMAS',
      operation: MathOperation.bodmas,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'simplification',
      name: 'Simplification',
      operation: MathOperation.simplification,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'series',
      name: 'Number Series',
      operation: MathOperation.series,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'unit_digit',
      name: 'Unit Digit',
      operation: MathOperation.unitDigit,
      iconAsset: 'asset/image/icon/algebra.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'powers',
      name: 'Powers & Indices',
      operation: MathOperation.powers,
      iconAsset: 'asset/image/icon/algebra.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'equations',
      name: 'Equations',
      operation: MathOperation.algebra,
      iconAsset: 'asset/image/icon/algebra.webp',
      section: PracticeSection.miscellaneous,
    ),
    QuizCategory(
      id: 'miscellaneous_mix',
      name: 'Miscellaneous Mix',
      operation: MathOperation.miscellaneousMix,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.miscellaneous,
    ),
  ];

  // ── Quick Recall ───────────────────────────────────────────────────────────
  static const List<QuizCategory> quickRecall = [
    QuizCategory(
      id: 'square',
      name: 'Squares',
      operation: MathOperation.square,
      iconAsset: 'asset/image/icon/square.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'cube',
      name: 'Cubes',
      operation: MathOperation.cube,
      iconAsset: 'asset/image/icon/cube.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'sqrt',
      name: 'Square Root',
      operation: MathOperation.squareRoot,
      iconAsset: 'asset/image/icon/sqareroot.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'cbrt',
      name: 'Cube Root',
      operation: MathOperation.cubeRoot,
      iconAsset: 'asset/image/icon/cuberoot.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'table',
      name: 'Tables',
      operation: MathOperation.table,
      iconAsset: 'asset/image/icon/table.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'exponents',
      name: 'Exponents',
      operation: MathOperation.exponents,
      iconAsset: 'asset/image/icon/algebra.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'trigonometry',
      name: 'Trigonometry',
      operation: MathOperation.trigonometry,
      iconAsset: 'asset/image/icon/trigo.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'percentage',
      name: 'Percentages',
      operation: MathOperation.percentage,
      iconAsset: 'asset/image/icon/percentage.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'fraction',
      name: 'Fractions',
      operation: MathOperation.fraction,
      iconAsset: 'asset/image/icon/fraction.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'di_addition',
      name: 'DI Addition',
      operation: MathOperation.diAddition,
      iconAsset: 'asset/image/icon/plus.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
    QuizCategory(
      id: 'quick_recall_workout',
      name: 'Quick Recall Workout',
      operation: MathOperation.quickRecallWorkout,
      iconAsset: 'asset/image/icon/complexity.webp',
      isAdvanced: true,
      section: PracticeSection.quickRecall,
    ),
  ];

  // ── Basics ─────────────────────────────────────────────────────────────────
  static const List<QuizCategory> basics = [
    QuizCategory(
      id: 'addition',
      name: 'Addition',
      operation: MathOperation.addition,
      iconAsset: 'asset/image/icon/plus.webp',
      section: PracticeSection.basics,
    ),
    QuizCategory(
      id: 'subtraction',
      name: 'Subtraction',
      operation: MathOperation.subtraction,
      iconAsset: 'asset/image/icon/minus.webp',
      section: PracticeSection.basics,
    ),
    QuizCategory(
      id: 'multiplication',
      name: 'Multiplication',
      operation: MathOperation.multiplication,
      iconAsset: 'asset/image/icon/multiply.webp',
      section: PracticeSection.basics,
    ),
    QuizCategory(
      id: 'division',
      name: 'Division',
      operation: MathOperation.division,
      iconAsset: 'asset/image/icon/division.webp',
      section: PracticeSection.basics,
    ),
    QuizCategory(
      id: 'complexity',
      name: 'Complexity Mix',
      operation: MathOperation.mixAdvance,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.basics,
    ),
    QuizCategory(
      id: 'basics_workout',
      name: 'Basics Workout',
      operation: MathOperation.basicsWorkout,
      iconAsset: 'asset/image/icon/complexity.webp',
      section: PracticeSection.basics,
    ),
  ];

  // Legacy compat
  static const List<QuizCategory> advanced = quickRecall;
}

enum PracticeSection {
  miscellaneous,
  quickRecall,
  basics,
}
