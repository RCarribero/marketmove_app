import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

/// Widget generico para graficos de lineas con tendencias
class TrendLineChart extends StatelessWidget {
  final List<FlSpot> salesSpots;
  final List<FlSpot> expenseSpots;
  final List<String> labels;
  final bool isDark;
  final bool showExpenses;
  final String? title;

  const TrendLineChart({
    super.key,
    required this.salesSpots,
    required this.expenseSpots,
    required this.labels,
    required this.isDark,
    this.showExpenses = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final allValues = [
      ...salesSpots.map((s) => s.y),
      ...expenseSpots.map((s) => s.y),
    ];
    final maxY = allValues.isEmpty
        ? 100.0
        : allValues.reduce((a, b) => a > b ? a : b) * 1.2;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: AppColors.success, label: 'Ventas'),
              if (showExpenses) ...[
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.error, label: 'Gastos'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                maxY: maxY == 0 ? 100 : maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDark ? AppColors.darkSurface : Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final isExpense = spot.barIndex == 1;
                        return LineTooltipItem(
                          '\$${NumberFormat('#,##0').format(spot.y)}',
                          TextStyle(
                            color: isExpense
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  _createLine(salesSpots, AppColors.success),
                  if (showExpenses) _createLine(expenseSpots, AppColors.error),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _createLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

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
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
