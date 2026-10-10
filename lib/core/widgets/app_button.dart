import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Button visual variants.
enum AppButtonVariant {
  primary,
  secondary,
  outline,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = AppSizes.buttonHeightMd,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;

  bool get _canPress => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: _buildButtonByVariant(context),
    );
  }

  Widget _buildButtonByVariant(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: _canPress ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: _buildContent(Colors.white),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: _canPress ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: _buildContent(Colors.white),
        );

      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: _canPress ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: _canPress ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: _buildContent(AppColors.primary),
        );
    }
  }

  Widget _buildContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18, color: foregroundColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(suffixIcon, size: 18, color: foregroundColor),
        ],
      ],
    );
  }
}
