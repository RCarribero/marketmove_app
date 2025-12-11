import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../shared/providers/ventas_provider.dart';
import '../../../shared/providers/gastos_provider.dart';
import '../../../shared/providers/products_provider.dart';
import '../../../shared/services/report_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/services/email_service.dart';
import '../../../shared/theme/colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedPeriod = 'month';
  String _selectedReportType = 'complete';
  bool _isGenerating = false;
  bool _isSending = false;
  File? _generatedFile;

  final _periodOptions = [
    {'value': 'today', 'label': 'Hoy', 'icon': Icons.today},
    {'value': 'week', 'label': 'Esta semana', 'icon': Icons.date_range},
    {'value': 'month', 'label': 'Este mes', 'icon': Icons.calendar_month},
    {'value': 'year', 'label': 'Este ano', 'icon': Icons.calendar_today},
    {'value': 'all', 'label': 'Todo', 'icon': Icons.all_inclusive},
  ];

  final _reportTypes = [
    {
      'value': 'complete',
      'label': 'Reporte Completo',
      'icon': Icons.analytics,
      'color': AppColors.primary,
    },
    {
      'value': 'sales',
      'label': 'Solo Ventas',
      'icon': Icons.shopping_bag,
      'color': AppColors.success,
    },
    {
      'value': 'expenses',
      'label': 'Solo Gastos',
      'icon': Icons.receipt,
      'color': AppColors.error,
    },
    {
      'value': 'products',
      'label': 'Inventario',
      'icon': Icons.inventory_2,
      'color': AppColors.secondary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case 'today':
        return (today, now);
      case 'week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return (startOfWeek, now);
      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return (startOfMonth, now);
      case 'year':
        final startOfYear = DateTime(now.year, 1, 1);
        return (startOfYear, now);
      case 'all':
      default:
        return (DateTime(2020, 1, 1), now);
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final (startDate, endDate) = _getDateRange();

      final ventasProvider = context.read<VentasProvider>();
      final gastosProvider = context.read<GastosProvider>();
      final productsProvider = context.read<ProductsProvider>();

      await ventasProvider.loadSales();
      await gastosProvider.loadExpenses();
      await productsProvider.loadProducts();

      final sales = ventasProvider.sales
          .where(
            (s) =>
                s.date.isAfter(startDate) &&
                s.date.isBefore(endDate.add(const Duration(days: 1))),
          )
          .toList();

      final expenses = gastosProvider.expenses
          .where(
            (e) =>
                e.date.isAfter(startDate) &&
                e.date.isBefore(endDate.add(const Duration(days: 1))),
          )
          .toList();

      final products = productsProvider.products;

      File file;
      switch (_selectedReportType) {
        case 'sales':
          file = await ReportService.generateSalesReport(
            sales,
            startDate,
            endDate,
          );
          break;
        case 'expenses':
          file = await ReportService.generateExpensesReport(
            expenses,
            startDate,
            endDate,
          );
          break;
        case 'products':
          file = await ReportService.generateProductsReport(products);
          break;
        case 'complete':
        default:
          file = await ReportService.generateCompleteReport(
            sales,
            expenses,
            products,
            startDate,
            endDate,
          );
      }

      setState(() => _generatedFile = file);
      if (mounted) {
        ToastService.success(context, 'Reporte generado correctamente');
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(context, 'Error generando reporte: $e');
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _shareReport() async {
    if (_generatedFile == null) return;

    await Share.shareXFiles(
      [XFile(_generatedFile!.path)],
      subject: 'Reporte MarketMove',
      text: 'Adjunto el reporte generado desde MarketMove.',
    );
  }

  Future<void> _sendByEmail() async {
    if (_generatedFile == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';

    if (email.isEmpty) {
      ToastService.error(context, 'No se encontro email del usuario');
      return;
    }

    setState(() => _isSending = true);

    try {
      final (startDate, endDate) = _getDateRange();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final reportTypeName =
          _reportTypes.firstWhere(
                (r) => r['value'] == _selectedReportType,
              )['label']
              as String;
      final period =
          '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

      await EmailService.sendReport(
        recipientEmail: email,
        reportType: reportTypeName,
        period: period,
        reportFile: _generatedFile!,
      );

      if (mounted) {
        ToastService.success(context, 'Email enviado a $email');
      }
    } catch (e) {
      if (mounted) {
        ToastService.error(context, 'Error enviando: $e');
        // Fallback to share
        await _shareReport();
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Reportes',
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
                      right: 20,
                      bottom: 60,
                      child: Icon(
                        Icons.assessment,
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

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User email card
                    _buildEmailCard(user?.email ?? 'No autenticado', isDark),
                    const SizedBox(height: 24),

                    // Period selector
                    _buildSectionTitle('Periodo del reporte', isDark),
                    const SizedBox(height: 12),
                    _buildPeriodSelector(isDark),
                    const SizedBox(height: 24),

                    // Report type
                    _buildSectionTitle('Tipo de reporte', isDark),
                    const SizedBox(height: 12),
                    _buildReportTypeSelector(isDark),
                    const SizedBox(height: 32),

                    // Generate button
                    _buildGenerateButton(isDark),
                    const SizedBox(height: 24),

                    // Actions (if file generated)
                    if (_generatedFile != null) ...[
                      _buildActionsSection(isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard(String email, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.email, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El reporte se enviara a:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildPeriodSelector(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _periodOptions.map((option) {
        final isSelected = _selectedPeriod == option['value'];
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedPeriod = option['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCardBackground : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withValues(alpha: 0.3),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  option['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportTypeSelector(bool isDark) {
    return Column(
      children: _reportTypes.map((type) {
        final isSelected = _selectedReportType == type['value'];
        final color = type['color'] as Color;

        return GestureDetector(
          onTap: () =>
              setState(() => _selectedReportType = type['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : (isDark ? AppColors.darkCardBackground : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(type['icon'] as IconData, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    type['label'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: color),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isGenerating ? null : _generateReport,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isGenerating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_download),
                  SizedBox(width: 8),
                  Text('Generar Reporte', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }

  Widget _buildActionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reporte generado', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _generatedFile!.path.split('/').last,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareReport,
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSending ? null : _sendByEmail,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.email),
                      label: Text(_isSending ? 'Enviando...' : 'Enviar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
