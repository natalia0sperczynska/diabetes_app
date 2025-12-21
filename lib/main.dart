import 'package:diabetes_app/ui/screens/intro/intro_screen.dart';
import 'package:diabetes_app/ui/themes/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
