import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:concentric_transition/concentric_transition.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static final List<PageData> _pages = [
    const PageData(
      icon: Icons.pie_chart_rounded,
      title: 'Track Your Nutrition',
      subtitle:
          'Pantau asupan kalori dan nutrisi harian dengan mudah dan akurat',
      bgColor: Color(0xFF6366F1), // Indigo - soft purple-blue
      textColor: Colors.white,
    ),
    const PageData(
      icon: Icons.track_changes_rounded,
      title: 'Set Your Goals',
      subtitle:
          'Tentukan target diet sesuai kebutuhanmu - Cutting, Maintenance, atau Bulking',
      bgColor: Color(0xFF14B8A6), // Teal - calming green
      textColor: Colors.white,
    ),
    const PageData(
      icon: Icons.auto_stories_rounded,
      title: 'Read Health Articles',
      subtitle:
          'Dapatkan tips kesehatan dan nutrisi dari artikel-artikel terpercaya',
      bgColor: Color(0xFFF97316), // Orange - warm and inviting
      textColor: Colors.white,
    ),
    const PageData(
      icon: Icons.self_improvement_rounded,
      title: 'Stay Healthy',
      subtitle:
          'Capai gaya hidup sehat dengan pemantauan progres yang konsisten',
      bgColor: Color(0xFFEC4899), // Pink - energetic finish
      textColor: Colors.white,
    ),
  ];

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          ConcentricPageView(
            colors: _pages.map((p) => p.bgColor).toList(),
            radius: screenWidth * 0.1,
            nextButtonBuilder: (context) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Icon(
                Icons.navigate_next,
                size: screenWidth * 0.08,
                color: Colors.white,
              ),
            ),
            itemCount: _pages.length,
            scaleFactor: 2,
            onFinish: () => _finishOnboarding(context),
            itemBuilder: (index) {
              final page = _pages[index];
              return SafeArea(child: _OnboardingPage(page: page));
            },
          ),
          // Skip Button
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => _finishOnboarding(context),
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: _pages[0].textColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _OnboardingPage extends StatelessWidget {
  final PageData page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.textColor.withValues(alpha: 0.15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.textColor.withValues(alpha: 0.25),
                  ),
                  child: Icon(
                    page.icon,
                    size: screenHeight * 0.07,
                    color: page.textColor,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: page.textColor,
                  fontSize: screenHeight * 0.032,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: page.textColor.withValues(alpha: 0.8),
                  fontSize: screenHeight * 0.016,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
