import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// Import providers
import 'providers/booking_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/field_management.dart';
import 'screens/admin/booking_management.dart';
import 'screens/user/user_home.dart';
// Import test screen
import 'database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ RESET DATABASE untuk fix login
  try {
    final db = DatabaseHelper.instance;
    String path = join(await getDatabasesPath(), 'sport_field.db');
    await deleteDatabase(path);
    print('🗑️ Database reset successfully');
  } catch (e) {
    print('❌ Error resetting database: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/user', builder: (context, state) => const UserHomeScreen()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/fields',
      builder: (context, state) => const FieldManagementScreen(),
    ),
    GoRoute(
      path: '/admin/bookings',
      builder: (context, state) => const BookingManagementScreen(),
    ),
    // ✅ ADD:  Test route
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sport Field App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: _router,
    );
  }
}
