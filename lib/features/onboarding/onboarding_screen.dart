import 'package:flutter/material.dart';
import 'package:bingwa_hybrid/core/themes/app_theme.dart';
import 'package:bingwa_hybrid/features/auth/screens/registration_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Sell your Bundles, airtime and minutes easily',
      description:
          'Focus on marketing and worry less about the process of delivery',
      image: 'assets/bingwa ultra.jpeg', // using the same logo for both pages
    ),
    OnboardingPage(
      title: 'Setting up instructions',
      description:
          'Ensure you have your Bingwa SIM Card to process customer requests and the till SIM Card to receive payments',
      image: 'assets/bingwa ultra.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo image
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: AssetImage(page.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      page.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text('Skip'),
                ),
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppTheme.primaryBlue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}