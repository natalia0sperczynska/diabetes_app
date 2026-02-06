import 'package:diabetes_app/ui/screens/statistics/statistics_screen.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../themes/colors/app_colors.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/navigation/drawer.dart';
import '../../widgets/navigation/bottom_navigation.dart';
import '../meals/calculator_screen.dart';
import '../meals/diet_screen.dart';
import '../health/health_screen.dart';
import '../analysis/analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    Widget getBody() {
      switch (viewModel.selectedIndex) {
        case 0:
          return const StatsScreen();
        case 1:
          return const CalculatorScreen();
        case 2:
          return const DietScreen();
        case 3:
          return const AnalysisScreen();
        case 4:
          return const HealthScreen();
        default:
          return const StatsScreen();
      }
    }

    return Stack(
      children: [
      Container(
      color: Theme.of(context).scaffoldBackgroundColor
    ),

    Positioned.fill(
    child: Opacity(
    opacity: 0.15,
    child: Image.asset(
    'assets/images/grid.png',
    repeat: ImageRepeat.repeat,
    scale: 1.0,
    ),
    ),
    ),
      Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: CyberGlitchText(viewModel.currentTitle, style: GoogleFonts.vt323(fontSize: 32, color: Theme.of(context).colorScheme.onPrimary)),backgroundColor: AppColors.cyberBlack.withOpacity(0.8),),
      drawer: const AppDrawer(),
      body: SafeArea(child: getBody()),
      bottomNavigationBar: const AppBottomNavigationBar(),
    ),
      ],
    );
  }
}
