import 'package:go_router/go_router.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';
import 'features/ventas/ui/ventas_page.dart';
import 'features/gastos/ui/gastos_page.dart';
import 'features/productos/ui/productos_page.dart';
import 'features/resumen/ui/resumen_page.dart';
import 'features/home/ui/home_page.dart';
import 'features/admin/ui/admin_users_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/ventas', builder: (context, state) => const VentasPage()),
    GoRoute(
      path: '/gastos',
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId'];
        return GastosPage(userId: userId);
      },
    ),
    GoRoute(
      path: '/productos',
      builder: (context, state) => const ProductosPage(),
    ),
    GoRoute(path: '/resumen', builder: (context, state) => const ResumenPage()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminUsersPage(),
    ),
  ],
);
