import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductService _service;

  ProductsProvider(this._service);

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga productos. Si isAdmin es true, carga todos los productos.
  String get _currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'demo-admin-user';
    } catch (_) {
      return 'demo-admin-user';
    }
  }

  Future<void> loadProducts({bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (isAdmin) {
        // Admin: cargar todos los productos
        _products = await _service.getAll();
      } else {
        // Usuario normal: cargar solo sus productos
        final userId = _currentUserId;
        _products = await _service.getAllForUser(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _currentUserId;
      final productWithUser = product.copyWith(userId: userId);
      final newProduct = await _service.insert(productWithUser);
      _products.add(newProduct);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _currentUserId;
      final productWithUser = product.copyWith(userId: userId);
      final updatedProduct = await _service.update(productWithUser);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
