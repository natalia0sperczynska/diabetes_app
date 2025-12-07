import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Meal {
  final String name;
  final int calories;
  final String macros;

  Meal(this.name, this.calories, this.macros);
}

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final List<Meal> meals = [];

  Future<void> openBarcodeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeScannerView(camera: camera, onScan: _onBarcodeScanned),
      ),
    );
  }

  void _onBarcodeScanned(String code) async {
    final product = await fetchProduct(code);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found.')),
      );
      return;
    }
    _showMealAddDialog(product);
  }

  Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    final url = Uri.parse("https://world.openfoodfacts.org/api/v0/product/$barcode.json");
    final res = await http.get(url);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data['status'] != 1) return null;
    return data['product'];
  }

  void _showMealAddDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add ${product['product_name'] ?? 'Unknown'} to:"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mealTarget("Breakfast", product),
              _mealTarget("Lunch", product),
              _mealTarget("Dinner", product),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text("View Full Nutrition Info"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _mealTarget(String label, Map<String, dynamic> p) {
    final kcal = ((p['nutriments']?['energy-kcal_100g']) ?? 0).round();
    final protein = ((p['nutriments']?['proteins_100g']) ?? 0).round();
    final fat = ((p['nutriments']?['fat_100g']) ?? 0).round();
    final carbs = ((p['nutriments']?['carbohydrates_100g']) ?? 0).round();

    return ListTile(
      title: Text(label),
      onTap: () {
        setState(() {
          meals.add(
            Meal(
              "$label: ${p['product_name']}",
              kcal,
              "P: $protein g, F: $fat g, C: $carbs g",
            ),
          );
        });
        Navigator.pop(context);
      },
    );
  }

  void _manualBarcodeInput() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter barcode manually"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. 5901234123457"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Search"),
            onPressed: () {
              Navigator.pop(context);
              _onBarcodeScanned(controller.text.trim());
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: openBarcodeCamera,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: _manualBarcodeInput,
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var meal in meals)
            ListTile(
              title: Text(meal.name),
              subtitle: Text(meal.macros),
              trailing: Text("${meal.calories} kcal"),
            )
        ],
      ),
    );
  }
}

// i used ML google kit (mowie wam, jesli googlowskie to musi dzialac dobrze)
class BarcodeScannerView extends StatefulWidget {
  final CameraDescription camera;
  final Function(String) onScan;

  const BarcodeScannerView({required this.camera, required this.onScan, super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  late CameraController controller;
  late BarcodeScanner scanner;
  bool scanning = true;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    scanner = BarcodeScanner(formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upca, BarcodeFormat.upce]);

    controller.initialize().then((_) {
      if (!mounted) return;
      controller.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future<void> _processCameraImage(CameraImage img) async {
    if (!scanning) return;

    final plane = img.planes.first;
    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(img.width.toDouble(), img.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );

    final barcodes = await scanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      scanning = false;
      final value = barcodes.first.rawValue;
      if (value != null) {
        widget.onScan(value);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(10),
              color: Colors.black54,
              child: const Text(
                "Scan a barcode",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final nutriments = product['nutriments'] ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(product['product_name'] ?? 'Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(product['product_name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _nutriItem("Calories (100g)", nutriments['energy-kcal_100g']?.toString() ?? "-"),
            _nutriItem("Proteins (100g)", nutriments['proteins_100g']?.toString() ?? "-"),
            _nutriItem("Fat (100g)", nutriments['fat_100g']?.toString() ?? "-"),
            _nutriItem("Carbs (100g)", nutriments['carbohydrates_100g']?.toString() ?? "-"),
            _nutriItem("Sugars (100g)", nutriments['sugars_100g']?.toString() ?? "-"),
            _nutriItem("Salt (100g)", nutriments['salt_100g']?.toString() ?? "-"),
          ],
        ),
      ),
    );
  }

  Widget _nutriItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}