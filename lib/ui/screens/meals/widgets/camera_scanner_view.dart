import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScannerView extends StatelessWidget {
  final bool initialized;
  final CameraController? controller;
  final VoidCallback onScan;

  const CameraScannerView({
    required this.initialized,
    required this.controller,
    required this.onScan,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (initialized &&
              controller != null &&
              controller!.value.isInitialized)
            CameraPreview(controller!)
          else
            Container(
              color: Colors.black12,
              child: const Center(
                child: Text('Camera not available'),
              ),
            ),

          /// overlay
          Center(
            child: Container(
              width: 260,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.black26,
              ),
              child: const Center(
                child: Text(
                  'Align barcode here',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          /// scan button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
            ),
          ),
        ],
      ),
    );
  }
}