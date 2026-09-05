import 'dart:math';

import '../../models/practice_models.dart';
import 'arithmetic_generator.dart';
import 'cubes_generator.dart';
import 'division_generator.dart';
import 'multiplication_generator.dart';
import 'percentage_generator.dart';
import 'probability_generator.dart';
import 'series_generator.dart';
import 'squares_generator.dart';
import 'word_problems_generator.dart';
import 'algebra_generator.dart';
import 'number_theory_generator.dart';

/// Quick Recall Workout: mixes Squares, Cubes, Percentages, and Multiplication
PracticeQuestion generateQuickRecallWorkout(PracticeConfig c, Random random) {
  final generators = <PracticeQuestion Function()>[
    () => generateSquares(c, random),
    () => generateCubes(c, random),
    () => generatePercentage(c, random),
    () => generateMultiplication(c, random),
  ];
  return generators[random.nextInt(generators.length)]();
}

/// Basics Workout: mixes Arithmetic, Multiplication, Division, and Percentages
PracticeQuestion generateBasicsWorkout(PracticeConfig c, Random random) {
  final generators = <PracticeQuestion Function()>[
    () => generateArithmetic(c, random),
    () => generateMultiplication(c, random),
    () => generateDivision(c, random),
    () => generatePercentage(c, random),
  ];
  return generators[random.nextInt(generators.length)]();
}

/// Advanced Mix: mixes Averages, Ratio, Remainders, Patterns, Quadratics, Probability, Data Interpretation
PracticeQuestion generateAdvancedMix(PracticeConfig c, Random random) {
  final generators = <PracticeQuestion Function()>[
    () => generateAverages(c, random),
    () => generateRatio(c, random),
    () => generateRemainders(c, random),
    () => generatePatterns(c, random),
    () => generateQuadratic(c, random),
    () => generateProbability(c, random),
    () => generateDataInterpretation(c, random),
  ];
  return generators[random.nextInt(generators.length)]();
}

/// Miscellaneous Mix: comprehensive mix of practical topics
PracticeQuestion generateMiscellaneousMix(PracticeConfig c, Random random) =>
    generateAdvancedMix(c, random);
