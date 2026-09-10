import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/quiz_category.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/practice_models.dart';
import 'practice_session_screen.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key, required this.category});

  final QuizCategory category;

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  late PracticePattern _pattern;
  int _lhs = 2, _rhs = 2, _terms = 2, _questions = 20;
  PracticeComplexity _complexity = PracticeComplexity.medium;
  PracticeTimeMode _timeMode = PracticeTimeMode.limit;
  int _seconds = 60;
  PracticeInputMode _input = PracticeInputMode.keyboard;
  bool _autoSubmit = true, _quickSubmit = true;
  int _tableStart = 1, _tableEnd = 10, _multiplier = 10;
  TableOrder _tableOrder = TableOrder.random;
  bool _shuffleSequential = false;
  int _valueStart = 1, _valueEnd = 50;

  // Single table & range state
  bool _isSingleTableMode = true;
  int _selectedSingleTable = 2;
  int _selectedDecadeStart = 1;
  late final TextEditingController _singleTableController;
  late final TextEditingController _customStartController;
  late final TextEditingController _customEndController;
  late final TextEditingController _recallStartController;
  late final TextEditingController _recallEndController;

  @override
  void initState() {
    super.initState();
    _pattern = _patternFor(widget.category.operation);
    // Set default value ranges depending on operation
    if (widget.category.operation == MathOperation.cube ||
        widget.category.operation == MathOperation.cubeRoot) {
      _valueEnd = 20;
    } else if (widget.category.operation == MathOperation.square ||
        widget.category.operation == MathOperation.squareRoot) {
      _valueEnd = 50;
    }
    _singleTableController =
        TextEditingController(text: '$_selectedSingleTable');
    _customStartController = TextEditingController(text: '$_tableStart');
    _customEndController = TextEditingController(text: '$_tableEnd');
    _recallStartController = TextEditingController(text: '$_valueStart');
    _recallEndController = TextEditingController(text: '$_valueEnd');
    if (_pattern == PracticePattern.tables) {
      _tableStart = _selectedSingleTable;
      _tableEnd = _selectedSingleTable;
    }
  }

  @override
  void dispose() {
    _singleTableController.dispose();
    _customStartController.dispose();
    _customEndController.dispose();
    _recallStartController.dispose();
    _recallEndController.dispose();
    super.dispose();
  }

  static PracticePattern _patternFor(MathOperation op) {
    switch (op) {
      case MathOperation.addition:
      case MathOperation.subtraction:
        return PracticePattern.arithmetic;
      case MathOperation.multiplication:
        return PracticePattern.multiplication;
      case MathOperation.division:
        return PracticePattern.division;
      case MathOperation.table:
        return PracticePattern.tables;
      case MathOperation.square:
      case MathOperation.cube:
      case MathOperation.squareRoot:
      case MathOperation.cubeRoot:
      case MathOperation.percentage:
      case MathOperation.fraction:
        return PracticePattern.recall;
      default:
        return PracticePattern.generic;
    }
  }

  bool get _isArithmetic => _pattern == PracticePattern.arithmetic;
  bool get _isDivision => _pattern == PracticePattern.division;
  bool get _isDigitOperation =>
      _isArithmetic ||
      _pattern == PracticePattern.multiplication ||
      _isDivision;
  bool get _isTables => _pattern == PracticePattern.tables;
  bool get _isRecall => _pattern == PracticePattern.recall;
  bool get _isSquareOrCube =>
      widget.category.operation == MathOperation.square ||
      widget.category.operation == MathOperation.cube ||
      widget.category.operation == MathOperation.squareRoot ||
      widget.category.operation == MathOperation.cubeRoot;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = practiceSectionColor(widget.category);

    return Scaffold(
      backgroundColor:
          dark ? AppColors.backgroundDark : const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Plan Practice',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: _stickyBottomBar(accent, dark),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _heroCard(accent, dark),
          const SizedBox(height: 14),
          if (_isDigitOperation) ...[
            _numberSettings(dark, accent),
            const SizedBox(height: 14),
          ],
          if (_isTables) ...[
            _tableSettings(dark, accent),
            const SizedBox(height: 14),
          ],
          if (_isRecall) ...[
            _recallSettings(dark, accent),
            const SizedBox(height: 14),
          ],
          if (!_isTables && !_isDigitOperation && !_isRecall) ...[
            _complexitySettings(dark, accent),
            const SizedBox(height: 14),
          ],
          if (_isRecall && !_isSquareOrCube) ...[
            _complexitySettings(dark, accent),
            const SizedBox(height: 14),
          ],
          _commonSettings(dark, accent),
        ],
      ),
    );
  }

  Widget _stickyBottomBar(Color accent, bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: dark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .35 : .08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: dark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: .25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_outlined, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _previewSummaryText(),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Start Practice',
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              onPressed: _start,
            ),
          ],
        ),
      ),
    );
  }

  String _previewSummaryText() {
    final modeStr =
        _timeMode == PracticeTimeMode.stopwatch ? 'Stopwatch' : _timeLabel();
    final inputStr = _input == PracticeInputMode.keyboard ? 'Keyboard' : 'MCQ';

    if (_isTables) {
      final tableStr = _isSingleTableMode || _tableStart == _tableEnd
          ? 'Table ${_isSingleTableMode ? _selectedSingleTable : _tableStart}'
          : 'Tables $_tableStart–$_tableEnd';
      final orderStr = _tableOrder == TableOrder.sequential
          ? (_shuffleSequential ? 'Shuffled' : 'Sequential')
          : 'Random';
      return '$_questions Qs • $tableStr (×$_multiplier, $orderStr) • $modeStr • $inputStr';
    }

    if (_isDivision) {
      return '$_questions Qs • Division ($_lhs-digit quotient ÷ $_rhs-digit divisor) • $modeStr • $inputStr';
    }

    if (_isDigitOperation) {
      return '$_questions Qs • ${widget.category.name} ($_lhs×$_rhs digits) • $modeStr • $inputStr';
    }

    if (_isSquareOrCube) {
      return '$_questions Qs • ${widget.category.name} [$_valueStart–$_valueEnd] • $modeStr • $inputStr';
    }

    return '$_questions Qs • ${widget.category.name} (${complexityLabel(_complexity)}) • $modeStr • $inputStr';
  }

  Widget _heroCard(Color accent, bool dark) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: .18),
              accent.withValues(alpha: .04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: .28)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                widget.category.iconAsset,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.calculate_rounded, color: accent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : const Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _topicDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  String _topicDescription() {
    switch (widget.category.operation) {
      case MathOperation.table:
        return 'Target a single table or custom range. Sequential mode completes every multiplier; random mode tests your agility.';
      case MathOperation.square:
        return 'Practice square recall strictly within the value range you set.';
      case MathOperation.cube:
        return 'Practice cube recall strictly within the value range you set.';
      case MathOperation.squareRoot:
        return 'Practice square-root recall from generated perfect squares in your range.';
      case MathOperation.cubeRoot:
        return 'Practice cube-root recall from generated perfect cubes in your range.';
      case MathOperation.division:
        return 'Practice clean integer division with configurable quotient and divisor sizes.';
      case MathOperation.percentage:
        return 'Practice percentage calculations with scaled patterns.';
      case MathOperation.fraction:
        return 'Convert common fractions to decimals with rapid recognition.';
      default:
        return 'Focus on this topic with custom session parameters. Every drill is fully repeatable.';
    }
  }

  Widget _numberSettings(bool dark, Color accent) {
    if (_isDivision) {
      return _section(
        dark,
        accent,
        Icons.tune_rounded,
        'Division structure',
        [
          _stepper(
            'Quotient digits (Answer)',
            _lhs,
            1,
            4,
            (v) => setState(() => _lhs = v),
          ),
          _stepper(
            'Divisor digits (Divider)',
            _rhs,
            1,
            4,
            (v) => setState(() => _rhs = v),
          ),
          _info(
            'The engine generates exact integer problems: (quotient × divisor) ÷ divisor = quotient. No ugly fractions.',
          ),
        ],
      );
    }

    return _section(
      dark,
      accent,
      Icons.tune_rounded,
      'Number structure',
      [
        _stepper(
          'Left-hand digits',
          _lhs,
          1,
          5,
          (v) => setState(() => _lhs = v),
        ),
        _stepper(
          'Right-hand digits',
          _rhs,
          1,
          5,
          (v) => setState(() => _rhs = v),
        ),
        if (_isArithmetic)
          _stepper(
            'Terms per question',
            _terms,
            2,
            6,
            (v) => setState(() => _terms = v),
          ),
        _info(
          'Higher digits increase calculation load. Use difficulty below to adjust additional parameters.',
        ),
      ],
    );
  }

  Widget _tableSettings(bool dark, Color accent) {
    return _section(
      dark,
      accent,
      Icons.grid_on_rounded,
      'Table selection',
      [
        // Mode Switch: Single Table (1 to 100) vs Table Range
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: dark ? AppColors.surfaceDark : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _modeSegmentButton(
                  title: '🎯 Single Table',
                  subtitle: '1 to 100',
                  isSelected: _isSingleTableMode,
                  accent: accent,
                  dark: dark,
                  onTap: () {
                    setState(() {
                      _isSingleTableMode = true;
                      _tableStart = _selectedSingleTable;
                      _tableEnd = _selectedSingleTable;
                    });
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _modeSegmentButton(
                  title: '📊 Table Range',
                  subtitle: 'Presets & Custom',
                  isSelected: !_isSingleTableMode,
                  accent: accent,
                  dark: dark,
                  onTap: () {
                    setState(() {
                      _isSingleTableMode = false;
                      if (_tableStart == _tableEnd) {
                        _tableStart = 1;
                        _tableEnd = 10;
                        _customStartController.text = '1';
                        _customEndController.text = '10';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        if (_isSingleTableMode)
          _singleTableSection(dark, accent)
        else
          _tableRangeSection(dark, accent),

        const SizedBox(height: 10),
        _choiceRow(
          'Multiplier limit',
          ['Up to 10', 'Up to 20'],
          _multiplier == 10 ? 'Up to 10' : 'Up to 20',
          (v) => setState(() => _multiplier = v == 'Up to 10' ? 10 : 20),
        ),
        _choiceRow(
          'Question order',
          ['Sequential', 'Random'],
          _tableOrder == TableOrder.sequential ? 'Sequential' : 'Random',
          (v) => setState(() => _tableOrder =
              v == 'Sequential' ? TableOrder.sequential : TableOrder.random),
        ),
        if (_tableOrder == TableOrder.sequential)
          _switchRow(
            'Shuffle sequence',
            _shuffleSequential,
            (v) => setState(() => _shuffleSequential = v),
          ),
        const SizedBox(height: 8),
        _tableLivePreview(dark, accent),
      ],
    );
  }

  Widget _modeSegmentButton({
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color accent,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: .35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withValues(alpha: .85)
                    : (dark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleTableSection(bool dark, Color accent) {
    const popularSingle = [
      2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 99
    ];

    const decadeStarts = [1, 11, 21, 31, 41, 51, 61, 71, 81, 91];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Table Hero Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: .24)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calculate_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table $_selectedSingleTable',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Drilling $_selectedSingleTable × 1 up to $_selectedSingleTable × $_multiplier',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Stepper & Direct Editable Box
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: _selectedSingleTable > 1
                        ? () => _selectSingleTable(_selectedSingleTable - 1)
                        : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _singleTableController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: accent,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 1 && n <= 100) {
                          setState(() {
                            _selectedSingleTable = n;
                            _tableStart = n;
                            _tableEnd = n;
                            _selectedDecadeStart =
                                ((n - 1) ~/ 10) * 10 + 1;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: _selectedSingleTable < 100
                        ? () => _selectSingleTable(_selectedSingleTable + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Action button: Browse All 100 Tables
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: accent.withValues(alpha: .4)),
            ),
            icon: Icon(Icons.grid_view_rounded, size: 18, color: accent),
            label: Text(
              'Browse All 100 Tables (1–100)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: accent,
              ),
            ),
            onPressed: () => _showAllTablesSheet(context, accent, dark),
          ),
        ),
        const SizedBox(height: 12),

        // Decade Selector (1–10, 11–20, ..., 91–100)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by decade',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: dark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '$_selectedDecadeStart–${_selectedDecadeStart + 9}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: decadeStarts.map((start) {
              final isDecadeActive = _selectedDecadeStart == start;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$start–${start + 9}'),
                  selected: isDecadeActive,
                  selectedColor: accent,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: isDecadeActive
                        ? Colors.white
                        : (dark ? Colors.white70 : Colors.black87),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedDecadeStart = start;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Individual table numbers for active decade
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: dark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: dark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(10, (idx) {
              final t = _selectedDecadeStart + idx;
              final isSelected = _selectedSingleTable == t;
              return ChoiceChip(
                label: Text('$t'),
                selected: isSelected,
                selectedColor: accent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : (dark ? Colors.white70 : Colors.black87),
                ),
                onSelected: (_) => _selectSingleTable(t),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        // Popular single tables row
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Popular tables',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: dark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: popularSingle.map((t) {
            final isSelected = _selectedSingleTable == t;
            return ChoiceChip(
              label: Text('$t'),
              selected: isSelected,
              selectedColor: accent,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black87),
              ),
              onSelected: (_) => _selectSingleTable(t),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _tableRangeSection(bool dark, Color accent) {
    const presets = [
      ('1–10', 1, 10, 'Basics'),
      ('11–20', 11, 20, 'Teens & 20s'),
      ('1–20', 1, 20, 'Standard'),
      ('12–19', 12, 19, 'Drill'),
      ('21–30', 21, 30, 'Twenties'),
      ('1–50', 1, 50, 'Marathon'),
      ('51–100', 51, 100, 'Upper 50'),
      ('1–100', 1, 100, 'All 100'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Range Presets Chips
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Range presets',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: dark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: presets.map((p) {
            final isSelected = _tableStart == p.$2 && _tableEnd == p.$3;
            return ChoiceChip(
              label: Text('${p.$1} (${p.$4})'),
              selected: isSelected,
              selectedColor: accent,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black87),
              ),
              onSelected: (_) => _applyTableRangePreset(p.$2, p.$3),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Custom Table Range Input Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Table Range',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_tableEnd - _tableStart + 1} tables total',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Enter any custom numbers 1–100 or adjust slider',
                style: TextStyle(
                  fontSize: 11.5,
                  color: dark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 10),

              // Dual Input Box (Start Table -> End Table)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _customTableNumberBox(
                    label: 'From Table',
                    controller: _customStartController,
                    value: _tableStart,
                    accent: accent,
                    dark: dark,
                    onMinus: _tableStart > 1
                        ? () => _applyTableRangePreset(_tableStart - 1, _tableEnd)
                        : null,
                    onPlus: _tableStart < _tableEnd
                        ? () => _applyTableRangePreset(_tableStart + 1, _tableEnd)
                        : null,
                    onChanged: (val) {
                      final n = int.tryParse(val);
                      if (n != null && n >= 1 && n <= 100) {
                        setState(() {
                          _tableStart = n;
                          if (_tableEnd < _tableStart) {
                            _tableEnd = _tableStart;
                            _customEndController.text = '$_tableEnd';
                          }
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  _customTableNumberBox(
                    label: 'To Table',
                    controller: _customEndController,
                    value: _tableEnd,
                    accent: accent,
                    dark: dark,
                    onMinus: _tableEnd > _tableStart
                        ? () => _applyTableRangePreset(_tableStart, _tableEnd - 1)
                        : null,
                    onPlus: _tableEnd < 100
                        ? () => _applyTableRangePreset(_tableStart, _tableEnd + 1)
                        : null,
                    onChanged: (val) {
                      final n = int.tryParse(val);
                      if (n != null && n >= 1 && n <= 100) {
                        setState(() {
                          _tableEnd = n;
                          if (_tableStart > _tableEnd) {
                            _tableStart = _tableEnd;
                            _customStartController.text = '$_tableStart';
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dual thumb RangeSlider (1 to 100)
              RangeSlider(
                values: RangeValues(
                  _tableStart.clamp(1, 100).toDouble(),
                  _tableEnd.clamp(1, 100).toDouble(),
                ),
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: accent,
                inactiveColor: accent.withValues(alpha: .2),
                labels: RangeLabels('$_tableStart', '$_tableEnd'),
                onChanged: (values) {
                  setState(() {
                    _tableStart = values.start.round();
                    _tableEnd = values.end.round();
                    _customStartController.text = '$_tableStart';
                    _customEndController.text = '$_tableEnd';
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customTableNumberBox({
    required String label,
    required TextEditingController controller,
    required int value,
    required Color accent,
    required bool dark,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: onMinus,
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: accent,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: onPlus,
            ),
          ],
        ),
      ],
    );
  }

  Widget _tableLivePreview(bool dark, Color accent) {
    final isSingle = _isSingleTableMode || _tableStart == _tableEnd;
    final tableNum = _isSingleTableMode ? _selectedSingleTable : _tableStart;
    final totalTables = isSingle ? 1 : (_tableEnd - _tableStart + 1);
    final totalEquations = totalTables * _multiplier;
    final orderDesc = _tableOrder == TableOrder.sequential
        ? (_shuffleSequential
            ? 'Systematic (Shuffled order)'
            : 'Sequential (1 to $_multiplier)')
        : 'Random agility';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                isSingle
                    ? 'Table $tableNum Live Formula'
                    : 'Tables $_tableStart–$_tableEnd Formula ($totalTables tables)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isSingle
                ? '$tableNum × 1 = ${tableNum * 1}  •  $tableNum × 2 = ${tableNum * 2}  ...  $tableNum × $_multiplier = ${tableNum * _multiplier}'
                : '$_tableStart × 1 = ${_tableStart * 1}  ...  $_tableEnd × $_multiplier = ${_tableEnd * _multiplier}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Coverage: $totalEquations unique equations • Order: $orderDesc',
            style: TextStyle(
              fontSize: 11,
              color: dark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _selectSingleTable(int t) {
    final clamped = t.clamp(1, 100);
    setState(() {
      _selectedSingleTable = clamped;
      _tableStart = clamped;
      _tableEnd = clamped;
      _singleTableController.text = '$clamped';
      _selectedDecadeStart = ((clamped - 1) ~/ 10) * 10 + 1;
    });
  }

  void _applyTableRangePreset(int start, int end) {
    setState(() {
      _tableStart = start.clamp(1, 100);
      _tableEnd = end.clamp(1, 100);
      _customStartController.text = '$_tableStart';
      _customEndController.text = '$_tableEnd';
    });
  }

  void _showAllTablesSheet(BuildContext context, Color accent, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Any Table (1–100)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: 100,
                      itemBuilder: (_, index) {
                        final t = index + 1;
                        final isSelected = _selectedSingleTable == t;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _selectSingleTable(t);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accent
                                  : (dark
                                      ? AppColors.cardDark
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? accent
                                    : (dark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$t',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: isSelected
                                    ? Colors.white
                                    : (dark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _recallSettings(bool dark, Color accent) {
    final isCube = widget.category.operation == MathOperation.cube ||
        widget.category.operation == MathOperation.cubeRoot;
    final presets = isCube
        ? ['1–10', '1–15', '1–20', '1–30', '1–50', '1–100']
        : ['1–10', '1–20', '1–30', '1–50', '1–100'];

    return _section(
      dark,
      accent,
      Icons.all_inclusive_rounded,
      'Recall range',
      [
        // Range presets ChoiceRow
        _choiceRow(
          'Range presets',
          presets,
          presets.contains('$_valueStart–$_valueEnd')
              ? '$_valueStart–$_valueEnd'
              : '',
          (v) {
            final parts = v.split('–');
            if (parts.length == 2) {
              final a = int.tryParse(parts[0]) ?? 1;
              final b = int.tryParse(parts[1]) ?? 20;
              _applyRecallPreset(a, b);
            }
          },
        ),
        const SizedBox(height: 10),

        // Custom Target Range Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Target Range',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_valueEnd - _valueStart + 1} values total',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Enter any custom numbers 1–100 or adjust slider',
                style: TextStyle(
                  fontSize: 11.5,
                  color: dark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 10),

              // Dual Input Box (Start Value -> End Value)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _customTableNumberBox(
                    label: 'From Value',
                    controller: _recallStartController,
                    value: _valueStart,
                    accent: accent,
                    dark: dark,
                    onMinus: _valueStart > 1
                        ? () => _applyRecallPreset(_valueStart - 1, _valueEnd)
                        : null,
                    onPlus: _valueStart < _valueEnd
                        ? () => _applyRecallPreset(_valueStart + 1, _valueEnd)
                        : null,
                    onChanged: (val) {
                      final n = int.tryParse(val);
                      if (n != null && n >= 1 && n <= 100) {
                        setState(() {
                          _valueStart = n;
                          if (_valueEnd < _valueStart) {
                            _valueEnd = _valueStart;
                            _recallEndController.text = '$_valueEnd';
                          }
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  _customTableNumberBox(
                    label: 'To Value',
                    controller: _recallEndController,
                    value: _valueEnd,
                    accent: accent,
                    dark: dark,
                    onMinus: _valueEnd > _valueStart
                        ? () => _applyRecallPreset(_valueStart, _valueEnd - 1)
                        : null,
                    onPlus: _valueEnd < 100
                        ? () => _applyRecallPreset(_valueStart, _valueEnd + 1)
                        : null,
                    onChanged: (val) {
                      final n = int.tryParse(val);
                      if (n != null && n >= 1 && n <= 100) {
                        setState(() {
                          _valueEnd = n;
                          if (_valueStart > _valueEnd) {
                            _valueStart = _valueEnd;
                            _recallStartController.text = '$_valueStart';
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dual-thumb RangeSlider (1 to 100)
              RangeSlider(
                values: RangeValues(
                  _valueStart.clamp(1, 100).toDouble(),
                  _valueEnd.clamp(1, 100).toDouble(),
                ),
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: accent,
                inactiveColor: accent.withValues(alpha: .2),
                labels: RangeLabels('$_valueStart', '$_valueEnd'),
                onChanged: (values) {
                  setState(() {
                    _valueStart = values.start.round();
                    _valueEnd = values.end.round();
                    _recallStartController.text = '$_valueStart';
                    _recallEndController.text = '$_valueEnd';
                  });
                },
              ),
            ],
          ),
        ),

        if (_valueStart == _valueEnd)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: .3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Single value selected ($_valueStart). All $_questions questions will test $_valueStart.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        _recallLivePreview(dark, accent),
      ],
    );
  }

  void _applyRecallPreset(int start, int end) {
    setState(() {
      _valueStart = start.clamp(1, 100);
      _valueEnd = end.clamp(1, 100);
      _recallStartController.text = '$_valueStart';
      _recallEndController.text = '$_valueEnd';
    });
  }

  Widget _recallLivePreview(bool dark, Color accent) {
    final op = widget.category.operation;
    final total = _valueEnd - _valueStart + 1;
    String previewText = '';

    if (op == MathOperation.square) {
      previewText =
          '$_valueStart² = ${_valueStart * _valueStart}  ...  $_valueEnd² = ${_valueEnd * _valueEnd}';
    } else if (op == MathOperation.cube) {
      previewText =
          '$_valueStart³ = ${_valueStart * _valueStart * _valueStart}  ...  $_valueEnd³ = ${_valueEnd * _valueEnd * _valueEnd}';
    } else if (op == MathOperation.squareRoot) {
      previewText =
          '√${_valueStart * _valueStart} = $_valueStart  ...  √${_valueEnd * _valueEnd} = $_valueEnd';
    } else if (op == MathOperation.cubeRoot) {
      previewText =
          '∛${_valueStart * _valueStart * _valueStart} = $_valueStart  ...  ∛${_valueEnd * _valueEnd * _valueEnd} = $_valueEnd';
    } else {
      previewText = 'Values range: [$_valueStart, $_valueEnd]';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                '${widget.category.name} [$_valueStart–$_valueEnd] Formula',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            previewText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Target scope: $total unique numbers • Strict limits enforced',
            style: TextStyle(
              fontSize: 11,
              color: dark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _complexitySettings(bool dark, Color accent) => _section(
        dark,
        accent,
        Icons.speed_rounded,
        'Difficulty',
        [
          _choiceRow(
            'Complexity',
            ['Easy', 'Medium', 'Hard'],
            complexityLabel(_complexity),
            (v) => setState(() => _complexity = PracticeComplexity.values
                .firstWhere((e) => complexityLabel(e) == v)),
          ),
        ],
      );

  Widget _commonSettings(bool dark, Color accent) => _section(
        dark,
        accent,
        Icons.settings_suggest_rounded,
        'Session controls',
        [
          _stepper(
            'Number of questions',
            _questions,
            5,
            100,
            (v) => setState(() => _questions = v),
          ),
          _choiceRow(
            'Quick question count',
            ['10', '20', '30', '50', '100'],
            ['10', '20', '30', '50', '100'].contains('$_questions')
                ? '$_questions'
                : '',
            (v) => setState(() => _questions = int.parse(v)),
          ),
          _choiceRow(
            'Time limit',
            ['30 sec', '1 min', '3 min', '5 min', '10 min', 'Stopwatch'],
            _timeLabel(),
            (v) => setState(() {
              _timeMode = v == 'Stopwatch'
                  ? PracticeTimeMode.stopwatch
                  : PracticeTimeMode.limit;
              _seconds = {
                    '30 sec': 30,
                    '1 min': 60,
                    '3 min': 180,
                    '5 min': 300,
                    '10 min': 600,
                  }[v] ??
                  60;
            }),
          ),
          _choiceRow(
            'Answer input mode',
            ['Keyboard', 'MCQ'],
            _input == PracticeInputMode.keyboard ? 'Keyboard' : 'MCQ',
            (v) => setState(() => _input = v == 'Keyboard'
                ? PracticeInputMode.keyboard
                : PracticeInputMode.mcq),
          ),
          if (_input == PracticeInputMode.keyboard) ...[
            _switchRow(
              'Auto-submit exact answers',
              _autoSubmit,
              (v) => setState(() => _autoSubmit = v),
            ),
            if (_autoSubmit)
              _switchRow(
                'Fast transition',
                _quickSubmit,
                (v) => setState(() => _quickSubmit = v),
              ),
          ],
        ],
      );

  String _timeLabel() => _timeMode == PracticeTimeMode.stopwatch
      ? 'Stopwatch'
      : const {
            30: '30 sec',
            60: '1 min',
            180: '3 min',
            300: '5 min',
            600: '10 min',
          }[_seconds] ??
          '1 min';

  Widget _section(
    bool dark,
    Color accent,
    IconData icon,
    String title,
    List<Widget> children,
  ) =>
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: dark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: dark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .15 : .03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: accent,
                    letterSpacing: .3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );

  Widget _info(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: Colors.grey,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
            ),
          ],
        ),
      );

  Widget _stepper(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            SizedBox(
              width: 34,
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
      );

  Widget _rangeRow(
    String label,
    int a,
    int b,
    String subtitle,
    int maxValue,
    void Function(int, int) onChanged,
  ) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _smallField(
              a,
              (v) => onChanged(v.clamp(1, b).toInt(), b),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('to', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            _smallField(
              b,
              (v) => onChanged(a, v.clamp(a, maxValue).toInt()),
            ),
          ],
        ),
      );

  Widget _smallField(int value, ValueChanged<int> onChanged) => SizedBox(
        width: 58,
        child: TextFormField(
          key: ValueKey(value),
          initialValue: '$value',
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onFieldSubmitted: (v) {
            final n = int.tryParse(v);
            if (n != null) onChanged(n);
          },
        ),
      );

  Widget _choiceRow(
    String label,
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final accent = practiceSectionColor(widget.category);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: values.map((v) {
              final isSelected = v == selected;
              return ChoiceChip(
                label: Text(v),
                selected: isSelected,
                selectedColor: accent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: isSelected
                      ? Colors.white
                      : (dark ? Colors.white70 : Colors.black87),
                ),
                onSelected: (_) => onChanged(v),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        value: value,
        onChanged: onChanged,
      );

  void _start() {
    if (_isTables) {
      if (_isSingleTableMode) {
        _tableStart = _selectedSingleTable;
        _tableEnd = _selectedSingleTable;
      } else {
        final a = min(_tableStart, _tableEnd).clamp(1, 100);
        final b = max(_tableStart, _tableEnd).clamp(1, 100);
        _tableStart = a;
        _tableEnd = b;
      }
    }

    if (_isRecall) {
      final a = min(_valueStart, _valueEnd).clamp(1, 100);
      final b = max(_valueStart, _valueEnd).clamp(1, 100);
      _valueStart = a;
      _valueEnd = b;
    }

    final config = PracticeConfig(
      category: widget.category,
      pattern: _pattern,
      lhsDigits: _lhs,
      rhsDigits: _rhs,
      terms: _terms,
      questions: _questions,
      complexity: _complexity,
      timeMode: _timeMode,
      timeLimitSeconds: _seconds,
      inputMode: _input,
      autoSubmit: _autoSubmit,
      quickSubmit: _quickSubmit,
      tableStart: _tableStart,
      tableEnd: _tableEnd,
      multiplierMax: _multiplier,
      tableOrder: _tableOrder,
      shuffleSequential: _shuffleSequential,
      valueStart: _valueStart,
      valueEnd: _valueEnd,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeSessionScreen(config: config),
      ),
    );
  }
}
