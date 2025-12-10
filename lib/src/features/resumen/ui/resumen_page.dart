import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/providers/products_provider.dart';
import '../../../shared/theme/colors.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({super.key});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedPeriod = 'month';
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VentasProvider>().loadSales();
        context.read<GastosProvider>().loadExpenses();
        context.read<ProductsProvider>().loadProducts();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Resumen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
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
                          color: Colors.white.withOpacity(0.1),
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
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 60,
                      child: Icon(
                        Icons.analytics,
                        size: 80,
                        color: Colors.white.withOpacity(0.15),
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

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child:
                  Consumer3<VentasProvider, GastosProvider, ProductsProvider>(
                    builder:
                        (
                          context,
                          ventasProvider,
                          gastosProvider,
                          productsProvider,
                          _,
                        ) {
                          if (ventasProvider.isLoading ||
                              gastosProvider.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(100),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final now = DateTime.now();
                          final sales = ventasProvider.sales;
                          final expenses = gastosProvider.expenses;

                          // Filter by period
                          final filteredSales = _filterByPeriod(sales, now);
                          final filteredExpenses = _filterByPeriod(
                            expenses,
                            now,
                          );

                          final totalSales = filteredSales.fold(
                            0.0,
                            (sum, s) => sum + s.total,
                          );
                          final totalExpenses = filteredExpenses.fold(
                            0.0,
                            (sum, e) => sum + e.amount,
                          );
                          final balance = totalSales - totalExpenses;

                          // Monthly comparison
                          final monthlyData = _getMonthlyComparison(
                            sales,
                            expenses,
                            now,
                          );

                          // Expense categories
                          final expenseCategories = _getExpenseCategories(
                            filteredExpenses,
                          );

                          // Top products
                          final topProducts = productsProvider.products
                              .take(5)
                              .toList();

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Period Selector
                                _buildPeriodSelector(isDark),
                                const SizedBox(height: 20),

                                // Summary Cards
                                _buildSummaryCards(
                                  totalSales,
                                  totalExpenses,
                                  balance,
                                  currencyFormat,
                                  isDark,
                                ),
                                const SizedBox(height: 28),

                                // Monthly Chart
                                _buildSectionTitle(
                                  'Comparativa Mensual',
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildMonthlyChart(monthlyData, isDark),
                                const SizedBox(height: 28),

                                // Expense Categories
                                if (expenseCategories.isNotEmpty) ...[
                                  _buildSectionTitle(
                                    'Distribucion de Gastos',
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildExpensesPieChart(
                                    expenseCategories,
                                    isDark,
                                    currencyFormat,
                                  ),
                                  const SizedBox(height: 28),
                                ],

                                // Quick Stats
                                _buildSectionTitle(
                                  'Estadisticas Rapidas',
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildQuickStats(
                                  sales.length,
                                  expenses.length,
                                  productsProvider.products.length,
                                  isDark,
                                ),
                                const SizedBox(height: 28),

                                // Top Products
                                if (topProducts.isNotEmpty) ...[
                                  _buildSectionTitle(
                                    'Productos Destacados',
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTopProducts(
                                    topProducts,
                                    currencyFormat,
                                    isDark,
                                  ),
                                ],
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterByPeriod(List<dynamic> items, DateTime now) {
    switch (_selectedPeriod) {
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return items.where((i) => i.date.isAfter(startOfWeek)).toList();
      case 'month':
        return items
            .where((i) => i.date.year == now.year && i.date.month == now.month)
            .toList();
      case 'year':
        return items.where((i) => i.date.year == now.year).toList();
      default:
        return items;
    }
  }

  List<Map<String, dynamic>> _getMonthlyComparison(
    List<dynamic> sales,
    List<dynamic> expenses,
    DateTime now,
  ) {
    final data = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthSales = sales
          .where(
            (s) => s.date.year == month.year && s.date.month == month.month,
          )
          .fold(0.0, (sum, s) => sum + s.total);
      final monthExpenses = expenses
          .where(
            (e) => e.date.year == month.year && e.date.month == month.month,
          )
          .fold(0.0, (sum, e) => sum + e.amount);
      data.add({
        'month': DateFormat('MMM').format(month),
        'sales': monthSales,
        'expenses': monthExpenses,
      });
    }
    return data;
  }

  Map<String, double> _getExpenseCategories(List<dynamic> expenses) {
    final categories = <String, double>{};
    for (final expense in expenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Otros';
      categories[category] = (categories[category] ?? 0) + expense.amount;
    }
    return categories;
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Semana',
            isSelected: _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
          _PeriodButton(
            label: 'Mes',
            isSelected: _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
          _PeriodButton(
            label: 'Ano',
            isSelected: _selectedPeriod == 'year',
            onTap: () => setState(() => _selectedPeriod = 'year'),
          ),
          _PeriodButton(
            label: 'Todo',
            isSelected: _selectedPeriod == 'all',
            onTap: () => setState(() => _selectedPeriod = 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSummaryCards(
    double totalSales,
    double totalExpenses,
    double balance,
    NumberFormat currencyFormat,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Ingresos',
                value: currencyFormat.format(totalSales),
                icon: Icons.trending_up,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Gastos',
                value: currencyFormat.format(totalExpenses),
                icon: Icons.trending_down,
                color: AppColors.error,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Balance Neto',
          value: currencyFormat.format(balance),
          icon: Icons.account_balance_wallet,
          color: balance >= 0 ? AppColors.primary : AppColors.error,
          isDark: isDark,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(List<Map<String, dynamic>> data, bool isDark) {
    if (data.isEmpty) return const SizedBox();

    final maxSales = data
        .map((d) => d['sales'] as double)
        .reduce((a, b) => a > b ? a : b);
    final maxExpenses = data
        .map((d) => d['expenses'] as double)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxSales > maxExpenses ? maxSales : maxExpenses) * 1.2;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendItem(label: 'Ingresos', color: AppColors.success),
              const SizedBox(width: 16),
              _LegendItem(label: 'Gastos', color: AppColors.error),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 100 : maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDark ? AppColors.darkSurface : Colors.white,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()]['month'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index]['sales'],
                        color: AppColors.success,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: data[index]['expenses'],
                        color: AppColors.error,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesPieChart(
    Map<String, double> data,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList();
    final colors = AppColors.chartColors;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: List.generate(entries.length, (i) {
                  final isTouched = i == _touchedPieIndex;
                  return PieChartSectionData(
                    value: entries[i].value,
                    title: isTouched
                        ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%'
                        : '',
                    color: colors[i % colors.length],
                    radius: isTouched ? 45.0 : 35.0,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                entries.length > 5 ? 5 : entries.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    int salesCount,
    int expensesCount,
    int productsCount,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatItem(
            label: 'Ventas',
            value: salesCount.toString(),
            icon: Icons.shopping_cart,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatItem(
            label: 'Gastos',
            value: expensesCount.toString(),
            icon: Icons.receipt,
            color: AppColors.error,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatItem(
            label: 'Productos',
            value: productsCount.toString(),
            icon: Icons.inventory_2,
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProducts(
    List<dynamic> products,
    NumberFormat currencyFormat,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(products.length, (index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < products.length - 1 ? 12 : 0,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLarge ? 14 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isLarge ? 28 : 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLarge ? 14 : 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _QuickStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
