import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/menu_item.dart';

class OrderController extends GetxController {
  static OrderController instance = Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fallback menu used to seed Firestore on first run (so the app
  // doesn't look empty before any admin adds items).
  static const List<Map<String, dynamic>> _seedMenu = [
    {
      "name": "Zinger Burger",
      "price": 450.0,
      "category": "Burgers",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=60",
      "description": "Crispy chicken fillet with mayo & lettuce.",
      "inStock": true,
    },
    {
      "name": "Pizza Slice",
      "price": 250.0,
      "category": "Pizza",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=500&q=60",
      "description": "Wood-fired Margherita slice.",
      "inStock": true,
    },
    {
      "name": "Biryani Box",
      "price": 350.0,
      "category": "Rice",
      "image":
          "https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=500&q=60",
      "description": "Chicken biryani with raita.",
      "inStock": true,
    },
    {
      "name": "Cold Coffee",
      "price": 200.0,
      "category": "Drinks",
      "image":
          "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=500&q=60",
      "description": "Iced coffee with cream.",
      "inStock": true,
    },
    {
      "name": "Fries",
      "price": 150.0,
      "category": "Snacks",
      "image":
          "https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=500&q=60",
      "description": "Crispy salted fries.",
      "inStock": true,
    },
  ];

  RxList<OrderModel> allOrders = <OrderModel>[].obs;
  RxList<MenuItem> menu = <MenuItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    allOrders.bindStream(_getAllOrders());
    menu.bindStream(_getMenu());
    _seedMenuIfEmpty();
  }

  // --- STREAMS ---

  Stream<List<OrderModel>> _getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => OrderModel.fromMap(item.data(), item.id))
            .toList());
  }

  Stream<List<MenuItem>> _getMenu() {
    return _db.collection('menu').snapshots().map((query) => query.docs
        .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
        .toList());
  }

  // First-run seed so the menu collection isn't empty on a fresh DB.
  Future<void> _seedMenuIfEmpty() async {
    try {
      final snap = await _db.collection('menu').limit(1).get();
      if (snap.docs.isEmpty) {
        final batch = _db.batch();
        for (final item in _seedMenu) {
          final ref = _db.collection('menu').doc();
          batch.set(ref, item);
        }
        await batch.commit();
      }
    } catch (_) {/* ignore - offline first launch */}
  }

  // --- ORDERS ---

  String _generatePickupCode() {
    final rng = Random();
    return (1000 + rng.nextInt(9000)).toString(); // 4-digit
  }

  Future<void> placeOrderFromCart() async {
    try {
      final cart = CartController.instance;
      if (cart.items.isEmpty) {
        Get.snackbar("Empty Cart", "Add something to order");
        return;
      }

      final email = AuthController.instance.auth.currentUser?.email;
      if (email == null) {
        Get.snackbar("Error", "You must be logged in");
        return;
      }

      final order = OrderModel(
        items: List<CartItem>.from(cart.items),
        total: cart.totalPrice,
        studentEmail: email,
        status: "Pending",
        timestamp: DateTime.now(),
        pickupCode: _generatePickupCode(),
      );

      await _db.collection('orders').add(order.toMap());
      cart.clear();

      Get.snackbar(
        "Order Placed!",
        "Pickup code: ${order.pickupCode}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar("Error", "Could not place order: $e");
    }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      Get.snackbar("Error", "Could not update status: $e");
    }
  }

  // --- MENU CRUD (admin) ---

  Future<void> addMenuItem(MenuItem item) async {
    await _db.collection('menu').add(item.toMap());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    if (item.id == null) return;
    await _db.collection('menu').doc(item.id).set(item.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await _db.collection('menu').doc(id).delete();
  }

  Future<void> toggleStock(MenuItem item) async {
    if (item.id == null) return;
    await _db
        .collection('menu')
        .doc(item.id)
        .update({'inStock': !item.inStock});
  }
}
