import 'save_open_document.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> generate(String text1, String text2) async {
    final pdf = Document();
    pdf.addPage(
      Page(
        build: (Context context) => Center(
            child: Column(children: [
          Text(text1, style: const TextStyle(fontSize: 20)),
          Text(text2, style: const TextStyle(fontSize: 20))
        ])),
      ),
    );
    return SaveAndOpenDocument.savePDF(name: 'result.pdf', pdf: pdf);
  }
}
