class GlycemicIndexStore {
  // dictionary of common foods and their approximate Glycemic Index (GI)
  // averages from Harvard Health and diabetic charts
  // Low: 0-55, Medium: 56-69, High: 70+
  static final Map<String, double> _commonGI = {
    'glucose': 100,
    'sucrose': 65,
    'fructose': 15,
    'honey': 61,
    'sugar': 65,
    'agave': 15,
    'maple syrup': 54,

    'white bread': 75,
    'whole wheat bread': 74,
    'sourdough': 54,
    'bagel': 72,
    'baguette': 95,
    'white rice': 73,
    'jasmine rice': 89,
    'brown rice': 68,
    'basmati rice': 67,
    'wild rice': 57,
    'quinoa': 53,
    'couscous': 65,
    'barley': 28,
    'oats': 55,
    'oatmeal': 55,
    'corn flakes': 81,
    'muesli': 57,
    'pasta': 49,
    'spaghetti': 49,
    'macaroni': 47,
    'pizza': 80,

    'apple': 36,
    'banana': 51,
    'overripe banana': 60,
    'orange': 43,
    'pear': 38,
    'grapes': 59,
    'strawberry': 40,
    'strawberries': 40,
    'blueberry': 53,
    'blueberries': 53,
    'raspberry': 32,
    'raspberries': 32,
    'cherry': 20,
    'cherries': 20,
    'grapefruit': 25,
    'peach': 42,
    'plum': 40,
    'watermelon': 72,
    'pineapple': 59,
    'mango': 51,
    'kiwi': 50,
    'dates': 42,

    'potato': 78,
    'baked potato': 85,
    'sweet potato': 63,
    'yam': 54,
    'corn': 52,
    'sweet corn': 52,
    'carrot': 39,
    'pumpkin': 75,
    'parsnip': 52,

    'broccoli': 15,
    'cabbage': 10,
    'lettuce': 10,
    'spinach': 15,
    'cucumber': 15,
    'tomato': 15,
    'zucchini': 15,
    'pepper': 15,
    'onion': 10,
    'cauliflower': 15,

    'milk': 39,
    'skim milk': 37,
    'yogurt': 41,
    'soy milk': 34,
    'rice milk': 86,
    'almond milk': 25,
    'ice cream': 51,
    'cheese': 0,
    'butter': 0,
    'cream': 0,

    'chicken': 0,
    'beef': 0,
    'pork': 0,
    'fish': 0,
    'egg': 0,
    'tofu': 15,
    'lentils': 32,
    'chickpeas': 28,
    'kidney beans': 24,
    'black beans': 30,
    'soy beans': 16,
    'peanuts': 7,
    'cashews': 22,
    'walnuts': 15,

    'cola': 63,
    'soda': 60,
    'chocolate': 40,
    'popcorn': 65,
    'chips': 51,
    'crisps': 51,
    'cracker': 70,
    'hummus': 6,
  };

  /// estimate GI based on the product name and categories (kinda lame but good for now)
  static double? estimateGI(String? productName, List<dynamic>? categories) {
    if (productName == null) return null;
    final lowerName = productName.toLowerCase();

    for (var entry in _commonGI.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    if (categories != null) {
      for (var tag in categories) {
        final lowerTag = tag.toString().toLowerCase().replaceAll('en:', '');
        for (var entry in _commonGI.entries) {
          if (lowerTag.contains(entry.key)) {
            return entry.value;
          }
        }
      }
    }

    return null;
  }
}