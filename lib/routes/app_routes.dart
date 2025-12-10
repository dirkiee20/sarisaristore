import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/products_tab/products.dart';
import '../presentation/add_product_screen/add_product_screen.dart';
import '../presentation/edit_product_screen/edit_product_screen.dart';
import '../presentation/stock_management_tab/stock_management_tab.dart';
import '../presentation/analytics_tab/analytics_tab.dart';
import '../presentation/checkout_screen/checkout_screen.dart';
import '../presentation/expenses_screen/expenses_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash';
  static const String productsTab = '/products-tab';
  static const String addProduct = '/add-product-screen';
  static const String editProduct = '/edit-product';
  static const String stockManagementTab = '/stock-management-tab';
  static const String analyticsTab = '/analytics-tab';
  static const String checkout = '/checkout';
  static const String expenses = '/expenses';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    productsTab: (context) => const ProductsTab(),
    addProduct: (context) => const AddProductScreen(),
    editProduct: (context) {
      final product =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (product == null) {
        // Fallback if no product provided
        return const ProductsTab();
      }
      return EditProductScreen(product: product);
    },
    stockManagementTab: (context) => const StockManagementTab(),
    analyticsTab: (context) => const AnalyticsTab(),
    expenses: (context) => const ExpensesScreen(),
    checkout: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final product = args['product'] as Map<String, dynamic>?;
        final cartOnly = args['cartOnly'] as bool? ?? false;
        final cartItems = args['cartItems'] as List<Map<String, dynamic>>?;
        return CheckoutScreen(
          product: product,
          cartOnly: cartOnly,
          cartItems: cartItems,
        );
      }
      return const CheckoutScreen(cartOnly: true);
    },
    // TODO: Add your other routes here
  };
}
