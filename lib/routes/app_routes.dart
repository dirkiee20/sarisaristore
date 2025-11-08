import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/products_tab/products.dart';
import '../presentation/add_product_screen/add_product_screen.dart';
import '../presentation/stock_management_tab/stock_management_tab.dart';
import '../presentation/analytics_tab/analytics_tab.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash';
  static const String productsTab = '/products-tab';
  static const String addProduct = '/add-product-screen';
  static const String stockManagementTab = '/stock-management-tab';
  static const String analyticsTab = '/analytics-tab';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    productsTab: (context) => const ProductsTab(),
    addProduct: (context) => const AddProductScreen(),
    stockManagementTab: (context) => const StockManagementTab(),
    analyticsTab: (context) => const AnalyticsTab(),
    // TODO: Add your other routes here
  };
}
