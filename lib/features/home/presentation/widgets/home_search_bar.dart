import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Visual search bar for Day 1 home preview.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
    this.onFilterTap,
  });

  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppTextField(
        readOnly: true,
        onTap: onTap,
        hintText: 'Search burgers, pizza, drinks...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.tune_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: onFilterTap,
          tooltip: 'Filter',
        ),
      ),
    );
  }
}
