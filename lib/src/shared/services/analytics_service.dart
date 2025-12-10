import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/product_model.dart';

/// Modelos para reportes analiticos
class KPIData {
  final double ticketPromedio;
  final double ventasPorDia;
  final double gastosPromedioDiario;
  final double margenNeto;
  final int diasConVentas;
  final int totalTransacciones;

  const KPIData({
    required this.ticketPromedio,
    required this.ventasPorDia,
    required this.gastosPromedioDiario,
    required this.margenNeto,
    required this.diasConVentas,
    required this.totalTransacciones,
  });
}

class TrendPoint {
  final DateTime date;
  final double ventas;
  final double gastos;

  const TrendPoint({
    required this.date,
    required this.ventas,
    required this.gastos,
  });
}

class ProductRentability {
  final Product product;
  final int cantidadVendida;
  final double ingresoTotal;
  final double porcentajeVentas;

  const ProductRentability({
    required this.product,
    required this.cantidadVendida,
    required this.ingresoTotal,
    required this.porcentajeVentas,
  });
}

class StockAlert {
  final Product product;
  final String alertType; // 'low_stock', 'no_movement', 'out_of_stock'
  final int diasSinMovimiento;

  const StockAlert({
    required this.product,
    required this.alertType,
    this.diasSinMovimiento = 0,
  });
}

class CashFlowPoint {
  final DateTime date;
  final double ingresos;
  final double gastos;
  final double balance;

  const CashFlowPoint({
    required this.date,
    required this.ingresos,
    required this.gastos,
    required this.balance,
  });
}

class CategoryAnalysis {
  final String category;
  final double total;
  final double porcentaje;
  final int cantidad;
  final double promedioMonto;

  const CategoryAnalysis({
    required this.category,
    required this.total,
    required this.porcentaje,
    required this.cantidad,
    required this.promedioMonto,
  });
}

/// Servicio de analiticas para calculos de KPIs y metricas avanzadas
class AnalyticsService {
  /// Calcula KPIs principales
  static KPIData calculateKPIs(
    List<Sale> sales,
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredSales = sales
        .where(
          (s) =>
              s.date.isAfter(startDate) &&
              s.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
    final filteredExpenses = expenses
        .where(
          (e) =>
              e.date.isAfter(startDate) &&
              e.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();

    final totalVentas = filteredSales.fold(0.0, (sum, s) => sum + s.total);
    final totalGastos = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final dias = endDate.difference(startDate).inDays + 1;

    final diasUnicos = filteredSales
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .length;

    return KPIData(
      ticketPromedio: filteredSales.isEmpty
          ? 0
          : totalVentas / filteredSales.length,
      ventasPorDia: dias > 0 ? totalVentas / dias : 0,
      gastosPromedioDiario: dias > 0 ? totalGastos / dias : 0,
      margenNeto: totalVentas > 0
          ? ((totalVentas - totalGastos) / totalVentas) * 100
          : 0,
      diasConVentas: diasUnicos,
      totalTransacciones: filteredSales.length,
    );
  }

  /// Obtiene tendencias por dia/semana/mes
  static List<TrendPoint> getTrends(
    List<Sale> sales,
    List<Expense> expenses,
    String groupBy, // 'day', 'week', 'month'
    int periods,
  ) {
    final now = DateTime.now();
    final trends = <TrendPoint>[];

    for (int i = periods - 1; i >= 0; i--) {
      late DateTime start, end;

      switch (groupBy) {
        case 'day':
          start = DateTime(now.year, now.month, now.day - i);
          end = DateTime(now.year, now.month, now.day - i, 23, 59, 59);
          break;
        case 'week':
          final weekStart = now.subtract(
            Duration(days: now.weekday - 1 + (i * 7)),
          );
          start = DateTime(weekStart.year, weekStart.month, weekStart.day);
          end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
          break;
        case 'month':
        default:
          start = DateTime(now.year, now.month - i, 1);
          end = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
      }

      final periodSales = sales
          .where(
            (s) =>
                s.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                s.date.isBefore(end.add(const Duration(seconds: 1))),
          )
          .fold(0.0, (sum, s) => sum + s.total);

      final periodExpenses = expenses
          .where(
            (e) =>
                e.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                e.date.isBefore(end.add(const Duration(seconds: 1))),
          )
          .fold(0.0, (sum, e) => sum + e.amount);

      trends.add(
        TrendPoint(date: start, ventas: periodSales, gastos: periodExpenses),
      );
    }

    return trends;
  }

  /// Analiza rentabilidad por producto
  static List<ProductRentability> getProductRentability(
    List<Sale> sales,
    List<Product> products,
  ) {
    final productSales = <int, Map<String, dynamic>>{};
    double totalIngresos = 0;

    for (final sale in sales) {
      for (final item in sale.items) {
        final productId = item['product_id'] as int?;
        final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final subtotal = price * quantity;

        if (productId != null) {
          productSales[productId] ??= {'cantidad': 0, 'ingreso': 0.0};
          productSales[productId]!['cantidad'] += quantity;
          productSales[productId]!['ingreso'] += subtotal;
          totalIngresos += subtotal;
        }
      }
    }

    final rentability = <ProductRentability>[];
    for (final product in products) {
      final data = productSales[product.id];
      if (data != null) {
        rentability.add(
          ProductRentability(
            product: product,
            cantidadVendida: data['cantidad'] as int,
            ingresoTotal: data['ingreso'] as double,
            porcentajeVentas: totalIngresos > 0
                ? (data['ingreso'] as double) / totalIngresos * 100
                : 0,
          ),
        );
      }
    }

    rentability.sort((a, b) => b.ingresoTotal.compareTo(a.ingresoTotal));
    return rentability;
  }

  /// Detecta alertas de stock
  static List<StockAlert> getStockAlerts(
    List<Product> products,
    List<Sale> sales, {
    int lowStockThreshold = 5,
    int noMovementDays = 30,
  }) {
    final alerts = <StockAlert>[];
    final now = DateTime.now();

    for (final product in products) {
      // Sin stock
      if (product.stock <= 0) {
        alerts.add(StockAlert(product: product, alertType: 'out_of_stock'));
        continue;
      }

      // Stock bajo
      if (product.stock <= lowStockThreshold) {
        alerts.add(StockAlert(product: product, alertType: 'low_stock'));
      }

      // Sin movimiento
      final lastSaleWithProduct = sales.where((sale) {
        return sale.items.any((item) => item['product_id'] == product.id);
      }).toList();

      if (lastSaleWithProduct.isEmpty) {
        final daysSinceCreation = product.createdAt != null
            ? now.difference(product.createdAt!).inDays
            : noMovementDays + 1;
        if (daysSinceCreation >= noMovementDays) {
          alerts.add(
            StockAlert(
              product: product,
              alertType: 'no_movement',
              diasSinMovimiento: daysSinceCreation,
            ),
          );
        }
      } else {
        lastSaleWithProduct.sort((a, b) => b.date.compareTo(a.date));
        final daysSinceLastSale = now
            .difference(lastSaleWithProduct.first.date)
            .inDays;
        if (daysSinceLastSale >= noMovementDays) {
          alerts.add(
            StockAlert(
              product: product,
              alertType: 'no_movement',
              diasSinMovimiento: daysSinceLastSale,
            ),
          );
        }
      }
    }

    return alerts;
  }

  /// Calcula flujo de caja
  static List<CashFlowPoint> getCashFlow(
    List<Sale> sales,
    List<Expense> expenses,
    String groupBy, // 'day', 'week'
    int periods,
  ) {
    final now = DateTime.now();
    final cashFlow = <CashFlowPoint>[];
    double balanceAcumulado = 0;

    for (int i = periods - 1; i >= 0; i--) {
      late DateTime start, end;

      if (groupBy == 'week') {
        final weekStart = now.subtract(
          Duration(days: now.weekday - 1 + (i * 7)),
        );
        start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
      } else {
        start = DateTime(now.year, now.month, now.day - i);
        end = DateTime(now.year, now.month, now.day - i, 23, 59, 59);
      }

      final periodSales = sales
          .where(
            (s) =>
                s.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                s.date.isBefore(end.add(const Duration(seconds: 1))),
          )
          .fold(0.0, (sum, s) => sum + s.total);

      final periodExpenses = expenses
          .where(
            (e) =>
                e.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                e.date.isBefore(end.add(const Duration(seconds: 1))),
          )
          .fold(0.0, (sum, e) => sum + e.amount);

      balanceAcumulado += periodSales - periodExpenses;

      cashFlow.add(
        CashFlowPoint(
          date: start,
          ingresos: periodSales,
          gastos: periodExpenses,
          balance: balanceAcumulado,
        ),
      );
    }

    return cashFlow;
  }

  /// Analiza gastos por categoria
  static List<CategoryAnalysis> getCategoryAnalysis(List<Expense> expenses) {
    final categoryTotals = <String, List<Expense>>{};
    double total = 0;

    for (final expense in expenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Otros';
      categoryTotals[category] ??= [];
      categoryTotals[category]!.add(expense);
      total += expense.amount;
    }

    final analysis = <CategoryAnalysis>[];
    for (final entry in categoryTotals.entries) {
      final categoryTotal = entry.value.fold(0.0, (sum, e) => sum + e.amount);
      analysis.add(
        CategoryAnalysis(
          category: entry.key,
          total: categoryTotal,
          porcentaje: total > 0 ? (categoryTotal / total) * 100 : 0,
          cantidad: entry.value.length,
          promedioMonto: entry.value.isNotEmpty
              ? categoryTotal / entry.value.length
              : 0,
        ),
      );
    }

    analysis.sort((a, b) => b.total.compareTo(a.total));
    return analysis;
  }

  /// Genera proyeccion simple de ventas
  static List<TrendPoint> getProjection(List<Sale> sales, int futureDays) {
    // Calcular promedio de los ultimos 30 dias
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentSales = sales
        .where((s) => s.date.isAfter(thirtyDaysAgo))
        .toList();
    final dailyAvg = recentSales.isEmpty
        ? 0.0
        : recentSales.fold(0.0, (sum, s) => sum + s.total) / 30;

    final projection = <TrendPoint>[];
    for (int i = 1; i <= futureDays; i++) {
      final date = now.add(Duration(days: i));
      // Proyeccion simple con variacion aleatoria pequena
      final projected = dailyAvg * (0.9 + (i % 3) * 0.05);
      projection.add(TrendPoint(date: date, ventas: projected, gastos: 0));
    }

    return projection;
  }
}
