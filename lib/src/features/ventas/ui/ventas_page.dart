import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/models/sale_model.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/swipe_tutorial_overlay.dart';

class VentasPage extends StatefulWidget {
  final String? saleId;

  const VentasPage({super.key, this.saleId});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final ScrollController _scrollController = ScrollController();
  int? _highlightedIndex;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VentasProvider>().loadSales();

        if (widget.saleId != null) {
          _scrollToSale();
        }
      }
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('ventas_swipe_tutorial') ?? false;
    if (!hasSeenTutorial && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ventas_swipe_tutorial', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSale() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final sales = context.read<VentasProvider>().sales;
      final saleIdInt = int.tryParse(widget.saleId ?? '');

      if (saleIdInt != null) {
        final index = sales.indexWhere((s) => s.id == saleIdInt);
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

  void _showSaleDialog([Sale? sale]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalController = TextEditingController(
      text: sale?.total.toString() ?? '',
    );
    final customerController = TextEditingController(
      text: sale?.customerName ?? '',
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
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      sale == null ? Icons.add_shopping_cart : Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    sale == null ? 'Nueva Venta' : 'Editar Venta',
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
                controller: totalController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Total',
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
                controller: customerController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: const Icon(Icons.person_outline),
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
                      final newSale = Sale(
                        id: sale?.id,
                        total: double.tryParse(totalController.text) ?? 0,
                        date: sale?.date ?? DateTime.now(),
                        customerName: customerController.text.isEmpty
                            ? null
                            : customerController.text,
                        items: [],
                      );

                      if (sale == null) {
                        await context.read<VentasProvider>().addSale(newSale);
                      } else {
                        await context.read<VentasProvider>().updateSale(
                          newSale,
                        );
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(sale == null ? 'Crear' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSale(Sale sale) async {
    if (sale.id == null) return;
    await context.read<VentasProvider>().deleteSale(sale.id!);
    if (mounted) {
      ToastService.success(context, 'Venta eliminada');
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
                    'Ventas',
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
                        colors: isDark
                            ? [AppColors.primaryDark, AppColors.primary]
                            : [AppColors.primary, AppColors.secondary],
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
                            Icons.shopping_bag,
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

              // Sales List
              Consumer<VentasProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.sales.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay ventas registradas',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primera venta',
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
                        final sale = provider.sales[index];
                        final isHighlighted = _highlightedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('sale_${sale.id}'),
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
                              return await _showDeleteConfirmation('venta');
                            },
                            onDismissed: (direction) {
                              _deleteSale(sale);
                            },
                            child: _SaleCard(
                              sale: sale,
                              currencyFormat: currencyFormat,
                              dateFormat: dateFormat,
                              isHighlighted: isHighlighted,
                              isDark: isDark,
                              onTap: () => _showSaleDialog(sale),
                            ),
                          ),
                        );
                      }, childCount: provider.sales.length),
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
        onPressed: () => _showSaleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return SwipeTutorialOverlay(
      onDismiss: _dismissTutorial,
      accentColor: AppColors.primary,
    );
  }

  Future<bool> _showDeleteConfirmation(String itemType) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Eliminar $itemType'),
            content: Text('Estas seguro de eliminar esta $itemType?'),
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

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final bool isHighlighted;
  final bool isDark;
  final VoidCallback onTap;

  const _SaleCard({
    required this.sale,
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
          color: isHighlighted ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppColors.primary.withValues(alpha: 0.3)
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
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
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
                        sale.customerName ?? 'Cliente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(sale.date),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(sale.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.success,
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
