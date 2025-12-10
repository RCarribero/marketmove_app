import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/expandable_fab.dart';
import 'dashboard_view.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final userEmail = authProvider.user?.email ?? 'Usuario';
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MarketMove',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.primaryDark, AppColors.primary]
                      : [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 29,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.primary.withOpacity(0.1),
                      child: Text(
                        userEmail[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MarketMove',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.point_of_sale,
                    label: 'Ventas',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/ventas');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.attach_money,
                    label: 'Gastos',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/gastos');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/productos');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart,
                    label: 'Resumen',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/resumen');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.assessment,
                    label: 'Reportes',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/reportes');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.insights,
                    label: 'Reportes Avanzados',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/reportes-avanzados');
                    },
                    isDark: isDark,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _DrawerItem(
                    icon: isDark ? Icons.light_mode : Icons.dark_mode,
                    label: isDark ? 'Modo Claro' : 'Modo Oscuro',
                    onTap: () => themeProvider.toggleTheme(),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _DrawerItem(
                icon: Icons.logout,
                label: 'Cerrar Sesion',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().signOut();
                  context.go('/login');
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
      body: const DashboardView(),
      floatingActionButton: const ExpandableFab(),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? color;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.color,
    required this.isDark,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeColor =
        widget.color ??
        (widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final activeColor = widget.isDark
        ? AppColors.primaryLight
        : AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? activeColor.withOpacity(0.1)
              : _isHovered
              ? activeColor.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.icon,
              color: widget.isSelected ? activeColor : themeColor,
              size: 22,
            ),
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? activeColor : themeColor,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          onTap: widget.onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          dense: true,
        ),
      ),
    );
  }
}
