import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../providers/order_provider.dart';
import '../widgets/order_card.dart';

/// Customer Order History Screen displaying past and active food delivery orders.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Order History',
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
      body: ordersAsync.when(
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading order history...'),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ErrorState(
              title: 'Unable to Load Orders',
              message: error.toString(),
              onRetry: () => ref.refresh(orderHistoryProvider),
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  title: 'No Orders Yet',
                  message: 'Looks like you haven\'t placed any orders yet. Discover delicious meals from our top restaurants!',
                  icon: Icons.receipt_long_outlined,
                  actionText: 'Browse Restaurants',
                  onAction: () => context.go('/home'),
                ),
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(orderHistoryProvider),
              color: AppColors.primary,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: OrderCard(
                      order: order,
                      onTap: () => context.push('/orders/${order.id}'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
