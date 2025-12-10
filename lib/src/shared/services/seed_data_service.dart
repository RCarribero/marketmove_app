import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../providers/products_provider.dart';
import '../providers/ventas_provider.dart';
import '../providers/gastos_provider.dart';
import '../providers/auth_provider.dart';

class SeedDataService {
  static Future<void> seedData(BuildContext context) async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    final productsProvider = context.read<ProductsProvider>();
    final salesProvider = context.read<VentasProvider>();
    final gastosProvider = context.read<GastosProvider>();

    // 1. Seed Products
    final products = [
      Product(
        name: 'Camiseta Básica',
        price: 15.00,
        stock: 50,
        description: 'Camiseta de algodón 100%',
        userId: userId,
      ),
      Product(
        name: 'Pantalón Jeans',
        price: 45.00,
        stock: 30,
        description: 'Jeans corte recto',
        userId: userId,
      ),
      Product(
        name: 'Zapatillas Sport',
        price: 89.99,
        stock: 20,
        description: 'Ideales para correr',
        userId: userId,
      ),
      Product(
        name: 'Gorra MarketMove',
        price: 12.50,
        stock: 100,
        description: 'Gorra con logo bordado',
        userId: userId,
      ),
      Product(
        name: 'Mochila Urbana',
        price: 35.00,
        stock: 15,
        description: 'Resistente al agua',
        userId: userId,
      ),
    ];

    for (var p in products) {
      await productsProvider.addProduct(p);
    }

    // 2. Seed Expenses
    final expenses = [
      Expense(
        amount: 450.00,
        description: 'Alquiler Local',
        category: 'Alquiler',
        date: DateTime.now(),
        userId: userId,
      ),
      Expense(
        amount: 85.50,
        description: 'Luz y Agua',
        category: 'Servicios',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userId: userId,
      ),
      Expense(
        amount: 120.00,
        description: 'Publicidad Facebook',
        category: 'Marketing',
        date: DateTime.now().subtract(const Duration(days: 5)),
        userId: userId,
      ),
    ];

    for (var e in expenses) {
      await gastosProvider.addExpense(e);
    }

    // 3. Seed Sales
    final random = Random();
    // Generate 10 random sales over the last 7 days
    for (int i = 0; i < 10; i++) {
      final daysAgo = random.nextInt(7);
      final amount = (random.nextDouble() * 100) + 20; // 20 to 120

      await salesProvider.addSale(
        Sale(
          total: double.parse(amount.toStringAsFixed(2)),
          date: DateTime.now().subtract(Duration(days: daysAgo)),
          customerName: 'Cliente #${random.nextInt(100)}',
          items: [], // Simplified for now
          userId: userId,
        ),
      );
    }
  }
}
