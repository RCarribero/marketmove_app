import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_model.dart';
import '../services/sale_service.dart';

class VentasProvider extends ChangeNotifier {
  final SaleService _service;

  VentasProvider(this._service);

  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga ventas. Si isAdmin es true, carga todas las ventas.
  Future<void> loadSales({bool isAdmin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (isAdmin) {
        // Admin: cargar todas las ventas
        _sales = await _service.getAll();
      } else {
        // Usuario normal: cargar solo sus ventas
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          _sales = await _service.getAllForUser(userId);
        } else {
          _sales = [];
          _error = 'Usuario no autenticado';
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final saleWithUser = sale.copyWith(userId: userId);
      final newSale = await _service.insert(saleWithUser);
      _sales.insert(0, newSale);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSale(Sale sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      final saleWithUser = sale.copyWith(userId: userId);
      final updatedSale = await _service.update(saleWithUser);
      final index = _sales.indexWhere((s) => s.id == updatedSale.id);
      if (index != -1) {
        _sales[index] = updatedSale;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSale(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      _sales.removeWhere((s) => s.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
