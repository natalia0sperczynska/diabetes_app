import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/theme_view_model.dart';
import 'color_themes_tab.dart';
import 'dexcom_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: "General"),
    Tab(text: "Color Themes"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDarkMode = themeViewModel.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // General tab content
          ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (value) {
                  themeViewModel.toggleTheme();
                },
                secondary:
                    Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.monitor_heart),
                title: const Text('Dexcom Connection'),
                subtitle: const Text('Configure Dexcom login credentials'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DexcomSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const ColorThemesTab(),
        ],
      ),
    );
  }
}
