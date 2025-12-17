import 'package:diabetes_app/ui/screens/intro/intro_screen.dart';
import 'package:flutter/material.dart';
import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/meal_view_model.dart';
import 'ui/view_models/analysis_view_model.dart';
import 'package:provider/provider.dart';

import 'ui/view_models/theme_view_model.dart';
import 'ui/view_models/statistics_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()),
        ChangeNotifierProvider(create: (_) => AnalysisViewModel()),
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
      home: const IntroductionScreen(),
      //home: const HomeScreen(),
    );
  }
}
