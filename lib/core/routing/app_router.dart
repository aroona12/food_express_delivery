import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/address/presentation/screens/add_edit_address_screen.dart';
import '../../features/address/presentation/screens/address_list_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/handlers/notification_navigation_handler.dart';
import '../../features/notifications/providers/fcm_token_sync_provider.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/order/presentation/screens/order_history_screen.dart';
import '../../features/order/presentation/screens/order_tracking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/providers/user_provider.dart';
import '../../features/restaurant/presentation/screens/restaurant_dashboard_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_details_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_menu_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_orders_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_settings_screen.dart';

/// Helper to bridge Riverpod authentication and user profile changes to GoRouter's [refreshListenable].
class AppRouterRefreshNotifier extends ChangeNotifier {
  AppRouterRefreshNotifier(Ref ref) {
    final authRepository = ref.read(authRepositoryProvider);
    _authSubscription = authRepository.authStateChanges.asBroadcastStream().listen((_) {
      notifyListeners();
    });

    ref.listen<AsyncValue<UserModel?>>(userProfileStreamProvider, (previous, next) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _authSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

/// Riverpod provider for declarative [GoRouter] with authentication protection and RBAC guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Activate reactive FCM token sync across authenticated user lifecycle
  ref.watch(fcmTokenSyncProvider);

  final authRepository = ref.watch(authRepositoryProvider);
  final refreshNotifier = AppRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final user = authRepository.currentUser;
      final isLoggedIn = user != null;

      final matchedLocation = state.matchedLocation;
      final isAuthRoute = matchedLocation == '/login' ||
          matchedLocation == '/register' ||
          matchedLocation == '/forgot-password';

      // 1. If unauthenticated and trying to access protected routes, redirect to /login
      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // 2. Resolve user role from real-time profile
      final profileAsync = ref.read(userProfileStreamProvider);

      // If the profile is actively loading and has no resolved data yet,
      // prevent premature role-based redirect decisions to avoid race conditions.
      final isProfileResolving = profileAsync.isLoading && !profileAsync.hasValue;
      if (isProfileResolving) {
        // Stay on auth routes while authenticating/loading profile (avoids flicker to /home)
        if (isAuthRoute) return null;

        // Do not prematurely evict users from role-protected portals before role is known
        if (matchedLocation.startsWith('/restaurant') || matchedLocation.startsWith('/admin')) {
          return null;
        }
      }

      final profile = profileAsync.valueOrNull ?? ref.read(userProfileProvider) ?? user;
      final role = profile.role;

      // 3. If authenticated and trying to access auth screens, redirect according to role
      if (isAuthRoute) {
        if (role.isRestaurant) {
          return '/restaurant/dashboard';
        } else if (role.isAdmin) {
          return '/admin/dashboard';
        } else {
          return '/home';
        }
      }

      // 4. Cold-start deep linking: if arriving at default landing routes, consume any pending notification route
      if (matchedLocation == '/home' || matchedLocation == '/restaurant/dashboard') {
        final pendingRoute = ref.read(notificationNavigationHandlerProvider).consumePendingRoute();
        if (pendingRoute != null && pendingRoute.isNotEmpty && pendingRoute != matchedLocation) {
          return pendingRoute;
        }
      }

      // 5. Role-based entry redirect: Restaurant Owners and Admins accessing /home
      if (matchedLocation == '/home') {
        if (role.isRestaurant) {
          return '/restaurant/dashboard';
        } else if (role.isAdmin) {
          return '/admin/dashboard';
        }
      }

      // 6. RBAC Route Guards for Protected Portals
      final isRestaurantManagementRoute =
          matchedLocation == '/restaurant/dashboard' ||
          matchedLocation == '/restaurant/menu' ||
          matchedLocation == '/restaurant/orders' ||
          matchedLocation == '/restaurant/settings';

      final isAdminRoute = matchedLocation.startsWith('/admin');

      // Customers cannot access restaurant management routes
      if (isRestaurantManagementRoute && !role.isRestaurant && !role.isAdmin) {
        return '/home';
      }

      // Non-admin roles cannot access admin routes
      if (isAdminRoute && !role.isAdmin) {
        return role.isRestaurant ? '/restaurant/dashboard' : '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success/:orderId',
        name: 'orderSuccess',
        builder: (context, state) => OrderSuccessScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) {
          final isSelectMode = state.uri.queryParameters['select'] == 'true';
          return AddressListScreen(isSelectMode: isSelectMode);
        },
      ),
      GoRoute(
        path: '/addresses/add',
        name: 'addAddress',
        builder: (context, state) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/addresses/edit/:addressId',
        name: 'editAddress',
        builder: (context, state) => AddEditAddressScreen(
          addressId: state.pathParameters['addressId'],
        ),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'orderDetails',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/restaurant/dashboard',
        name: 'restaurantDashboard',
        builder: (context, state) => const RestaurantDashboardScreen(),
      ),
      GoRoute(
        path: '/restaurant/menu',
        name: 'restaurantMenu',
        builder: (context, state) => const RestaurantMenuScreen(),
      ),
      GoRoute(
        path: '/restaurant/orders',
        name: 'restaurantOrders',
        builder: (context, state) => const RestaurantOrdersScreen(),
      ),
      GoRoute(
        path: '/restaurant/settings',
        name: 'restaurantSettings',
        builder: (context, state) => const RestaurantSettingsScreen(),
      ),
      GoRoute(
        path: '/restaurant/:restaurantId',
        name: 'restaurantDetails',
        builder: (context, state) => RestaurantDetailsScreen(
          restaurantId: state.pathParameters['restaurantId']!,
        ),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
