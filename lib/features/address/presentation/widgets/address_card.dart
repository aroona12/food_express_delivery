import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/address_model.dart';

/// Reusable card displaying an address record with status badges and quick actions.
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.showSelectionIndicator = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  final AddressModel address;
  final bool isSelected;
  final bool showSelectionIndicator;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase().trim()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
      case 'office':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      elevation: isSelected ? 3 : 1,
      borderColor: isSelected ? AppColors.primary : AppColors.border,
      backgroundColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.03)
          : AppColors.surface,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Label + Badges + Menu Actions
          Row(
            children: [
              // Label Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Icon(
                  _getLabelIcon(address.label),
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Address Label Title
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.label,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: AppRadius.roundedPill,
                        ),
                        child: Text(
                          'DEFAULT',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Selection Radio Indicator or Actions Menu
              if (showSelectionIndicator)
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 22,
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Address options',
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    } else if (value == 'default' && onSetDefault != null) {
                      onSetDefault!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!address.isDefault && onSetDefault != null)
                      PopupMenuItem<String>(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Text('Set as Default', style: AppTypography.labelMedium),
                          ],
                        ),
                      ),
                    if (onEdit != null)
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined,
                                color: AppColors.textPrimary, size: 18),
                            const SizedBox(width: 8),
                            Text('Edit Address', style: AppTypography.labelMedium),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Text('Delete',
                                style: AppTypography.labelMedium
                                    .copyWith(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Street Address & City
          Text(
            address.fullAddress,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (address.city.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                address.city,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // Phone Number
          if (address.phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    address.phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Additional Delivery Instructions
          if (address.additionalInstructions != null &&
              address.additionalInstructions!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address.additionalInstructions!.trim(),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
