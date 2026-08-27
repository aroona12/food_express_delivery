import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';

/// Form screen for adding a new address or editing an existing delivery address.
class AddEditAddressScreen extends ConsumerStatefulWidget {
  const AddEditAddressScreen({
    super.key,
    this.addressId,
  });

  /// Address ID to edit. If null, this screen is in creation mode.
  final String? addressId;

  bool get isEditing => addressId != null && addressId!.isNotEmpty;

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullAddressController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _customLabelController;

  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _predefinedLabels = const ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    _fullAddressController = TextEditingController();
    _cityController = TextEditingController(text: 'Springfield');
    _phoneController = TextEditingController();
    _instructionsController = TextEditingController();
    _customLabelController = TextEditingController();
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'guest-user';

    final effectiveLabel = _selectedLabel == 'Other' &&
            _customLabelController.text.trim().isNotEmpty
        ? _customLabelController.text.trim()
        : _selectedLabel;

    setState(() => _isLoading = true);

    try {
      if (widget.isEditing) {
        final updatedAddress = AddressModel(
          id: widget.addressId!,
          userId: userId,
          label: effectiveLabel,
          fullAddress: _fullAddressController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim(),
          additionalInstructions: _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text.trim()
              : null,
          isDefault: _isDefault,
          createdAt: DateTime.now(),
        );

        await ref
            .read(addressListProvider.notifier)
            .updateAddress(updatedAddress);
      } else {
        final newAddress = AddressModel(
          id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          label: effectiveLabel,
          fullAddress: _fullAddressController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim(),
          additionalInstructions: _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text.trim()
              : null,
          isDefault: _isDefault,
          createdAt: DateTime.now(),
        );

        final created = await ref
            .read(addressListProvider.notifier)
            .addAddress(newAddress);

        if (created != null) {
          ref.read(selectedAddressIdProvider.notifier).state = created.id;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Address updated successfully!'
                  : 'Address added successfully!',
            ),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_isInitialized) {
      final addressesAsync = ref.watch(addressListProvider);
      final address = addressesAsync.valueOrNull?.firstWhere(
        (a) => a.id == widget.addressId,
        orElse: () => AddressModel(
          id: '',
          userId: '',
          label: 'Home',
          fullAddress: '',
          city: '',
          phone: '',
          createdAt: DateTime.now(),
        ),
      );

      if (address != null && address.id.isNotEmpty) {
        _fullAddressController.text = address.fullAddress;
        _cityController.text = address.city;
        _phoneController.text = address.phone;
        _instructionsController.text = address.additionalInstructions ?? '';
        _isDefault = address.isDefault;

        if (_predefinedLabels.contains(address.label)) {
          _selectedLabel = address.label;
        } else {
          _selectedLabel = 'Other';
          _customLabelController.text = address.label;
        }
        _isInitialized = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Address' : 'Add Delivery Address',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Label Selection
                Text(
                  'Address Label',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _predefinedLabels.map((label) {
                    final isSelected = _selectedLabel == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedLabel = label);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

                if (_selectedLabel == 'Other') ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _customLabelController,
                    hintText: 'Custom label (e.g. Grandma\'s House, Gym)',
                    prefixIcon: const Icon(Icons.label_outline_rounded, size: 20),
                    validator: (val) {
                      if (_selectedLabel == 'Other' &&
                          (val == null || val.trim().isEmpty)) {
                        return 'Please enter a custom address label';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // 2. Full Street Address
                Text(
                  'Street Address & Apartment / Suite',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('address_full_field'),
                  controller: _fullAddressController,
                  hintText: 'e.g. 742 Evergreen Terrace, Apt 4B',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Street address is required';
                    }
                    if (val.trim().length < 5) {
                      return 'Please enter a valid complete street address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. City
                Text(
                  'City / Municipality',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('address_city_field'),
                  controller: _cityController,
                  hintText: 'e.g. Springfield',
                  prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // 4. Contact Phone Number
                Text(
                  'Delivery Contact Phone Number',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('address_phone_field'),
                  controller: _phoneController,
                  hintText: 'e.g. +1 (555) 012-3456',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Phone number is required for delivery coordination';
                    }
                    if (val.trim().length < 7) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // 5. Additional Delivery Instructions
                Text(
                  'Delivery Instructions (Optional)',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  key: const Key('address_instructions_field'),
                  controller: _instructionsController,
                  hintText: 'e.g. Gate code #1234, leave package on front porch',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                ),

                const SizedBox(height: AppSpacing.md),

                // 6. Default Address Toggle Switch
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isDefault = val),
                  title: Text(
                    'Set as default delivery address',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'This address will be automatically selected during checkout.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 7. Save Action Button
                AppButton(
                  key: const Key('save_address_button'),
                  text: widget.isEditing ? 'Update Address' : 'Save Address',
                  isLoading: _isLoading,
                  prefixIcon: Icons.check_circle_outline_rounded,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
