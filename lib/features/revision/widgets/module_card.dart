import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/revision_models.dart';
import '../screens/topic_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Academy Banner
// ─────────────────────────────────────────────────────────────────────────────

class AcademyBanner extends StatelessWidget {
  const AcademyBanner({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1328), const Color(0xFF1A1D26)]
              : [const Color(0xFFEDE7F6), const Color(0xFFF3E5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.module4Color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.module4Color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.school_rounded,
                color: AppColors.module4Color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Math Academy',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5 modules  ·  20+ topics  ·  Formula sheets',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module Card (Expandable)
// ─────────────────────────────────────────────────────────────────────────────

class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.isDark,
  });

  final LearnModule module;
  final bool isDark;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: isDark ? 0.8 : 0.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Column(
        children: [
          // Top accent strip
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [m.color, m.color.withValues(alpha: 0.3)]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),

          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(m.icon, color: m.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title,
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 2),
                        Text(m.subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${m.topics.length}',
                        style: AppTypography.chipText.copyWith(color: m.color)),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        size: 22),
                  ),
                ],
              ),
            ),
          ),

          // Topics list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight),
                ...m.topics.map((topic) => TopicRow(
                      topic: topic,
                      accentColor: m.color,
                      isDark: isDark,
                      onTap: () => _showDetail(context, topic),
                    )),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, LearnTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopicDetailScreen(
          topic: topic,
          isDark: widget.isDark,
          accentColor: widget.module.color,
          moduleTitle: widget.module.title,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topic Row
// ─────────────────────────────────────────────────────────────────────────────

class TopicRow extends StatelessWidget {
  const TopicRow({
    super.key,
    required this.topic,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final LearnTopic topic;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                topic.icon,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.auto_stories_outlined, color: accentColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topic.name,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (topic.isNew)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('NEW',
                    style: AppTypography.tagText
                        .copyWith(color: AppColors.success)),
              ),
            Icon(Icons.chevron_right_rounded, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }
}
