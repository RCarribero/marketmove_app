import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../data/embedded_mock_data.dart';

class ProductService {
  final SupabaseClient? _client;
  static final List<Product> _embeddedItems = EmbeddedMockData.initialProducts;

  ProductService([this._client]);

  Future<List<Product>> getAll() async {
    if (_client != null) {
      try {
        final response = await _client
            .from('productos')
            .select()
            .order('createdat');
        final items = (response as List).map((e) => Product.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback to embedded demo data
      }
    }
    return List.from(_embeddedItems);
  }

  Future<List<Product>> getAllForUser(String userId) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('productos')
            .select()
            .eq('user_id', userId)
            .order('createdat');
        final items = (response as List).map((e) => Product.fromJson(e)).toList();
        if (items.isNotEmpty) return items;
      } catch (_) {
        // Fallback to embedded demo data
      }
    }
    return List.from(_embeddedItems);
  }

  Future<Product> getById(int id) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('productos')
            .select()
            .eq('id', id)
            .single();
        return Product.fromJson(response);
      } catch (_) {
        // Fallback
      }
    }
    return _embeddedItems.firstWhere(
      (p) => p.id == id,
      orElse: () => _embeddedItems.first,
    );
  }

  Future<Product> insert(Product product) async {
    if (_client != null) {
      try {
        final response = await _client
            .from('productos')
            .insert(product.toJson()..remove('id'))
            .select()
            .single();
        final created = Product.fromJson(response);
        _embeddedItems.insert(0, created);
        return created;
      } catch (_) {
        // Fallback in-memory
      }
    }

    final newId = (_embeddedItems.isEmpty ? 1 : (_embeddedItems.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1));
    final created = product.copyWith(
      id: newId,
      createdAt: DateTime.now(),
    );
    _embeddedItems.insert(0, created);
    return created;
  }

  Future<Product> update(Product product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }

    if (_client != null) {
      try {
        final response = await _client
            .from('productos')
            .update(product.toJson())
            .eq('id', product.id!)
            .select()
            .single();
        final updated = Product.fromJson(response);
        final index = _embeddedItems.indexWhere((p) => p.id == updated.id);
        if (index != -1) _embeddedItems[index] = updated;
        return updated;
      } catch (_) {
        // Fallback in-memory
      }
    }

    final index = _embeddedItems.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _embeddedItems[index] = product;
    }
    return product;
  }

  Future<void> delete(int id) async {
    if (_client != null) {
      try {
        await _client.from('productos').delete().eq('id', id);
      } catch (_) {}
    }
    _embeddedItems.removeWhere((p) => p.id == id);
  }
}
