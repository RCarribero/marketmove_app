import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';
import 'features/auth/ui/plan_selection_page.dart';
import 'features/ventas/ui/ventas_page.dart';
import 'features/gastos/ui/gastos_page.dart';
import 'features/productos/ui/productos_page.dart';
import 'features/resumen/ui/resumen_page.dart';
import 'features/reports/ui/reports_page.dart';
import 'features/reports/ui/advanced_reports_page.dart';
import 'features/pricing/screens/pricing_screen.dart';
import 'features/profile/ui/profile_page.dart';
import 'features/home/ui/home_page.dart';
import 'features/home/ui/user_dashboard_page.dart';
import 'features/admin/ui/admin_users_page.dart';
import 'features/splash/splash_screen.dart';
import 'features/subscription_guard.dart';
import 'features/chat/ui/chat_page.dart';

/// Tipos de transicion disponibles para las rutas
enum PageTransitionType { slide, fade }

/// Construye una pagina con transicion personalizada
/// [type] - Tipo de transicion (slide o fade)
/// [durationMs] - Duracion de la transicion en milisegundos
CustomTransitionPage<T> _buildPage<T>(
  GoRouterState state,
  Widget child, {
  PageTransitionType type = PageTransitionType.slide,
  int durationMs = 300,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: durationMs),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return switch (type) {
        PageTransitionType.fade => FadeTransition(
          opacity: animation,
          child: child,
        ),
        PageTransitionType.slide => SlideTransition(
          position: Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: child,
        ),
      };
    },
  );
}

/// Verifica si el usuario tiene sesion activa para redireccionar
String? _redirectLogic(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isAuthenticated = session != null;
  final isGoingToAuth =
      state.matchedLocation == '/login' || state.matchedLocation == '/register';

  // En web: si el usuario esta autenticado y va a pricing o login, redirigir a home
  if (kIsWeb &&
      isAuthenticated &&
      (isGoingToAuth || state.matchedLocation == '/')) {
    return '/home';
  }

  return null; // No redirigir
}

final router = GoRouter(
  initialLocation: '/',
  redirect: _redirectLogic,
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPage(
        state,
        // En web muestra pricing, en movil muestra splash
        kIsWeb ? const PricingScreen() : const SplashScreen(),
        type: PageTransitionType.fade,
        durationMs: 500,
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _buildPage(state, const LoginPage(), type: PageTransitionType.fade),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildPage(state, const RegisterPage()),
    ),
    GoRoute(
      path: '/plan-selection',
      pageBuilder: (context, state) => _buildPage(
        state,
        const PlanSelectionPage(),
        type: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPage(
        state,
        const SubscriptionGuard(child: HomePage()),
        type: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: '/user-dashboard',
      pageBuilder: (context, state) => _buildPage(
        state,
        const SubscriptionGuard(child: UserDashboardPage()),
      ),
    ),
    GoRoute(
      path: '/ventas',
      pageBuilder: (context, state) {
        final saleId = state.uri.queryParameters['saleId'];
        return _buildPage(
          state,
          SubscriptionGuard(child: VentasPage(saleId: saleId)),
        );
      },
    ),
    GoRoute(
      path: '/gastos',
      pageBuilder: (context, state) {
        final userId = state.uri.queryParameters['userId'];
        final expenseId = state.uri.queryParameters['expenseId'];
        return _buildPage(
          state,
          SubscriptionGuard(
            child: GastosPage(userId: userId, expenseId: expenseId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/productos',
      pageBuilder: (context, state) =>
          _buildPage(state, const SubscriptionGuard(child: ProductosPage())),
    ),
    GoRoute(
      path: '/resumen',
      pageBuilder: (context, state) =>
          _buildPage(state, const SubscriptionGuard(child: ResumenPage())),
    ),
    GoRoute(
      path: '/reportes',
      pageBuilder: (context, state) =>
          _buildPage(state, const SubscriptionGuard(child: ReportsPage())),
    ),
    GoRoute(
      path: '/reportes-avanzados',
      pageBuilder: (context, state) => _buildPage(
        state,
        const SubscriptionGuard(child: AdvancedReportsPage()),
      ),
    ),
    GoRoute(
      path: '/pricing',
      pageBuilder: (context, state) => _buildPage(state, const PricingScreen()),
    ),
    GoRoute(
      path: '/perfil',
      pageBuilder: (context, state) => _buildPage(state, const ProfilePage()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) =>
          _buildPage(state, const AdminUsersPage()),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) =>
          _buildPage(state, const SubscriptionGuard(child: ChatPage())),
    ),
  ],
);
