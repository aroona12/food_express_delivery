import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../order/providers/order_provider.dart';

/// Screen displayed immediately following successful order placement in Cloud Firestore.
///
/// Provides confirmation details, order ID badge, restaurant summary, and quick navigation
/// to real-time order tracking or the home discovery feed.
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(watchOrderByIdProvider(orderId));
    final order = orderAsync.valueOrNull;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Order Confirmed',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Home',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),

                // 1. Success Animation / Checkmark Header
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Headings
                Text(
                  'Order Placed Successfully!',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your order has been transmitted to the kitchen and is being confirmed.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Order ID Pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_rounded,
                          color: AppColors.primaryDark,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Order ID: #$orderId',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Order Information Card
                AppCard(
                  padding: AppSpacing.cardPadding,
                  elevation: 1,
                  child: Column(
                    children: [
                      if (order != null) ...[
                        _buildInfoRow(
                          icon: Icons.storefront_rounded,
                          title: 'Restaurant',
                          subtitle: order.restaurantName,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _buildInfoRow(
                          icon: Icons.attach_money_rounded,
                          title: 'Total Amount',
                          subtitle: order.formattedTotal,
                          isHighlight: true,
                        ),
                        if (order.deliveryAddress != null &&
                            order.deliveryAddress!.isNotEmpty) ...[
                          const Divider(height: AppSpacing.lg),
                          _buildInfoRow(
                            icon: Icons.location_on_rounded,
                            title: 'Delivery Address',
                            subtitle: order.deliveryAddress!,
                          ),
                        ],
                      ] else ...[
                        _buildInfoRow(
                          icon: Icons.storefront_rounded,
                          title: 'Order Status',
                          subtitle: 'Pending Confirmation',
                        ),
                        const Divider(height: AppSpacing.lg),
                        _buildInfoRow(
                          icon: Icons.hourglass_top_rounded,
                          title: 'Estimated Delivery',
                          subtitle: '25-35 minutes',
                          isHighlight: true,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 5. Action Buttons
                AppButton(
                  key: const Key('order_success_track_button'),
                  text: 'Track Order Live',
                  prefixIcon: Icons.route_rounded,
                  height: AppSizes.buttonHeightLg,
                  onPressed: () => context.go('/orders/$orderId'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  key: const Key('order_success_home_button'),
                  text: 'Continue Shopping',
                  variant: AppButtonVariant.outline,
                  height: AppSizes.buttonHeightLg,
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.primaryContainer
                : AppColors.surfaceVariant,
            borderRadius: AppRadius.roundedSm,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isHighlight ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                  color: isHighlight ? AppColors.primaryDark : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
