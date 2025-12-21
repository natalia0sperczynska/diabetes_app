import 'package:provider/provider.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import '../../view_models/analysis_view_model.dart';
import 'package:flutter/material.dart';
import '../../themes/colors/app_colors.dart';
import 'analysis_content.dart';

//tylko kontener na dane, bez logiki
class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalysisViewModel()..loadData(),
      child: Scaffold(
        backgroundColor: AppColors.darkBlue2,
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue1,
          title: Consumer<AnalysisViewModel>(
            builder: (context, vm, _) => Text(vm.currentTitle),
          ),
        ),
        body: const AnalysisContent(),
      ),
    );
  }
}