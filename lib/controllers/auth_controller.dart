import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());

    // NOTE: We removed the 'ever' listener here.
    // This allows the Splash Screen to finish its animation
    // before we force the user to the next screen.
  }

  // NEW: The Splash Screen calls this when animation finishes
  void decideRoute() {
    User? user = auth.currentUser;

    if (user == null) {
      Get.offAllNamed("/login");
    } else {
      checkRoleAndNavigate(user);
    }
  }

  // Helper function to check database for role
  void checkRoleAndNavigate(User user) async {
    // 1. Check if it's the Master Admin (Hardcoded)
    if (user.email == "admin@canteen.com") {
      Get.offAllNamed("/admin_dashboard");
      return;
    }

    // 2. Check Database for Role (Student vs Admin)
    try {
      DocumentSnapshot userDoc = await db.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['role'] == 'admin') {
        Get.offAllNamed("/admin_dashboard");
      } else {
        // Default to student if role is missing or is 'student'
        Get.offAllNamed("/student_home");
      }
    } catch (e) {
      // If error (e.g., no internet), default to student
      Get.offAllNamed("/student_home");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      // After successful login, we manually check where to go
      decideRoute();
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> register(String email, String password, String role) async {
    try {
      // 1. Create User in Auth
      UserCredential cred = await auth.createUserWithEmailAndPassword(email: email, password: password);

      // 2. Save Role to Database
      await db.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'role': role, // "student" or "admin"
        'created_at': DateTime.now(),
      });

      Get.snackbar("Success", "Account created as $role!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      // Navigate to home immediately after registering
      decideRoute();

    } catch (e) {
      Get.snackbar("Registration Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void signOut() async {
    await auth.signOut();
    // Manually go back to login since we removed the listener
    Get.offAllNamed("/login");
  }
}