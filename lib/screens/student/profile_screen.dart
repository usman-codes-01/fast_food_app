import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final orders = OrderController.instance;
    final theme = ThemeController.instance;
    final email = auth.auth.currentUser?.email ?? "Guest";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar card
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 14,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : "?",
                      style: const TextStyle(
                          fontSize: 38,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(email,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Member since today",
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Obx(() {
            final my = orders.allOrders
                .where((o) =>
                    o.studentEmail == auth.auth.currentUser?.email)
                .toList();
            final totalOrders = my.length;
            final totalSpent =
                my.fold<double>(0.0, (sum, o) => sum + o.total);
            final active = my
                .where((o) => o.status != "Picked Up")
                .length;
            return Row(
              children: [
                _statBox("Orders", "$totalOrders", Icons.receipt_long),
                const SizedBox(width: 10),
                _statBox(
                    "Active", "$active", Icons.local_fire_department),
                const SizedBox(width: 10),
                _statBox(
                    "Spent", "Rs.${totalSpent.toInt()}", Icons.savings),
              ],
            );
          }),

          const SizedBox(height: 24),

          const Text("Settings",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Dark mode tile
          Obx(() => _settingsTile(
                context,
                icon: theme.isDark.value
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: "Dark Mode",
                subtitle: theme.isDark.value ? "On" : "Off",
                trailing: Switch(
                  activeThumbColor: AppColors.primary,
                  value: theme.isDark.value,
                  onChanged: (_) => theme.toggle(),
                ),
              )),

          const SizedBox(height: 8),
          _settingsTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: "Notifications",
            subtitle: "Order updates",
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.snackbar(
                "Coming soon", "Push notifications in next update"),
          ),

          const SizedBox(height: 8),
          _settingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: "About Campus Bites",
            subtitle: "Version 1.0.0",
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      Widget? trailing,
      VoidCallback? onTap}) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
