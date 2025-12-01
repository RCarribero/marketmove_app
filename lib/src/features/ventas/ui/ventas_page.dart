import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/models/sale_model.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VentasProvider>().loadSales());
  }

  void _showSaleDialog([Sale? sale]) {
    final totalController = TextEditingController(
      text: sale?.total.toString() ?? '',
    );
    final customerController = TextEditingController(
      text: sale?.customerName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sale == null ? 'Nueva Venta' : 'Editar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalController,
              decoration: const InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: customerController,
              decoration: const InputDecoration(labelText: 'Cliente'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final newSale = Sale(
                id: sale?.id ?? 0,
                total: double.tryParse(totalController.text) ?? 0,
                date: sale?.date ?? DateTime.now(),
                customerName: customerController.text.isEmpty
                    ? null
                    : customerController.text,
                items: sale?.items ?? [],
              );

              if (sale == null) {
                await context.read<VentasProvider>().addSale(newSale);
              } else {
                await context.read<VentasProvider>().updateSale(newSale);
              }

              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: Consumer<VentasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.sales.isEmpty) {
            return const Center(child: Text('No hay ventas registradas'));
          }

          return ListView.builder(
            itemCount: provider.sales.length,
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              return ListTile(
                title: Text('Venta #${sale.id}'),
                subtitle: Text(sale.customerName ?? 'Cliente General'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\$${sale.total.toStringAsFixed(2)}'),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showSaleDialog(sale),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('¿Eliminar esta venta?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          await context.read<VentasProvider>().deleteSale(
                            sale.id,
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSaleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
