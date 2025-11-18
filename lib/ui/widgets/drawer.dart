import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../view_models/home_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: viewModel.selectedIndex == 0,
            onTap: () {
              context.read<HomeViewModel>().setIndex(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Meals'),
            selected: viewModel.selectedIndex == 1,
            onTap: () {
              context.read<HomeViewModel>().setIndex(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.stacked_bar_chart),
            title: const Text('Stats'),
            selected: viewModel.selectedIndex == 2,
            onTap: () {
              context.read<HomeViewModel>().setIndex(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
