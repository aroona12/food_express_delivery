import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_tracking_timeline.dart';

/// Screen providing real-time live order tracking and comprehensive itemized breakdown.
///
/// Reactively listens to Firestore document snapshots via [watchOrderByIdProvider]
/// so status updates, timestamps, and details refresh automatically with zero manual polling.
class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  bool _isCancelling = false;

  Future<void> _showCancelConfirmationDialog(
    BuildContext context,
    OrderModel order,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Cancel Order?',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your order #${order.id} is currently pending confirmation. '
          'Cancelling this order is permanent and cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Keep Order',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel == true && mounted) {
      await _cancelOrder(order);
    }
  }

  Future<void> _cancelOrder(OrderModel order) async {
    if (_isCancelling) return;

    setState(() => _isCancelling = true);

    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(order.id, OrderStatus.cancelled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id} has been cancelled.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderStream = ref.watch(watchOrderByIdProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Live Tracking',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/orders');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: orderStream.when(
        loading: () => const Center(
          child: LoadingIndicator(message: 'Connecting to live order tracking...'),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ErrorState(
              title: 'Tracking Unavailable',
              message: error.toString(),
              onRetry: () => ref.refresh(watchOrderByIdProvider(widget.orderId)),
            ),
          ),
        ),
        data: (order) {
          if (order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  title: 'Order Not Found',
                  message: 'The requested order #${widget.orderId} could not be found.',
                  icon: Icons.receipt_long_outlined,
                  actionText: 'View All Orders',
                  onAction: () => context.go('/orders'),
                ),
              ),
            );
          }

          final status = order.status;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Order Status Header Card
                  AppCard(
                    padding: AppSpacing.cardPadding,
                    backgroundColor: status.containerColor,
                    borderColor: status.color.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(
                            status.icon,
                            color: status.color,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    status.displayName,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: status.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: status.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order #${order.id} • ${order.formattedDate}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Visual Status Progress Timeline
                  OrderTrackingTimeline(status: order.status),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Fulfilling Restaurant Info Card
                  AppCard(
                    padding: AppSpacing.cardPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fulfilling Restaurant',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.restaurantName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (order.restaurantId.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => context.push('/restaurant/${order.restaurantId}'),
                            icon: const Icon(Icons.storefront_rounded, size: 16),
                            label: const Text('Store'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. Delivery Address & Instructions Card
                  if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                    AppCard(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Delivery Address',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            order.deliveryAddress!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (order.orderNotes != null && order.orderNotes!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Notes: ${order.orderNotes!}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 5. Ordered Items List
                  Text(
                    'Ordered Items (${order.itemCount})',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return _buildOrderItemRow(item);
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 6. Payment & Pricing Summary
                  Text(
                    'Bill Summary',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  AppCard(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          label: 'Item Subtotal',
                          value: order.formattedSubtotal,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildSummaryRow(
                          label: 'Delivery Fee',
                          value: order.formattedDeliveryFee,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.sm),
                        _buildSummaryRow(
                          label: 'Total Amount',
                          value: order.formattedTotal,
                          isTotal: true,
                        ),
                        if (order.paymentMethod != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Method',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                order.paymentMethod!,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 7. Customer Cancellation Action (Visible ONLY when status is pending)
                  if (order.status == OrderStatus.pending) ...[
                    OutlinedButton.icon(
                      key: const Key('cancel_order_button'),
                      onPressed: _isCancelling
                          ? null
                          : () => _showCancelConfirmationDialog(context, order),
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                              ),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                      label: Text(
                        _isCancelling ? 'Cancelling Order...' : 'Cancel Order',
                        style: AppTypography.labelLarge.copyWith(
                          color: _isCancelling ? AppColors.textTertiary : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: _isCancelling ? AppColors.border : AppColors.error,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // 8. Navigation Actions
                  if (order.restaurantId.isNotEmpty) ...[
                    AppButton(
                      text: 'Order Again from this Restaurant',
                      prefixIcon: Icons.replay_rounded,
                      onPressed: () => context.push('/restaurant/${order.restaurantId}'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    text: 'View All Orders',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/orders'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dish Thumbnail
          ClipRRect(
            borderRadius: AppRadius.roundedSm,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryContainer,
                  child: const Icon(
                    Icons.fastfood_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Quantity & Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity}x @ ${item.formattedUnitPrice}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            item.formattedSubtotal,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)
              : AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                )
              : AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
