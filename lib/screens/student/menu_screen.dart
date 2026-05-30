import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants.dart';
import '../../models/menu_item.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final OrderController orderController = Get.put(OrderController());
  final CartController cartController = Get.put(CartController());
  final AuthController authController = AuthController.instance;

  final RxInt _selectedIndex = 0.obs;
  final RxString _selectedCategory = "All".obs;
  final RxString _query = "".obs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(() => Text(
              _selectedIndex.value == 0
                  ? AppStrings.appName
                  : _selectedIndex.value == 1
                      ? "My Orders"
                      : "Profile",
              style: const TextStyle(fontWeight: FontWeight.w800),
            )),
        actions: [
          Obx(() {
            final count = cartController.totalCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.primary),
                  onPressed: () => Get.to(() => const CartScreen()),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        "$count",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              return IndexedStack(
                index: _selectedIndex.value,
                children: [
                  _buildMenuList(context, scheme),
                  const MyOrdersScreen(),
                  const ProfileScreen(),
                ],
              );
            }),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => CurvedNavigationBar(
                  currentIndex: _selectedIndex.value,
                  onTap: (index) => _selectedIndex.value = index,
                  items: const [
                    Icons.fastfood_rounded,
                    Icons.receipt_long_rounded,
                    Icons.person_rounded,
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hey there! 👋",
                  style: TextStyle(
                      color: scheme.onSurface.withAlpha(150), fontSize: 16)),
              const SizedBox(height: 4),
              const Text("What are you craving?",
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => _query.value = v.toLowerCase().trim(),
            decoration: const InputDecoration(
              hintText: "Search food...",
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Categories
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppStrings.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = AppStrings.categories[i];
              return Obx(() {
                final selected = _selectedCategory.value == cat;
                return GestureDetector(
                  onTap: () => _selectedCategory.value = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? Colors.white : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // List
        Expanded(
          child: Obx(() {
            final all = orderController.menu;
            final filtered = all.where((m) {
              final catOk = _selectedCategory.value == "All" ||
                  m.category == _selectedCategory.value;
              final qOk = _query.value.isEmpty ||
                  m.name.toLowerCase().contains(_query.value);
              return catOk && qOk;
            }).toList();

            if (all.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 70, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("No food found",
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding:
                  const EdgeInsets.only(bottom: 160, left: 16, right: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _foodCard(context, item);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _foodCard(BuildContext context, MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.08),
              blurRadius: 15,
              offset: Offset(0, 5))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Hero(
              tag: 'food-${item.id ?? item.name}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  item.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text("Rs. ${item.price.toInt()}",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: item.inStock
                          ? () => cartController.addItem(item)
                          : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: Text(
                          item.inStock ? "Add to Cart" : "Out of stock"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            item.inStock ? Colors.black : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CURVED NAV BAR (unchanged design, kept here)
// ---------------------------------------------------------------------------
class CurvedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> items;

  const CurvedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double itemWidth = width / items.length;

    return SizedBox(
      height: 95,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(width, 80),
            painter: _CurvedPainter(
              xOffset: (currentIndex * itemWidth) + (itemWidth / 2),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            top: -25,
            left: (currentIndex * itemWidth) + (itemWidth / 2) - 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(255, 87, 34, 0.4),
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ],
              ),
              child:
                  Icon(items[currentIndex], color: Colors.white, size: 28),
            ),
          ),
          SizedBox(
            height: 80,
            child: Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      child: currentIndex == index
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: Icon(items[index],
                                  color: Colors.grey.shade400, size: 28),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedPainter extends CustomPainter {
  final double xOffset;
  _CurvedPainter({required this.xOffset});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    double curveWidth = 70;
    path.lineTo(xOffset - curveWidth, 0);
    path.cubicTo(xOffset - (curveWidth / 2), 0,
        xOffset - (curveWidth / 2), 55, xOffset, 55);
    path.cubicTo(xOffset + (curveWidth / 2), 55,
        xOffset + (curveWidth / 2), 0, xOffset + curveWidth, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, const Color.fromRGBO(0, 0, 0, 0.3), 10.0, true);

    final paint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CurvedPainter oldDelegate) => xOffset != oldDelegate.xOffset;
}
