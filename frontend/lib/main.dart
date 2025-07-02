import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize API service
    ApiService().initialize();

    runApp(const JivhalaMotorsApp());
  } catch (e) {
    // Handle initialization errors
    debugPrint('Error during app initialization: $e');
    // Run with minimal dependencies in case of error
    runApp(const JivhalaMotorsRecoveryApp());
  }
}

/// A minimal version of the app that runs when initialization fails
class JivhalaMotorsRecoveryApp extends StatelessWidget {
  const JivhalaMotorsRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jivhala Motors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Jivhala Motors',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Loading app resources...'),
              const SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class JivhalaMotorsApp extends StatelessWidget {
  const JivhalaMotorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Jivhala Motors',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: GoogleFonts.poppinsTextTheme(
                AppTheme.lightTheme.textTheme,
              ),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: GoogleFonts.poppinsTextTheme(
                AppTheme.darkTheme.textTheme,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
