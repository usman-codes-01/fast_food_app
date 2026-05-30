import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  String? id;
  final List<CartItem> items;
  final double total;
  final String studentEmail;
  final String status;
  final DateTime timestamp;
  final String pickupCode;

  OrderModel({
    this.id,
    required this.items,
    required this.total,
    required this.studentEmail,
    required this.status,
    required this.timestamp,
    required this.pickupCode,
  });

  // Convenience: first item info (for compact display)
  String get headline {
    if (items.isEmpty) return "Order";
    if (items.length == 1) return items.first.name;
    return "${items.first.name} +${items.length - 1} more";
  }

  String get firstImage => items.isNotEmpty ? items.first.image : '';

  int get totalQuantity =>
      items.fold(0, (acc, item) => acc + item.quantity);

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'studentEmail': studentEmail,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'pickupCode': pickupCode,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    // Backwards-compat: old orders stored a single itemName/price/image
    List<CartItem> parsedItems = [];
    if (map['items'] is List) {
      parsedItems = (map['items'] as List)
          .whereType<Map>()
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else if (map['itemName'] != null) {
      parsedItems = [
        CartItem(
          name: map['itemName'] ?? 'Unknown Item',
          price: (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : (map['price'] ?? 0.0).toDouble(),
          image: map['image'] ?? '',
        )
      ];
    }

    double parsedTotal;
    if (map['total'] != null) {
      parsedTotal = (map['total'] is int)
          ? (map['total'] as int).toDouble()
          : (map['total'] as num).toDouble();
    } else {
      parsedTotal =
          parsedItems.fold(0.0, (acc, i) => acc + i.price * i.quantity);
    }

    return OrderModel(
      id: docId,
      items: parsedItems,
      total: parsedTotal,
      studentEmail: map['studentEmail'] ?? '',
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      pickupCode: map['pickupCode'] ?? '----',
    );
  }
}
