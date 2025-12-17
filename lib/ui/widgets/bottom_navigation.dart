import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    
    // Define icon colors depending on active and inactive states
    final activeColor = Colors.white;
    // using onSurface as onBackground is deprecated in newer Flutter versions
    final inactiveColor = colorScheme.onSurface.withOpacity(0.6);

    List<Widget> items = [
      Icon(Icons.home, color: viewModel.selectedIndex == 0 ? activeColor : inactiveColor),
      Icon(Icons.calculate, color: viewModel.selectedIndex == 1 ? activeColor : inactiveColor),
      Icon(Icons.restaurant_menu, color: viewModel.selectedIndex == 2 ? activeColor : inactiveColor),
      Icon(Icons.stacked_bar_chart, color: viewModel.selectedIndex == 3 ? activeColor : inactiveColor),
    ];

    return CurvedNavigationBar(
      items: items,
      color: colorScheme.surface, // using surface instead of background
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: colorScheme.primary,
      index: viewModel.selectedIndex,
      onTap: (int index) {
        context.read<HomeViewModel>().setIndex(index);
      },
    );
  }
}
