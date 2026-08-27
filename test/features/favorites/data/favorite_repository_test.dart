import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/favorites/data/favorite_repository.dart';

void main() {
  group('MockFavoriteRepository', () {
    late MockFavoriteRepository repository;

    setUp(() {
      repository = MockFavoriteRepository();
    });

    test('getFavorites returns empty list initially for a new user', () async {
      final favorites = await repository.getFavorites('user-1');
      expect(favorites, isEmpty);
    });

    test('addFavorite adds a restaurant to user favorites', () async {
      await repository.addFavorite('user-1', 'rest-1');

      final favorites = await repository.getFavorites('user-1');
      expect(favorites.length, 1);
      expect(favorites.first.restaurantId, 'rest-1');
      expect(favorites.first.userId, 'user-1');
    });

    test('addFavorite does not duplicate when adding same restaurant twice', () async {
      await repository.addFavorite('user-1', 'rest-1');
      await repository.addFavorite('user-1', 'rest-1');

      final favorites = await repository.getFavorites('user-1');
      expect(favorites.length, 1);
    });

    test('isFavorite returns true only when restaurant is in user favorites', () async {
      expect(await repository.isFavorite('user-1', 'rest-1'), isFalse);

      await repository.addFavorite('user-1', 'rest-1');
      expect(await repository.isFavorite('user-1', 'rest-1'), isTrue);
      expect(await repository.isFavorite('user-1', 'rest-2'), isFalse);
    });

    test('removeFavorite removes an existing favorite', () async {
      await repository.addFavorite('user-1', 'rest-1');
      await repository.addFavorite('user-1', 'rest-2');

      await repository.removeFavorite('user-1', 'rest-1');

      final favorites = await repository.getFavorites('user-1');
      expect(favorites.length, 1);
      expect(favorites.first.restaurantId, 'rest-2');
      expect(await repository.isFavorite('user-1', 'rest-1'), isFalse);
    });

    test('toggleFavorite toggles status correctly', () async {
      final state1 = await repository.toggleFavorite('user-1', 'rest-1');
      expect(state1, isTrue);
      expect(await repository.isFavorite('user-1', 'rest-1'), isTrue);

      final state2 = await repository.toggleFavorite('user-1', 'rest-1');
      expect(state2, isFalse);
      expect(await repository.isFavorite('user-1', 'rest-1'), isFalse);
    });

    test('favorites are strictly isolated by userId', () async {
      await repository.addFavorite('user-A', 'rest-1');
      await repository.addFavorite('user-B', 'rest-2');

      final favoritesA = await repository.getFavorites('user-A');
      final favoritesB = await repository.getFavorites('user-B');

      expect(favoritesA.map((f) => f.restaurantId), contains('rest-1'));
      expect(favoritesA.map((f) => f.restaurantId), isNot(contains('rest-2')));

      expect(favoritesB.map((f) => f.restaurantId), contains('rest-2'));
      expect(favoritesB.map((f) => f.restaurantId), isNot(contains('rest-1')));
    });
  });
}
