import 'package:diabetes_app/ui/screens/home/home_screen.dart';
import 'package:diabetes_app/ui/themes/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/meal_view_model.dart';
import 'utils/dexcom_api/dexcom_home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
        ChangeNotifierProvider(create: (_) => DexcomHome()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes App',
      theme: AppTheme.pixelTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
