import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return CurvedNavigationBar(
      items: <Widget>[
        const Icon(Icons.home_outlined),
        const Icon(Icons.restaurant_menu_outlined),
        const Icon(Icons.stacked_bar_chart_outlined),
      ],
      color: Theme.of(context).colorScheme.background,
      index: viewModel.selectedIndex,
      onTap: (int index) {
        context.read<HomeViewModel>().setIndex(index);
      },
    );
  }
}
