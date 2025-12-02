import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/field_management.dart';
import 'screens/admin/booking_management.dart';
import 'screens/user/user_home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BookingProvider())],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sport Field App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: _router,
    );
  }
}
