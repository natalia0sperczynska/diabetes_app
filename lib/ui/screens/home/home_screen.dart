import 'package:diabetes_app/ui/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:provider/provider.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_navigation.dart';
import '../meals/meal_screen.dart';
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
          return const MealScreen();
        case 2:
          return const StatsScreen();
        default:
          return const HomeContent();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(viewModel.currentTitle)),
      drawer: const AppDrawer(),
      body: SafeArea(child: getBody()),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
