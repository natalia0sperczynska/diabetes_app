import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DexcomService {
  final String clientId = "id";
  final String clientSecret = "secret";

  final String redirectUri =
      "https://BinaryWiz4rd.github.io/dexcom-redirect/dexcom-callback.html";

  String _formatDateForDexcom(DateTime dt) {
    return dt.toUtc().toIso8601String().split('.').first;
  }

  Future<void> launchAuthentication() async {
    final url = Uri.parse(
        "https://sandbox-api.dexcom.com/v2/oauth2/login"
            "?client_id=$clientId"
            "&redirect_uri=$redirectUri"
            "&response_type=code"
            "&scope=read");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        print("Authentication URL launched. User must copy the code from the browser.");
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print("Authentication launch failed: $e");
    }
  }

  Future<String?> getAccessToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse("https://sandbox-api.dexcom.com/v2/oauth2/token"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "client_id": clientId,
          "client_secret": clientSecret,
          "code": code,
          "grant_type": "authorization_code",
          "redirect_uri": redirectUri,
        },
      );

      if (response.statusCode != 200) {
        print("Token exchange failed: ${response.statusCode} ${response.body}");
        return null;
      }

      final body = jsonDecode(response.body);
      return body["access_token"] as String?;
    } catch (e) {
      print("Token exchange exception: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEgvs({required String accessToken}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 3));

      final startDateString = _formatDateForDexcom(start);
      final endDateString = _formatDateForDexcom(now);

      final url =
          "https://sandbox-api.dexcom.com/v2/users/self/egvs"
          "?startDate=$startDateString"
          "&endDate=$endDateString";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        print("Fetch EGVs failed: ${response.statusCode} ${response.body}");
        return [];
      }

      final data = jsonDecode(response.body);
      return (data["egvs"] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print("Fetch EGVs exception: $e");
      return [];
    }
  }
}