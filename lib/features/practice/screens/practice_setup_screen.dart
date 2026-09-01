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
  int _valueStart = 1, _valueEnd = 100;

  @override
  void initState() {
    super.initState();
    _pattern = _patternFor(widget.category.operation);
  }

  static PracticePattern _patternFor(MathOperation op) {
    switch (op) {
      case MathOperation.addition:
      case MathOperation.subtraction: return PracticePattern.arithmetic;
      case MathOperation.multiplication: return PracticePattern.multiplication;
      case MathOperation.division: return PracticePattern.division;
      case MathOperation.table: return PracticePattern.tables;
      case MathOperation.square:
      case MathOperation.cube:
      case MathOperation.squareRoot:
      case MathOperation.cubeRoot:
      case MathOperation.percentage:
      case MathOperation.fraction: return PracticePattern.recall;
      default: return PracticePattern.generic;
    }
  }

  bool get _isArithmetic => _pattern == PracticePattern.arithmetic;
  bool get _isDigitOperation => _isArithmetic || _pattern == PracticePattern.multiplication || _pattern == PracticePattern.division;
  bool get _isTables => _pattern == PracticePattern.tables;
  bool get _isRecall => _pattern == PracticePattern.recall;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = practiceSectionColor(widget.category);
    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      appBar: AppBar(backgroundColor: dark ? AppColors.surfaceDark : Colors.white, surfaceTintColor: Colors.transparent, title: Text('Practice ${widget.category.name}', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _heroCard(accent, dark),
          const SizedBox(height: 12),
          if (_isDigitOperation) ...[_numberSettings(dark, accent), const SizedBox(height: 12)],
          if (_isTables) ...[_tableSettings(dark, accent), const SizedBox(height: 12)],
          if (_isRecall) ...[_recallSettings(dark, accent), const SizedBox(height: 12)],
          if (!_isTables && !_isDigitOperation && !_isRecall) ...[_complexitySettings(dark, accent), const SizedBox(height: 12)],
          if (_isRecall) ...[_complexitySettings(dark, accent), const SizedBox(height: 12)],
          _commonSettings(dark, accent),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Start Practice', icon: const Icon(Icons.play_arrow_rounded, color: Colors.white), onPressed: _start),
        ],
      ),
    );
  }

  Widget _heroCard(Color accent, bool dark) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [accent.withValues(alpha: .18), accent.withValues(alpha: .05)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: accent.withValues(alpha: .3))),
    child: Row(children: [
      Container(width: 52, height: 52, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(15)), child: Image.asset(widget.category.iconAsset, errorBuilder: (_, _, _) => Icon(Icons.calculate_rounded, color: accent))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.category.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF172033))), const SizedBox(height: 4), Text('Practice this learned topic as many times as you want. Each session generates fresh drills.', style: TextStyle(color: dark ? Colors.white70 : Colors.black54))])),
    ]),
  );

  Widget _numberSettings(bool dark, Color accent) => _section(dark, accent, 'Number structure', [
    _stepper('LHS digits', _lhs, 1, 5, (v) => setState(() => _lhs = v)),
    _stepper('RHS digits', _rhs, 1, 5, (v) => setState(() => _rhs = v)),
    if (_isArithmetic) _stepper('Number of terms', _terms, 2, 6, (v) => setState(() => _terms = v)),
  ]);

  Widget _tableSettings(bool dark, Color accent) => _section(dark, accent, 'Table drill', [
    _rangeRow('Tables', _tableStart, _tableEnd, '1–100 tables', 100, (a, b) => setState(() { _tableStart = a; _tableEnd = b; })),
    _choiceRow('Multipliers', ['10', '20'], _multiplier == 10 ? '10' : '20', (v) => setState(() => _multiplier = int.parse(v))),
    _choiceRow('Order', ['Sequential', 'Random'], _tableOrder == TableOrder.sequential ? 'Sequential' : 'Random', (v) => setState(() => _tableOrder = v == 'Sequential' ? TableOrder.sequential : TableOrder.random)),
    if (_tableOrder == TableOrder.sequential) _switchRow('Shuffle sequence', _shuffleSequential, (v) => setState(() => _shuffleSequential = v)),
  ]);

  Widget _recallSettings(bool dark, Color accent) => _section(dark, accent, 'Recall range', [
    _rangeRow('Values', _valueStart, _valueEnd, '1–1000 values', 1000, (a, b) => setState(() { _valueStart = a; _valueEnd = b; })),
  ]);

  Widget _complexitySettings(bool dark, Color accent) => _section(dark, accent, 'Difficulty', [
    _choiceRow('Complexity', ['Easy', 'Medium', 'Hard'], complexityLabel(_complexity), (v) => setState(() => _complexity = PracticeComplexity.values.firstWhere((e) => complexityLabel(e) == v))),
  ]);

  Widget _commonSettings(bool dark, Color accent) => _section(dark, accent, 'Session', [
    _stepper('Questions', _questions, 5, 100, (v) => setState(() => _questions = v)),
    _choiceRow('Timer', ['1 min', '5 min', '15 min', '30 min', '60 min', 'Stopwatch'], _timeLabel(), (v) => setState(() { _timeMode = v == 'Stopwatch' ? PracticeTimeMode.stopwatch : PracticeTimeMode.limit; _seconds = {'1 min':60,'5 min':300,'15 min':900,'30 min':1800,'60 min':3600}[v] ?? 60; })),
    _choiceRow('Answer mode', ['Keyboard', 'MCQ'], _input == PracticeInputMode.keyboard ? 'Keyboard' : 'MCQ', (v) => setState(() => _input = v == 'Keyboard' ? PracticeInputMode.keyboard : PracticeInputMode.mcq)),
    if (_input == PracticeInputMode.keyboard) _switchRow('Auto-submit answers', _autoSubmit, (v) => setState(() => _autoSubmit = v)),
    if (_input == PracticeInputMode.keyboard && _autoSubmit) _switchRow('Quick submit', _quickSubmit, (v) => setState(() => _quickSubmit = v)),
  ]);

  String _timeLabel() => _timeMode == PracticeTimeMode.stopwatch ? 'Stopwatch' : const {60:'1 min',300:'5 min',900:'15 min',1800:'30 min',3600:'60 min'}[_seconds] ?? '1 min';

  Widget _section(bool dark, Color accent, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
    decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: dark ? AppColors.borderDark : AppColors.borderLight)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: accent, letterSpacing: .3)), const SizedBox(height: 4), ...children]),
  );

  Widget _stepper(String label, int value, int min, int max, ValueChanged<int> onChanged) => ListTile(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: value > min ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline_rounded)), SizedBox(width: 34, child: Center(child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))), IconButton(onPressed: value < max ? () => onChanged(value + 1) : null, icon: const Icon(Icons.add_circle_outline_rounded))]));

  Widget _rangeRow(String label, int a, int b, String subtitle, int maxValue, void Function(int, int) onChanged) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(subtitle),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      _smallField(a, (v) => onChanged(v.clamp(1, b).toInt(), b)),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('to')),
      _smallField(b, (v) => onChanged(a, v.clamp(a, maxValue).toInt())),
    ]),
  );

  Widget _smallField(int value, ValueChanged<int> onChanged) => SizedBox(width: 58, child: TextFormField(initialValue: '$value', textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()), onFieldSubmitted: (v) { final n = int.tryParse(v); if (n != null) onChanged(n); }));

  Widget _choiceRow(String label, List<String> values, String selected, ValueChanged<String> onChanged) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Wrap(spacing: 6, children: values.map((v) => ChoiceChip(label: Text(v), selected: v == selected, onSelected: (_) => onChanged(v))).toList())]));
  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), value: value, onChanged: onChanged);

  void _start() {
    final config = PracticeConfig(category: widget.category, pattern: _pattern, lhsDigits: _lhs, rhsDigits: _rhs, terms: _terms, questions: _questions, complexity: _complexity, timeMode: _timeMode, timeLimitSeconds: _seconds, inputMode: _input, autoSubmit: _autoSubmit, quickSubmit: _quickSubmit, tableStart: _tableStart, tableEnd: _tableEnd, multiplierMax: _multiplier, tableOrder: _tableOrder, shuffleSequential: _shuffleSequential, valueStart: _valueStart, valueEnd: _valueEnd);
    Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeSessionScreen(config: config)));
  }
}
