import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';
import 'features/ventas/ui/ventas_page.dart';
import 'features/gastos/ui/gastos_page.dart';
import 'features/productos/ui/productos_page.dart';
import 'features/resumen/ui/resumen_page.dart';
import 'features/reports/ui/reports_page.dart';
import 'features/reports/ui/advanced_reports_page.dart';
import 'features/pricing/ui/pricing_page.dart';
import 'features/profile/ui/profile_page.dart';
import 'features/home/ui/home_page.dart';
import 'features/home/ui/user_dashboard_page.dart';
import 'features/admin/ui/admin_users_page.dart';
import 'features/splash/splash_screen.dart';

// Custom page transition
CustomTransitionPage<T> _buildPageWithTransition<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// Fade transition for splash
CustomTransitionPage<T> _buildFadeTransition<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildFadeTransition(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _buildFadeTransition(state, const LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const RegisterPage()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) =>
          _buildFadeTransition(state, const HomePage()),
    ),
    GoRoute(
      path: '/user-dashboard',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const UserDashboardPage()),
    ),
    GoRoute(
      path: '/ventas',
      pageBuilder: (context, state) {
        final saleId = state.uri.queryParameters['saleId'];
        return _buildPageWithTransition(state, VentasPage(saleId: saleId));
      },
    ),
    GoRoute(
      path: '/gastos',
      pageBuilder: (context, state) {
        final userId = state.uri.queryParameters['userId'];
        final expenseId = state.uri.queryParameters['expenseId'];
        return _buildPageWithTransition(
          state,
          GastosPage(userId: userId, expenseId: expenseId),
        );
      },
    ),
    GoRoute(
      path: '/productos',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const ProductosPage()),
    ),
    GoRoute(
      path: '/resumen',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const ResumenPage()),
    ),
    GoRoute(
      path: '/reportes',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const ReportsPage()),
    ),
    GoRoute(
      path: '/reportes-avanzados',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const AdvancedReportsPage()),
    ),
    GoRoute(
      path: '/pricing',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const PricingPage()),
    ),
    GoRoute(
      path: '/perfil',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const ProfilePage()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const AdminUsersPage()),
    ),
  ],
);
