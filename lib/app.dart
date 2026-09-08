import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/shoe_products.dart';
import 'models/shoe_product.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';

class ShoeApp extends StatefulWidget {
  const ShoeApp({super.key});

  @override
  State<ShoeApp> createState() => _ShoeAppState();
}

class _ShoeAppState extends State<ShoeApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final Map<String, int> _cart = {};

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _changeQuantity(String productId, int delta) {
    setState(() {
      final current = _cart[productId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId] = next;
      }
    });
  }

  int _getCartCount() {
    return _cart.values.fold<int>(0, (sum, count) => sum + count);
  }

  List<CartItem> _getCartItems() {
    return _cart.entries.map((entry) {
      final product = products.firstWhere(
        (item) => item.id == entry.key,
        orElse: () => products.first,
      );
      return CartItem(
        product: product,
        quantity: entry.value,
        onIncrease: () => _changeQuantity(entry.key, 1),
        onDecrease: () => _changeQuantity(entry.key, -1),
      );
    }).toList();
  }

  double _getCartTotal() {
    return _getCartItems().fold<double>(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void _checkout(BuildContext context) {
    final checkoutItems = _getCartItems();
    final checkoutTotal = _getCartTotal();
    final checkoutCount = _getCartCount();

    setState(() {
      _cart.clear();
    });

    context.go(
      '/checkout',
      extra: {
        'items': checkoutItems,
        'total': checkoutTotal,
        'count': checkoutCount,
      },
    );
  }

  ThemeData _buildTheme(bool isDark) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final scheme = isDark
        ? const ColorScheme.dark(primary: Color(0xFFE53935), surface: Color(0xFF121212))
        : const ColorScheme.light(primary: Color(0xFFE53935), surface: Color(0xFFF5F5F5));

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1B1B1B) : const Color(0xFFFFFFFF),
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(
          onToggleTheme: _toggleTheme,
          onViewCart: () => context.go('/cart'),
          cartCount: _getCartCount(),
        ),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final product = products.firstWhere(
            (item) => item.id == productId,
            orElse: () => products.first,
          );

          return ProductDetailScreen(
            product: product,
            onAddToCart: () {
              _addToCart(product.id);
            },
            onViewCart: () => context.go('/cart'),
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartScreen(
          cartItems: _getCartItems(),
          total: _getCartTotal(),
          onCheckout: () => _checkout(context),
          onContinueShopping: () => context.go('/'),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          final total = (extra['total'] as num?)?.toDouble() ?? 0.0;
          final count = extra['count'] as int? ?? 0;

          return CheckoutConfirmationScreen(
            total: total,
            itemCount: count,
            onBackHome: () => context.go('/'),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nike Shop',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      routerConfig: _router,
    );
  }
}
