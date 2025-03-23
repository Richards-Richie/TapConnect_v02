// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'saveContact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String name = "";
  String phoneNumber = "";
  String email = "";
  String userId = "";

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _triggerScannerDetails(ScannerId, QrId) async {
    final triggerRes = await http.post(
      Uri.parse('http://localhost:5555/ScannerDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'scannerId': ScannerId, 'qrId': QrId}),
    );
    if (triggerRes.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Shared your details sucessfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('could not share your details please try again')),
      );
    }
  }

  void _onQRCodeDetected(BarcodeCapture barcode) async {
    final myUserId = await _getUserId();
    if (barcode.barcodes.isNotEmpty) {
      final String code = barcode.barcodes.first.rawValue ?? '';
      final contactInfo = code.split(RegExp(r'[\n,;]+'));

      if (contactInfo.isNotEmpty) name = contactInfo[0].trim();
      if (contactInfo.length > 1) phoneNumber = contactInfo[1].trim();
      if (contactInfo.length > 2) email = contactInfo[2].trim();
      if (contactInfo.length > 3) userId = contactInfo[3].split(': ')[1].trim();
      print(userId);
      _triggerScannerDetails(myUserId, userId);
      setState(() {});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaveContactPage(
            name: name,
            phoneNumber: phoneNumber,
            email: email,
          ),
        ),
      );
    }
  }

  Widget _buildScannerBox() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 239, 236, 236), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MobileScanner(
          controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates),
          onDetect: _onQRCodeDetected,
        ),
      ),
    );
  }

  Widget _buildScannedData() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Scanned Data: $name, $phoneNumber, $email',
            style: TextStyle(
              color: Color.fromARGB(255, 239, 236, 236),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        foregroundColor: Color.fromARGB(255, 239, 236, 236),
      ),
      body: Stack(
        children: [
          Center(child: _buildScannerBox()),
          if (name.isNotEmpty) _buildScannedData(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
    );
  }
}
