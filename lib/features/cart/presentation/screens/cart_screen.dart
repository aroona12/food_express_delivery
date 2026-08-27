import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

/// Full customer shopping cart screen.
///
/// Displays cart line items, quantity modifiers, centralized pricing summary,
/// and responsive checkout actions powered by Riverpod.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _showClearCartConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Clear Cart?',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(cartControllerProvider.notifier).clearCart();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartModel cart) {
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Cart',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (cart.isNotEmpty)
              Text(
                '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
              tooltip: 'Clear Cart',
              onPressed: () => _showClearCartConfirmation(context, ref),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              title: 'Your Cart is Empty',
              message:
                  'Looks like you haven\'t added any dishes to your cart yet. Explore our restaurant menus and discover delicious meals!',
              icon: Icons.shopping_bag_outlined,
              actionText: 'Browse Restaurants',
              onAction: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
            )
          : SafeArea(
              child: Column(
                children: [
                  // Scrollable Cart Items & Summary
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      children: [
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Items',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${cart.items.length} ${cart.items.length == 1 ? 'dish' : 'dishes'}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // List of cart line items
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: CartItemTile(item: item),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Order Summary Card
                        AppCard(
                          padding: AppSpacing.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Subtotal Row
                              _buildSummaryRow(
                                label: 'Subtotal (${cart.totalItemCount} items)',
                                value: cart.formattedSubtotal,
                                isBold: false,
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Delivery Fee Row
                              _buildSummaryRow(
                                label: 'Delivery Fee',
                                value: cart.formattedDeliveryFee,
                                isBold: false,
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                child: Divider(color: AppColors.border, height: 1),
                              ),

                              // Grand Total Row
                              _buildSummaryRow(
                                label: 'Grand Total',
                                value: cart.formattedTotal,
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Sticky Checkout Bar
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: const Border(
                        top: BorderSide(color: AppColors.border, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: 'Proceed to Checkout • ${cart.formattedTotal}',
                      onPressed: () => _handleCheckout(context, cart),
                      variant: AppButtonVariant.primary,
                      height: AppSizes.buttonHeightLg,
                      prefixIcon: Icons.shopping_bag_rounded,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: isBold
                ? AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: isBold
              ? AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textPrimary,
                )
              : AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );
  }
}
