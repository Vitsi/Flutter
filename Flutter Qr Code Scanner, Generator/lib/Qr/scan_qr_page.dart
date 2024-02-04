import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const QRViewWidget());

class QRViewWidget extends StatefulWidget {
  const QRViewWidget({Key? key}) : super(key: key);

  @override
  QRViewWidgetState createState() => QRViewWidgetState();
}

class QRViewWidgetState extends State<QRViewWidget> {
  String _scanBarcode = '';

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(222, 37, 10, 105),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Barcode and QR code scan'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back button press
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearScanResult,
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 200),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () => scanBarcodeNormal(),
                      child: const Text('Start barcode scan'),
                    ),
                    OutlinedButton(
                      onPressed: () => scanQR(),
                      child: const Text('Start QR scan'),
                    ),
                    OutlinedButton(
                      onPressed: () => scanFromGallery(),
                      child: const Text('Scan from Gallery'),
                    ),
                  ],
                ),
                SizedBox(height: 160),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                      
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(222, 37, 10, 105)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Scanned result: $_scanBarcode',
                                style: TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () => _copyToClipboard(_scanBarcode),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> scanFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // You need to handle the image here, for example, by displaying it.
      // You can use the pickedFile.path to get the file path.

      // Now, let's scan the barcode from the picked image.
      String barcodeScanRes;
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666',
          'Cancel',
          true,
          ScanMode.DEFAULT,
          //path: pickedFile.path,
        );
        debugPrint(barcodeScanRes);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      if (!mounted) return;

      setState(() {
        _scanBarcode = barcodeScanRes;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to Clipboard'),
      ),
    );
  }

  void _clearScanResult() {
    setState(() {
      _scanBarcode = '';
    });
  }
}
