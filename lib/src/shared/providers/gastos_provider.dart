import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class GastosProvider extends ChangeNotifier {
  final ExpenseService _service;

  GastosProvider(this._service);

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'demo-admin-user';
    } catch (_) {
      return 'demo-admin-user';
    }
  }

  /// Carga gastos. Si isAdmin es true, carga todos los gastos.
  Future<void> loadExpenses({bool isAdmin = false, String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (isAdmin) {
        // Admin: cargar todos los gastos
        _expenses = await _service.getAll();
      } else {
        // Usuario normal: cargar solo sus gastos
        final currentUserId = userId ?? _currentUserId;
        _expenses = await _service.getAllForUser(currentUserId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _currentUserId;
      final expenseWithUser = expense.copyWith(userId: userId);
      final newExpense = await _service.insert(expenseWithUser);
      _expenses.insert(0, newExpense);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _currentUserId;
      final expenseWithUser = expense.copyWith(userId: userId);
      final updatedExpense = await _service.update(expenseWithUser);
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _expenses.removeWhere((e) => e.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
