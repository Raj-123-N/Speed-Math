import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/speed_app_bar.dart';
import 'models/revision_models.dart';
import 'widgets/module_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Revision / Learn Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class RevisionScreen extends StatelessWidget {
  const RevisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F7),
      appBar: const SpeedMathAppBar(title: 'Math Academy'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          AcademyBanner(isDark: isDark),
          ...List.generate(kRevisionModules.length, (i) =>
              ModuleCard(module: kRevisionModules[i], isDark: isDark)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
