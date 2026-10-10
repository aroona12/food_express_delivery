import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

/// Top bar with delivery address selector, brand title, cart badge, notification, and profile/logout actions.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onProfileTap,
    this.onFavoritesTap,
    this.onOrdersTap,
    this.onLogoutTap,
    this.userName,
    this.userEmail,
    this.userAddress,
    this.cartItemCount = 0,
    this.unreadNotificationCount = 0,
  });

  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onLogoutTap;
  final String? userName;
  final String? userEmail;
  final String? userAddress;
  final int cartItemCount;
  final int unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    final effectiveAddress = userAddress != null && userAddress!.trim().isNotEmpty
        ? userAddress!.trim()
        : '742 Evergreen Terrace, Springfield';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location Selector
          Expanded(
            child: InkWell(
              borderRadius: AppRadius.roundedSm,
              onTap: onLocationTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DELIVER TO',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    effectiveAddress,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Cart Action Button with Dynamic Badge
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              key: const Key('home_cart_button'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: onCartTap,
              tooltip: 'Shopping Cart',
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Notification Action Button with Dynamic Reactive Badge
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              key: const Key('home_notification_button'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  if (unreadNotificationCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadNotificationCount > 9 ? '9+' : '$unreadNotificationCount',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: onNotificationTap,
              tooltip: 'Notifications',
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Profile / Logout Menu Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 22),
              tooltip: 'Account',
              offset: const Offset(0, 48),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
              onSelected: (value) {
                if (value == 'profile' && onProfileTap != null) {
                  onProfileTap!();
                } else if (value == 'favorites' && onFavoritesTap != null) {
                  onFavoritesTap!();
                } else if (value == 'orders' && onOrdersTap != null) {
                  onOrdersTap!();
                } else if (value == 'logout' && onLogoutTap != null) {
                  onLogoutTap!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName != null && userName!.isNotEmpty ? userName! : 'FoodExpress User',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (userEmail != null && userEmail!.isNotEmpty)
                        Text(
                          userEmail!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'View Profile',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'favorites',
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_outline_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'My Favorites',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'orders',
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Order History',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
