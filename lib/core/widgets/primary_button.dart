import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Premium gradient primary button with optional icon and loading state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width = double.infinity,
    this.height = 52,
    this.borderRadius = 14.0,
    this.backgroundColor,
    this.gradientColors,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool enabled;
  final double width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final effectiveCallback = (enabled && !isLoading) ? onPressed : null;
    final gradient = gradientColors ?? [AppColors.gradOrangeStart, AppColors.gradOrangeEnd];

    return GestureDetector(
      onTap: effectiveCallback,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: gradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: enabled ? null : AppColors.borderDark,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon!,
                        const SizedBox(width: 10),
                        Text(label, style: AppTypography.buttonText),
                      ],
                    )
                  : Text(label, style: AppTypography.buttonText),
        ),
      ),
    );
  }
}

/// Outlined (secondary) button variant — bordered, no fill.
class OutlinedPrimaryButton extends StatelessWidget {
  const OutlinedPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
    this.borderRadius = 14.0,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(label,
                        style: AppTypography.buttonText.copyWith(color: color)),
                  ],
                )
              : Text(label,
                  style: AppTypography.buttonText.copyWith(color: color)),
        ),
      ),
    );
  }
}
