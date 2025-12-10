import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_model.dart';

class SaleService {
  final SupabaseClient _client;

  SaleService(this._client);

  Future<List<Sale>> getAll() async {
    final response = await _client
        .from('ventas')
        .select()
        .order('date', ascending: false);
    return (response as List).map((e) => Sale.fromJson(e)).toList();
  }

  Future<Sale> getById(int id) async {
    final response = await _client
        .from('ventas')
        .select()
        .eq('id', id)
        .single();
    return Sale.fromJson(response);
  }

  Future<Sale> insert(Sale sale) async {
    final response = await _client
        .from('ventas')
        .insert(sale.toJson()..remove('id'))
        .select()
        .single();
    return Sale.fromJson(response);
  }

  Future<Sale> update(Sale sale) async {
    if (sale.id == null) {
      throw Exception('Sale ID is required for update');
    }
    final response = await _client
        .from('ventas')
        .update(sale.toJson())
        .eq('id', sale.id!)
        .select()
        .single();
    return Sale.fromJson(response);
  }

  Future<void> delete(int id) async {
    await _client.from('ventas').delete().eq('id', id);
  }
}
