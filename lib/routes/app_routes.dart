import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/products_tab/products.dart';
import '../presentation/add_product_screen/add_product_screen.dart';
import '../presentation/edit_product_screen/edit_product_screen.dart';
import '../presentation/stock_management_tab/stock_management_tab.dart';
import '../presentation/analytics_tab/analytics_tab.dart';
import '../presentation/checkout_screen/checkout_screen.dart';

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
    checkout: (context) {
      final product =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CheckoutScreen(product: product);
    },
    // TODO: Add your other routes here
  };
}
