import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants.dart';
import '../../models/menu_item.dart';

class MenuManageScreen extends StatelessWidget {
  const MenuManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Menu"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
        onPressed: () => _showItemDialog(context, null),
      ),
      body: Obx(() {
        final menu = controller.menu;
        if (menu.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menu.length,
          itemBuilder: (context, i) {
            final item = menu[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade100,
                        child:
                            const Icon(Icons.fastfood_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text("${item.category} • Rs. ${item.price.toInt()}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.inStock
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.inStock ? "In Stock" : "Out",
                                style: TextStyle(
                                    color: item.inStock
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        item.inStock
                            ? Icons.toggle_on
                            : Icons.toggle_off,
                        color: item.inStock ? Colors.green : Colors.grey,
                        size: 32),
                    onPressed: () => controller.toggleStock(item),
                    tooltip: "Toggle stock",
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == "edit") _showItemDialog(context, item);
                      if (v == "delete") _confirmDelete(item);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: "edit",
                          child: Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Edit")
                          ])),
                      PopupMenuItem(
                          value: "delete",
                          child: Row(children: [
                            Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete",
                                style: TextStyle(color: Colors.red))
                          ])),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(MenuItem item) {
    Get.dialog(AlertDialog(
      title: const Text("Delete item?"),
      content: Text("Remove '${item.name}' from menu?"),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            if (item.id != null) {
              OrderController.instance.deleteMenuItem(item.id!);
            }
            Get.back();
          },
          child: const Text("Delete"),
        )
      ],
    ));
  }

  void _showItemDialog(BuildContext context, MenuItem? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? "");
    final priceCtrl = TextEditingController(
        text: existing?.price.toInt().toString() ?? "");
    final imageCtrl = TextEditingController(text: existing?.image ?? "");
    final descCtrl =
        TextEditingController(text: existing?.description ?? "");
    String category = existing?.category ?? "Snacks";

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? "Add Item" : "Edit Item",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Price (Rs.)"),
                ),
                const SizedBox(height: 10),
                StatefulBuilder(builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                        labelText: "Category"),
                    items: AppStrings.categories
                        .where((c) => c != "All")
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => category = v ?? category),
                  );
                }),
                const SizedBox(height: 10),
                TextField(
                  controller: imageCtrl,
                  decoration:
                      const InputDecoration(labelText: "Image URL"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: "Description (optional)"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final price =
                            double.tryParse(priceCtrl.text.trim()) ?? 0;
                        if (name.isEmpty || price <= 0) {
                          Get.snackbar("Invalid",
                              "Name and valid price required",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }
                        final item = MenuItem(
                          id: existing?.id,
                          name: name,
                          price: price,
                          image: imageCtrl.text.trim(),
                          category: category,
                          description: descCtrl.text.trim(),
                          inStock: existing?.inStock ?? true,
                        );
                        if (existing == null) {
                          await OrderController.instance.addMenuItem(item);
                        } else {
                          await OrderController.instance
                              .updateMenuItem(item);
                        }
                        Get.back();
                      },
                      child: Text(existing == null ? "Add" : "Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
