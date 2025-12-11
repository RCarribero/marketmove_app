import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/models/expense_model.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/swipe_tutorial_overlay.dart';

class GastosPage extends StatefulWidget {
  final String? userId;
  final String? expenseId;

  const GastosPage({super.key, this.userId, this.expenseId});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final ScrollController _scrollController = ScrollController();
  int? _highlightedIndex;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GastosProvider>().loadExpenses(userId: widget.userId);

        if (widget.expenseId != null) {
          _scrollToExpense();
        }
      }
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('gastos_swipe_tutorial') ?? false;
    if (!hasSeenTutorial && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gastos_swipe_tutorial', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToExpense() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final expenses = context.read<GastosProvider>().expenses;
      final expenseIdInt = int.tryParse(widget.expenseId ?? '');

      if (expenseIdInt != null) {
        final index = expenses.indexWhere((e) => e.id == expenseIdInt);
        if (index != -1 && mounted) {
          setState(() => _highlightedIndex = index);

          _scrollController.animateTo(
            index * 100.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _highlightedIndex = null);
            }
          });
        }
      }
    });
  }

  void _showExpenseDialog([Expense? expense]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    final categoryController = TextEditingController(
      text: expense?.category ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error,
                          AppColors.error.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      expense == null ? Icons.add_card : Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    expense == null ? 'Nuevo Gasto' : 'Editar Gasto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Descripcion',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      final newExpense = Expense(
                        id: expense?.id,
                        amount: double.tryParse(amountController.text) ?? 0,
                        description: descriptionController.text,
                        category: categoryController.text,
                        date: expense?.date ?? DateTime.now(),
                      );

                      if (expense == null) {
                        await context.read<GastosProvider>().addExpense(
                          newExpense,
                        );
                      } else {
                        await context.read<GastosProvider>().updateExpense(
                          newExpense,
                        );
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: Text(expense == null ? 'Crear' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    if (expense.id == null) return;
    await context.read<GastosProvider>().deleteExpense(expense.id!);
    if (mounted) {
      ToastService.success(context, 'Gasto eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Gastos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.error,
                          AppColors.error.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: 60,
                          child: Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),

              // Expenses List
              Consumer<GastosProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.expenses.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay gastos registrados',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Registra tu primer gasto',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextHint
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final expense = provider.expenses[index];
                        final isHighlighted = _highlightedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('expense_${expense.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await _showDeleteConfirmation('gasto');
                            },
                            onDismissed: (direction) {
                              _deleteExpense(expense);
                            },
                            child: _ExpenseCard(
                              expense: expense,
                              currencyFormat: currencyFormat,
                              dateFormat: dateFormat,
                              isHighlighted: isHighlighted,
                              isDark: isDark,
                              onTap: () => _showExpenseDialog(expense),
                            ),
                          ),
                        );
                      }, childCount: provider.expenses.length),
                    ),
                  );
                },
              ),
            ],
          ),

          // Tutorial Overlay
          if (_showTutorial) _buildTutorialOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return SwipeTutorialOverlay(
      onDismiss: _dismissTutorial,
      accentColor: AppColors.error,
    );
  }

  Future<bool> _showDeleteConfirmation(String itemType) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Eliminar $itemType'),
            content: Text('Estas seguro de eliminar este $itemType?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final bool isHighlighted;
  final bool isDark;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.expense,
    required this.currencyFormat,
    required this.dateFormat,
    required this.isHighlighted,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.error : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppColors.error.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: isHighlighted ? 12 : 8,
            spreadRadius: isHighlighted ? 2 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              expense.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateFormat.format(expense.date),
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey[600],
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${currencyFormat.format(expense.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
