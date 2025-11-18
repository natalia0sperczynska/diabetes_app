import 'package:flutter/material.dart';

import '../../../utils/app_assets/app_assets.dart';
import '../../themes/colors/app_colors.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: AppColors.darkBlue1,
              borderRadius: BorderRadius.zero,
            ),
            child: Image.asset(
              AppAssets.placeholder,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          Text("MEALS LOG"),
        ],
      ),
    );
  }
}
