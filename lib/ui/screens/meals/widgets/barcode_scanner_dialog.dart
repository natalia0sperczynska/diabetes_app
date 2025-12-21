import 'dart:async';
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

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  CameraController? _cameraController;
  BarcodeScanner? _scanner;
  bool _initialized = false;
  bool _busy = false;
  final _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanner?.close();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    _scanner = BarcodeService.createScanner();

    setState(() => _initialized = true);
  }

  Future<void> _scan() async {
    if (_busy || !_initialized) return;
    _busy = true;

    try {
      final file = await _cameraController!.takePicture();
      final image = InputImage.fromFilePath(file.path);
      final barcodes = await _scanner!.processImage(image);

      if (barcodes.isNotEmpty) {
        final value = barcodes.first.rawValue;
        if (value != null && value.isNotEmpty) {
          Navigator.pop(context, value);
        }
      }
    } finally {
      _busy = false;
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
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CameraScannerView(
            initialized: _initialized,
            controller: _cameraController,
            onScan: _scan,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _manualController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter barcode manually',
                prefixIcon: const Icon(Icons.keyboard),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
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
  }
}