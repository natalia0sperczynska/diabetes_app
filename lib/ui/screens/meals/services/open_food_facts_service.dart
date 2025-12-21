import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// fetches a single product by barcode
  static Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/api/v0/product/$barcode.json');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;

      return data['product'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// searches for products by name
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=10',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) return [];

      final data = json.decode(res.body);
      final products = (data['products'] as List?) ?? [];

      return products.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}