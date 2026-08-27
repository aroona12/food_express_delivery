import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_tile.dart';

/// Main Customer Profile Screen for FoodExpress.
///
/// Fully decoupled from Firebase Firestore SDKs; communicates entirely
/// through Riverpod providers and repositories.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
        title: Text(
          'Log Out',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of your FoodExpress account?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStream = ref.watch(userProfileStreamProvider);
    final fallbackUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              final user = profileStream.valueOrNull ?? fallbackUser;
              if (user != null) {
                EditProfileSheet.show(context, user);
              }
            },
          ),
        ],
      ),
      body: profileStream.when(
        data: (user) {
          final effectiveUser = user ?? fallbackUser;
          if (effectiveUser == null) {
            return const ErrorState(
              title: 'No Profile Found',
              message: 'Please sign in to view and manage your profile.',
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Header Card
                  ProfileHeaderCard(
                    user: effectiveUser,
                    onEditTap: () => EditProfileSheet.show(context, effectiveUser),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Personal Information Section
                  Text(
                    'Personal Information',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    elevation: 1,
                    child: Column(
                      children: [
                        ProfileInfoTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: effectiveUser.name,
                          placeholder: 'Add your name',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onTap: () => EditProfileSheet.show(context, effectiveUser),
                        ),
                        const Divider(height: 1),
                        ProfileInfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: effectiveUser.email,
                          trailing: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textTertiary,
                            size: 18,
                          ),
                        ),
                        const Divider(height: 1),
                        ProfileInfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: effectiveUser.phone,
                          placeholder: 'Add phone number',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onTap: () => EditProfileSheet.show(context, effectiveUser),
                        ),
                        const Divider(height: 1),
                        ProfileInfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Delivery Address',
                          value: effectiveUser.address,
                          placeholder: 'Add delivery address',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          onTap: () => EditProfileSheet.show(context, effectiveUser),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Quick Actions Section
                  Text(
                    'Account Settings',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    elevation: 1,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                            ),
                            child: const Icon(Icons.favorite_outline_rounded,
                                color: AppColors.error, size: 20),
                          ),
                          title: Text(
                            'My Favorites',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'View your saved restaurants',
                            style: AppTypography.bodySmall,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                          onTap: () => context.push('/favorites'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                            ),
                            child: const Icon(Icons.receipt_long_outlined,
                                color: AppColors.secondary, size: 20),
                          ),
                          title: Text(
                            'Order History',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'View past orders and tracking',
                            style: AppTypography.bodySmall,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                          onTap: () => context.push('/orders'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                            ),
                            child: const Icon(Icons.location_on_outlined,
                                color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            'Delivery Addresses',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Manage and add delivery addresses',
                            style: AppTypography.bodySmall,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                          onTap: () => context.push('/addresses'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                            ),
                            child: const Icon(Icons.edit_note_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            'Edit Profile Details',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Update name, phone number, and address',
                            style: AppTypography.bodySmall,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                          onTap: () => EditProfileSheet.show(context, effectiveUser),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 4. Logout Action
                  AppButton(
                    text: 'Log Out',
                    variant: AppButtonVariant.outline,
                    prefixIcon: Icons.logout_rounded,
                    onPressed: () => _handleSignOut(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
        loading: () => fallbackUser != null
            ? SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeaderCard(
                        user: fallbackUser,
                        onEditTap: () => EditProfileSheet.show(context, fallbackUser),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const LoadingIndicator(message: 'Syncing profile details from Cloud Firestore...'),
                    ],
                  ),
                ),
              )
            : const Center(
                child: LoadingIndicator(message: 'Loading customer profile...'),
              ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ErrorState(
              title: 'Unable to Load Profile',
              message: error.toString(),
              onRetry: () => ref.refresh(userProfileStreamProvider),
            ),
          ),
        ),
      ),
    );
  }
}
