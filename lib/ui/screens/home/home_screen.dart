import 'package:diabetes_app/ui/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:provider/provider.dart';
import '../../themes/colors/app_colors.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_navigation.dart';
import '../meals/calculator_screen.dart';
import '../meals/diet_screen.dart';
import '../health/health_screen.dart';
import 'home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    Widget getBody() {
      switch (viewModel.selectedIndex) {
        case 0:
          return const HomeContent();
        case 1:
          return const CalculatorScreen();
        case 2:
          return const DietScreen();
        case 3:
          return const StatsScreen();
        case 4:
          return const HealthScreen();
        default:
          return const HomeContent();
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
      appBar: AppBar(title: Text(viewModel.currentTitle),backgroundColor: AppColors.cyberBlack.withOpacity(0.8),),
      drawer: const AppDrawer(),
      body: SafeArea(child: getBody()),
      bottomNavigationBar: const AppBottomNavigationBar(),
    ),
      ],
    );
  }
}
