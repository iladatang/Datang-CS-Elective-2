import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('home screen shows products, adds items to cart, and confirms checkout', (tester) async {
    await tester.pumpWidget(const ShoeApp());
    await tester.pumpAndSettle();

    expect(find.text('Nike Shop'), findsOneWidget);
    expect(find.text('Featured Picks'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Nike Air Max Pulse'), findsOneWidget);

    await tester.tap(find.text('Nike Air Max Pulse'));
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);

    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    expect(find.text('View Cart'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('View Cart'), 100);
    await tester.tap(find.text('View Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Qty: 1'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Qty: 2'), findsOneWidget);
    expect(find.text('₱13180.00'), findsWidgets);

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout confirmed'), findsOneWidget);
  });
}
