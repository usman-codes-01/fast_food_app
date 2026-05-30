import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Quick in-memory flag — first launch goes to onboarding, all subsequent
  // launches in the same install go straight to login/home.
  static bool _onboardingShown = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), _afterSplash);
      }
    });
  }

  void _afterSplash() {
    final loggedIn = AuthController.instance.auth.currentUser != null;
    if (!loggedIn && !_onboardingShown) {
      _onboardingShown = true;
      Get.offAll(() => const OnboardingScreen());
    } else {
      AuthController.instance.decideRoute();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topOfScreen = -screenHeight / 2;
    final double bottomOfScreen = screenHeight / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double currentY = 0;
              double ballSize = 60;

              if (_controller.value <= 0.35) {
                double t = (_controller.value / 0.35);
                t = Curves.easeIn.transform(t);
                currentY = topOfScreen +
                    ((bottomOfScreen - ballSize) - topOfScreen) * t;
              } else if (_controller.value <= 0.6) {
                double t = (_controller.value - 0.35) / 0.25;
                t = Curves.easeOutBack.transform(t);
                currentY = (bottomOfScreen - ballSize) * (1 - t);
              } else {
                currentY = 0;
              }

              return Transform.translate(
                offset: Offset(0, currentY),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: ballSize,
                    height: ballSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood_rounded,
                      size: 100, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    "Campus Bites",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
