import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes_app/ui/view_models/statistics_view_model.dart';
import 'package:diabetes_app/data/charts/chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatisticsViewModel>();
    final date = viewModel.selectedDate;
    final dateStr = "${date.day}/${date.month}/${date.year}";

    return Stack(
        children: [
    Container(
    color: Theme.of(context).scaffoldBackgroundColor
    ),

    Positioned.fill(
    child: Opacity(
    opacity: 0.15,
    child: Image.asset(
    'assets/images/grid.png',
    repeat: ImageRepeat.repeat,
    scale: 1.0,
    ),
    ),
    ),
    Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => viewModel.previousDay(),
                  ),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: viewModel.canGoNext ? () => viewModel.nextDay() : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : viewModel.errorMessage.isNotEmpty
                        ? Text("Error: ${viewModel.errorMessage}")
                        : viewModel.glucoseSpots.isEmpty
                            ? const Text("No data available for this date")
                            : SizedBox(
                                height: 500,
                                width: 500,
                                child: Chart(
                                  title: 'Glucose',
                                  glucoseSpots: viewModel.glucoseSpots,
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<StatisticsViewModel>().fetchGlucoseData();
        },
        child: const Icon(Icons.refresh),
      ),
    ),
    ],
    );
  }
}
