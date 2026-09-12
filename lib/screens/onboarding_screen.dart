import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Easy Rent Payments',
      'subtitle': 'Track and pay your monthly rent hassle-free.',
      'description': 'Never miss a payment deadline. View your rent history, set reminders, and pay securely all in one place.',
      'icon': 'payment',
    },
    {
      'title': 'Utility & Bills',
      'subtitle': 'Monitor electricity meter readings and utility charges in real time.',
      'description': 'Track your electricity usage, view meter readings, and get real-time updates on your utility bills.',
      'icon': 'electricity',
    },
    {
      'title': 'Stay Connected',
      'subtitle': 'Access lease details and report maintenance issues instantly.',
      'description': 'Keep your lease documents handy, report maintenance requests, and stay in touch with your property manager.',
      'icon': 'connected',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'payment':
        return Icons.payment_rounded;
      case 'electricity':
        return Icons.electric_bolt_rounded;
      case 'connected':
        return Icons.connect_without_contact_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  _getIcon(_onboardingData[index]['icon']!),
                                  size: 70,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Title
                        Text(
                          _onboardingData[index]['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        // Subtitle
                        Text(
                          _onboardingData[index]['subtitle']!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Description
                        Text(
                          _onboardingData[index]['description']!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textHint,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _onboardingData.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.border,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
