import 'package:diabetes_app/ui/screens/intro/intro_screen.dart';
import 'package:flutter/material.dart';
import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/meal_view_model.dart';
import 'package:provider/provider.dart';

import 'ui/view_models/theme_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        //inne providery
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //glowny widget apki
  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'Diabetes App',
      themeMode: themeViewModel.themeMode,
      theme: themeViewModel.lightThemeData,
      darkTheme: themeViewModel.darkThemeData,
      debugShowCheckedModeBanner: false,
      home: IntroductionScreen(),
      //home: const HomeScreen(),
    );
  }
}
