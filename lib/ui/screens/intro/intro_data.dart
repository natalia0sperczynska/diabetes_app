import 'package:diabetes_app/utils/app_assets/app_assets.dart';
import 'package:flutter/material.dart';
import 'intro_component.dart';

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
