import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/field_management.dart';
import '../screens/user/user_home.dart';
import '../screens/auth/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth Routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Admin Routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/fields',
      builder: (context, state) => const FieldManagementScreen(),
    ),

    // User Routes
    GoRoute(path: '/user', builder: (context, state) => const UserHomeScreen()),
  ],
);
