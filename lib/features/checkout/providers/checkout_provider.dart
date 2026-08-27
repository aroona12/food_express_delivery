import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../address/providers/address_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../order/models/order_item_model.dart';
import '../../order/models/order_model.dart';
import '../../order/providers/order_provider.dart';
import '../../restaurant/providers/restaurant_provider.dart';
import '../models/checkout_model.dart';

/// State provider storing customer-selected payment method for checkout.
final checkoutPaymentMethodProvider =
    StateProvider<String>((ref) => 'Cash on Delivery');

/// State provider storing optional customer order instructions / notes.
final checkoutOrderNotesProvider = StateProvider<String>((ref) => '');

/// Derived provider assembling the complete [CheckoutModel] payload from Cart, Address, and Restaurant state.
final checkoutProvider = Provider<CheckoutModel>((ref) {
  final cart = ref.watch(cartProvider);
  final address = ref.watch(selectedAddressProvider);
  final paymentMethod = ref.watch(checkoutPaymentMethodProvider);
  final orderNotes = ref.watch(checkoutOrderNotesProvider);

  final restaurantId = cart.restaurantId;
  final restaurantAsync = restaurantId != null && restaurantId.isNotEmpty
      ? ref.watch(restaurantByIdProvider(restaurantId))
      : null;

  final restaurant = restaurantAsync?.valueOrNull;

  return CheckoutModel(
    restaurant: restaurant,
    items: cart.items,
    subtotal: cart.subtotal,
    deliveryFee: cart.deliveryFee,
    total: cart.total,
    deliveryAddress: address,
    paymentMethod: paymentMethod,
    orderNotes: orderNotes.trim().isNotEmpty ? orderNotes.trim() : null,
  );
});

/// Controller handling the order placement submission, Firestore persistence,
/// and atomic post-success cart clearing.
class CheckoutController extends StateNotifier<AsyncValue<String?>> {
  CheckoutController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// Validates checkout data and submits the order to [OrderRepository].
  ///
  /// Atomically clears the shopping cart ONLY after successful Firestore persistence.
  /// If creation fails, preserves cart and records error in [state].
  Future<String?> placeOrder() async {
    if (state.isLoading) {
      // Prevent duplicate concurrent submissions
      return null;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.id.isEmpty) {
      state = AsyncValue.error(
        Exception('You must be signed in to place an order.'),
        StackTrace.current,
      );
      return null;
    }

    final checkout = ref.read(checkoutProvider);

    if (checkout.items.isEmpty) {
      state = AsyncValue.error(
        Exception('Your cart is empty. Please add dishes to continue.'),
        StackTrace.current,
      );
      return null;
    }

    if (checkout.deliveryAddress == null ||
        checkout.deliveryAddress!.fullAddress.trim().isEmpty) {
      state = AsyncValue.error(
        Exception('Please select a valid delivery address to proceed.'),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(orderRepositoryProvider);

      // Convert CartItemModel objects to OrderItemModel domain objects
      final orderItems = checkout.items
          .map(
            (cartItem) => OrderItemModel(
              foodItemId: cartItem.foodItemId,
              restaurantId: cartItem.restaurantId,
              name: cartItem.name,
              imageUrl: cartItem.imageUrl,
              unitPrice: cartItem.unitPrice,
              quantity: cartItem.quantity,
            ),
          )
          .toList();

      final restaurantId = checkout.restaurant?.id ??
          (checkout.items.isNotEmpty ? checkout.items.first.restaurantId : '');
      final restaurantName = checkout.restaurant?.name ?? 'Restaurant';

      final orderPayload = OrderModel(
        id: '', // Will be assigned by repository / Firestore
        userId: user.id,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: orderItems,
        subtotal: checkout.subtotal,
        deliveryFee: checkout.deliveryFee,
        total: checkout.total,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: checkout.deliveryAddress?.formattedAddress,
        orderNotes: checkout.orderNotes,
        paymentMethod: checkout.paymentMethod,
      );

      // 1. Persist to Firestore
      final createdOrderId = await repository.createOrder(orderPayload);

      // 2. Only after successful order creation, clear customer shopping cart
      ref.read(cartControllerProvider.notifier).clearCart();

      // 3. Reset checkout notes
      ref.read(checkoutOrderNotesProvider.notifier).state = '';

      state = AsyncValue.data(createdOrderId);
      return createdOrderId;
    } catch (e, st) {
      // Keep cart intact on error
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Resets the controller state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider exposing [CheckoutController].
final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<String?>>((ref) {
  return CheckoutController(ref);
});
