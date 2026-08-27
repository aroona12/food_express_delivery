import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../restaurant/models/food_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

/// Represents the outcome of an [CartController.addToCart] operation.
enum AddToCartResult {
  /// The food item was newly added to the cart with quantity 1.
  added,

  /// The food item already existed in the cart; its quantity was incremented.
  updatedQuantity,

  /// The item belongs to a different restaurant than the items currently in the cart.
  /// The UI should ask the user for confirmation before clearing the existing cart.
  restaurantMismatch,

  /// The item is marked unavailable/out of stock and cannot be added.
  unavailable,
}

/// State notifier managing cart mutations and calculations with immutable state.
class CartController extends StateNotifier<CartModel> {
  CartController([super.initialCart = const CartModel()]);

  /// Adds a food item to the shopping cart.
  ///
  /// - If the item is unavailable, returns [AddToCartResult.unavailable] without modifying state.
  /// - If the cart contains items from another restaurant, returns [AddToCartResult.restaurantMismatch].
  /// - If the item already exists in the cart, increments its quantity by 1 and returns [AddToCartResult.updatedQuantity].
  /// - Otherwise, appends the new [CartItemModel] with quantity 1 and returns [AddToCartResult.added].
  AddToCartResult addToCart(FoodItemModel item) {
    if (!item.isAvailable) {
      return AddToCartResult.unavailable;
    }

    final currentRestaurantId = state.effectiveRestaurantId;
    if (state.isNotEmpty &&
        currentRestaurantId != null &&
        currentRestaurantId != item.restaurantId) {
      return AddToCartResult.restaurantMismatch;
    }

    final existingIndex =
        state.items.indexWhere((ci) => ci.foodItemId == item.id);

    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
      return AddToCartResult.updatedQuantity;
    } else {
      final updatedList = [
        ...state.items,
        CartItemModel(foodItem: item, quantity: 1),
      ];
      state = state.copyWith(
        items: updatedList,
        restaurantId: item.restaurantId,
      );
      return AddToCartResult.added;
    }
  }

  /// Clears the existing cart and adds the new [item].
  ///
  /// Used after the customer confirms switching restaurants.
  void clearAndAddToCart(FoodItemModel item) {
    if (!item.isAvailable) return;
    state = CartModel(
      items: [CartItemModel(foodItem: item, quantity: 1)],
      restaurantId: item.restaurantId,
    );
  }

  /// Increments the quantity of an existing cart item by 1.
  void increaseQuantity(String foodItemId) {
    final index = state.items.indexWhere((ci) => ci.foodItemId == foodItemId);
    if (index < 0) return;

    final existingItem = state.items[index];
    final updatedList = List<CartItemModel>.from(state.items);
    updatedList[index] = existingItem.copyWith(
      quantity: existingItem.quantity + 1,
    );
    state = state.copyWith(items: updatedList);
  }

  /// Decrements the quantity of an existing cart item by 1.
  ///
  /// If the quantity reaches 0, the item is removed from the cart.
  void decreaseQuantity(String foodItemId) {
    final index = state.items.indexWhere((ci) => ci.foodItemId == foodItemId);
    if (index < 0) return;

    final existingItem = state.items[index];
    final updatedList = List<CartItemModel>.from(state.items);

    if (existingItem.quantity > 1) {
      updatedList[index] = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
      );
    } else {
      updatedList.removeAt(index);
    }

    state = state.copyWith(
      items: updatedList,
      clearRestaurantId: updatedList.isEmpty,
    );
  }

  /// Completely removes an item from the cart.
  void removeFromCart(String foodItemId) {
    final updatedList =
        state.items.where((ci) => ci.foodItemId != foodItemId).toList();
    state = state.copyWith(
      items: updatedList,
      clearRestaurantId: updatedList.isEmpty,
    );
  }

  /// Resets the cart to an empty state.
  void clearCart() {
    state = const CartModel(items: [], restaurantId: null);
  }
}

/// Riverpod provider for [CartController] managing cart mutations.
final cartControllerProvider =
    StateNotifierProvider<CartController, CartModel>((ref) {
  return CartController();
});

/// Riverpod provider exposing the current [CartModel] instance.
final cartProvider = Provider<CartModel>((ref) {
  return ref.watch(cartControllerProvider);
});

/// Derived provider exposing total item count across all dishes in the cart.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItemCount;
});

/// Derived provider exposing the subtotal sum before delivery fees.
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Derived provider exposing the centralized delivery fee.
final cartDeliveryFeeProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).deliveryFee;
});

/// Derived provider exposing the grand total sum (subtotal + deliveryFee).
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

/// Derived provider exposing whether the cart is currently empty.
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});
