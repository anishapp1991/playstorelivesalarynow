import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class PDFProtectedScreen extends StatefulWidget {
  final String? url;

  const PDFProtectedScreen({Key? key, this.url})
      : super(key: key);

  @override
  State<PDFProtectedScreen> createState() => _PDFProtectedScreenState();
}

class _PDFProtectedScreenState extends State<PDFProtectedScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
      ),
      body: SfPdfViewer.network(
        widget.url!,
        // 'https://cdn.syncfusion.com/content/PDFViewer/encrypted.pdf',
        // password:'syncfusion',
        canShowPasswordDialog: true,
      )
    );
  }
}