import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/quiz_category.dart';
import '../../../core/services/practice_feedback_service.dart';
import '../models/practice_models.dart';
import '../services/practice_question_engine.dart';
import 'practice_setup_screen.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, required this.config});
  final PracticeConfig config;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen>
    with SingleTickerProviderStateMixin {
  final _engine = PracticeQuestionEngine();
  final _feedback = PracticeFeedbackService.instance;
  final _answer = TextEditingController();
  final _focus = FocusNode();
  late PracticeQuestion _question;
  late DateTime _started;
  Timer? _timer;
  int _index = 0, _correct = 0, _wrong = 0, _remaining = 0;
  bool _locked = false, _finishing = false;
  bool? _lastCorrect;
  late final AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: .94,
      upperBound: 1,
      value: 1,
    );
    _started = DateTime.now();
    _remaining = widget.config.timeLimitSeconds;
    _question = _engine.next(widget.config);
    _feedback.initialize();
    _feedback.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _tick() {
    if (!mounted || _finishing) return;
    if (widget.config.timeMode == PracticeTimeMode.limit && _remaining <= 1) {
      setState(() => _remaining = 0);
      _finish();
      return;
    }
    setState(() {
      if (widget.config.timeMode == PracticeTimeMode.limit) _remaining--;
    });
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
    setState(() {
      _locked = true;
      _lastCorrect = ok;
      if (ok) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    await _feedbackController.reverse();
    if (!mounted) return;
    await _feedbackController.forward();
    if (ok) {
      await _feedback.correct();
    } else {
      await _feedback.incorrect();
    }

    Future.delayed(Duration(milliseconds: widget.config.quickSubmit ? 170 : 360), () {
      if (!mounted || _finishing) return;
      if (_index + 1 >= widget.config.questions) {
        _finish();
        return;
      }
      setState(() {
        _index++;
        _question = _engine.next(widget.config);
        _answer.clear();
        _locked = false;
        _lastCorrect = null;
      });
      _focus.requestFocus();
    });
  }

  void _finish() {
    if (!mounted || _finishing) return;
    _finishing = true;
    _timer?.cancel();
    final answered = _index + (_locked ? 1 : 0);
    _feedback.complete(_correct > 0 && _correct >= _wrong);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, animation, __) => PracticeResultScreen(
          result: PracticeResult(
            total: answered,
            correct: _correct,
            wrong: _wrong,
            elapsed: DateTime.now().difference(_started),
          ),
          config: widget.config,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
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
    final time = widget.config.timeMode == PracticeTimeMode.stopwatch
        ? DateTime.now().difference(_started)
        : Duration(seconds: _remaining);
    final remainingQuestions = max(0, widget.config.questions - (_index + 1));
    final progress = (_index + 1) / widget.config.questions;

    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.config.category.name,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'End Practice',
            onPressed: _finish,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  _metric(Icons.timer_outlined, _format(time), accent),
                  const Spacer(),
                  _metric(Icons.format_list_numbered_rounded,
                      '$remainingQuestions left', accent),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                color: accent,
                backgroundColor: accent.withValues(alpha: .12),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(.08, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                        child: child,
                      ),
                    ),
                    child: Text(
                      'PRACTICE ${_index + 1}',
                      key: ValueKey(_index),
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, color: accent),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ScaleTransition(
                    scale: _feedbackController,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                      decoration: BoxDecoration(
                        color: dark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _lastCorrect == null
                              ? accent.withValues(alpha: .25)
                              : (_lastCorrect! ? Colors.green : Colors.red).withValues(alpha: .5),
                          width: _lastCorrect == null ? 1 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            spreadRadius: 0,
                            color: (_lastCorrect == null ? accent : (_lastCorrect! ? Colors.green : Colors.red))
                                .withValues(alpha: .08),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            _question.prompt,
                            key: ValueKey(_question.prompt),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
                                color: dark ? Colors.white : const Color(0xFF162033)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.config.inputMode == PracticeInputMode.mcq && _question.hasOptions)
                    _buildMcq(accent)
                  else
                    _buildKeyboard(accent, dark),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: _locked
                        ? Center(
                            key: const ValueKey('feedback'),
                            child: Text(
                              _lastCorrect == true ? 'Correct ✓' : 'Answer: ${_question.answer}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _lastCorrect == true ? Colors.green : Colors.red,
                              ),
                            ),
                          )
                        : const SizedBox(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String text, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.w900, color: accent)),
        ]),
      );

  String _format(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildKeyboard(Color accent, bool dark) => Column(children: [
        TextField(
          controller: _answer,
          focusNode: _focus,
          autofocus: true,
          enabled: !_locked,
          keyboardType: _numericInput ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
          onChanged: (v) {
            if (widget.config.autoSubmit && v.trim().isNotEmpty && _matches(v, _question.answer)) _submit(v);
          },
          decoration: InputDecoration(
            labelText: _question.inputHint,
            hintText: _numericInput ? 'Use your number pad or type here' : 'Use your full keyboard • letters and symbols supported',
            prefixIcon: Icon(Icons.keyboard_alt_outlined, color: accent),
            suffixIcon: IconButton(tooltip: 'Submit answer', onPressed: _locked ? null : () => _submit(_answer.text), icon: Icon(Icons.bolt_rounded, color: accent)),
            filled: true,
            fillColor: dark ? AppColors.cardDark : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent.withValues(alpha: .3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent, width: 2)),
          ),
        ),
        const SizedBox(height: 10),
        Text(widget.config.autoSubmit ? 'Auto-submit on exact answer • Bolt = submit now' : 'Press Enter or tap the bolt to submit', style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
      ]);

  Widget _buildMcq(Color accent) => Column(
        children: _question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 180 + index * 45),
              curve: Curves.easeOutBack,
              builder: (_, value, child) => Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.translate(offset: Offset(0, (1 - value) * 10), child: child),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _locked
                      ? null
                      : () {
                          _answer.text = option;
                          _feedback.tap();
                          _submit(option);
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: accent.withValues(alpha: .35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          );
        }).toList(),
      );
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
    final message = accuracy >= .9 ? 'Excellent work!' : accuracy >= .7 ? 'Strong session!' : accuracy >= .5 ? 'Good effort — keep practicing.' : 'Keep going — repetition builds speed.';
    return Scaffold(
      backgroundColor: dark ? AppColors.backgroundDark : const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.elasticOut,
                builder: (_, value, child) => Transform.scale(scale: value, child: child),
                child: Icon(Icons.emoji_events_rounded, size: 76, color: accent),
              ),
              const SizedBox(height: 16),
              Text('Practice complete', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(config.category.name, style: TextStyle(color: dark ? Colors.white60 : Colors.black54)),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Column(children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: accuracy * 100),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, value, __) => Text('${value.round()}%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: accent)),
                  ),
                  const Text('Accuracy'),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Text('✓ ${result.correct}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green)),
                    Text('✕ ${result.wrong}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red)),
                    Text(_format(result.elapsed), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 12),
                  Text('${result.total} questions answered', style: TextStyle(color: dark ? Colors.white60 : Colors.black54)),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PracticeSessionScreen(config: config))), icon: const Icon(Icons.replay_rounded), label: const Text('Practice Again')),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PracticeSetupScreen(category: config.category))), icon: const Icon(Icons.tune_rounded), label: const Text('Change Practice')),
              const SizedBox(height: 10),
              TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Back to Practice Topics')),
            ]),
          ),
        ),
      ),
    );
  }

  String _format(Duration d) => '${d.inMinutes}m ${d.inSeconds % 60}s';
}
