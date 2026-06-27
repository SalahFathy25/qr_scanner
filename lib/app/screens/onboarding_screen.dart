import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_code/core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardData(
      lottie: 'assets/lottie/qr_scanner.json',
      title: 'Welcome to ${AppConstants.appName}',
      subtitle: 'Generate, scan, and manage QR codes\nfor all your needs',
    ),
    _OnboardData(
      lottie: 'assets/lottie/qr_scanner.json',
      title: 'Multiple QR Types',
      subtitle: 'From WiFi and vCard to Calendar\nand Location — we\'ve got you covered',
    ),
    _OnboardData(
      lottie: 'assets/lottie/qr_scanner.json',
      title: 'Beautiful & Customizable',
      subtitle: 'Gradients, colors, logos —\nmake your QR codes stand out',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final p = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(p.lottie, height: 250),
                      const SizedBox(height: 40),
                      Text(p.title, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Text(p.subtitle, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(180))),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      widget.onDone();
                    }
                  },
                  child: Text(_currentPage < _pages.length - 1 ? 'Next' : 'Get Started'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnboardData {
  final String lottie;
  final String title;
  final String subtitle;
  const _OnboardData({required this.lottie, required this.title, required this.subtitle});
}
