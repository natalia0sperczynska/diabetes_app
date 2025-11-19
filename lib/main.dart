import 'package:diabetes_app/ui/screens/home/home_screen.dart';
import 'package:diabetes_app/ui/screens/intro/intro_screen.dart';
import 'package:diabetes_app/ui/themes/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'ui/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'ui/screens/intro/intro_screen.dart';

void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HomeViewModel()),
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
    return MaterialApp(
      title: 'Diabetes App',
      theme: AppTheme.pixelTheme,
      debugShowCheckedModeBanner: false,
      home: IntroductionScreen(),
      //home: const HomeScreen(),
    );
  }
}