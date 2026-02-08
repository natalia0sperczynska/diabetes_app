import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/analysis/analysis_screen.dart';
import '../../screens/doctor/doctor_screen.dart';
import '../../screens/health/health_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/menstrual_cycle/menstrual_cycle_screen.dart';
import '../../view_models/home_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/doctor_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    bool isFemale = user?.gender == 'Female';
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text(
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
            leading: const Icon(Icons.calculate),
            title: const Text('Calculator'),
            selected: viewModel.selectedIndex == 1,
            onTap: () {
              context.read<HomeViewModel>().setIndex(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Meals'),
            selected: viewModel.selectedIndex == 2,
            onTap: () {
              context.read<HomeViewModel>().setIndex(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.stacked_bar_chart),
            title: const Text('AI Analysis'),
            selected: viewModel.selectedIndex == 3,
            onTap: () {
              context.read<HomeViewModel>().setIndex(3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text('Health Connect'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HealthScreen()),
              );
            },
          ),
          if (isFemale)
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Menstrual Cycle'),
              selected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MenstrualCycleScreen()),
                );
              },
            ),
          if (user?.isDoctor == true)
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Doctor Panel'),
              selected: false,
              onTap: () {
                Navigator.pop(context);
                final doctorVm = context.read<DoctorViewModel>();
                doctorVm.loadPatients(user!);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DoctorScreen()),
                );
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
            leading: const Hero(tag: 'profile', child: Icon(Icons.person)),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
