import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/theme_view_model.dart';
import '../../themes/colors/app_colors.dart';

class ColorThemesTab extends StatelessWidget {
  const ColorThemesTab({super.key});

  // Define themes to be displayed with their main colors to preview
  static final Map<String, List<Color>> themeColors = {
    'pixel': [
      AppColors.mainBlue,
      AppColors.mainComplement,
      AppColors.pink,
      AppColors.darkBlue1,
    ],
    'popeYellow': [
      AppColors.popeYellowPrimaryLight,
      AppColors.popeYellowSecondaryLight,
      AppColors.popeYellowSurfaceLight,
      AppColors.popeYellowBackgroundLight,
    ],
    'forestGreen': [
      AppColors.forestGreenPrimaryLight,
      AppColors.forestGreenSecondaryLight,
      AppColors.forestGreenSurfaceLight,
      AppColors.forestGreenBackgroundLight,
    ],
    'sunsetOrange': [
      AppColors.sunsetOrangePrimaryLight,
      AppColors.sunsetOrangeSecondaryLight,
      AppColors.sunsetOrangeSurfaceLight,
      AppColors.sunsetOrangeBackgroundLight,
    ],
    'deepPurple': [
      AppColors.deepPurplePrimaryLight,
      AppColors.deepPurpleSecondaryLight,
      AppColors.deepPurpleSurfaceLight,
      AppColors.deepPurpleBackgroundLight,
    ],
    'oceanBlue': [
      AppColors.oceanBluePrimaryLight,
      AppColors.oceanBlueSecondaryLight,
      AppColors.oceanBlueSurfaceLight,
      AppColors.oceanBlueBackgroundLight,
    ],
    'cyberPunk':[
      AppColors.cyberBlack,
      AppColors.cyberDarkBlue,
      AppColors.neonPink,
      AppColors.neonCyan,
      AppColors.neonGreen,
    ]
  };

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final selectedTheme = themeViewModel.selectedTheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: themeColors.entries.map((entry) {
        final themeName = entry.key;
        final colors = entry.value;
        final isSelected = themeName == selectedTheme;

        return Card(
          color: isSelected ? Colors.blue.shade100 : null,
          child: ListTile(
            onTap: () {
              themeViewModel.setTheme(themeName);
            },
            title: Text(
              _themeDisplayName(themeName),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: colors
                  .map((color) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black26),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _themeDisplayName(String key) {
    // Map internal theme keys to display names with spaces and capitalization
    switch (key) {
      case 'pixel':
        return 'Pixel';
      case 'popeYellow':
        return 'Pope Yellow';
      case 'forestGreen':
        return 'Forest Green';
      case 'sunsetOrange':
        return 'Sunset Orange';
      case 'deepPurple':
        return 'Deep Purple';
      case 'oceanBlue':
        return 'Ocean Blue';
        case 'cyberPunk':
        return 'Cyber Punk';
      default:
        return key;
    }
  }
}
