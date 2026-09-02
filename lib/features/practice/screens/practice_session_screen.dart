import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/quiz_category.dart';
import '../../../core/services/practice_feedback_service.dart';
import '../models/practice_models.dart';
import '../services/practice_progress_service.dart';
import '../services/practice_question_engine.dart';
import 'practice_setup_screen.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, required this.config});
  final PracticeConfig config;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> with SingleTickerProviderStateMixin {
  final _engine = PracticeQuestionEngine();
  final _feedback = PracticeFeedbackService.instance;
  final _progress = PracticeProgressService.instance;
  final _answer = TextEditingController();
  final _focus = FocusNode();
  late PracticeQuestion _question;
  late DateTime _started;
  late DateTime _questionStarted;
  Timer? _timer;
  int _index = 0, _correct = 0, _wrong = 0, _remaining = 0;
  bool _locked = false, _finishing = false, _animationsEnabled = true;
  bool? _lastCorrect;
  late final AnimationController _feedbackController;
  final List<PracticeAnswerRecord> _answers = [];

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), lowerBound: .94, upperBound: 1, value: 1);
    _started = DateTime.now();
    _questionStarted = _started;
    _remaining = widget.config.timeLimitSeconds;
    _question = _engine.next(widget.config);
    _prepareFeedback();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _requestKeyboard();
  }

  Future<void> _prepareFeedback() async {
    await _feedback.initialize();
    if (!mounted) return;
    setState(() => _animationsEnabled = _feedback.animationsEnabled);
    await _feedback.start();
  }

  void _requestKeyboard() {
    if (widget.config.inputMode != PracticeInputMode.keyboard) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _locked || _finishing) return;
      FocusScope.of(context).requestFocus(_focus);
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  void _tick() {
    if (!mounted || _finishing) return;
    if (widget.config.timeMode == PracticeTimeMode.limit && _remaining <= 1) {
      setState(() => _remaining = 0);
      _finish();
      return;
    }
    if (widget.config.timeMode == PracticeTimeMode.limit) setState(() => _remaining--);
    else setState(() {});
  }

  bool _matches(String raw, String expected) {
    final normalized = raw.trim().replaceAll(' ', '').toLowerCase();
    final target = expected.trim().replaceAll(' ', '').toLowerCase();
    if (normalized == target) return true;
    final a = double.tryParse(normalized), b = double.tryParse(target);
    return a != null && b != null && (a - b).abs() < 0.0000001;
  }

  Future<void> _submit(String raw) async {
    if (_locked || _finishing || raw.trim().isEmpty) return;
    final ok = _matches(raw, _question.answer);
    final elapsed = DateTime.now().difference(_questionStarted);
    final record = PracticeAnswerRecord(questionNumber: _index + 1, prompt: _question.prompt, correctAnswer: _question.answer, userAnswer: raw.trim(), correct: ok, elapsed: elapsed);
    setState(() {
      _locked = true;
      _lastCorrect = ok;
      _answers.add(record);
      if (ok) _correct++; else _wrong++;
    });
    if (_animationsEnabled) {
      await _feedbackController.reverse();
      if (!mounted) return;
      await _feedbackController.forward();
    }
    if (ok) await _feedback.correct(); else await _feedback.incorrect();

    final delay = Duration(milliseconds: widget.config.quickSubmit ? 220 : 480);
    await Future.delayed(_animationsEnabled ? delay : const Duration(milliseconds: 120));
    if (!mounted || _finishing) return;
    if (_index + 1 >= widget.config.questions) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _question = _engine.next(widget.config);
      _questionStarted = DateTime.now();
      _answer.clear();
      _locked = false;
      _lastCorrect = null;
    });
    _requestKeyboard();
  }

  Future<void> _finish() async {
    if (!mounted || _finishing) return;
    _finishing = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_started);
    final result = PracticeResult(total: _answers.length, correct: _correct, wrong: _wrong, elapsed: elapsed, answers: List.unmodifiable(_answers));
    await _progress.recordSession(topicId: widget.config.category.id, topicName: widget.config.category.name, questions: result.total, correct: result.correct, elapsed: result.elapsed);
    await _feedback.complete(result.correct > 0 && result.correct >= result.wrong);
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      transitionDuration: _animationsEnabled ? const Duration(milliseconds: 360) : Duration.zero,
      pageBuilder: (_, animation, __) => PracticeResultScreen(result: result, config: widget.config),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child),
    ));
  }

  bool get _numericInput {
    switch (widget.config.category.operation) {
      case MathOperation.trigonometry:
      case MathOperation.series:
      case MathOperation.linearEquation:
      case MathOperation.quadraticEquation:
      case MathOperation.cubicEquation:
      case MathOperation.algebra:
        return false;
      default:
        return true;
    }
  }

  Duration _duration(int ms) => _animationsEnabled ? Duration(milliseconds: ms) : Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackController.dispose();
    _answer.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = practiceSectionColor(widget.config.category);
    final time = widget.config.timeMode == PracticeTimeMode.stopwatch ? DateTime.now().difference(_started) : Duration(seconds: _remaining);
    final remainingQuestions = max(0, widget.config.questions - (_index + 1));
    final progress = widget.config.questions == 0 ? 0.0 : (_index + 1) / widget.config.questions;

    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.config.category.name, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900)), Text('Question ${_index + 1} of ${widget.config.questions}', style: TextStyle(fontSize: 11, color: dark ? Colors.white54 : Colors.black45))]),
        actions: [IconButton(tooltip: 'End Practice', onPressed: _finish, icon: const Icon(Icons.close_rounded))],
      ),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Row(children: [
          _metric(Icons.timer_outlined, _format(time), accent),
          const SizedBox(width: 8),
          _metric(Icons.check_circle_outline_rounded, '$_correct correct', Colors.green),
          const Spacer(),
          _metric(Icons.format_list_numbered_rounded, '$remainingQuestions left', accent),
        ])),
        TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: progress), duration: _duration(320), curve: Curves.easeOutCubic, builder: (_, value, __) => LinearProgressIndicator(value: value, minHeight: 5, color: accent, backgroundColor: accent.withValues(alpha: .12))),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 28), children: [
          Row(children: [Expanded(child: Text(_planLabel(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent))), Text(_format(time), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accent))]),
          const SizedBox(height: 12),
          AnimatedSwitcher(duration: _duration(180), transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween(begin: const Offset(.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)), child: child)), child: Text('PRACTICE ${_index + 1}', key: ValueKey(_index), style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, color: accent))),
          const SizedBox(height: 14),
          ScaleTransition(scale: _feedbackController, child: AnimatedContainer(duration: _duration(180), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32), decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _lastCorrect == null ? accent.withValues(alpha: .25) : (_lastCorrect! ? Colors.green : Colors.red).withValues(alpha: .5), width: _lastCorrect == null ? 1 : 2), boxShadow: [BoxShadow(blurRadius: 18, color: (_lastCorrect == null ? accent : (_lastCorrect! ? Colors.green : Colors.red)).withValues(alpha: .08))]), child: Center(child: AnimatedSwitcher(duration: _duration(180), child: Text(_question.prompt, key: ValueKey(_question.prompt), textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF162033))))))),
          const SizedBox(height: 24),
          if (widget.config.inputMode == PracticeInputMode.mcq && _question.hasOptions) _buildMcq(accent) else _buildKeyboard(accent, dark),
          const SizedBox(height: 18),
          AnimatedSwitcher(duration: _duration(160), child: _locked ? Center(key: const ValueKey('feedback'), child: Text(_lastCorrect == true ? 'Correct ✓' : 'Answer: ${_question.answer}', style: TextStyle(fontWeight: FontWeight.w900, color: _lastCorrect == true ? Colors.green : Colors.red))) : const SizedBox(key: ValueKey('empty'))),
        ])),
      ])),
    );
  }

  String _planLabel() {
    if (widget.config.pattern == PracticePattern.tables) {
      final range = widget.config.tableStart == widget.config.tableEnd ? 'Table ${widget.config.tableStart}' : 'Tables ${widget.config.tableStart}–${widget.config.tableEnd}';
      return '$range • ${widget.config.tableOrder == TableOrder.sequential ? 'Sequential' : 'Random'}';
    }
    return '${complexityLabel(widget.config.complexity)} difficulty • ${widget.config.timeMode == PracticeTimeMode.stopwatch ? 'Stopwatch' : _format(Duration(seconds: widget.config.timeLimitSeconds))}';
  }

  Widget _metric(IconData icon, String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 5), Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color))]));

  String _format(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildKeyboard(Color accent, bool dark) => Column(children: [
        TextField(controller: _answer, focusNode: _focus, autofocus: true, enabled: !_locked, keyboardType: _numericInput ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text, textInputAction: TextInputAction.done, onSubmitted: _submit, onChanged: (v) { if (widget.config.autoSubmit && v.trim().isNotEmpty && _matches(v, _question.answer)) _submit(v); }, decoration: InputDecoration(labelText: _question.inputHint, hintText: _numericInput ? 'Type the answer' : 'Letters and symbols supported', prefixIcon: Icon(Icons.keyboard_alt_outlined, color: accent), suffixIcon: IconButton(tooltip: 'Submit answer', onPressed: _locked ? null : () => _submit(_answer.text), icon: Icon(Icons.bolt_rounded, color: accent)), filled: true, fillColor: dark ? AppColors.cardDark : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent.withValues(alpha: .3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent, width: 2))),),
        const SizedBox(height: 10),
        Text(widget.config.autoSubmit ? 'Auto-submit on exact answer • Enter also works' : 'Press Enter or tap the bolt to submit', style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
      ]);

  Widget _buildMcq(Color accent) => Column(children: _question.options.asMap().entries.map((entry) {
    final index = entry.key, option = entry.value;
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: _duration(180 + index * 45), curve: Curves.easeOutBack, builder: (_, value, child) => Opacity(opacity: value.clamp(0.0, 1.0).toDouble(), child: Transform.translate(offset: Offset(0, (1 - value) * 10), child: child)), child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _locked ? null : () { _answer.text = option; _feedback.tap(); _submit(option); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: accent.withValues(alpha: .35)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))))));
  }).toList());
}

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key, required this.result, required this.config});
  final PracticeResult result;
  final PracticeConfig config;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = practiceSectionColor(config.category);
    final accuracy = result.accuracy;
    final message = accuracy >= .9 ? 'Excellent work!' : accuracy >= .7 ? 'Strong session!' : accuracy >= .5 ? 'Good effort — keep practicing.' : 'Repetition builds speed.';
    return Scaffold(backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9), body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 28, 20, 40), children: [
      Center(child: Icon(Icons.emoji_events_rounded, size: 72, color: accent)),
      const SizedBox(height: 10),
      Center(child: Text('Practice complete', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900))),
      const SizedBox(height: 4),
      Center(child: Text('${config.category.name} • $message', style: TextStyle(color: accent, fontWeight: FontWeight.w800))),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [
        Text('${(accuracy * 100).round()}%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: accent)),
        const Text('Accuracy'),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text('✓ ${result.correct}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)), Text('✕ ${result.wrong}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)), Text(_format(result.elapsed), style: const TextStyle(fontWeight: FontWeight.w900))]),
        const SizedBox(height: 8),
        Text('${result.total} answered • ${result.answers.isEmpty ? 0 : (result.elapsed.inMilliseconds / result.answers.length / 1000).toStringAsFixed(1)}s avg/question', style: TextStyle(color: dark ? Colors.white60 : Colors.black54)),
      ])),
      const SizedBox(height: 18),
      Text('QUESTION REVIEW', style: AppTypography.sectionHeader.copyWith(color: accent, letterSpacing: 1.4)),
      const SizedBox(height: 8),
      if (result.answers.isEmpty) _emptyReview(dark) else ...result.answers.map((a) => _answerTile(a, dark, accent)),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PracticeSessionScreen(config: config))), icon: const Icon(Icons.replay_rounded), label: const Text('Practice Again')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PracticeSetupScreen(category: config.category))), icon: const Icon(Icons.tune_rounded), label: const Text('Change Practice Plan')),
      const SizedBox(height: 6),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Practice Topics')),
    ])));
  }

  Widget _answerTile(PracticeAnswerRecord a, bool dark, Color accent) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: (a.correct ? Colors.green : Colors.red).withValues(alpha: .25))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 30, height: 30, decoration: BoxDecoration(color: (a.correct ? Colors.green : Colors.red).withValues(alpha: .12), shape: BoxShape.circle), child: Icon(a.correct ? Icons.check_rounded : Icons.close_rounded, size: 18, color: a.correct ? Colors.green : Colors.red)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${a.questionNumber}. ${a.prompt}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('Your answer: ${a.userAnswer}', style: TextStyle(color: a.correct ? Colors.green : Colors.red, fontWeight: FontWeight.w700)), if (!a.correct) Text('Correct answer: ${a.correctAnswer}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('Time: ${a.elapsed.inMilliseconds / 1000}s', style: TextStyle(fontSize: 11, color: dark ? Colors.white54 : Colors.black45))]))]));

  Widget _emptyReview(bool dark) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(15)), child: const Text('No questions were answered before the session ended.'));

  String _format(Duration d) => '${d.inMinutes}m ${d.inSeconds % 60}s';
}
