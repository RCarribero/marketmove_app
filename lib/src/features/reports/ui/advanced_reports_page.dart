import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/providers/products_provider.dart';
import '../../../shared/services/analytics_service.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/kpi_card.dart';
import '../../../shared/widgets/trend_line_chart.dart';

class AdvancedReportsPage extends StatefulWidget {
  const AdvancedReportsPage({super.key});

  @override
  State<AdvancedReportsPage> createState() => _AdvancedReportsPageState();
}

class _AdvancedReportsPageState extends State<AdvancedReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'month';
  final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<VentasProvider>().loadSales();
    context.read<GastosProvider>().loadExpenses();
    context.read<ProductsProvider>().loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        return (now.subtract(const Duration(days: 7)), now);
      case 'month':
        return (DateTime(now.year, now.month, 1), now);
      case 'year':
        return (DateTime(now.year, 1, 1), now);
      case 'all':
      default:
        return (DateTime(2020, 1, 1), now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Reportes Avanzados',
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
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
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
                      bottom: 50,
                      child: Icon(
                        Icons.insights,
                        size: 60,
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.trending_up, size: 20),
                    text: 'Tendencias',
                  ),
                  Tab(
                    icon: Icon(Icons.monetization_on, size: 20),
                    text: 'Rentabilidad',
                  ),
                  Tab(icon: Icon(Icons.speed, size: 20), text: 'KPIs'),
                  Tab(
                    icon: Icon(Icons.pie_chart, size: 20),
                    text: 'Categorias',
                  ),
                  Tab(
                    icon: Icon(Icons.auto_graph, size: 20),
                    text: 'Proyecciones',
                  ),
                  Tab(
                    icon: Icon(Icons.warning_amber, size: 20),
                    text: 'Alertas Stock',
                  ),
                  Tab(
                    icon: Icon(Icons.account_balance_wallet, size: 20),
                    text: 'Flujo Caja',
                  ),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: Consumer3<VentasProvider, GastosProvider, ProductsProvider>(
          builder:
              (context, ventasProvider, gastosProvider, productsProvider, _) {
                if (ventasProvider.isLoading ||
                    gastosProvider.isLoading ||
                    productsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    _buildPeriodSelector(isDark),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTrendsTab(
                            ventasProvider,
                            gastosProvider,
                            isDark,
                          ),
                          _buildRentabilityTab(
                            ventasProvider,
                            productsProvider,
                            isDark,
                          ),
                          _buildKPIsTab(ventasProvider, gastosProvider, isDark),
                          _buildCategoriesTab(gastosProvider, isDark),
                          _buildProjectionsTab(ventasProvider, isDark),
                          _buildStockAlertsTab(
                            productsProvider,
                            ventasProvider,
                            isDark,
                          ),
                          _buildCashFlowTab(
                            ventasProvider,
                            gastosProvider,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
      child: Row(
        children: [
          Text(
            'Periodo:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PeriodChip(
                    label: 'Semana',
                    isSelected: _selectedPeriod == 'week',
                    onTap: () => setState(() => _selectedPeriod = 'week'),
                  ),
                  _PeriodChip(
                    label: 'Mes',
                    isSelected: _selectedPeriod == 'month',
                    onTap: () => setState(() => _selectedPeriod = 'month'),
                  ),
                  _PeriodChip(
                    label: 'Ano',
                    isSelected: _selectedPeriod == 'year',
                    onTap: () => setState(() => _selectedPeriod = 'year'),
                  ),
                  _PeriodChip(
                    label: 'Todo',
                    isSelected: _selectedPeriod == 'all',
                    onTap: () => setState(() => _selectedPeriod = 'all'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Tendencias
  Widget _buildTrendsTab(
    VentasProvider ventas,
    GastosProvider gastos,
    bool isDark,
  ) {
    final groupBy = _selectedPeriod == 'week' ? 'day' : 'month';
    final periods = _selectedPeriod == 'week' ? 7 : 6;
    final trends = AnalyticsService.getTrends(
      ventas.sales,
      gastos.expenses,
      groupBy,
      periods,
    );

    final salesSpots = trends
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.ventas))
        .toList();
    final expenseSpots = trends
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.gastos))
        .toList();
    final labels = trends
        .map(
          (t) => groupBy == 'day'
              ? DateFormat('E').format(t.date)
              : DateFormat('MMM').format(t.date),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrendLineChart(
            salesSpots: salesSpots,
            expenseSpots: expenseSpots,
            labels: labels,
            isDark: isDark,
            title: 'Evolucion de Ventas vs Gastos',
          ),
          const SizedBox(height: 20),
          _buildTrendSummary(trends, isDark),
        ],
      ),
    );
  }

  Widget _buildTrendSummary(List<TrendPoint> trends, bool isDark) {
    if (trends.length < 2) return const SizedBox();

    final lastVentas = trends.last.ventas;
    final prevVentas = trends[trends.length - 2].ventas;
    final ventasChange = prevVentas > 0
        ? ((lastVentas - prevVentas) / prevVentas) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Variacion vs periodo anterior',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      ventasChange >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: ventasChange >= 0
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ventasChange.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ventasChange >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total del periodo',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(
                    trends.fold(0.0, (sum, t) => sum + t.ventas),
                  ),
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
        ],
      ),
    );
  }

  // TAB 2: Rentabilidad
  Widget _buildRentabilityTab(
    VentasProvider ventas,
    ProductsProvider products,
    bool isDark,
  ) {
    final (startDate, endDate) = _getDateRange();
    final filteredSales = ventas.sales
        .where(
          (s) =>
              s.date.isAfter(startDate) &&
              s.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();

    final rentability = AnalyticsService.getProductRentability(
      filteredSales,
      products.products,
    );

    if (rentability.isEmpty) {
      return _buildEmptyState(
        'No hay datos de ventas para analizar',
        Icons.monetization_on,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentability.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: KpiCardLarge(
              title: 'Total Ingresos del Periodo',
              value: _currencyFormat.format(
                rentability.fold(0.0, (sum, r) => sum + r.ingresoTotal),
              ),
              description:
                  '${rentability.fold(0, (sum, r) => sum + r.cantidadVendida)} unidades vendidas',
              icon: Icons.trending_up,
              color: AppColors.success,
              isDark: isDark,
            ),
          );
        }

        final item = rentability[index - 1];
        final isTop3 = index <= 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isTop3
                ? Border.all(color: AppColors.success.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isTop3
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? AppColors.success : AppColors.primary,
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
                      item.product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.cantidadVendida} vendidos',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currencyFormat.format(item.ingresoTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '${item.porcentajeVentas.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: KPIs
  Widget _buildKPIsTab(
    VentasProvider ventas,
    GastosProvider gastos,
    bool isDark,
  ) {
    final (startDate, endDate) = _getDateRange();
    final kpis = AnalyticsService.calculateKPIs(
      ventas.sales,
      gastos.expenses,
      startDate,
      endDate,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          KpiCardLarge(
            title: 'Margen Neto',
            value: '${kpis.margenNeto.toStringAsFixed(1)}%',
            description: kpis.margenNeto >= 0
                ? 'Operacion rentable'
                : 'Operacion con perdidas',
            icon: Icons.show_chart,
            color: kpis.margenNeto >= 0 ? AppColors.success : AppColors.error,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Ticket Promedio',
                  value: _currencyFormat.format(kpis.ticketPromedio),
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Ventas/Dia',
                  value: _currencyFormat.format(kpis.ventasPorDia),
                  icon: Icons.calendar_today,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Gastos/Dia',
                  value: _currencyFormat.format(kpis.gastosPromedioDiario),
                  icon: Icons.payments,
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Total Transacciones',
                  value: kpis.totalTransacciones.toString(),
                  subtitle: '${kpis.diasConVentas} dias con ventas',
                  icon: Icons.shopping_cart,
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 4: Categorias
  Widget _buildCategoriesTab(GastosProvider gastos, bool isDark) {
    final (startDate, endDate) = _getDateRange();
    final filteredExpenses = gastos.expenses
        .where(
          (e) =>
              e.date.isAfter(startDate) &&
              e.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();

    final categories = AnalyticsService.getCategoryAnalysis(filteredExpenses);

    if (categories.isEmpty) {
      return _buildEmptyState('No hay gastos registrados', Icons.pie_chart);
    }

    final colors = AppColors.chartColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: categories.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cat = entry.value;
                  return PieChartSectionData(
                    value: cat.total,
                    title: '${cat.porcentaje.toStringAsFixed(0)}%',
                    color: colors[i % colors.length],
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...categories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.category,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${cat.cantidad} gastos - Prom: ${_currencyFormat.format(cat.promedioMonto)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currencyFormat.format(cat.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        '${cat.porcentaje.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 5: Proyecciones
  Widget _buildProjectionsTab(VentasProvider ventas, bool isDark) {
    final historico = AnalyticsService.getTrends(ventas.sales, [], 'day', 14);
    final proyeccion = AnalyticsService.getProjection(ventas.sales, 7);

    final allPoints = [...historico, ...proyeccion];
    final salesSpots = allPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.ventas))
        .toList();
    final labels = allPoints.asMap().entries.map((e) {
      if (e.key % 3 == 0) {
        return DateFormat('d/M').format(e.value.date);
      }
      return '';
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Proyeccion basada en promedio movil de ultimos 30 dias',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TrendLineChart(
            salesSpots: salesSpots,
            expenseSpots: [],
            labels: labels,
            isDark: isDark,
            showExpenses: false,
            title: 'Historico + Proyeccion (7 dias)',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proyeccion proximos 7 dias',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currencyFormat.format(
                    proyeccion.fold(0.0, (sum, p) => sum + p.ventas),
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 6: Alertas Stock
  Widget _buildStockAlertsTab(
    ProductsProvider products,
    VentasProvider ventas,
    bool isDark,
  ) {
    final alerts = AnalyticsService.getStockAlerts(
      products.products,
      ventas.sales,
    );

    if (alerts.isEmpty) {
      return _buildEmptyState(
        'No hay alertas de stock',
        Icons.check_circle,
        isPositive: true,
      );
    }

    final outOfStock = alerts
        .where((a) => a.alertType == 'out_of_stock')
        .toList();
    final lowStock = alerts.where((a) => a.alertType == 'low_stock').toList();
    final noMovement = alerts
        .where((a) => a.alertType == 'no_movement')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AlertSummaryCard(
                count: outOfStock.length,
                label: 'Sin Stock',
                color: AppColors.error,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _AlertSummaryCard(
                count: lowStock.length,
                label: 'Stock Bajo',
                color: AppColors.warning,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _AlertSummaryCard(
                count: noMovement.length,
                label: 'Sin Movimiento',
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ],
          ),
          if (outOfStock.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAlertSection(
              'Sin Stock',
              outOfStock,
              AppColors.error,
              isDark,
            ),
          ],
          if (lowStock.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAlertSection(
              'Stock Bajo',
              lowStock,
              AppColors.warning,
              isDark,
            ),
          ],
          if (noMovement.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAlertSection(
              'Sin Movimiento (+30 dias)',
              noMovement,
              AppColors.secondary,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertSection(
    String title,
    List<StockAlert> alerts,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 8),
        ...alerts.map(
          (alert) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.product.name,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Stock: ${alert.product.stock}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 7: Flujo de Caja
  Widget _buildCashFlowTab(
    VentasProvider ventas,
    GastosProvider gastos,
    bool isDark,
  ) {
    final groupBy = _selectedPeriod == 'week' ? 'day' : 'week';
    final periods = _selectedPeriod == 'week' ? 7 : 8;
    final cashFlow = AnalyticsService.getCashFlow(
      ventas.sales,
      gastos.expenses,
      groupBy,
      periods,
    );

    final maxValue = cashFlow.fold(0.0, (max, c) {
      final localMax = [
        c.ingresos,
        c.gastos,
        c.balance.abs(),
      ].reduce((a, b) => a > b ? a : b);
      return localMax > max ? localMax : max;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          KpiCardLarge(
            title: 'Balance Acumulado',
            value: _currencyFormat.format(
              cashFlow.isNotEmpty ? cashFlow.last.balance : 0,
            ),
            icon: Icons.account_balance_wallet,
            color: (cashFlow.isNotEmpty && cashFlow.last.balance >= 0)
                ? AppColors.success
                : AppColors.error,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _LegendItem(color: AppColors.success, label: 'Ingresos'),
                    const SizedBox(width: 12),
                    _LegendItem(color: AppColors.error, label: 'Gastos'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxValue * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              isDark ? AppColors.darkSurface : Colors.white,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < cashFlow.length) {
                                return Text(
                                  groupBy == 'day'
                                      ? DateFormat(
                                          'E',
                                        ).format(cashFlow[value.toInt()].date)
                                      : DateFormat(
                                          'd/M',
                                        ).format(cashFlow[value.toInt()].date),
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
                      barGroups: cashFlow.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.ingresos,
                              color: AppColors.success,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: entry.value.gastos,
                              color: AppColors.error,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String message,
    IconData icon, {
    bool isPositive = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isPositive ? AppColors.success : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Helper widgets
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _StickyTabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final bool isDark;

  const _AlertSummaryCard({
    required this.count,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
