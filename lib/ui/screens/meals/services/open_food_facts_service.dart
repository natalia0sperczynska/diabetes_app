import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;

      return data['product'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}