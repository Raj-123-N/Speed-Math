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
      final tableStr = _tableStart == _tableEnd
          ? 'Table $_tableStart'
          : 'Tables $_tableStart–$_tableEnd';
      final orderStr =
          _tableOrder == TableOrder.sequential ? 'Sequential' : 'Random';
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
    const popularSingle = [
      2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 25, 99
    ];

    return _section(
      dark,
      accent,
      Icons.grid_on_rounded,
      'Table selection',
      [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Text(
            'Popular single tables',
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
            final isSelected = _tableStart == t && _tableEnd == t;
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
              onSelected: (_) => setState(() {
                _tableStart = t;
                _tableEnd = t;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _choiceRow(
          'Range presets',
          ['1–10', '11–20', '1–20'],
          _tableStart == 1 && _tableEnd == 10
              ? '1–10'
              : _tableStart == 11 && _tableEnd == 20
                  ? '11–20'
                  : _tableStart == 1 && _tableEnd == 20
                      ? '1–20'
                      : '',
          (v) {
            setState(() {
              if (v == '1–10') {
                _tableStart = 1;
                _tableEnd = 10;
              } else if (v == '11–20') {
                _tableStart = 11;
                _tableEnd = 20;
              } else if (v == '1–20') {
                _tableStart = 1;
                _tableEnd = 20;
              }
            });
          },
        ),
        _rangeRow(
          'Custom table range',
          _tableStart,
          _tableEnd,
          'Practice between any tables 1–100',
          100,
          (a, b) => setState(() {
            _tableStart = a;
            _tableEnd = b;
          }),
        ),
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
        _info(
          _tableOrder == TableOrder.sequential
              ? (_tableStart == _tableEnd
                  ? 'Sequential mode walks through $_tableStart × 1 up to $_tableStart × $_multiplier without repeating.'
                  : 'Sequential mode systematically covers tables $_tableStart to $_tableEnd up to ×$_multiplier.')
              : 'Random mode picks random table numbers and random multipliers strictly inside your range.',
        ),
      ],
    );
  }

  Widget _recallSettings(bool dark, Color accent) {
    final isSquare = widget.category.operation == MathOperation.square ||
        widget.category.operation == MathOperation.squareRoot;
    final maxPreset = isSquare ? 100 : 30;

    return _section(
      dark,
      accent,
      Icons.all_inclusive_rounded,
      'Recall range',
      [
        _choiceRow(
          'Range presets',
          isSquare
              ? ['1–10', '1–20', '1–30', '1–50', '1–100']
              : ['1–10', '1–15', '1–20', '1–30'],
          '$_valueStart–$_valueEnd',
          (v) {
            final parts = v.split('–');
            if (parts.length == 2) {
              setState(() {
                _valueStart = int.tryParse(parts[0]) ?? 1;
                _valueEnd = int.tryParse(parts[1]) ?? 20;
              });
            }
          },
        ),
        _rangeRow(
          'Target values',
          _valueStart,
          _valueEnd,
          'Questions strictly drawn from this range',
          maxPreset,
          (a, b) => setState(() {
            _valueStart = a;
            _valueEnd = b;
          }),
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
        _info(
          'Only numbers in [$_valueStart, $_valueEnd] will be tested. No numbers lower or higher will appear.',
        ),
      ],
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
