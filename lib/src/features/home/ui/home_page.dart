import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MarketMove Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MenuButton(
              icon: Icons.point_of_sale,
              label: 'Ventas',
              onTap: () => context.push('/ventas'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.attach_money,
              label: 'Gastos',
              onTap: () => context.push('/gastos'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.inventory,
              label: 'Productos',
              onTap: () => context.push('/productos'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.bar_chart,
              label: 'Resumen',
              onTap: () => context.push('/resumen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 32),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
