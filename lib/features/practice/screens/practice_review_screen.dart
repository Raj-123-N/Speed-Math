import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/practice_feedback_service.dart';
import '../models/practice_models.dart';
import 'practice_session_screen.dart';
import 'practice_setup_screen.dart';

enum AnswerFilter { all, correct, wrong }

class PracticeReviewScreen extends StatefulWidget {
  const PracticeReviewScreen({
    super.key,
    required this.result,
    required this.config,
  });

  final PracticeResult result;
  final PracticeConfig config;

  @override
  State<PracticeReviewScreen> createState() => _PracticeReviewScreenState();
}

class _PracticeReviewScreenState extends State<PracticeReviewScreen> {
  AnswerFilter _filter = AnswerFilter.all;

  @override
  void initState() {
    super.initState();
    _playResultSound();
  }

  Future<void> _playResultSound() async {
    final feedback = PracticeFeedbackService.instance;
    await feedback.initialize();
    if (widget.result.accuracy >= 0.8) {
      await feedback.playWon();
    } else if (widget.result.accuracy < 0.5) {
      await feedback.playLose();
    } else {
      await feedback.end();
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  List<PracticeAnswerRecord> get _filteredAnswers {
    switch (_filter) {
      case AnswerFilter.all:
        return widget.result.answers;
      case AnswerFilter.correct:
        return widget.result.answers.where((a) => a.correct).toList();
      case AnswerFilter.wrong:
        return widget.result.answers.where((a) => !a.correct).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = practiceSectionColor(widget.config.category);
    final answers = _filteredAnswers;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.backgroundDark : const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: dark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Drill Review',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Done',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      bottomNavigationBar: _bottomActionButtons(accent, dark),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          _summaryCard(accent, dark),
          const SizedBox(height: 16),
          _filterBar(accent, dark),
          const SizedBox(height: 12),
          if (answers.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Text(
                _filter == AnswerFilter.wrong
                    ? '🎉 Incredible! Zero mistakes in this drill!'
                    : 'No matching questions found.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white60 : Colors.black54,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: answers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = answers[index];
                return _answerCard(item, dark);
              },
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(Color accent, bool dark) {
    final res = widget.result;
    final pct = (res.accuracy * 100).round();
    final avgSeconds = res.total == 0
        ? '0.0'
        : (res.elapsed.inMilliseconds / res.total / 1000).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .2 : .04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Lottie.asset(
                  AppAssets.animQuizReview,
                  repeat: false,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.emoji_events_rounded, size: 56, color: accent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.config.category.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${res.correct} / ${res.total} Correct',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: dark ? Colors.white : const Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pct% Accuracy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: pct >= 80
                            ? const Color(0xFF16A34A)
                            : pct >= 50
                                ? const Color(0xFFD97706)
                                : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: res.accuracy.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: dark
                  ? Colors.white.withValues(alpha: .1)
                  : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 80
                    ? const Color(0xFF16A34A)
                    : pct >= 50
                        ? const Color(0xFFD97706)
                        : const Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statPill(
                  label: 'Correct',
                  value: '${res.correct}',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF16A34A),
                  dark: dark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statPill(
                  label: 'Wrong',
                  value: '${res.wrong}',
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFDC2626),
                  dark: dark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statPill(
                  label: 'Total Time',
                  value: _formatTime(res.elapsed),
                  icon: Icons.timer_outlined,
                  color: accent,
                  dark: dark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statPill(
                  label: 'Speed',
                  value: '${avgSeconds}s/Q',
                  icon: Icons.bolt_rounded,
                  color: Colors.amber[700] ?? Colors.amber,
                  dark: dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: dark ? Colors.white : const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(Color accent, bool dark) {
    return Row(
      children: [
        _filterChip(
          label: 'All (${widget.result.total})',
          filter: AnswerFilter.all,
          accent: accent,
          dark: dark,
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: '✓ Correct (${widget.result.correct})',
          filter: AnswerFilter.correct,
          accent: const Color(0xFF16A34A),
          dark: dark,
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: '✗ Wrong (${widget.result.wrong})',
          filter: AnswerFilter.wrong,
          accent: const Color(0xFFDC2626),
          dark: dark,
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required AnswerFilter filter,
    required Color accent,
    required bool dark,
  }) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: accent,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
        color: selected
            ? Colors.white
            : (dark ? Colors.white70 : Colors.black87),
      ),
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _answerCard(PracticeAnswerRecord item, bool dark) {
    final isCorrect = item.correct;
    final statusColor =
        isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: isCorrect ? .25 : .45),
          width: isCorrect ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (dark ? Colors.white : Colors.black)
                      .withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${item.questionNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: dark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.prompt,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .3,
                  ),
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${(item.elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Your answer: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                item.userAnswer.isEmpty ? '—' : item.userAnswer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
              if (!isCorrect) ...[
                const SizedBox(width: 14),
                Text(
                  'Correct: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: dark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  item.correctAnswer,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomActionButtons(Color accent, bool dark) {
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
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back to Practice',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: dark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          PracticeSetupScreen(category: widget.config.category),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text(
                  'New Setup',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          PracticeSessionScreen(config: widget.config),
                    ),
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text(
                  'Retry Drill',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
