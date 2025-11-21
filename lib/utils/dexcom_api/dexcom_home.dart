import 'package:flutter/material.dart';
import 'dexcom_service.dart';

class DexcomHome extends ChangeNotifier {
  final DexcomService dexService = DexcomService();

  List<double> dexcomValues = [];
  List<DateTime> dexcomTimes = [];

  String welcomeMessage = "Welcome!";
  bool isLoading = false;
  String? errorMessage;

  Future<void> launchDexcomAuth() async {
    errorMessage = null;
    notifyListeners();
    await dexService.launchAuthentication();
  }

  Future<void> loadDexcomData(String code) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (code.isEmpty) {
      errorMessage = "Authorization code cannot be empty.";
      isLoading = false;
      notifyListeners();
      return;
    }

    final accessToken = await dexService.getAccessToken(code);
    if (accessToken == null) {
      errorMessage = "Failed to get access token.";
      isLoading = false;
      notifyListeners();
      return;
    }

    final egvs = await dexService.fetchEgvs(accessToken: accessToken);

    if (egvs.isEmpty) {
      errorMessage = "No glucose data found or Dexcom API returned no data.";
    } else {
      dexcomValues = egvs.map((e) => (e["value"] as num).toDouble()).toList();
      dexcomTimes = egvs.map((e) => DateTime.parse(e["systemTime"])).toList();
    }

    isLoading = false;
    notifyListeners();
  }
}