import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_screen.dart'; // Make sure this path is correct

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final _storage = GetStorage();

  // Define your app's theme colors from LoginScreen
  final Color primaryColor = const Color(0xFF7AB7A7);
  final Color gradientStart = const Color(0xFFeaf4f2);
  final Color gradientEnd = const Color(0xFFfdfaf6);
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.black54;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to Saathi",
      "subtitle": "Caring made simpler, for your loved ones.",
      "image": "assets/images/carousel1.jpg"
    },
    {
      "title": "Connect with Confidence",
      "subtitle": "Find verified, trusted walkers for your daily needs, all with live tracking.",
      "image": "assets/images/carousel3.png"
    },
    {
      "title": "Join the Community",
      "subtitle": "Offer your time as a Walker or find a companion as a Wanderer.",
      "image": "assets/images/carousel4.jpg"
    },
  ];

  void _onGetStartedPressed() {
    _storage.write('hasSeenOnboarding', true);
    Get.offAll(() => LoginScreen()); // Navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    final srcheight = MediaQuery.of(context).size.height;
    final srcwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: srcheight,
        width: srcwidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: onboardingData.length,
              options: CarouselOptions(
                height: srcheight,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final item = onboardingData[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image Asset
                    Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                    ),

                    // Faded Gradient to make text readable
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientEnd.withOpacity(0.1),
                            gradientEnd.withOpacity(0.7),
                            gradientEnd
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 0.6, 0.8],
                        ),
                      ),
                    ),

                    // Text Content
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: srcwidth * 0.08,
                          right: srcwidth * 0.08,
                          bottom: srcheight * 0.22, // Position text above buttons
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item["title"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: srcwidth * 0.07,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item["subtitle"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: srcwidth * 0.04,
                                color: textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Buttons and Dot Indicators
            Positioned(
              bottom: srcwidth * 0.1, // Positioned from bottom
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingData.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? primaryColor
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Get Started Button
                  ElevatedButton(
                    onPressed: _onGetStartedPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Themed Button Color
                      foregroundColor: Colors.white,
                      minimumSize: Size(srcwidth * 0.8, srcheight * 0.065),
                      textStyle: GoogleFonts.nunito(
                        fontSize: srcwidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(srcheight * 0.02),
                      ),
                      elevation: 6,
                    ),
                    child: const Text("Get Started"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

