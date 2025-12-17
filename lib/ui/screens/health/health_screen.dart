import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';
import '../../view_models/health_connect_view_model.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthConnectViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Health Connect")),
      body: SafeArea(
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Health Connect Data",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            if (!viewModel.isAuthorized)
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => viewModel.authorize(),
                    child: const Text("Connect to Health Connect"),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                             Column(
                               children: [
                                 const Icon(Icons.directions_walk, size: 40),
                                 const SizedBox(height: 8),
                                 Text("${viewModel.steps}", style: Theme.of(context).textTheme.titleLarge),
                                 const Text("Steps (Last 24h)"),
                               ],
                             ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: viewModel.isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.healthDataList.isEmpty
                          ? const Center(child: Text("No data found"))
                          : ListView.builder(
                            itemCount: viewModel.healthDataList.length,
                            itemBuilder: (context, index) {
                              HealthDataPoint p = viewModel.healthDataList[index];
                              return ListTile(
                                leading: _getIconForType(p.type),
                                title: Text(_formatType(p.type)),
                                subtitle: Text("${p.value}\n${p.dateFrom} - ${p.dateTo}"),
                                isThreeLine: true,
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: viewModel.isAuthorized 
        ? FloatingActionButton(
            onPressed: () => viewModel.fetchData(),
            child: const Icon(Icons.refresh),
          )
        : null,
    );
  }

  Icon _getIconForType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return const Icon(Icons.directions_walk);
      case HealthDataType.HEART_RATE:
        return const Icon(Icons.favorite);
      case HealthDataType.BLOOD_GLUCOSE:
        return const Icon(Icons.water_drop);
      default:
        return const Icon(Icons.health_and_safety);
    }
  }

  String _formatType(HealthDataType type) {
    return type.toString().split('.').last.replaceAll('_', ' ');
  }
}
