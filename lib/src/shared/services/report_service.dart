import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/product_model.dart';

class ReportService {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  static Future<File> generateSalesReport(
    List<Sale> sales,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Ventas'];

    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Headers
    final headers = ['ID', 'Cliente', 'Total', 'Fecha'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Data
    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(sale.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(sale.customerName ?? 'Sin nombre');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(sale.total));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = TextCellValue(_dateFormat.format(sale.date));
    }

    // Summary row
    final totalRow = sales.length + 2;
    final total = sales.fold(0.0, (sum, s) => sum + s.total);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: totalRow))
      ..value = TextCellValue('TOTAL:')
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
      ..value = TextCellValue(_currencyFormat.format(total))
      ..cellStyle = CellStyle(bold: true);

    // Set column widths
    sheet.setColumnWidth(0, 10);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 20);

    excel.delete('Sheet1');

    return _saveExcel(excel, 'ventas', startDate, endDate);
  }

  static Future<File> generateExpensesReport(
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Gastos'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#F44336'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = ['ID', 'Descripcion', 'Categoria', 'Monto', 'Fecha'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(expense.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(expense.description);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(expense.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(expense.amount));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
        ..value = TextCellValue(_dateFormat.format(expense.date));
    }

    final totalRow = expenses.length + 2;
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
      ..value = TextCellValue('TOTAL:')
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
      ..value = TextCellValue(_currencyFormat.format(total))
      ..cellStyle = CellStyle(bold: true);

    sheet.setColumnWidth(0, 10);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 20);

    excel.delete('Sheet1');

    return _saveExcel(excel, 'gastos', startDate, endDate);
  }

  static Future<File> generateProductsReport(List<Product> products) async {
    final excel = Excel.createExcel();
    final sheet = excel['Productos'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = ['ID', 'Nombre', 'Precio', 'Stock', 'Descripcion'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(product.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(product.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(product.price));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = IntCellValue(product.stock);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
        ..value = TextCellValue(product.description ?? '');
    }

    final totalRow = products.length + 2;
    final totalStock = products.fold(0, (sum, p) => sum + p.stock);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
      ..value = TextCellValue('Total Stock:')
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
      ..value = IntCellValue(totalStock)
      ..cellStyle = CellStyle(bold: true);

    sheet.setColumnWidth(0, 10);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 10);
    sheet.setColumnWidth(4, 30);

    excel.delete('Sheet1');

    final now = DateTime.now();
    return _saveExcel(excel, 'productos', now, now);
  }

  static Future<File> generateCompleteReport(
    List<Sale> sales,
    List<Expense> expenses,
    List<Product> products,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final excel = Excel.createExcel();

    // Ventas sheet
    _addSalesSheet(excel, sales);
    _addExpensesSheet(excel, expenses);
    _addProductsSheet(excel, products);
    _addSummarySheet(excel, sales, expenses, startDate, endDate);

    excel.delete('Sheet1');

    return _saveExcel(excel, 'reporte_completo', startDate, endDate);
  }

  static void _addSalesSheet(Excel excel, List<Sale> sales) {
    final sheet = excel['Ventas'];
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
      fontColorHex: ExcelColor.white,
    );

    final headers = ['ID', 'Cliente', 'Total', 'Fecha'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(sale.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(sale.customerName ?? 'Sin nombre');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(sale.total));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = TextCellValue(_dateFormat.format(sale.date));
    }
  }

  static void _addExpensesSheet(Excel excel, List<Expense> expenses) {
    final sheet = excel['Gastos'];
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#F44336'),
      fontColorHex: ExcelColor.white,
    );

    final headers = ['ID', 'Descripcion', 'Categoria', 'Monto', 'Fecha'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(expense.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(expense.description);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(expense.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(expense.amount));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
        ..value = TextCellValue(_dateFormat.format(expense.date));
    }
  }

  static void _addProductsSheet(Excel excel, List<Product> products) {
    final sheet = excel['Productos'];
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
      fontColorHex: ExcelColor.white,
    );

    final headers = ['ID', 'Nombre', 'Precio', 'Stock'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = IntCellValue(product.id ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(product.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        ..value = TextCellValue(_currencyFormat.format(product.price));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
        ..value = IntCellValue(product.stock);
    }
  }

  static void _addSummarySheet(
    Excel excel,
    List<Sale> sales,
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    final sheet = excel['Resumen'];
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#9C27B0'),
      fontColorHex: ExcelColor.white,
    );

    final periodFormat = DateFormat('dd/MM/yyyy');
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.total);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalSales - totalExpenses;

    final data = [
      [
        'Periodo',
        '${periodFormat.format(startDate)} - ${periodFormat.format(endDate)}',
      ],
      ['', ''],
      ['Total Ventas', _currencyFormat.format(totalSales)],
      ['Numero de Ventas', sales.length.toString()],
      ['', ''],
      ['Total Gastos', _currencyFormat.format(totalExpenses)],
      ['Numero de Gastos', expenses.length.toString()],
      ['', ''],
      ['Balance Neto', _currencyFormat.format(balance)],
    ];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Concepto')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
      ..value = TextCellValue('Valor')
      ..cellStyle = headerStyle;

    for (var i = 0; i < data.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        ..value = TextCellValue(data[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        ..value = TextCellValue(data[i][1]);
    }

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 30);
  }

  static Future<File> _saveExcel(
    Excel excel,
    String prefix,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final directory = await getTemporaryDirectory();
    final dateFormat = DateFormat('yyyyMMdd');
    final fileName =
        '${prefix}_${dateFormat.format(startDate)}_${dateFormat.format(endDate)}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes == null) throw Exception('Error generando Excel');

    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    return file;
  }
}
