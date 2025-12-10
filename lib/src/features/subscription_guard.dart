import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_provider.dart';

/// Wrapper que verifica si el usuario tiene suscripcion activa
/// Si no, muestra pantalla de trial expirado
class SubscriptionGuard extends StatelessWidget {
  final Widget child;

  const SubscriptionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Mostrar loading mientras carga
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si no tiene suscripcion activa, mostrar pantalla de trial expirado
    if (!auth.hasActiveSubscription) {
      return const _SubscriptionExpiredScreen();
    }

    return child;
  }
}

class _SubscriptionExpiredScreen extends StatelessWidget {
  const _SubscriptionExpiredScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Tu prueba ha terminado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Para seguir usando MarketMove, elige un plan de pago.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.push('/pricing'),
                icon: const Icon(Icons.upgrade),
                label: const Text('Ver Planes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Cerrar sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
