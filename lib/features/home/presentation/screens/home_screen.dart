import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../widgets/category_list.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/restaurant_card.dart';

/// FoodExpress Home Screen Preview for Day 1.
///
/// Demonstrates the design system, typography, color palette, and reusable components.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategoryId = 'all';
  int _currentNavIndex = 0;

  void _showNotificationMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
      ),
    );
  }

  void _openDesignSystemShowcase() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DesignSystemShowcaseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: HomeAppBar(
                onLocationTap: () => _showNotificationMessage('Delivery address selector (Coming in Day 7)'),
                onNotificationTap: () => _showNotificationMessage('Notifications (Coming in Day 9)'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Greeting & Headline
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening 👋',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find delicious food near you',
                      style: AppTypography.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Visual Search Field
            SliverToBoxAdapter(
              child: HomeSearchBar(
                onTap: () => _showNotificationMessage('Live search will be built in Day 4'),
                onFilterTap: () => _showNotificationMessage('Filters will be built in Day 4'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Promo Banner / Hero Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppCard(
                  padding: AppSpacing.cardPadding,
                  backgroundColor: AppColors.secondary,
                  borderRadius: AppRadius.roundedXl,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Text(
                                'SPECIAL OFFER',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get 20% OFF on your first order',
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use code FOODEXPRESS at checkout',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        '🎁',
                        style: TextStyle(fontSize: 44),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Category Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Categories',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Category Horizontal List
            SliverToBoxAdapter(
              child: CategoryList(
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (id) {
                  setState(() {
                    _selectedCategoryId = id;
                  });
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Featured Restaurants Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Restaurants',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showNotificationMessage('Full restaurant catalog coming in Day 3'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),

            // Restaurant Cards List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = MockData.featuredRestaurants[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RestaurantCard(
                        restaurant: restaurant,
                        onTap: () => _showNotificationMessage('Opening ${restaurant.name} (Coming in Day 3)'),
                      ),
                    );
                  },
                  childCount: MockData.featuredRestaurants.length,
                ),
              ),
            ),

            // Design System Showcase Trigger Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
                child: AppCard(
                  padding: AppSpacing.cardPadding,
                  backgroundColor: AppColors.primaryContainer,
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  child: Column(
                    children: [
                      Text(
                        '🎨 Design System Showcase',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preview all reusable Day 1 buttons, text fields, loaders, empty and error states.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'Open Component Preview',
                        variant: AppButtonVariant.primary,
                        height: 42,
                        prefixIcon: Icons.widgets_outlined,
                        onPressed: _openDesignSystemShowcase,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index != 0) {
            _showNotificationMessage('Tab navigation will be connected in future days.');
          }
        },
      ),
    );
  }
}

/// Interactive sheet to verify all Day 1 reusable widgets.
class _DesignSystemShowcaseSheet extends StatefulWidget {
  const _DesignSystemShowcaseSheet();

  @override
  State<_DesignSystemShowcaseSheet> createState() => _DesignSystemShowcaseSheetState();
}

class _DesignSystemShowcaseSheetState extends State<_DesignSystemShowcaseSheet> {
  bool _isButtonLoading = false;
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Design System Components',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Component Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    _buildTabChip(0, 'Buttons'),
                    const SizedBox(width: 8),
                    _buildTabChip(1, 'Inputs & Cards'),
                    const SizedBox(width: 8),
                    _buildTabChip(2, 'Loading & Error'),
                    const SizedBox(width: 8),
                    _buildTabChip(3, 'Empty State'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (_activeTabIndex == 0) _buildButtonsSection(),
                    if (_activeTabIndex == 1) _buildInputsAndCardsSection(),
                    if (_activeTabIndex == 2) _buildLoadingAndErrorSection(),
                    if (_activeTabIndex == 3) _buildEmptyStateSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _activeTabIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _activeTabIndex = index;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AppButton Variants', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          text: 'Primary Action Button',
          onPressed: () {},
          prefixIcon: Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: 'Secondary Action Button',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
          prefixIcon: Icons.admin_panel_settings_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: 'Outline Button',
          variant: AppButtonVariant.outline,
          onPressed: () {},
          suffixIcon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Loading & Disabled State', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: 'Click to test loading',
          isLoading: _isButtonLoading,
          onPressed: () async {
            setState(() => _isButtonLoading = true);
            await Future<void>.delayed(const Duration(seconds: 2));
            if (mounted) setState(() => _isButtonLoading = false);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppButton(
          text: 'Disabled Button',
          isDisabled: true,
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildInputsAndCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AppTextField', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        const AppTextField(
          hintText: 'Enter your email address',
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppTextField(
          hintText: 'Enter your password',
          obscureText: true,
          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
          suffixIcon: Icon(Icons.visibility_off_outlined, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('AppCard Variations', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Default Flat Card', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Uses pure white background with subtle border outline.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          elevation: 2,
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Elevated Interactive Card', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Includes subtle drop shadow and ripple effect when tapped.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAndErrorSection() {
    return Column(
      children: [
        Text('Loading Indicator', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        const LoadingIndicator(message: 'Fetching fresh meals near you...'),
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        Text('Error State', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ErrorState(
          title: 'Unable to connect',
          message: 'Please check your internet connection and try again.',
          onRetry: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retrying action...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyStateSection() {
    return Column(
      children: [
        Text('Empty State Widget', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        EmptyState(
          title: 'No Orders Yet',
          message: 'When you place an order, it will appear here for live tracking.',
          icon: Icons.receipt_long_outlined,
          actionText: 'Explore Menu',
          onAction: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
