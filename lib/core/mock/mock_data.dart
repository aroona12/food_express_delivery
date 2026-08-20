import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// TEMPORARY DEVELOPMENT MOCK DATA (DAY 1 ONLY)
///
/// NOTE: This file is strictly for UI layout demonstration and testing the
/// design system on Day 1. It must NOT be connected to future Firebase
/// repositories or production code.
/// ---------------------------------------------------------------------------

class MockCategory {
  const MockCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.badge,
  });

  final String id;
  final String name;
  final String icon;
  final String? badge;
}

class MockRestaurant {
  const MockRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.gradientColors,
    this.badge,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final List<Color> gradientColors;
  final String? badge;
  final bool isFavorite;
}

abstract final class MockData {
  static const List<MockCategory> categories = [
    MockCategory(id: 'all', name: 'All', icon: '🍽️'),
    MockCategory(id: 'burgers', name: 'Burgers', icon: '🍔', badge: 'Hot'),
    MockCategory(id: 'pizza', name: 'Pizza', icon: '🍕'),
    MockCategory(id: 'asian', name: 'Asian', icon: '🍜'),
    MockCategory(id: 'healthy', name: 'Healthy', icon: '🥗'),
    MockCategory(id: 'dessert', name: 'Dessert', icon: '🍰'),
    MockCategory(id: 'drinks', name: 'Drinks', icon: '🧃'),
  ];

  static const List<MockRestaurant> featuredRestaurants = [
    MockRestaurant(
      id: 'rest-1',
      name: 'The Burger Studio',
      cuisine: 'Gourmet Burgers • American',
      rating: 4.8,
      reviewCount: 320,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free delivery',
      badge: 'Featured',
      gradientColors: [Color(0xFFFF8A50), Color(0xFFFF5722)],
    ),
    MockRestaurant(
      id: 'rest-2',
      name: 'Napoli Artisan Pizzeria',
      cuisine: 'Italian • Wood-fired Pizza',
      rating: 4.9,
      reviewCount: 485,
      deliveryTime: '25-35 min',
      deliveryFee: '\$1.99 Delivery',
      badge: 'Popular',
      gradientColors: [Color(0xFFE53935), Color(0xFFC62828)],
    ),
    MockRestaurant(
      id: 'rest-3',
      name: 'Tokyo Ramen & Bowls',
      cuisine: 'Japanese • Ramen • Sushi',
      rating: 4.7,
      reviewCount: 190,
      deliveryTime: '15-25 min',
      deliveryFee: '\$0.99 Delivery',
      gradientColors: [Color(0xFF26A69A), Color(0xFF00796B)],
    ),
    MockRestaurant(
      id: 'rest-4',
      name: 'Green Harvest Bowls',
      cuisine: 'Salads • Organic • Vegan',
      rating: 4.6,
      reviewCount: 140,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free over \$20',
      gradientColors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    ),
  ];
}
