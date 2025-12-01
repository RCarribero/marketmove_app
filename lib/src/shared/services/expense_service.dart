import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final SupabaseClient _client;

  ExpenseService(this._client);

  Future<List<Expense>> getAll() async {
    final response = await _client
        .from('gastos')
        .select()
        .order('date', ascending: false);
    return (response as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<Expense> getById(int id) async {
    final response = await _client
        .from('gastos')
        .select()
        .eq('id', id)
        .single();
    return Expense.fromJson(response);
  }

  Future<Expense> insert(Expense expense) async {
    final response = await _client
        .from('gastos')
        .insert(expense.toJson()..remove('id'))
        .select()
        .single();
    return Expense.fromJson(response);
  }

  Future<Expense> update(Expense expense) async {
    final response = await _client
        .from('gastos')
        .update(expense.toJson())
        .eq('id', expense.id)
        .select()
        .single();
    return Expense.fromJson(response);
  }

  Future<void> delete(int id) async {
    await _client.from('gastos').delete().eq('id', id);
  }
}
