import 'package:flutter/foundation.dart';
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

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _service.getAll();
      print('Ventas loaded: ${_sales.length}');
    } catch (e) {
      _error = e.toString();
      print('Error loading sales: $_error');
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
      final newSale = await _service.insert(sale);
      _sales.insert(0, newSale); // Add to top as it's newest
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
      final updatedSale = await _service.update(sale);
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
