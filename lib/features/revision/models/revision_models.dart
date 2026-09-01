import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Revision Models
// ─────────────────────────────────────────────────────────────────────────────

class LearnTopic {
  const LearnTopic({
    required this.id,
    required this.name,
    required this.icon,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String icon;
  final bool isNew;
}

class LearnModule {
  const LearnModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.topics,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<LearnTopic> topics;
}

class ContentRow {
  const ContentRow({
    required this.label,
    required this.value,
    required this.display,
    this.isDivider = false,
  });

  final String label;
  final String value;
  final String display;
  final bool isDivider;
}

// ─────────────────────────────────────────────────────────────────────────────
// Default Revision Modules Configuration
// ─────────────────────────────────────────────────────────────────────────────

const kRevisionModules = [
  LearnModule(
    id: 'numbers',
    title: 'Number Foundations',
    subtitle: 'Powers, Roots & Tables',
    icon: Icons.tag_rounded,
    color: AppColors.module1Color,
    topics: [
      LearnTopic(id: 'squares', name: 'Squares 1–100', icon: AppAssets.iconSquare),
      LearnTopic(id: 'cubes', name: 'Cubes 1–100', icon: AppAssets.iconCube),
      LearnTopic(id: 'tables', name: 'Tables 1–100 × 1–10', icon: AppAssets.iconTable),
      LearnTopic(id: 'square_roots', name: 'Square Roots 1–100', icon: AppAssets.iconSqareroot, isNew: true),
      LearnTopic(id: 'cube_roots', name: 'Cube Roots 1–100', icon: AppAssets.iconCuberoot, isNew: true),
      LearnTopic(id: 'powers_roots', name: 'Powers & Indices', icon: AppAssets.iconAlgebra),
    ],
  ),
  LearnModule(
    id: 'geometry',
    title: 'Geometry & Trigonometry',
    subtitle: 'Shapes, Angles & Ratios',
    icon: Icons.architecture_rounded,
    color: AppColors.module2Color,
    topics: [
      LearnTopic(id: 'trigonometry', name: 'Trig Values', icon: AppAssets.iconTrigo),
      LearnTopic(id: 'mensuration_2d', name: 'Mensuration 2D', icon: AppAssets.icon2d),
      LearnTopic(id: 'mensuration_3d', name: 'Mensuration 3D', icon: AppAssets.icon3d),
      LearnTopic(id: 'pythagorean', name: 'Pythagorean Triplets', icon: AppAssets.iconComplexity),
    ],
  ),
  LearnModule(
    id: 'arithmetic',
    title: 'Arithmetic Formulas',
    subtitle: 'Interest, Profit & More',
    icon: Icons.functions_rounded,
    color: AppColors.module3Color,
    topics: [
      LearnTopic(id: 'arithmetic', name: 'SI & CI', icon: AppAssets.iconPercentage),
      LearnTopic(id: 'ratio_average', name: 'Ratio & Average', icon: AppAssets.iconFraction),
      LearnTopic(id: 'speed_time_work', name: 'Speed Time Work', icon: AppAssets.iconStopwatch),
    ],
  ),
  LearnModule(
    id: 'advanced',
    title: 'Advanced Topics',
    subtitle: 'Algebra, Fractions & Beyond',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.module4Color,
    topics: [
      LearnTopic(id: 'fractions', name: 'Fractions & Decimals', icon: AppAssets.iconFraction),
      LearnTopic(id: 'bodmas', name: 'BODMAS & Simplification', icon: AppAssets.iconComplexity),
      LearnTopic(id: 'unit_digit', name: 'Unit Digit Method', icon: AppAssets.iconAlgebra),
      LearnTopic(id: 'algebra_basics', name: 'Algebra Basics', icon: AppAssets.iconAlgebra, isNew: true),
    ],
  ),
  LearnModule(
    id: 'reference',
    title: 'Quick Reference',
    subtitle: 'Cheat Sheets & Tables',
    icon: Icons.grid_view_rounded,
    color: AppColors.module5Color,
    topics: [
      LearnTopic(id: 'all_tables', name: 'All Tables 1–100', icon: AppAssets.iconTable),
      LearnTopic(id: 'all_squares', name: 'All Squares 1–100', icon: AppAssets.iconSquare),
      LearnTopic(id: 'trig_full', name: 'Full Trig Table', icon: AppAssets.iconTrigo),
      LearnTopic(id: 'key_percentages', name: 'Key Percentages', icon: AppAssets.iconPercentage, isNew: true),
    ],
  ),
];
