import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../widgets/food_item_card.dart';
import '../widgets/menu_category_list.dart';
import '../widgets/restaurant_header.dart';

/// Restaurant Details and Menu Browsing Screen.
///
/// Fetches restaurant data and food items via Riverpod family providers.
class RestaurantDetailsScreen extends ConsumerWidget {
  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false, // Allow hero image to extend to status bar
        child: restaurantAsync.when(
          loading: () => const Center(
            child: LoadingIndicator(message: 'Loading restaurant menu...'),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: Center(
              child: ErrorState(
                title: 'Unable to Load Restaurant',
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(restaurantByIdProvider(restaurantId));
                  ref.invalidate(foodItemsProvider(restaurantId));
                },
              ),
            ),
          ),
          data: (restaurant) {
            if (restaurant == null) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                body: Center(
                  child: EmptyState(
                    title: 'Restaurant Not Found',
                    message: 'The restaurant you are looking for is no longer available.',
                    icon: Icons.storefront_outlined,
                    actionText: 'Back to Home',
                    onAction: () => Navigator.of(context).maybePop(),
                  ),
                ),
              );
            }

            final categoriesAsync = ref.watch(menuCategoriesProvider(restaurantId));
            final selectedCategory = ref.watch(selectedMenuCategoryProvider(restaurantId));
            final foodItemsAsync = ref.watch(filteredFoodItemsProvider(restaurantId));

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Restaurant Header with Hero Image
                SliverToBoxAdapter(
                  child: RestaurantHeader(
                    restaurant: restaurant,
                    onBackPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

                // Menu Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      'Menu & Categories',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // Menu Category Chips
                SliverToBoxAdapter(
                  child: categoriesAsync.when(
                    data: (categories) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: MenuCategoryList(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          ref
                              .read(selectedMenuCategoryProvider(restaurantId).notifier)
                              .state = category;
                        },
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sm),
                ),

                // Food Items List or States
                foodItemsAsync.when(
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: LoadingIndicator(message: 'Loading dishes...'),
                    ),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ErrorState(
                        title: 'Failed to load menu items',
                        message: error.toString(),
                        onRetry: () => ref.invalidate(filteredFoodItemsProvider(restaurantId)),
                      ),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: EmptyState(
                            title: 'No Dishes Available',
                            message: 'There are no dishes listed under "$selectedCategory". Try selecting another category.',
                            icon: Icons.no_food_outlined,
                            actionText: 'View All Dishes',
                            onAction: () {
                              ref
                                  .read(selectedMenuCategoryProvider(restaurantId).notifier)
                                  .state = 'All';
                            },
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: FoodItemCard(item: item),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: ref.watch(cartProvider).isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  text: 'View Cart (${ref.watch(cartProvider).totalItemCount}) • ${ref.watch(cartProvider).formattedTotal}',
                  prefixIcon: Icons.shopping_bag_outlined,
                  onPressed: () => context.push('/cart'),
                  variant: AppButtonVariant.primary,
                  height: AppSizes.buttonHeightMd,
                ),
              ),
            )
          : null,
    );
  }
}
