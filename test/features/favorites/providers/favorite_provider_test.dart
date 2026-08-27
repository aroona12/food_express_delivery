import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/favorites/data/favorite_repository.dart';
import 'package:foodexpressdelivery/features/favorites/providers/favorite_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  group('Favorite Providers & Controller', () {
    late MockFavoriteRepository fakeFavoriteRepo;
    late MockRestaurantRepository fakeRestaurantRepo;

    const testUser = UserModel(
      id: 'user-123',
      email: 'customer@test.com',
      name: 'Test Customer',
      role: UserRole.customer,
    );

    const testRestaurant1 = RestaurantModel(
      id: 'rest-1',
      name: 'Burger Haven',
      description: 'Best burgers in town',
      imageUrl: 'https://example.com/burger.jpg',
      rating: 4.8,
      reviewCount: 120,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free',
      cuisine: 'Burgers',
      isOpen: true,
      address: '123 Main St',
    );

    const testRestaurant2 = RestaurantModel(
      id: 'rest-2',
      name: 'Pizza Palace',
      description: 'Hot & cheesy pizza',
      imageUrl: 'https://example.com/pizza.jpg',
      rating: 4.6,
      reviewCount: 85,
      deliveryTime: '30-40 min',
      deliveryFee: '\$1.99',
      cuisine: 'Pizza',
      isOpen: true,
      address: '456 Elm St',
    );

    ProviderContainer createContainer({
      UserModel? currentUser = testUser,
    }) {
      fakeFavoriteRepo = MockFavoriteRepository();
      fakeRestaurantRepo = MockRestaurantRepository(
        restaurants: [testRestaurant1, testRestaurant2],
      );

      final container = ProviderContainer(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(fakeFavoriteRepo),
          restaurantRepositoryProvider.overrideWithValue(fakeRestaurantRepo),
          currentUserProvider.overrideWithValue(currentUser),
        ],
      );

      addTearDown(container.dispose);
      return container;
    }

    test('favoriteIdsProvider starts empty when user has no favorites', () async {
      final container = createContainer();

      expect(container.read(favoriteIdsProvider), isEmpty);
      expect(container.read(isFavoriteProvider('rest-1')), isFalse);
    });

    test('FavoriteController.toggleFavorite adds and removes restaurant ID', () async {
      final container = createContainer();

      final controller = container.read(favoriteControllerProvider.notifier);

      // 1. Toggle ON
      final result1 = await controller.toggleFavorite('rest-1');
      expect(result1, isTrue);
      expect(container.read(favoriteIdsProvider), contains('rest-1'));
      expect(container.read(isFavoriteProvider('rest-1')), isTrue);
      expect(container.read(isFavoriteProvider('rest-2')), isFalse);

      // 2. Toggle OFF
      final result2 = await controller.toggleFavorite('rest-1');
      expect(result2, isFalse);
      expect(container.read(favoriteIdsProvider), isEmpty);
      expect(container.read(isFavoriteProvider('rest-1')), isFalse);
    });

    test('FavoriteController.addFavorite and removeFavorite work correctly', () async {
      final container = createContainer();
      final controller = container.read(favoriteControllerProvider.notifier);

      await controller.addFavorite('rest-1');
      await controller.addFavorite('rest-2');

      expect(container.read(favoriteIdsProvider), {'rest-1', 'rest-2'});
      expect(container.read(isFavoriteProvider('rest-1')), isTrue);
      expect(container.read(isFavoriteProvider('rest-2')), isTrue);

      await controller.removeFavorite('rest-1');
      expect(container.read(favoriteIdsProvider), {'rest-2'});
      expect(container.read(isFavoriteProvider('rest-1')), isFalse);
    });

    test('favoriteRestaurantsProvider resolves full RestaurantModel list', () async {
      final container = createContainer();
      final controller = container.read(favoriteControllerProvider.notifier);

      await controller.addFavorite('rest-1');

      final restaurants = await container.read(favoriteRestaurantsProvider.future);
      expect(restaurants.length, 1);
      expect(restaurants.first.id, 'rest-1');
      expect(restaurants.first.name, 'Burger Haven');
    });

    test('userFavoritesProvider fetches raw FavoriteModel records', () async {
      final container = createContainer();
      final controller = container.read(favoriteControllerProvider.notifier);

      await controller.addFavorite('rest-1');

      final favorites = await container.read(userFavoritesProvider.future);
      expect(favorites.length, 1);
      expect(favorites.first.restaurantId, 'rest-1');
      expect(favorites.first.userId, 'user-123');
    });
  });
}
