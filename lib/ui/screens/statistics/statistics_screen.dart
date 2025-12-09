import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes_app/ui/view_models/statistics_view_model.dart';
import 'package:diabetes_app/data/charts/chart.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatisticsViewModel>();

    return Scaffold(
      body: Center(
        child: viewModel.isLoading
            ? const CircularProgressIndicator()
            : viewModel.errorMessage.isNotEmpty
                ? Text("Error: ${viewModel.errorMessage}")
                : viewModel.glucoseSpots.isEmpty
                    ? const Text("No data available")
                    : SizedBox(
                        height: 500,
                        width: 500,
                        child: Chart(
                          title: 'Glucose',
                          glucoseSpots: viewModel.glucoseSpots,
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<StatisticsViewModel>().fetchGlucoseData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
