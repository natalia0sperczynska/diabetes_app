import 'package:diabetes_app/utils/app_assets/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'intro_component.dart';
import '../../view_models/home_view_model.dart';
import '../home/home_screen.dart';

List<Widget> getPagesWithContext(BuildContext context) {
  return [
    IntroComponent(
      title: "MONITOR YOUR SUGAR",
      description: "Connect to your sensor and track your glucose levels.",
      image: AppAssets.logo,
    ),
    IntroComponent(
      title: "TRACK YOUR MEALS",
      description:
          "Log down your carbohydrates and see how they affect your health.",
      image: AppAssets.logo,
      onImageTap: () {
        // Navigate to HomeScreen with Meals tab selected
        context.read<HomeViewModel>().setIndex(1);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
    ),
    IntroComponent(
      title: "ANALYZE YOUR RESULTS",
      description: "Clear graphs will help you better control your diabetes.",
      image: AppAssets.logo,
    ),
  ];
}

// Keep for backwards compatibility
final List<Widget> pages = [
  IntroComponent(
    title: "MONITOR YOUR SUGAR",
    description: "Connect to your sensor and track your glucose levels.",
    image: AppAssets.logo,
  ),
  IntroComponent(
    title: "TRACK YOUR MEALS",
    description:
        "Log down your carbohydrates and see how they affect your health.",
    image: AppAssets.logo,
  ),
  IntroComponent(
    title: "ANALYZE YOUR RESULTS",
    description: "Clear graphs will help you better control your diabetes.",
    image: AppAssets.logo,
  ),
];
