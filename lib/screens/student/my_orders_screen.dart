import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find();
    final AuthController authController = AuthController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order History",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 5),
              const Text("Track your food 🚚",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final myOrders = orderController.allOrders
                .where((order) =>
                    order.studentEmail ==
                    authController.auth.currentUser?.email)
                .toList();

            if (myOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood_outlined,
                        size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 20),
                    Text("No active orders yet",
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 18)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: myOrders.length,
              padding: const EdgeInsets.only(
                  bottom: 160, left: 16, right: 16),
              itemBuilder: (context, index) {
                final order = myOrders[index];
                return _orderCard(context, order);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final statusBgColor = statusColor.withAlpha(35);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 15,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: image + headline + status
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: order.firstImage.isNotEmpty
                    ? Image.network(
                        order.firstImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood_rounded),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood_rounded),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.headline,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      "${order.totalQuantity} item${order.totalQuantity > 1 ? 's' : ''}  •  Rs. ${order.total.toInt()}",
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(order.status),
                        size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(order.status,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),

          // Pickup code (always shown — student needs it)
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withAlpha(60), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PICKUP CODE",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.brown.shade400,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      Text(order.pickupCode,
                          style: const TextStyle(
                              fontSize: 22,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4)),
                    ],
                  ),
                ),
                Text(
                  order.status == "Ready"
                      ? "Show at counter"
                      : "Save this code",
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade400,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),

          // Show items list (if more than one)
          if (order.items.length > 1) ...[
            const SizedBox(height: 10),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text("• ${item.name}",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[700])),
                      const SizedBox(width: 6),
                      Text("x${item.quantity}",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text("Rs. ${item.subtotal.toInt()}",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                ))
          ]
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Ready":
        return AppColors.statusReady;
      case "Cooking":
        return AppColors.statusCooking;
      case "Pending":
        return AppColors.statusPending;
      case "Picked Up":
        return AppColors.statusPickedUp;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Ready":
        return Icons.check_circle_rounded;
      case "Cooking":
        return Icons.local_fire_department_rounded;
      case "Pending":
        return Icons.hourglass_top_rounded;
      case "Picked Up":
        return Icons.shopping_bag_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
