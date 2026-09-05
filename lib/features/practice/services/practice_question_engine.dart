import 'dart:math';

import '../../../core/models/quiz_category.dart';
import '../models/practice_models.dart';
import 'generators/algebra_generator.dart';
import 'generators/arithmetic_generator.dart';
import 'generators/cube_roots_generator.dart';
import 'generators/cubes_generator.dart';
import 'generators/division_generator.dart';
import 'generators/fraction_generator.dart';
import 'generators/geometry_generator.dart';
import 'generators/misc_generator.dart';
import 'generators/multiplication_generator.dart';
import 'generators/number_theory_generator.dart';
import 'generators/percentage_generator.dart';
import 'generators/probability_generator.dart';
import 'generators/series_generator.dart';
import 'generators/square_roots_generator.dart';
import 'generators/squares_generator.dart';
import 'generators/tables_generator.dart';
import 'generators/word_problems_generator.dart';
import 'generators/workout_generator.dart';

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
        return generateArithmetic(c, _random);
      case PracticePattern.multiplication:
        return generateMultiplication(c, _random);
      case PracticePattern.division:
        return generateDivision(c, _random);
      case PracticePattern.tables:
        return generateTables(c, _random, _tableCursor, _tableOrders);
      case PracticePattern.recall:
        return _recall(c);
      case PracticePattern.generic:
        return _topic(c);
    }
  }

  PracticeQuestion _recall(PracticeConfig c) {
    switch (c.category.operation) {
      case MathOperation.square:
        return generateSquares(c, _random);
      case MathOperation.cube:
        return generateCubes(c, _random);
      case MathOperation.squareRoot:
        return generateSquareRoots(c, _random);
      case MathOperation.cubeRoot:
        return generateCubeRoots(c, _random);
      case MathOperation.percentage:
        return generatePercentage(c, _random);
      case MathOperation.fraction:
        return generateFraction(c.complexity, _random);
      default:
        return _topic(c);
    }
  }

  PracticeQuestion _topic(PracticeConfig c) {
    switch (c.category.operation) {
      case MathOperation.numberSystem:
        return generateNumberSystem(c, _random);
      case MathOperation.placeValue:
        return generatePlaceValue(c, _random);
      case MathOperation.factorsMultiples:
        return generateFactors(c, _random);
      case MathOperation.divisibility:
        return generateDivisibility(c, _random);
      case MathOperation.remainders:
        return generateRemainders(c, _random);
      case MathOperation.averages:
        return generateAverages(c, _random);
      case MathOperation.ratioProportion:
        return generateRatio(c, _random);
      case MathOperation.profitLossDiscount:
        return generateProfitLoss(c, _random);
      case MathOperation.simpleCompoundInterest:
        return generateInterest(c, _random);
      case MathOperation.mixtureAlligation:
        return generateMixture(c, _random);
      case MathOperation.partnership:
        return generatePartnership(c, _random);
      case MathOperation.ages:
        return generateAges(c, _random);
      case MathOperation.timeWork:
        return generateTimeWork(c, _random);
      case MathOperation.pipesCisterns:
        return generatePipes(c, _random);
      case MathOperation.speedDistance:
        return generateSpeedDistance(c, _random);
      case MathOperation.trains:
        return generateTrains(c, _random);
      case MathOperation.boatsStreams:
        return generateBoats(c, _random);
      case MathOperation.series:
        return generateSeries(c, _random);
      case MathOperation.arithmeticProgression:
        return generateAP(c, _random);
      case MathOperation.geometricProgression:
        return generateGP(c, _random);
      case MathOperation.sequencesPatterns:
        return generatePatterns(c, _random);
      case MathOperation.polynomials:
        return generatePolynomials(c, _random);
      case MathOperation.geometryBasics:
        return generateGeometry(c, _random);
      case MathOperation.mensuration2d:
        return generateMensuration2d(c, _random);
      case MathOperation.mensuration3d:
        return generateMensuration3d(c, _random);
      case MathOperation.pythagorean:
        return generatePythagorean(c, _random);
      case MathOperation.trigonometry:
        return generateTrigonometry(c, _random);
      case MathOperation.permutationCombination:
        return generatePnC(c, _random);
      case MathOperation.probability:
        return generateProbability(c, _random);
      case MathOperation.dataInterpretation:
        return generateDataInterpretation(c, _random);
      case MathOperation.statistics:
        return generateStatistics(c, _random);
      case MathOperation.mentalMultiplication:
        return generateMentalMultiplication(c, _random);
      case MathOperation.fastDivision:
        return generateFastDivision(c, _random);
      case MathOperation.bodmas:
        return generateBODMAS(c, _random);
      case MathOperation.simplification:
        return generateSimplification(c, _random);
      case MathOperation.linearEquation:
        return generateLinear(c, _random);
      case MathOperation.quadraticEquation:
        return generateQuadratic(c, _random);
      case MathOperation.cubicEquation:
        return generateCubic(c, _random);
      case MathOperation.unitDigit:
        return generateUnitDigit(c, _random);
      case MathOperation.powers:
      case MathOperation.exponents:
        return generatePowers(c, _random);
      case MathOperation.algebra:
        return generateEquationMix(c, _random);
      case MathOperation.percentage:
        return generatePercentage(c, _random);
      case MathOperation.fraction:
        return generateFraction(c.complexity, _random);
      case MathOperation.square:
        return generateSquares(c, _random);
      case MathOperation.cube:
        return generateCubes(c, _random);
      case MathOperation.squareRoot:
        return generateSquareRoots(c, _random);
      case MathOperation.cubeRoot:
        return generateCubeRoots(c, _random);
      case MathOperation.addition:
        return generateArithmetic(c, _random);
      case MathOperation.subtraction:
        return generateArithmetic(c, _random);
      case MathOperation.multiplication:
        return generateMultiplication(c, _random);
      case MathOperation.division:
        return generateDivision(c, _random);
      case MathOperation.table:
        return generateTables(c, _random, _tableCursor, _tableOrders);
      case MathOperation.diAddition:
        return generateDataInterpretation(c, _random);
      case MathOperation.quickRecallWorkout:
        return generateQuickRecallWorkout(c, _random);
      case MathOperation.basicsWorkout:
        return generateBasicsWorkout(c, _random);
      case MathOperation.mixAdvance:
        return generateAdvancedMix(c, _random);
      case MathOperation.miscellaneousMix:
        return generateMiscellaneousMix(c, _random);
    }
  }
}
