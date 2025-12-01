import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({super.key});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VentasProvider>().loadSales();
      context.read<GastosProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Financiero',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Consumer2<VentasProvider, GastosProvider>(
              builder: (context, ventasProvider, gastosProvider, child) {
                if (ventasProvider.isLoading || gastosProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final totalVentas = ventasProvider.sales.fold<double>(
                  0,
                  (sum, sale) => sum + sale.total,
                );

                final totalGastos = gastosProvider.expenses.fold<double>(
                  0,
                  (sum, expense) => sum + expense.amount,
                );

                final balance = totalVentas - totalGastos;

                return Column(
                  children: [
                    _SummaryCard(
                      title: 'Total Ventas',
                      amount: totalVentas,
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _SummaryCard(
                      title: 'Total Gastos',
                      amount: totalGastos,
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _SummaryCard(
                      title: 'Balance',
                      amount: balance,
                      icon: Icons.account_balance_wallet,
                      color: balance >= 0 ? Colors.blue : Colors.orange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
