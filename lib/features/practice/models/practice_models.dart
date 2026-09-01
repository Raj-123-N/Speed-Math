import 'package:flutter/material.dart';
import '../../../core/models/quiz_category.dart';

/// Shared settings for a repeatable Practice drill.
enum PracticeInputMode { keyboard, mcq }
enum PracticeTimeMode { limit, stopwatch }
enum PracticeComplexity { easy, medium, hard }
enum TableOrder { sequential, random }

enum PracticePattern {
  arithmetic,
  multiplication,
  division,
  tables,
  recall,
  generic,
}

class PracticeConfig {
  const PracticeConfig({
    required this.category,
    required this.pattern,
    this.lhsDigits = 2,
    this.rhsDigits = 2,
    this.terms = 2,
    this.questions = 20,
    this.complexity = PracticeComplexity.medium,
    this.timeMode = PracticeTimeMode.limit,
    this.timeLimitSeconds = 60,
    this.inputMode = PracticeInputMode.keyboard,
    this.autoSubmit = true,
    this.quickSubmit = true,
    this.tableStart = 1,
    this.tableEnd = 10,
    this.multiplierMax = 10,
    this.tableOrder = TableOrder.random,
    this.shuffleSequential = false,
    this.valueStart = 1,
    this.valueEnd = 100,
  });

  final QuizCategory category;
  final PracticePattern pattern;
  final int lhsDigits;
  final int rhsDigits;
  final int terms;
  final int questions;
  final PracticeComplexity complexity;
  final PracticeTimeMode timeMode;
  final int timeLimitSeconds;
  final PracticeInputMode inputMode;
  final bool autoSubmit;
  final bool quickSubmit;
  final int tableStart;
  final int tableEnd;
  final int multiplierMax;
  final TableOrder tableOrder;
  final bool shuffleSequential;
  final int valueStart;
  final int valueEnd;
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.prompt,
    required this.answer,
    this.options = const [],
    this.inputHint = 'Answer',
  });

  final String prompt;
  final String answer;
  final List<String> options;
  final String inputHint;

  bool get hasOptions => options.isNotEmpty;
}

class PracticeResult {
  const PracticeResult({
    required this.total,
    required this.correct,
    required this.wrong,
    required this.elapsed,
  });

  final int total;
  final int correct;
  final int wrong;
  final Duration elapsed;

  double get accuracy => total == 0 ? 0 : correct / total;
}

Color practiceSectionColor(QuizCategory category) {
  switch (category.section) {
    case PracticeSection.basics:
      return const Color(0xFF22C55E);
    case PracticeSection.quickRecall:
      return const Color(0xFFF97316);
    case PracticeSection.miscellaneous:
      return const Color(0xFF8B5CF6);
  }
}

String complexityLabel(PracticeComplexity value) {
  switch (value) {
    case PracticeComplexity.easy:
      return 'Easy';
    case PracticeComplexity.medium:
      return 'Medium';
    case PracticeComplexity.hard:
      return 'Hard';
  }
}
