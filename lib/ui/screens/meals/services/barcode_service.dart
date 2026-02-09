import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeService {
  static BarcodeScanner createScanner() {
    return BarcodeScanner(
      formats: [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upca,
        BarcodeFormat.upce,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.qrCode,
      ],
    );
  }
}