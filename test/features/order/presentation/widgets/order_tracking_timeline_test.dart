import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/presentation/widgets/order_tracking_timeline.dart';

void main() {
  group('OrderTrackingTimeline Widget Tests', () {
    Widget createTestWidget(OrderStatus status) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: OrderTrackingTimeline(status: status),
          ),
        ),
      );
    }

    testWidgets('renders all 5 timeline stages for pending status with CURRENT chip', (tester) async {
      await tester.pumpWidget(createTestWidget(OrderStatus.pending));
      await tester.pumpAndSettle();

      expect(find.text('Live Order Progress'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Preparing Food'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Order Delivered'), findsOneWidget);
      expect(find.text('CURRENT'), findsOneWidget);
    });

    testWidgets('renders timeline with Out for Delivery status', (tester) async {
      await tester.pumpWidget(createTestWidget(OrderStatus.outForDelivery));
      await tester.pumpAndSettle();

      expect(find.text('Live Order Progress'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsWidgets);
      expect(find.text('CURRENT'), findsOneWidget);
    });

    testWidgets('renders distinct cancelled card when status is cancelled', (tester) async {
      await tester.pumpWidget(createTestWidget(OrderStatus.cancelled));
      await tester.pumpAndSettle();

      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.textContaining('This order was cancelled'), findsOneWidget);
      expect(find.text('Order Placed'), findsNothing);
    });
  });
}
