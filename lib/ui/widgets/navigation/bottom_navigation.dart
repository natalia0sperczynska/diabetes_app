import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/home_view_model.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final neonColor = colorScheme.primary;
    final barColor = colorScheme.surface.withOpacity(0.95);

    Widget buildIcon(IconData icon, int index) {
      final isSelected = viewModel.selectedIndex == index;
      return Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.black : Colors.white,
        shadows: isSelected ? [] : [
          Shadow(color: neonColor, blurRadius: 10),
        ],
      );
    }
    List<Widget> items = [
      buildIcon(Icons.home, 0),
      buildIcon(Icons.calculate, 1),
      buildIcon(Icons.restaurant_menu, 2),
      buildIcon(Icons.stacked_bar_chart, 3),
    ];

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
      Positioned(
      bottom: -20,
      left: 0,
      right: 0,
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, 0.6),
            radius: 1.0,
            colors: [
              neonColor.withOpacity(0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    ),CurvedNavigationBar(
      items: items,
      color: barColor,
      height: 65.0,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: neonColor,
      index: viewModel.selectedIndex,
      animationCurve: Curves.easeInOutBack,
      animationDuration: const Duration(milliseconds: 500),
      onTap: (int index) {
        context.read<HomeViewModel>().setIndex(index);
      },
    ),
    ],
    );
  }
}
