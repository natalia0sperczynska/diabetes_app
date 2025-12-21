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
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),

          /// overlay Viewfinder
          Center(
            child: Container(
              width: 240,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.extended(
              heroTag: 'scan_btn',
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!initialized ||
        controller == null ||
        !controller!.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.previewSize?.height ?? 1,
              height: controller!.value.previewSize?.width ?? 1,
              child: CameraPreview(controller!),
            ),
          ),
        );
      },
    );
  }
}