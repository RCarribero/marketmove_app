import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/widgets/summary_card.dart';

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
                    SummaryCard(
                      title: 'Total Ventas',
                      amount: totalVentas,
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    SummaryCard(
                      title: 'Total Gastos',
                      amount: totalGastos,
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    SummaryCard(
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
