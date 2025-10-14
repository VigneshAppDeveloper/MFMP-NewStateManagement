import 'package:flutter/material.dart';

import '../models/FoodModels/resturant_menu_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<RestaurantMenuModel, int> _items = {};

  Map<RestaurantMenuModel, int> get items => _items;

  /// Add or update quantity
  void addItem(RestaurantMenuModel menu, int qty) {
    if (qty > 0) {
      _items[menu] = qty;
    } else {
      _items.remove(menu);
    }
    Future.microtask(() => notifyListeners());
  }

  void removeItem(RestaurantMenuModel menu) {
    _items.remove(menu);
      Future.microtask(() => notifyListeners());
  }

  void clearCart() {
    _items.clear();
      Future.microtask(() => notifyListeners());
  }

  bool get hasItems => _items.isNotEmpty;
  int get totalItems => _items.values.fold(0, (a, b) => a + b);
}
