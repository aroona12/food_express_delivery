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
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../widgets/address_card.dart';

/// Screen displaying all customer delivery addresses with management and selection capabilities.
class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({
    super.key,
    this.isSelectMode = false,
  });

  /// Whether this screen was opened for selecting an address for checkout.
  final bool isSelectMode;

  Future<void> _handleDeleteAddress(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Delete Address?',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove "${address.label} - ${address.fullAddress}" from your saved addresses?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(addressListProvider.notifier)
          .deleteAddress(address.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address "${address.label}" deleted'),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
          ),
        );
      }
    }
  }

  void _handleSelectAddress(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) {
    ref.read(selectedAddressIdProvider.notifier).state = address.id;

    if (isSelectMode) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/checkout');
      }
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery address set to "${address.label}"'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSelectMode ? 'Select Delivery Address' : 'Delivery Addresses',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Add New Address',
            onPressed: () => context.push('/addresses/add'),
          ),
        ],
      ),
      body: addressesAsync.when(
        loading: () => const Center(
          child: LoadingIndicator(message: 'Loading saved delivery addresses...'),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ErrorState(
              title: 'Unable to Load Addresses',
              message: error.toString(),
              onRetry: () => ref.read(addressListProvider.notifier).loadAddresses(),
            ),
          ),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: EmptyState(
                  title: 'No Addresses Saved',
                  message:
                      'You haven\'t added any delivery addresses yet. Add one now to enjoy seamless checkout!',
                  icon: Icons.location_off_outlined,
                  actionText: 'Add New Address',
                  onAction: () => context.push('/addresses/add'),
                ),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                if (isSelectMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    color: AppColors.primaryContainer,
                    child: Text(
                      'Tap an address to deliver your order here.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(addressListProvider.notifier).loadAddresses(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final isSelected = selectedAddress?.id == address.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AddressCard(
                            address: address,
                            isSelected: isSelected,
                            showSelectionIndicator: isSelectMode,
                            onTap: () =>
                                _handleSelectAddress(context, ref, address),
                            onEdit: () =>
                                context.push('/addresses/edit/${address.id}'),
                            onDelete: () =>
                                _handleDeleteAddress(context, ref, address),
                            onSetDefault: () => ref
                                .read(addressListProvider.notifier)
                                .setDefaultAddress(address.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppButton(
                    text: 'Add New Address',
                    prefixIcon: Icons.add_location_alt_rounded,
                    onPressed: () => context.push('/addresses/add'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
