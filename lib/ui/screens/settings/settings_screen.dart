import 'package:diabetes_app/ui/widgets/glitch.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../view_models/theme_view_model.dart';
import 'color_themes_tab.dart';

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

    return Stack(
        children: [
    Container(
    color: Theme.of(context).scaffoldBackgroundColor),

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
    appBar: AppBar(

    title: CyberGlitchText("Settings",style: GoogleFonts.vt323(fontSize: 32, color:Theme.of(context).colorScheme.onPrimary),),
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
    secondary: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
    ),
    ],
    ),

    // Color Themes tab content - placeholder to be replaced by new widget
    const ColorThemesTab(),
    ],
    ),
    ),
    ],
    );
    }
}
