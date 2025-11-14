import 'package:diabetes_app/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'ui/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'ui/screens/home/home_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}