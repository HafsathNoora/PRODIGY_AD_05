import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const QRScannerApp());

class QRScannerApp extends StatelessWidget {
  const QRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Scanner',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const QRScannerScreen(),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? scannedData;

  void handleScannedBarcode(String code) {
    setState(() {
      scannedData = code;
    });
  }

  Future<void> launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can't launch the URL")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final barcode = capture.barcodes.first;
                final String? code = barcode.rawValue;
                if (code != null && scannedData != code) {
                  handleScannedBarcode(code);
                }
              },
            ),
          ),
          if (scannedData != null)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Scanned Data:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(scannedData!),
                    const SizedBox(height: 20),
                    if (scannedData!.startsWith('http'))
                      ElevatedButton(
                        onPressed: () => launchURL(scannedData!),
                        child: const Text('Open Link'),
                      )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
