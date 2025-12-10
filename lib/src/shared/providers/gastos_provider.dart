import 'package:flutter/foundation.dart';
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

  Future<void> loadExpenses({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Si se pasa userId, filtramos por ese ID (Solo funcionará si es Admin por RLS)
      // Si no, carga los propios (comportamiento default)
      if (userId != null) {
        final response = await _service.getAllForUser(
          userId,
        ); // Necesitamos agregar este método al servicio
        _expenses = response;
      } else {
        _expenses = await _service.getAll();
      }
      print('Gastos loaded: ${_expenses.length}');
    } catch (e) {
      _error = e.toString();
      print('Error loading expenses: $_error');
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
      final newExpense = await _service.insert(expense);
      _expenses.insert(0, newExpense); // Add to top
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
      final updatedExpense = await _service.update(expense);
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
