import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/providers/products_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/skeleton_widgets.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Detectar si el usuario es admin
      final authProvider = context.read<AuthProvider>();
      final isAdmin = authProvider.isAdmin;

      await Future.wait([
        context.read<VentasProvider>().loadSales(isAdmin: isAdmin),
        context.read<GastosProvider>().loadExpenses(isAdmin: isAdmin),
        context.read<ProductsProvider>().loadProducts(isAdmin: isAdmin),
      ]);
      if (mounted) {
        setState(() => _isLoading = false);
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
    if (_isLoading) {
      return const DashboardSkeleton();
    }

    final authProvider = context.watch<AuthProvider>();
    final salesProvider = context.watch<VentasProvider>();
    final expensesProvider = context.watch<GastosProvider>();
    final productsProvider = context.watch<ProductsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userEmail = authProvider.user?.email ?? 'Usuario';
    final username = userEmail.split('@')[0];

    final now = DateTime.now();
    final sales = salesProvider.sales;
    final expenses = expensesProvider.expenses;

    // Today stats
    final salesToday = sales
        .where((s) => _isToday(s.date, now))
        .fold(0.0, (sum, item) => sum + item.total);

    final salesYesterday = sales
        .where((s) => _isYesterday(s.date, now))
        .fold(0.0, (sum, item) => sum + item.total);

    // Month stats
    final salesMonth = sales
        .where((s) => _isThisMonth(s.date, now))
        .fold(0.0, (sum, item) => sum + item.total);

    final salesLastMonth = sales
        .where((s) => _isLastMonth(s.date, now))
        .fold(0.0, (sum, item) => sum + item.total);

    final expensesMonth = expenses
        .where((e) => _isThisMonth(e.date, now))
        .fold(0.0, (sum, item) => sum + item.amount);

    final expensesLastMonth = expenses
        .where((e) => _isLastMonth(e.date, now))
        .fold(0.0, (sum, item) => sum + item.amount);

    // Net profit
    final profitMonth = salesMonth - expensesMonth;
    final profitLastMonth = salesLastMonth - expensesLastMonth;

    // Products and clients
    final totalProducts = productsProvider.products.length;
    final uniqueClients = sales
        .map((s) => s.customerName)
        .where((name) => name != null)
        .toSet()
        .length;

    // Weekly sales data
    final weeklySales = _getWeeklySalesData(sales, now);

    // Monthly trend (last 6 months)
    final monthlyTrend = _getMonthlyTrendData(sales, expenses, now);

    // Expenses by category
    final expensesByCategory = _getExpensesByCategory(expenses, now);

    // Recent Activity
    final recentActivity = [
      ...sales.map((s) => {'type': 'sale', 'data': s, 'date': s.date}),
      ...expenses.map((e) => {'type': 'expense', 'data': e, 'date': e.date}),
    ];
    recentActivity.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    final recentItems = recentActivity.take(5).toList();

    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return FadeTransition(
      opacity: _animationController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(username, isDark),
            const SizedBox(height: 24),

            // Quick Stats Row
            _buildQuickStatsRow(
              salesToday,
              salesYesterday,
              salesMonth,
              salesLastMonth,
              currencyFormat,
              isDark,
              context,
            ),
            const SizedBox(height: 24),

            // Main Metrics Cards
            _buildSectionTitle('Resumen del Mes', isDark),
            const SizedBox(height: 12),
            _buildMainMetricsGrid(
              salesMonth,
              expensesMonth,
              profitMonth,
              salesLastMonth,
              expensesLastMonth,
              profitLastMonth,
              totalProducts,
              uniqueClients,
              currencyFormat,
              isDark,
              context,
            ),
            const SizedBox(height: 28),

            // Charts Row
            _buildSectionTitle('Analisis', isDark),
            const SizedBox(height: 12),
            _buildChartsSection(
              weeklySales,
              monthlyTrend,
              expensesByCategory,
              isDark,
              currencyFormat,
            ),
            const SizedBox(height: 28),

            // Recent Activity
            _buildRecentActivitySection(recentItems, currencyFormat, isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Date helpers
  bool _isToday(DateTime date, DateTime now) =>
      date.year == now.year && date.month == now.month && date.day == now.day;

  bool _isYesterday(DateTime date, DateTime now) {
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  bool _isThisMonth(DateTime date, DateTime now) =>
      date.year == now.year && date.month == now.month;

  bool _isLastMonth(DateTime date, DateTime now) {
    final lastMonth = DateTime(now.year, now.month - 1);
    return date.year == lastMonth.year && date.month == lastMonth.month;
  }

  List<double> _getWeeklySalesData(List<dynamic> sales, DateTime now) {
    final weekData = List<double>.filled(7, 0.0);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (final sale in sales) {
      final diff = sale.date.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7) {
        weekData[diff] += sale.total;
      }
    }
    return weekData;
  }

  List<Map<String, dynamic>> _getMonthlyTrendData(
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

  Map<String, double> _getExpensesByCategory(
    List<dynamic> expenses,
    DateTime now,
  ) {
    final categories = <String, double>{};
    final monthExpenses = expenses.where((e) => _isThisMonth(e.date, now));
    for (final expense in monthExpenses) {
      final category = expense.description.split(' ').first;
      categories[category] = (categories[category] ?? 0) + expense.amount;
    }
    return categories;
  }

  double _calculatePercentChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  Widget _buildWelcomeSection(String username, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Buenos dias';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nightlight_outlined;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    greetingIcon,
                    size: 18,
                    color: isDark ? AppColors.warning : AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$greeting, ${username.isNotEmpty ? username[0].toUpperCase() + username.substring(1) : 'Usuario'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildQuickStatsRow(
    double salesToday,
    double salesYesterday,
    double salesMonth,
    double salesLastMonth,
    NumberFormat currencyFormat,
    bool isDark,
    BuildContext context,
  ) {
    final todayChange = _calculatePercentChange(salesToday, salesYesterday);
    final monthChange = _calculatePercentChange(salesMonth, salesLastMonth);

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            label: 'Ventas Hoy',
            value: currencyFormat.format(salesToday),
            change: todayChange,
            icon: Icons.today,
            isDark: isDark,
            onTap: () => context.push('/ventas'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            label: 'Ventas Mes',
            value: currencyFormat.format(salesMonth),
            change: monthChange,
            icon: Icons.calendar_month,
            isDark: isDark,
            onTap: () => context.push('/ventas'),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMetricsGrid(
    double salesMonth,
    double expensesMonth,
    double profitMonth,
    double salesLastMonth,
    double expensesLastMonth,
    double profitLastMonth,
    int totalProducts,
    int uniqueClients,
    NumberFormat currencyFormat,
    bool isDark,
    BuildContext context,
  ) {
    final salesChange = _calculatePercentChange(salesMonth, salesLastMonth);
    final expensesChange = _calculatePercentChange(
      expensesMonth,
      expensesLastMonth,
    );
    final profitChange = _calculatePercentChange(profitMonth, profitLastMonth);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Ingresos',
                value: currencyFormat.format(salesMonth),
                subtitle: 'Este mes',
                change: salesChange,
                icon: Icons.trending_up,
                color: AppColors.success,
                isDark: isDark,
                onTap: () => context.push('/ventas'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Gastos',
                value: currencyFormat.format(expensesMonth),
                subtitle: 'Este mes',
                change: expensesChange,
                icon: Icons.trending_down,
                color: AppColors.error,
                invertChangeColor: true,
                isDark: isDark,
                onTap: () => context.push('/gastos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Beneficio Neto',
                value: currencyFormat.format(profitMonth),
                subtitle: 'Este mes',
                change: profitChange,
                icon: Icons.account_balance_wallet,
                color: profitMonth >= 0 ? AppColors.primary : AppColors.error,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Productos',
                      value: totalProducts.toString(),
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.secondary,
                      isDark: isDark,
                      onTap: () => context.push('/productos'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Clientes',
                      value: uniqueClients.toString(),
                      icon: Icons.people_outline,
                      color: AppColors.warning,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(
    List<double> weeklySales,
    List<Map<String, dynamic>> monthlyTrend,
    Map<String, double> expensesByCategory,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    return Column(
      children: [
        // Weekly Sales Chart
        _buildChartCard(
          title: 'Ventas Semanales',
          isDark: isDark,
          child: SizedBox(
            height: 180,
            child: _buildWeeklyBarChart(weeklySales, isDark),
          ),
        ),
        const SizedBox(height: 16),

        // Monthly Trend Chart
        _buildChartCard(
          title: 'Tendencia Mensual',
          isDark: isDark,
          child: SizedBox(
            height: 180,
            child: _buildMonthlyLineChart(monthlyTrend, isDark),
          ),
        ),
        const SizedBox(height: 16),

        // Expenses by Category
        if (expensesByCategory.isNotEmpty)
          _buildChartCard(
            title: 'Gastos por Categoria',
            isDark: isDark,
            child: SizedBox(
              height: 200,
              child: _buildExpensesPieChart(
                expensesByCategory,
                isDark,
                currencyFormat,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(List<double> weeklySales, bool isDark) {
    final maxY = weeklySales.reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY == 0 ? 100.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: adjustedMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                isDark ? AppColors.darkSurface : AppColors.primary,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
              return BarTooltipItem(
                '${days[group.x]}\n\$${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                return Text(
                  days[value.toInt()],
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                );
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
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklySales[index],
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyLineChart(List<Map<String, dynamic>> data, bool isDark) {
    if (data.isEmpty) return const SizedBox();

    final maxSales = data
        .map((d) => d['sales'] as double)
        .reduce((a, b) => a > b ? a : b);
    final maxExpenses = data
        .map((d) => d['expenses'] as double)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxSales > maxExpenses ? maxSales : maxExpenses) * 1.2;

    return LineChart(
      LineChartData(
        maxY: maxY == 0 ? 100 : maxY,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Text(
                    data[value.toInt()]['month'],
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 10,
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Sales line
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]['sales']),
            ),
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.success,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
          // Expenses line
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]['expenses']),
            ),
            isCurved: true,
            color: AppColors.error,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.error,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                isDark ? AppColors.darkSurface : Colors.white,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final color = spot.barIndex == 0
                    ? AppColors.success
                    : AppColors.error;
                final label = spot.barIndex == 0 ? 'Ventas' : 'Gastos';
                return LineTooltipItem(
                  '$label: \$${spot.y.toStringAsFixed(0)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
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

    return Row(
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
              centerSpaceRadius: 40,
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedPieIndex;
                final radius = isTouched ? 50.0 : 40.0;
                return PieChartSectionData(
                  value: entries[i].value,
                  title: isTouched
                      ? '${(entries[i].value / total * 100).toStringAsFixed(0)}%'
                      : '',
                  color: colors[i % colors.length],
                  radius: radius,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
              entries.length > 4 ? 4 : entries.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: TextStyle(
                          fontSize: 11,
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
    );
  }

  Widget _buildRecentActivitySection(
    List<Map<String, dynamic>> recentItems,
    NumberFormat currencyFormat,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Actividad Reciente', isDark),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No hay actividad reciente',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final item = recentItems[index];
                final isSale = item['type'] == 'sale';
                final date = item['date'] as DateTime;
                final amount = isSale
                    ? (item['data'] as dynamic).total
                    : (item['data'] as dynamic).amount;
                final title = isSale
                    ? 'Venta realizada'
                    : (item['data'] as dynamic).description;

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isSale ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSale
                          ? Icons.attach_money
                          : Icons.shopping_cart_outlined,
                      color: isSale ? AppColors.success : AppColors.error,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '#${(item['data'] as dynamic).id} - ${DateFormat('dd MMM HH:mm').format(date)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    '${isSale ? "+" : "-"}${currencyFormat.format(amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSale ? AppColors.success : AppColors.error,
                    ),
                  ),
                  onTap: () {
                    if (isSale) {
                      context.push(
                        '/ventas?saleId=${(item['data'] as dynamic).id}',
                      );
                    } else {
                      context.push(
                        '/gastos?expenseId=${(item['data'] as dynamic).id}',
                      );
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

// Quick Stat Card
class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final double change;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${change.abs().toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Metric Card
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double change;
  final IconData icon;
  final Color color;
  final bool invertChangeColor;
  final bool isDark;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.icon,
    required this.color,
    this.invertChangeColor = false,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = invertChangeColor
        ? (isPositive ? AppColors.error : AppColors.success)
        : (isPositive ? AppColors.success : AppColors.error);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: changeColor,
                    ),
                    Text(
                      '${change.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small Metric Card
class _SmallMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
