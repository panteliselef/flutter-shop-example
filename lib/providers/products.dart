import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exception.dart';
import 'package:my_shop/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchandSetProducts([bool filterByUser = false]) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '' ;
    final url =
        'https://flutter-shop-66fc3.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      final favoritesResponse = await http.get(
          'https://flutter-shop-66fc3.firebaseio.com/userFavorites/$userId/.json?auth=$authToken');
      final favoriteData = json.decode(favoritesResponse.body);
      final List<Product> loadedProducts = [];
      data.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          description: prodData['description'],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });

      _items = loadedProducts;
      print(items.toString());
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product newProduct) async {
    final url =
        'https://flutter-shop-66fc3.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'creatorId': userId,
        }),
      );
      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        price: newProduct.price,
        description: newProduct.description,
        imageUrl: newProduct.imageUrl,
        isFavorite: newProduct.isFavorite,
      ));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> removeProduct(String id) async {
    final url =
        'https://flutter-shop-66fc3.firebaseio.com/products/${id}.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((item) => item.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final index =
        _items.indexWhere((product) => product.id == updatedProduct.id);

    if (index >= 0) {
      final url =
          'https://flutter-shop-66fc3.firebaseio.com/products/${updatedProduct.id}.json?auth=$authToken';
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'price': updatedProduct.price,
            'imageUrl': updatedProduct.imageUrl,
          }),
        );
        _items[index] = updatedProduct;
        notifyListeners();
      } catch (error) {
        print(error);
      }
    }
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
}
