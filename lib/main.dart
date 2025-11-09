import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../data/database/database_initializer.dart';
import '../services/demo_mode_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  try {
    final dbInitializer = DatabaseInitializer();
    await dbInitializer.initialize();
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DemoModeService _demoModeService = DemoModeService();

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return ListenableBuilder(
        listenable: _demoModeService,
        builder: (context, child) {
          return MaterialApp(
            title:
                'sarisari_pro${_demoModeService.isDemoMode ? " (Demo)" : ""}',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
            // 🚨 END CRITICAL SECTION
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.initial,
          );
        },
      );
    });
  }
}
