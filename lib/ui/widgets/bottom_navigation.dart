import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';

class AppBottomNavigationBar extends StatelessWidget{
    const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return NavigationBar(
      selectedIndex: viewModel.selectedIndex,
      onDestinationSelected: (int index) {
        context.read<HomeViewModel>().setIndex(index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          selectedIcon: Icon(Icons.restaurant_menu),
          label: 'Meals',
        ),
        NavigationDestination(
          icon: Icon(Icons.stacked_bar_chart_outlined),
          selectedIcon: Icon(Icons.stacked_bar_chart),
          label: 'Stats',
        ),
      ],
    );
  }
}