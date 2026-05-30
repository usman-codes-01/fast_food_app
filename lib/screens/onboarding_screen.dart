import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _index = 0;

  final List<_Slide> _slides = const [
    _Slide(
      icon: Icons.fastfood_rounded,
      title: "Order Tasty Food",
      subtitle:
          "Browse the canteen menu and add your favorites to the cart in seconds.",
      color: AppColors.primary,
    ),
    _Slide(
      icon: Icons.qr_code_2_rounded,
      title: "Skip the Queue",
      subtitle:
          "Get a unique pickup code with every order — just show it at the counter.",
      color: Color(0xFFFFA000),
    ),
    _Slide(
      icon: Icons.local_fire_department_rounded,
      title: "Live Status",
      subtitle:
          "Watch your order go from Pending → Cooking → Ready in real time.",
      color: AppColors.statusReady,
    ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      Get.offAll(() => const LoginScreen());
    } else {
      _pc.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Get.offAll(() => const LoginScreen()),
                child: const Text("Skip",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _buildSlide(_slides[i]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _index == _slides.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_Slide s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.color.withAlpha(30),
            ),
            child: Container(
              margin: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.color.withAlpha(60),
              ),
              child: Icon(s.icon, size: 70, color: s.color),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            s.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            s.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[600], fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
