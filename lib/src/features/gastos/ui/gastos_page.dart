import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/models/expense_model.dart';

class GastosPage extends StatefulWidget {
  final String? userId;
  const GastosPage({super.key, this.userId});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<GastosProvider>().loadExpenses(userId: widget.userId),
    );
  }

  void _showExpenseDialog([Expense? expense]) {
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    final descController = TextEditingController(
      text: expense?.description ?? '',
    );
    final categoryController = TextEditingController(
      text: expense?.category ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense == null ? 'Nuevo Gasto' : 'Editar Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final newExpense = Expense(
                id: expense?.id ?? 0,
                amount: double.tryParse(amountController.text) ?? 0,
                description: descController.text,
                category: categoryController.text,
                date: expense?.date ?? DateTime.now(),
              );

              if (expense == null) {
                await context.read<GastosProvider>().addExpense(newExpense);
              } else {
                await context.read<GastosProvider>().updateExpense(newExpense);
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
      appBar: AppBar(title: const Text('Gastos')),
      body: Consumer<GastosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.expenses.isEmpty) {
            return const Center(child: Text('No hay gastos registrados'));
          }

          return ListView.builder(
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ListTile(
                title: Text(expense.description),
                subtitle: Text(expense.category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\$${expense.amount.toStringAsFixed(2)}'),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showExpenseDialog(expense),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('¿Eliminar este gasto?'),
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
                          await context.read<GastosProvider>().deleteExpense(
                            expense.id,
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
        onPressed: () => _showExpenseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
