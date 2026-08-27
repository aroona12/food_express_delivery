import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../models/checkout_model.dart';
import '../../providers/checkout_provider.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_order_summary.dart';

/// Full-featured Customer Checkout Screen.
///
/// Combines delivery address selection, order review, payment method preview,
/// and order placement with comprehensive validation and instant feedback.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showOrderSuccessDialog(String orderId, CheckoutModel checkout) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation / Icon Container
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                'Order Placed!',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),

              Text(
                'Your order has been received and sent to the kitchen.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Order ID Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.roundedPill,
                ),
                child: Text(
                  'Order ID: #$orderId',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'Delivering to: ${checkout.deliveryAddress?.formattedAddress ?? "Your address"}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              AppButton(
                text: 'View Order History',
                prefixIcon: Icons.receipt_long_rounded,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.go('/orders');
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                text: 'Back to Home',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(CheckoutModel checkout) async {
    // 1. Validation check
    if (checkout.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Please add items to order.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (checkout.deliveryAddress == null ||
        checkout.deliveryAddress!.fullAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a delivery address to complete checkout.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Add Address',
            textColor: Colors.white,
            onPressed: () => context.push('/addresses/add'),
          ),
        ),
      );
      return;
    }

    // Save notes
    ref.read(checkoutOrderNotesProvider.notifier).state = _notesController.text.trim();

    // 2. Submit order placement
    final orderId = await ref
        .read(checkoutControllerProvider.notifier)
        .placeOrder();

    if (orderId != null && mounted) {
      try {
        context.go('/order-success/$orderId');
      } catch (_) {
        _showOrderSuccessDialog(orderId, checkout);
      }
    } else if (mounted) {
      final error = ref.read(checkoutControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final isPlacingOrder = checkoutState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: checkout.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  title: 'Your Cart is Empty',
                  message: 'Add items from our top restaurants to proceed with checkout.',
                  icon: Icons.shopping_bag_outlined,
                  actionText: 'Browse Restaurants',
                  onAction: () => context.go('/home'),
                ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Delivery Address Section
                          CheckoutAddressSection(
                            selectedAddress: checkout.deliveryAddress,
                            onChangeTap: () => context.push('/addresses?select=true'),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 2. Payment Method Card Preview
                          Text(
                            'Payment Method',
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppCard(
                            padding: AppSpacing.cardPadding,
                            elevation: 1,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.successContainer,
                                    borderRadius: AppRadius.roundedSm,
                                  ),
                                  child: const Icon(
                                    Icons.payments_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        checkout.paymentMethod,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Pay cash or mobile transfer when your food arrives.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 3. Special Instructions / Notes
                          Text(
                            'Delivery Notes (Optional)',
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppTextField(
                            key: const Key('checkout_notes_field'),
                            controller: _notesController,
                            hintText: 'e.g. Extra napkins, leave at door, don\'t ring bell',
                            maxLines: 2,
                            prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 4. Order & Pricing Summary
                          CheckoutOrderSummary(checkout: checkout),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Sticky Order Placement Action Bar
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  checkout.formattedTotal,
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.lg),
                                child: AppButton(
                                  key: const Key('place_order_button'),
                                  text: 'Place Order',
                                  isLoading: isPlacingOrder,
                                  prefixIcon: Icons.shopping_cart_checkout_rounded,
                                  height: AppSizes.buttonHeightLg,
                                  onPressed: () => _handlePlaceOrder(checkout),
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
