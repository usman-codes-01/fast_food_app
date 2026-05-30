import 'package:fast_food_app/screens/auth/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

// CONTROLLERS
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';

// CORE
import 'core/theme.dart';
import 'firebase_options.dart';

// SCREENS
import 'screens/auth/login_screen.dart';
import 'screens/student/menu_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Surface a clear setup message instead of a blank screen / crash loop.
    firebaseError = e;
  }

  Get.put(ThemeController());
  if (firebaseError == null) {
    Get.put(AuthController());
  }

  runApp(MyApp(firebaseError: firebaseError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseError;
  const MyApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Campus Bites',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          getPages: [
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(name: '/register', page: () => const RegisterScreen()),
            GetPage(name: '/student_home', page: () => MenuScreen()),
            GetPage(
                name: '/admin_dashboard',
                page: () => const AdminDashboard()),
          ],
          home: firebaseError != null
              ? _FirebaseSetupScreen(error: firebaseError!)
              : const SplashScreen(),
        ));
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  final Object error;
  const _FirebaseSetupScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 80, color: Colors.deepOrange),
                  const SizedBox(height: 20),
                  const Text(
                    "Firebase not configured",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Run this command from the project root to finish setup:",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "flutterfire configure",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "$error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
