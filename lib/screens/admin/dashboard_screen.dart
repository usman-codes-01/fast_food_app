import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import 'menu_manage_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(OrderController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kitchen Display",
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            Text("Manage incoming orders",
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Manage Menu",
            icon: const Icon(Icons.restaurant_menu_rounded,
                color: Colors.white),
            onPressed: () => Get.to(() => const MenuManageScreen()),
          ),
          IconButton(
              onPressed: () => AuthController.instance.signOut(),
              icon: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent))
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Obx(() {
            final all = orderController.allOrders;
            final pending = all.where((o) => o.status == "Pending").length;
            final cooking = all.where((o) => o.status == "Cooking").length;
            final ready = all.where((o) => o.status == "Ready").length;
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              color: Colors.black87,
              child: Row(
                children: [
                  _stat("Pending", pending, AppColors.statusPending),
                  _stat("Cooking", cooking, AppColors.statusCooking),
                  _stat("Ready", ready, AppColors.statusReady),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              // Hide already-picked-up orders from the live kitchen view
              final active = orderController.allOrders
                  .where((o) => o.status != "Picked Up")
                  .toList();

              if (active.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_rounded,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text("Kitchen is clear!",
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 18)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: active.length,
                itemBuilder: (context, index) {
                  final order = active[index];
                  return _orderCard(context, order, orderController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Column(
          children: [
            Text("$value",
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(
      BuildContext context, OrderModel order, OrderController controller) {
    Color statusColor;
    Color bgColor;
    IconData statusIcon;
    String actionLabel;
    VoidCallback? onAction;

    switch (order.status) {
      case "Pending":
        statusColor = AppColors.statusPending;
        bgColor = Colors.blue.shade50;
        statusIcon = Icons.notifications_active;
        actionLabel = "Start Cooking";
        onAction = () => controller.updateStatus(order.id!, "Cooking");
        break;
      case "Cooking":
        statusColor = AppColors.statusCooking;
        bgColor = Colors.orange.shade50;
        statusIcon = Icons.local_fire_department;
        actionLabel = "Mark Ready";
        onAction = () => controller.updateStatus(order.id!, "Ready");
        break;
      case "Ready":
        statusColor = AppColors.statusReady;
        bgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        actionLabel = "Verify Pickup";
        onAction = () => _verifyPickup(context, order, controller);
        break;
      default:
        statusColor = Colors.grey;
        bgColor = Colors.grey.shade100;
        statusIcon = Icons.help;
        actionLabel = "Unknown";
        onAction = null;
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 6)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.headline,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("Rs. ${order.total.toInt()}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),

              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.studentEmail,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("#${order.pickupCode}",
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),

              // Items list
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text("x${item.quantity}",
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(item.name,
                                style: const TextStyle(fontSize: 14))),
                        Text("Rs. ${item.subtotal.toInt()}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  )),

              const SizedBox(height: 10),

              // Action row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (onAction != null)
                    ElevatedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.arrow_forward_rounded,
                          size: 18),
                      label: Text(actionLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Asks staff to type the customer's 4-digit pickup code before closing the order
  void _verifyPickup(
      BuildContext context, OrderModel order, OrderController controller) {
    final codeController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text("Verify Pickup"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ask the customer for their 4-digit pickup code:"),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textAlign: TextAlign.center,
              maxLength: 4,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 16),
              decoration: const InputDecoration(
                counterText: "",
                hintText: "0000",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim() == order.pickupCode) {
                controller.updateStatus(order.id!, "Picked Up");
                Get.back();
                Get.snackbar("Verified!", "Order handed over",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP);
              } else {
                Get.snackbar("Wrong Code",
                    "Code does not match this order",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
