import 'package:diabetes_app/ui/screens/intro/intro_screen.dart';
import 'package:diabetes_app/ui/widgets/vibe/crt_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/meal_view_model.dart';
import 'ui/view_models/analysis_view_model.dart';
import 'package:provider/provider.dart';

import 'ui/view_models/theme_view_model.dart';
import 'ui/view_models/statistics_view_model.dart';
import 'ui/view_models/health_connect_view_model.dart';
import 'ui/view_models/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()),
        ChangeNotifierProvider(create: (_) => HealthConnectViewModel()),
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
      title: 'Diabeto',
      themeMode: themeViewModel.themeMode,
      theme: themeViewModel.lightThemeData,
      darkTheme: themeViewModel.darkThemeData,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const CrtOverlay(),
          ],
        );
      },
      home: const IntroductionScreen(),
      //home: const HomeScreen(),
    );
  }
}
