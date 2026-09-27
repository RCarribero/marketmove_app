import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';
import '../data/embedded_mock_data.dart';

class ExpenseService {
  final SupabaseClient? _client;
  static final List<Expense> _embeddedExpenses = EmbeddedMockData.initialExpenses;

  ExpenseService([this._client]);

  Future<List<Expense>> getAll() async {
    if (_client != null) {
      try {
        final response = await _client
            .from('gastos')
            .select()
            .order('date', ascending: false);
        final items = (response as List).map((e) => Expense.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback
      }
    }
    return List.from(_embeddedExpenses);
  }

  Future<List<Expense>> getAllForUser(String userId) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('gastos')
            .select()
            .eq('user_id', userId)
            .order('date', ascending: false);
        final items = (response as List).map((e) => Expense.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback
      }
    }
    return List.from(_embeddedExpenses);
  }

  Future<Expense> getById(int id) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('gastos')
            .select()
            .eq('id', id)
            .single();
        return Expense.fromJson(response);
      } catch (_) {
        // Fallback
      }
    }
    return _embeddedExpenses.firstWhere(
      (e) => e.id == id,
      orElse: () => _embeddedExpenses.first,
    );
  }

  Future<Expense> insert(Expense expense) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('gastos')
            .insert(expense.toJson()..remove('id'))
            .select()
            .single();
        final created = Expense.fromJson(response);
        _embeddedExpenses.insert(0, created);
        return created;
      } catch (_) {
        // Fallback
      }
    }

    final newId = (_embeddedExpenses.isEmpty ? 200 : (_embeddedExpenses.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1));
    final created = expense.copyWith(id: newId);
    _embeddedExpenses.insert(0, created);
    return created;
  }

  Future<Expense> update(Expense expense) async {
    if (expense.id == null) {
      throw Exception('Expense ID is required for update');
    }

    if (_client != null) {
      try {
        final response = await _client
            .from('gastos')
            .update(expense.toJson())
            .eq('id', expense.id!)
            .select()
            .single();
        final updated = Expense.fromJson(response);
        final index = _embeddedExpenses.indexWhere((e) => e.id == updated.id);
        if (index != -1) _embeddedExpenses[index] = updated;
        return updated;
      } catch (_) {
        // Fallback
      }
    }

    final index = _embeddedExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _embeddedExpenses[index] = expense;
    }
    return expense;
  }

  Future<void> delete(int id) async {
    if (_client != null) {
      try {
        await _client.from('gastos').delete().eq('id', id);
      } catch (_) {}
    }
    _embeddedExpenses.removeWhere((e) => e.id == id);
  }
}
