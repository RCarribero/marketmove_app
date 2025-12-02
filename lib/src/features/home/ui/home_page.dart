import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/colors.dart';
import 'dashboard_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final userEmail = authProvider.user?.email ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(title: const Text('MarketMove')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('MarketMove'),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Ventas'),
              onTap: () {
                Navigator.pop(context);
                context.push('/ventas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Gastos'),
              onTap: () {
                Navigator.pop(context);
                context.push('/gastos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Productos'),
              onTap: () {
                Navigator.pop(context);
                context.push('/productos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Resumen'),
              onTap: () {
                Navigator.pop(context);
                context.push('/resumen');
              },
            ),
            if (isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administrar Usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin');
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().signOut();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: const DashboardView(),
    );
  }
}
