import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/order_model.dart';

/// Clean, multi-stage visual tracking progress timeline for customer food orders.
///
/// Highlights active status, displays checkmarks for completed steps, and cleanly separates cancelled states.
class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  static const List<_TimelineStep> _standardSteps = [
    _TimelineStep(
      status: OrderStatus.pending,
      title: 'Order Placed',
      description: 'Your order was sent to the restaurant.',
      icon: Icons.receipt_long_rounded,
    ),
    _TimelineStep(
      status: OrderStatus.confirmed,
      title: 'Order Confirmed',
      description: 'Restaurant has accepted and confirmed your order.',
      icon: Icons.check_circle_outline_rounded,
    ),
    _TimelineStep(
      status: OrderStatus.preparing,
      title: 'Preparing Food',
      description: 'The kitchen is preparing and packing your meal.',
      icon: Icons.soup_kitchen_rounded,
    ),
    _TimelineStep(
      status: OrderStatus.outForDelivery,
      title: 'Out for Delivery',
      description: 'Delivery rider has picked up your food and is on the way.',
      icon: Icons.delivery_dining_rounded,
    ),
    _TimelineStep(
      status: OrderStatus.delivered,
      title: 'Order Delivered',
      description: 'Food has been successfully delivered. Enjoy your meal!',
      icon: Icons.task_alt_rounded,
    ),
  ];

  int _getStepIndex(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return AppCard(
        padding: AppSpacing.cardPadding,
        backgroundColor: const Color(0xFFFFEBEE),
        borderColor: AppColors.error.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This order was cancelled. If you were charged, a refund will be processed to your original payment method.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _getStepIndex(status);

    return AppCard(
      padding: AppSpacing.cardPadding,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Order Progress',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.containerColor,
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 14, color: status.color),
                    const SizedBox(width: 4),
                    Text(
                      status.displayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Timeline steps list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _standardSteps.length,
            itemBuilder: (context, index) {
              final step = _standardSteps[index];
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == _standardSteps.length - 1;

              return _buildStepRow(
                step: step,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: isLast,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required _TimelineStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    Color indicatorColor;
    Color iconColor;
    Color backgroundColor;
    IconData stepIcon;

    if (isCompleted) {
      indicatorColor = AppColors.success;
      iconColor = Colors.white;
      backgroundColor = AppColors.success;
      stepIcon = Icons.check_rounded;
    } else if (isCurrent) {
      indicatorColor = AppColors.primary;
      iconColor = Colors.white;
      backgroundColor = AppColors.primary;
      stepIcon = step.icon;
    } else {
      indicatorColor = AppColors.border;
      iconColor = AppColors.textTertiary;
      backgroundColor = AppColors.surfaceVariant;
      stepIcon = step.icon;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Indicator circle and vertical connector line
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor,
                    width: 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  stepIcon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Right side: Step Title and Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? AppSpacing.xs : AppSpacing.lg,
                top: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: isCurrent || isCompleted
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.primaryDark
                              : (isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: AppRadius.roundedPill,
                          ),
                          child: Text(
                            'CURRENT',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: isCurrent
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
  });

  final OrderStatus status;
  final String title;
  final String description;
  final IconData icon;
}
