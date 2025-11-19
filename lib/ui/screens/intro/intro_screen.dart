import 'package:diabetes_app/ui/screens/intro/intro_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/colors/app_colors.dart';
import '../home/home_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final _pages = pages;

  void _skip() {
    _onFinish();
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue2,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) => _pages[index],
          ),
          if (_currentIndex != _pages.length - 1)
            Positioned(
              bottom: 40,
              left: 20,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  "SKIP",
                  style: GoogleFonts.iceland(
                    fontSize: 20,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            right: 20,
            child: TextButton(
              onPressed: _onNext,
              child: Text(
                _currentIndex == _pages.length - 1 ? "FINISH" : "NEXT",
                style: GoogleFonts.iceland(
                  fontSize: 24,
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                onDotClicked: (index) {
                  _animateToPage(index);
                },
                effect: const SwapEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 20,
                  dotColor: AppColors.darkBlue1,
                  activeDotColor: AppColors.pink,
                  paintStyle: PaintingStyle.fill,
                  type: SwapType.yRotation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
