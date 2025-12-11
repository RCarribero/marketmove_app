import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _client;

  ProductService(this._client);

  Future<List<Product>> getAll() async {
    final response = await _client
        .from('productos')
        .select()
        .order('createdat');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getAllForUser(String userId) async {
    final response = await _client
        .from('productos')
        .select()
        .eq('user_id', userId)
        .order('createdat');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getById(int id) async {
    final response = await _client
        .from('productos')
        .select()
        .eq('id', id)
        .single();
    return Product.fromJson(response);
  }

  Future<Product> insert(Product product) async {
    final response = await _client
        .from('productos')
        .insert(product.toJson()..remove('id')) // Remove ID for auto-increment
        .select()
        .single();
    return Product.fromJson(response);
  }

  Future<Product> update(Product product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }
    final response = await _client
        .from('productos')
        .update(product.toJson())
        .eq('id', product.id!)
        .select()
        .single();
    return Product.fromJson(response);
  }

  Future<void> delete(int id) async {
    await _client.from('productos').delete().eq('id', id);
  }
}
