class LocalFoodService {
  // hardcoded list of basic foods with nutrition info and GI (kinda cheating but shhh)
  // GI values are based on averages (Harvard Health / Sydney University GI Database)
  static final List<Map<String, dynamic>> _localDatabase = [
    {
      'code': 'local_apple',
      'product_name': 'Apple (Raw, w/ Skin)',
      'nutriments': {
        'energy-kcal_100g': 52.0,
        'proteins_100g': 0.3,
        'fat_100g': 0.2,
        'carbohydrates_100g': 13.8,
        'fiber_100g': 2.4,
        'sugars_100g': 10.4,
        'salt_100g': 0.0,
        'glycemic-index': 36.0,
      }
    },
    {
      'code': 'local_banana',
      'product_name': 'Banana (Ripe)',
      'nutriments': {
        'energy-kcal_100g': 89.0,
        'proteins_100g': 1.1,
        'fat_100g': 0.3,
        'carbohydrates_100g': 22.8,
        'fiber_100g': 2.6,
        'sugars_100g': 12.2,
        'salt_100g': 0.0,
        'glycemic-index': 51.0,
      }
    },
    {
      'code': 'local_chicken_breast',
      'product_name': 'Chicken Breast (Raw)',
      'nutriments': {
        'energy-kcal_100g': 165.0,
        'proteins_100g': 31.0,
        'fat_100g': 3.6,
        'carbohydrates_100g': 0.0,
        'fiber_100g': 0.0,
        'sugars_100g': 0.0,
        'salt_100g': 0.2,
        'glycemic-index': 0.0,
      }
    },
    {
      'code': 'local_egg',
      'product_name': 'Egg (Large)',
      'nutriments': {
        'energy-kcal_100g': 143.0,
        'proteins_100g': 12.6,
        'fat_100g': 9.5,
        'carbohydrates_100g': 0.7,
        'fiber_100g': 0.0,
        'sugars_100g': 0.7,
        'salt_100g': 0.4,
        'glycemic-index': 0.0,
      }
    },
    {
      'code': 'local_white_rice',
      'product_name': 'White Rice (Cooked)',
      'nutriments': {
        'energy-kcal_100g': 130.0,
        'proteins_100g': 2.7,
        'fat_100g': 0.3,
        'carbohydrates_100g': 28.0,
        'fiber_100g': 0.4,
        'sugars_100g': 0.1,
        'salt_100g': 0.0,
        'glycemic-index': 73.0,
      }
    },
    {
      'code': 'local_brown_rice',
      'product_name': 'Brown Rice (Cooked)',
      'nutriments': {
        'energy-kcal_100g': 111.0,
        'proteins_100g': 2.6,
        'fat_100g': 0.9,
        'carbohydrates_100g': 23.0,
        'fiber_100g': 1.8,
        'sugars_100g': 0.4,
        'salt_100g': 0.0,
        'glycemic-index': 68.0,
      }
    },
    {
      'code': 'local_bread_white',
      'product_name': 'White Bread',
      'nutriments': {
        'energy-kcal_100g': 265.0,
        'proteins_100g': 9.0,
        'fat_100g': 3.2,
        'carbohydrates_100g': 49.0,
        'fiber_100g': 2.7,
        'sugars_100g': 5.0,
        'salt_100g': 1.2,
        'glycemic-index': 75.0,
      }
    },
    {
      'code': 'local_bread_wholewheat',
      'product_name': 'Whole Wheat Bread',
      'nutriments': {
        'energy-kcal_100g': 247.0,
        'proteins_100g': 13.0,
        'fat_100g': 3.4,
        'carbohydrates_100g': 41.0,
        'fiber_100g': 7.0,
        'sugars_100g': 6.0,
        'salt_100g': 1.1,
        'glycemic-index': 74.0,
      }
    },
    {
      'code': 'local_potato',
      'product_name': 'Potato (Boiled)',
      'nutriments': {
        'energy-kcal_100g': 87.0,
        'proteins_100g': 1.9,
        'fat_100g': 0.1,
        'carbohydrates_100g': 20.1,
        'fiber_100g': 1.8,
        'sugars_100g': 0.9,
        'salt_100g': 0.0,
        'glycemic-index': 78.0,
      }
    },
    {
      'code': 'local_milk',
      'product_name': 'Milk (Whole, 3.25%)',
      'nutriments': {
        'energy-kcal_100g': 61.0,
        'proteins_100g': 3.2,
        'fat_100g': 3.3,
        'carbohydrates_100g': 4.8,
        'fiber_100g': 0.0,
        'sugars_100g': 5.1,
        'salt_100g': 0.1,
        'glycemic-index': 39.0,
      }
    },
    {
      'code': 'local_oats',
      'product_name': 'Oats (Rolled, Raw)',
      'nutriments': {
        'energy-kcal_100g': 389.0,
        'proteins_100g': 16.9,
        'fat_100g': 6.9,
        'carbohydrates_100g': 66.3,
        'fiber_100g': 10.6,
        'sugars_100g': 0.0,
        'salt_100g': 0.0,
        'glycemic-index': 55.0,
      }
    },
    {
      'code': 'local_broccoli',
      'product_name': 'Broccoli (Raw)',
      'nutriments': {
        'energy-kcal_100g': 34.0,
        'proteins_100g': 2.8,
        'fat_100g': 0.4,
        'carbohydrates_100g': 6.6,
        'fiber_100g': 2.6,
        'sugars_100g': 1.7,
        'salt_100g': 0.1,
        'glycemic-index': 15.0,
      }
    }
  ];

  static Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();

    return _localDatabase.where((item) {
      final name = (item['product_name'] as String).toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }

  static Map<String, dynamic>? getProductByCode(String code) {
    try {
      return _localDatabase.firstWhere((item) => item['code'] == code);
    } catch (_) {
      return null;
    }
  }
}