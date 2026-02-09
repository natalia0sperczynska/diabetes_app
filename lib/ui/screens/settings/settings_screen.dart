import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/sensor_preference_service.dart';
import '../../view_models/theme_view_model.dart';
import 'color_themes_tab.dart';
import 'dexcom_settings_screen.dart';
import 'libre_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SensorType _selectedSensorType = SensorType.none;
  bool _isLoadingSensor = true;

  final List<Tab> _tabs = const [
    Tab(text: "General"),
    Tab(text: "Color Themes"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadSensorPreference();
  }

  Future<void> _loadSensorPreference() async {
    final sensorType = await SensorPreferenceService.getSensorType();
    setState(() {
      _selectedSensorType = sensorType;
      _isLoadingSensor = false;
    });
  }

  Future<void> _setSensorType(SensorType type) async {
    await SensorPreferenceService.setSensorType(type);
    setState(() {
      _selectedSensorType = type;
    });
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
              
              // Sensor Type Selection Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CGM Sensor Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your continuous glucose monitor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_isLoadingSensor)
                const Center(child: CircularProgressIndicator())
              else ...[
                RadioListTile<SensorType>(
                  title: const Text('Dexcom'),
                  subtitle: const Text('Connect with Dexcom Share'),
                  value: SensorType.dexcom,
                  groupValue: _selectedSensorType,
                  onChanged: (value) {
                    if (value != null) _setSensorType(value);
                  },
                  secondary: const Icon(Icons.monitor_heart),
                ),
                RadioListTile<SensorType>(
                  title: const Text('FreeStyle Libre'),
                  subtitle: const Text('Connect with LibreLinkUp'),
                  value: SensorType.libre,
                  groupValue: _selectedSensorType,
                  onChanged: (value) {
                    if (value != null) _setSensorType(value);
                  },
                  secondary: const Icon(Icons.sensors),
                ),
                RadioListTile<SensorType>(
                  title: const Text('None'),
                  subtitle: const Text('No CGM sensor connected'),
                  value: SensorType.none,
                  groupValue: _selectedSensorType,
                  onChanged: (value) {
                    if (value != null) _setSensorType(value);
                  },
                  secondary: const Icon(Icons.not_interested),
                ),
              ],
              
              const Divider(),
              
              // Show settings based on selected sensor
              if (_selectedSensorType == SensorType.dexcom)
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Dexcom Settings'),
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
              
              if (_selectedSensorType == SensorType.libre)
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('LibreLinkUp Settings'),
                  subtitle: const Text('Configure LibreLinkUp login credentials'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LibreSettingsScreen(),
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
