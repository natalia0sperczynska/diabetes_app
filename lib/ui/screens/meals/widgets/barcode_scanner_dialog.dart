import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../services/barcode_service.dart';
import 'camera_scanner_view.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  BarcodeScanner? _barcodeScanner;

  bool _initialized = false;
  bool _scanning = false;

  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner?.close();
    _manualController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _barcodeScanner = BarcodeService.createScanner();

      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      debugPrint("Camera Init Error: $e");
      if (mounted) setState(() => _initialized = false);
    }
  }

  Future<void> _scan() async {
    if (_scanning || !_initialized || _cameraController == null) return;

    setState(() => _scanning = true);

    try {
      final image = await _cameraController!.takePicture();
      final input = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner!.processImage(input);

      if (barcodes.isNotEmpty) {
        final value = barcodes.first.rawValue;
        if (value != null && value.isNotEmpty && mounted) {
          Navigator.pop(context, value);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No barcode detected. Try again.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _submitManual() {
    final code = _manualController.text.trim();
    if (code.isNotEmpty) {
      Navigator.pop(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double squareSize = constraints.maxWidth;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                SizedBox.square(
                  dimension: squareSize,
                  child: CameraScannerView(
                    initialized: _initialized,
                    controller: _cameraController,
                    onScan: _scan,
                  ),
                ),

                const Divider(height: 24),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _manualController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Enter barcode manually',
                      prefixIcon: const Icon(Icons.keyboard),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _submitManual,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _submitManual(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}