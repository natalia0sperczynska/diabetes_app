import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;

class Meal {
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final double sugars;
  final double salt;
  final int grams;

  Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.sugars,
    required this.salt,
    required this.grams,
  });
}
class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> with WidgetsBindingObserver {
  final int dailyCalorieGoal = 2500;
  final int proteinGoal = 150;
  final int fatGoal = 80;
  final int carbGoal = 250;

  int caloriesConsumed = 0;
  double proteinConsumed = 0;
  double fatConsumed = 0;
  double carbConsumed = 0;

  final List<Meal> meals = [];

  CameraController? _cameraController;
  BarcodeScanner? _barcodeScanner;
  bool _cameraInitialized = false;
  bool _scanningInProgress = false;
  CameraDescription? _cameraDescription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameraAndScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.stopImageStream();
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraAndScanner();
    }
  }

  Future<void> _initCameraAndScanner() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraInitialized = false);
        return;
      }
      _cameraDescription = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _barcodeScanner = BarcodeScanner(formats: [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upca,
        BarcodeFormat.upce,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.qrCode,
      ]);

      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _cameraInitialized = false;
      });
    }
  }

  Future<void> _captureAndScan() async {
    if (!_cameraInitialized || _cameraController == null || _scanningInProgress) return;
    try {
      _scanningInProgress = true;
      final XFile file = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final barcodes = await _barcodeScanner!.processImage(inputImage);

      if (barcodes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No barcode detected. Try again.')));
      } else {
        final barcode = barcodes.first;
        final value = barcode.rawValue;
        if (value != null && value.isNotEmpty) {
          await _onBarcodeFound(value);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode value empty.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan error: $e')));
    } finally {
      _scanningInProgress = false;
    }
  }

  void _manualBarcodeInput() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter barcode manually'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 5901234123457'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              Navigator.pop(context);
              if (code.isNotEmpty) _onBarcodeFound(code);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _onBarcodeFound(String code) async {
    final product = await _fetchProductFromOpenFoodFacts(code);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product not found on OpenFoodFacts.')));
      return;
    }
    _showAddWithGramsDialog(product);
  }

  Future<Map<String, dynamic>?> _fetchProductFromOpenFoodFacts(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = (data['product'] as Map<String, dynamic>);
      return product;
    } catch (e) {
      return null;
    }
  }

  double _toDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  void _showAddWithGramsDialog(Map<String, dynamic> product) {
    final String name = (product['product_name'] ?? product['generic_name'] ?? 'Unknown product').toString();
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final kcals100 = _toDoubleSafe(nutriments['energy-kcal_100g'] ?? nutriments['energy_100g'] ?? nutriments['energy_value'] ?? nutriments['energy_kcal_100g']);
    final protein100 = _toDoubleSafe(nutriments['proteins_100g'] ?? nutriments['protein_100g']);
    final fat100 = _toDoubleSafe(nutriments['fat_100g']);
    final carbs100 = _toDoubleSafe(nutriments['carbohydrates_100g'] ?? nutriments['carbohydrate_100g']);
    final fiber100 = _toDoubleSafe(nutriments['fiber_100g'] ?? nutriments['fibers_100g']);
    final sugars100 = _toDoubleSafe(nutriments['sugars_100g']);
    final salt100 = _toDoubleSafe(nutriments['salt_100g'] ?? nutriments['sodium_100g']);

    final gramsController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          String previewText() {
            final text = gramsController.text.trim();
            if (text.isEmpty) return '--';
            final grams = double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
            if (grams <= 0) return '--';
            final factor = grams / 100.0;
            final kcal = (kcals100 * factor).round();
            final p = (protein100 * factor);
            final f = (fat100 * factor);
            final c = (carbs100 * factor);
            return '${grams.toStringAsFixed(0)} g → $kcal kcal, P ${p.toStringAsFixed(1)}g, F ${f.toStringAsFixed(1)}g, C ${c.toStringAsFixed(1)}g';
          }

          return AlertDialog(
            title: Text('Add "$name"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(alignment: Alignment.centerLeft, child: Text('Enter amount in grams (per 100g data used):')),
                const SizedBox(height: 8),
                TextField(
                  controller: gramsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.scale), hintText: 'e.g. 150'),
                  onChanged: (_) => setStateDialog(() {}),
                ),
                const SizedBox(height: 12),
                Text(previewText(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextButton(
                  child: const Text('View full nutrition info'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final gText = gramsController.text.trim();
                  final grams = double.tryParse(gText.replaceAll(',', '.')) ?? 0.0;
                  if (grams <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid grams amount.')));
                    return;
                  }
                  final factor = grams / 100.0;
                  final kcal = (kcals100 * factor).round();
                  final protein = protein100 * factor;
                  final fat = fat100 * factor;
                  final carbs = carbs100 * factor;
                  final fiber = fiber100 * factor;
                  final sugars = sugars100 * factor;
                  final salt = salt100 * factor;

                  setState(() {
                    caloriesConsumed += kcal;
                    proteinConsumed += protein;
                    fatConsumed += fat;
                    carbConsumed += carbs;

                    meals.add(Meal(
                      name: '$name (${grams.toStringAsFixed(0)} g)',
                      calories: kcal,
                      protein: double.parse(protein.toStringAsFixed(1)),
                      fat: double.parse(fat.toStringAsFixed(1)),
                      carbs: double.parse(carbs.toStringAsFixed(1)),
                      fiber: double.parse(fiber.toStringAsFixed(1)),
                      sugars: double.parse(sugars.toStringAsFixed(1)),
                      salt: double.parse(salt.toStringAsFixed(2)),
                      grams: grams.round(),
                    ));
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final remainingCalories = dailyCalorieGoal - caloriesConsumed;
    final calorieProgress = (caloriesConsumed / dailyCalorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.keyboard), onPressed: _manualBarcodeInput, tooltip: 'Enter barcode manually'),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                if (_cameraInitialized && _cameraController != null && _cameraController!.value.isInitialized)
                  CameraPreview(_cameraController!)
                else
                  Container(
                    color: Colors.black12,
                    child: const Center(child: Text('Camera not available')),
                  ),
                Center(
                  child: Container(
                    width: 260,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black26,
                    ),
                    child: const Center(
                      child: Text('Align barcode here', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.extended(
                    heroTag: 'scanBtn',
                    onPressed: _captureAndScan,
                    label: const Text('Scan'),
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Remaining', style: TextStyle(fontSize: 14)),
                            Text('$remainingCalories kcal', style: TextStyle(fontSize: 22, color: cs.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Goal: $dailyCalorieGoal kcal'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: calorieProgress),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _macroColumn('Protein', proteinConsumed, proteinGoal),
                        _macroColumn('Fat', fatConsumed, fatGoal),
                        _macroColumn('Carbs', carbConsumed, carbGoal),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[meals.length - 1 - index]; // show newest first
                return ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(meal.name),
                  subtitle: Text('P ${meal.protein} g • F ${meal.fat} g • C ${meal.carbs} g • ${meal.grams} g'),
                  trailing: Text('${meal.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(meal.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calories: ${meal.calories} kcal'),
                            Text('Protein: ${meal.protein} g'),
                            Text('Fat: ${meal.fat} g'),
                            Text('Carbs: ${meal.carbs} g'),
                            Text('Fiber: ${meal.fiber} g'),
                            Text('Sugars: ${meal.sugars} g'),
                            Text('Salt: ${meal.salt} g'),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _manualQuickAddFallback,
        child: const Icon(Icons.add),
        tooltip: 'Add custom food',
      ),
    );
  }

  Widget _macroColumn(String label, double consumed, int goal) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(width: 60, child: LinearProgressIndicator(value: progress)),
        const SizedBox(height: 6),
        Text('${consumed.toStringAsFixed(1)} / $goal g'),
      ],
    );
  }

  void _manualQuickAddFallback() {
    final nameController = TextEditingController();
    final gramsController = TextEditingController(text: '100');
    final kcalController = TextEditingController(text: '0');
    final protController = TextEditingController(text: '0');
    final fatController = TextEditingController(text: '0');
    final carbController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add custom food'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: gramsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Grams')),
              TextField(controller: kcalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)')),
              TextField(controller: protController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)')),
              TextField(controller: fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat (g)')),
              TextField(controller: carbController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final grams = double.tryParse(gramsController.text.trim().replaceAll(',', '.')) ?? 0.0;
              final kcal = (double.tryParse(kcalController.text.trim().replaceAll(',', '.')) ?? 0.0).round();
              final prot = double.tryParse(protController.text.trim().replaceAll(',', '.')) ?? 0.0;
              final fat = double.tryParse(fatController.text.trim().replaceAll(',', '.')) ?? 0.0;
              final carb = double.tryParse(carbController.text.trim().replaceAll(',', '.')) ?? 0.0;

              if (name.isEmpty || grams <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name and grams.')));
                return;
              }

              setState(() {
                caloriesConsumed += kcal;
                proteinConsumed += prot;
                fatConsumed += fat;
                carbConsumed += carb;
                meals.add(Meal(
                  name: '$name (${grams.round()} g)',
                  calories: kcal,
                  protein: double.parse(prot.toStringAsFixed(1)),
                  fat: double.parse(fat.toStringAsFixed(1)),
                  carbs: double.parse(carb.toStringAsFixed(1)),
                  fiber: 0,
                  sugars: 0,
                  salt: 0,
                  grams: grams.round(),
                ));
              });

              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({required this.product, super.key});

  double _toDoubleSafe(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    String name = product['product_name'] ?? product['generic_name'] ?? 'Unknown product';

    Widget row(String label, dynamic value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            row('Calories (kcal / 100g)', nutriments['energy-kcal_100g'] ?? nutriments['energy_100g'] ?? '-'),
            row('Proteins (g / 100g)', nutriments['proteins_100g'] ?? '-'),
            row('Fat (g / 100g)', nutriments['fat_100g'] ?? '-'),
            row('Carbohydrates (g / 100g)', nutriments['carbohydrates_100g'] ?? '-'),
            row('Sugars (g / 100g)', nutriments['sugars_100g'] ?? '-'),
            row('Fiber (g / 100g)', nutriments['fiber_100g'] ?? '-'),
            row('Salt (g / 100g)', nutriments['salt_100g'] ?? '-'),
            const SizedBox(height: 12),
            Text(product['brands']?.toString() ?? '', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Barcode: ${product['code'] ?? '-'}', style: const TextStyle(color: Colors.black45)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}