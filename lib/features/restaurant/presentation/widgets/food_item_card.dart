import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../models/food_item_model.dart';

/// Reusable card component representing an individual menu food dish.
///
/// Features an interactive "Add to Cart" control with Riverpod state integration,
/// responsive layout protection, and multi-restaurant conflict handling.
class FoodItemCard extends ConsumerWidget {
  const FoodItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final FoodItemModel item;
  final VoidCallback? onTap;

  void _handleAddToCart(BuildContext context, WidgetRef ref) {
    final result = ref.read(cartControllerProvider.notifier).addToCart(item);

    switch (result) {
      case AddToCartResult.added:
        _showAddedFeedback(context, 'Added ${item.name} to cart');
        break;
      case AddToCartResult.updatedQuantity:
        _showAddedFeedback(context, 'Updated quantity for ${item.name}');
        break;
      case AddToCartResult.restaurantMismatch:
        _showRestaurantMismatchDialog(context, ref);
        break;
      case AddToCartResult.unavailable:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This dish is currently unavailable.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _showAddedFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.accent,
          onPressed: () => GoRouter.of(context).push('/cart'),
        ),
      ),
    );
  }

  void _showRestaurantMismatchDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Different Restaurant',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your cart contains items from another restaurant. Clear cart and add this item?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(cartControllerProvider.notifier).clearAndAddToCart(item);
              _showAddedFeedback(context, 'Cart cleared & added ${item.name}');
            },
            child: const Text('Clear & Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = item.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.6,
      child: AppCard(
        padding: AppSpacing.cardPaddingSm,
        onTap: isAvailable
            ? (onTap ?? () => _handleAddToCart(context, ref))
            : null,
        elevation: isAvailable ? 1 : 0,
        backgroundColor: isAvailable ? AppColors.surface : AppColors.surfaceVariant,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Item Thumbnail Image
            ClipRRect(
              borderRadius: AppRadius.roundedMd,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryContainer,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood_rounded,
                            size: 32,
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (!isAvailable)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.85),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              'Sold Out',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm + 4),

            // Item Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Row (Protected against line wrapping)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isAvailable ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        item.formattedPrice,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    item.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Bottom Action Row: Category Tag, Calories, Rating & Add Button
                  Row(
                    children: [
                      // Category Tag
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Text(
                            item.category,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      if (item.calories != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${item.calories} kcal',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                        ),
                      ],

                      if (item.rating != null) ...[
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating!.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const Spacer(),

                      // Action button: Unavailable Chip or Add to Cart Button
                      if (!isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Text(
                            'Unavailable',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        )
                      else
                        Material(
                          color: AppColors.primary,
                          borderRadius: AppRadius.roundedSm,
                          child: InkWell(
                            key: Key('add_button_${item.id}'),
                            borderRadius: AppRadius.roundedSm,
                            onTap: () => _handleAddToCart(context, ref),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Add',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
