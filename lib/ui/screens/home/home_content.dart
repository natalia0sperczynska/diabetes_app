import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:diabetes_app/ui/widgets/snack_bars/awesome_snack_bar.dart';
import 'package:diabetes_app/services/dexcom_service.dart';

import '../../view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/charts/chart.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = false;
  String _glucoseData = '';

  Future<void> _loadDexcomData() async {
    setState(() {
      _isLoading = true;
      _glucoseData = 'Loading data...';
    });

    try {
      final result = await DexcomService.getCurrentGlucose(
        username: 'anniefocused@gmail.com', // USERNAME ANI
        password:
            '',
      );

      if (result['success']) {
        setState(() {
          _glucoseData =
              '''
Glucose: ${result['value']} mg/dL
Trend: ${result['trend']}
Time: ${result['time']}
''';
        });

        if (mounted) {
          SnackbarUtils.showAwesomeSnackbar(
            context,
            title: "Success",
            message: "Dexcom data loaded!",
            contentType: ContentType.success,
          );
        }
      } else {
        setState(() {
          _glucoseData = 'Error: ${result['error']}';
        });

        if (mounted) {
          SnackbarUtils.showAwesomeSnackbar(
            context,
            title: "Error",
            message: result['error'],
            contentType: ContentType.failure,
          );
        }
      }
    } catch (e) {
      setState(() {
        _glucoseData = 'Connection Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.welcomeMessage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isLoading ? null : _loadDexcomData,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Load Data"),
              ),
            ],
          ),
          const SizedBox(width: 40),
          if (_glucoseData.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                _glucoseData,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          const SizedBox(width: 20),
          SizedBox(
            height:500,
            width: 500,
            child: Chart(title: 'Glucose', glucoseSpots: dummyData)
          ),
        ],
      ),
    );
  }
}

final List<FlSpot> dummyData = [
  const FlSpot(0, 110),
  const FlSpot(2, 105),
  const FlSpot(4, 100),
  const FlSpot(6, 110),
  const FlSpot(7.5, 160),
  const FlSpot(9, 140),
  const FlSpot(11, 100),
  const FlSpot(12.5, 180),
  const FlSpot(14, 210),
  const FlSpot(16, 150),
  const FlSpot(18, 110),
  const FlSpot(19.5, 155),
  const FlSpot(22, 130),
  const FlSpot(23.9, 115),
];
