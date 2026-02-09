# TODO: Add 5 New Themes with Dark and Light Modes to Diabetes App

## Tasks:

1. lib/ui/themes/colors/app_colors.dart
   - Add new color constants for 5 new themes including "pope yellow" (both light and dark mode colors).

2. lib/ui/themes/theme/app_theme.dart
   - Add ThemeData getters for light and dark modes of the 5 new themes.
   - Follow the pattern of existing pixelTheme and pixelLightTheme.

3. lib/ui/view_models/theme_view_model.dart
   - Extend to hold the currently selected theme by name/id.
   - Keep themeMode (light/dark) state.
   - Add methods to set current theme and toggle light/dark mode.
   - Notify listeners on changes.

4. lib/main.dart
   - Update theme and darkTheme in MaterialApp to use the current theme from ThemeViewModel dynamically.
   - Map theme names to ThemeData getters.

5. lib/ui/screens/settings/settings_screen.dart
   - Add a DropdownButton or ListView to select among available theme names.
   - Keep the Dark Mode switch to toggle dark/light mode of selected theme.
   - Consume ThemeViewModel for current theme and themeMode states.

## Follow-up:
- Test the theme selection and light/dark toggling across the app with the new themes.
