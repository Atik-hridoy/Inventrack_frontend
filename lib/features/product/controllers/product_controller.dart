import 'package:flutter/material.dart';
import '../../../data/repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository;

  ProductController(this._repository);

  List<dynamic> _products = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _repository.fetchProducts();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProduct({
    required String name,
    required String sku,
    required double price,
    required int quantity,
    String? imageBase64,
    dynamic imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createProduct(
        name: name,
        sku: sku,
        price: price,
        quantity: quantity,
        imageBase64: imageBase64,
        imageFile: imageFile,
      );
      await fetchProducts(); // Refresh list after creation
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double price,
    required int quantity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateProduct(
        id: id,
        name: name,
        sku: sku,
        price: price,
        quantity: quantity,
      );
      await fetchProducts();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteProduct(id);
      await fetchProducts();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}