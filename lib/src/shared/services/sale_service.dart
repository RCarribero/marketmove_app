import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_model.dart';
import '../data/embedded_mock_data.dart';

class SaleService {
  final SupabaseClient? _client;
  static final List<Sale> _embeddedSales = EmbeddedMockData.initialSales;

  SaleService([this._client]);

  Future<List<Sale>> getAll() async {
    if (_client != null) {
      try {
        final response = await _client
            .from('ventas')
            .select()
            .order('date', ascending: false);
        final items = (response as List).map((e) => Sale.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback
      }
    }
    return List.from(_embeddedSales);
  }

  Future<List<Sale>> getAllForUser(String userId) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('ventas')
            .select()
            .eq('user_id', userId)
            .order('date', ascending: false);
        final items = (response as List).map((e) => Sale.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback
      }
    }
    return List.from(_embeddedSales);
  }

  Future<Sale> getById(int id) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('ventas')
            .select()
            .eq('id', id)
            .single();
        return Sale.fromJson(response);
      } catch (_) {
        // Fallback
      }
    }
    return _embeddedSales.firstWhere(
      (s) => s.id == id,
      orElse: () => _embeddedSales.first,
    );
  }

  Future<Sale> insert(Sale sale) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('ventas')
            .insert(sale.toJson()..remove('id'))
            .select()
            .single();
        final created = Sale.fromJson(response);
        _embeddedSales.insert(0, created);
        return created;
      } catch (_) {
        // Fallback
      }
    }

    final newId = (_embeddedSales.isEmpty ? 100 : (_embeddedSales.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1));
    final created = sale.copyWith(id: newId);
    _embeddedSales.insert(0, created);
    return created;
  }

  Future<Sale> update(Sale sale) async {
    if (sale.id == null) {
      throw Exception('Sale ID is required for update');
    }

    if (_client != null) {
      try {
        final response = await _client
            .from('ventas')
            .update(sale.toJson())
            .eq('id', sale.id!)
            .select()
            .single();
        final updated = Sale.fromJson(response);
        final index = _embeddedSales.indexWhere((s) => s.id == updated.id);
        if (index != -1) _embeddedSales[index] = updated;
        return updated;
      } catch (_) {
        // Fallback
      }
    }

    final index = _embeddedSales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      _embeddedSales[index] = sale;
    }
    return sale;
  }

  Future<void> delete(int id) async {
    if (_client != null) {
      try {
        await _client.from('ventas').delete().eq('id', id);
      } catch (_) {}
    }
    _embeddedSales.removeWhere((s) => s.id == id);
  }
}
