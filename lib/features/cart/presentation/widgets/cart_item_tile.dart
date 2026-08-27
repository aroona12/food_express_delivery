import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';

/// Reusable tile component representing an individual item in the shopping cart.
///
/// Provides responsive quantity increment/decrement controls, direct item deletion,
/// and prevents awkward price wrapping across varying screen widths.
class CartItemTile extends ConsumerWidget {
  const CartItemTile({
    super.key,
    required this.item,
  });

  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartControllerProvider.notifier);

    return AppCard(
      padding: AppSpacing.cardPaddingSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Food Thumbnail Image
          ClipRRect(
            borderRadius: AppRadius.roundedMd,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryContainer,
                  child: const Center(
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm + 4),

          // Item Details & Quantity Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Delete Action Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    InkWell(
                      key: Key('delete_item_${item.foodItemId}'),
                      borderRadius: AppRadius.roundedSm,
                      onTap: () => cartNotifier.removeFromCart(item.foodItemId),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Unit Price
                Text(
                  '${item.formattedUnitPrice} each',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),

                const SizedBox(height: 8),

                // Controls & Subtotal Row (Price protected against wrapping)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls (+ / -)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrement Button
                          _buildQuantityButton(
                            key: Key('decrement_${item.foodItemId}'),
                            icon: item.quantity > 1
                                ? Icons.remove_rounded
                                : Icons.delete_outline_rounded,
                            iconColor: item.quantity > 1
                                ? AppColors.textPrimary
                                : AppColors.error,
                            onTap: () => cartNotifier.decreaseQuantity(item.foodItemId),
                            tooltip: item.quantity > 1 ? 'Decrease' : 'Remove',
                          ),

                          // Quantity Text
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${item.quantity}',
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Increment Button
                          _buildQuantityButton(
                            key: Key('increment_${item.foodItemId}'),
                            icon: Icons.add_rounded,
                            iconColor: AppColors.textPrimary,
                            onTap: () => cartNotifier.increaseQuantity(item.foodItemId),
                            tooltip: 'Increase',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Line Item Subtotal (Unbreakable single-line text)
                    Flexible(
                      child: Text(
                        item.formattedSubtotal,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Container(
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }
}
