import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartController extends GetxController {
  static CartController instance = Get.find();

  final RxList<CartItem> items = <CartItem>[].obs;

  int get totalCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem(MenuItem menu) {
    final existing = items.indexWhere((i) => i.name == menu.name);
    if (existing >= 0) {
      items[existing].quantity += 1;
      items.refresh();
    } else {
      items.add(CartItem(
        name: menu.name,
        price: menu.price,
        image: menu.image,
      ));
    }
    Get.snackbar(
      "Added",
      "${menu.name} in cart",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 900),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void increment(int index) {
    if (index < 0 || index >= items.length) return;
    items[index].quantity += 1;
    items.refresh();
  }

  void decrement(int index) {
    if (index < 0 || index >= items.length) return;
    if (items[index].quantity > 1) {
      items[index].quantity -= 1;
      items.refresh();
    } else {
      items.removeAt(index);
    }
  }

  void remove(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
  }

  void clear() => items.clear();
}
