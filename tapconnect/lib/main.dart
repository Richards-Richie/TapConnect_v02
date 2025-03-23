// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tapconnect/detailsPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tapconnect/qrCodePage.dart';
import 'package:tapconnect/Scanner.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text("TapConnect"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => details()),
                );
              },
              icon: Icon(
                Icons.account_circle,
                color: Colors.purple[600],
                size: 50,
              ),
            )
          ],
        ),
        body: MainContent(), // Replace with your actual content widget
      ),
    );
  }
}

// This should be your main content widget
class MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ScannerPage()), // Navigate to ScannerPage
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 18, 18, 18),
              foregroundColor: Color.fromARGB(255, 239, 236, 236),
            ),
            icon: Icon(Icons.camera_alt_rounded, size: 50),
            label: Text("Camera"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeGenerator(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 18, 18, 18),
              foregroundColor: Color.fromARGB(255, 239, 236, 236),
            ),
            icon: Icon(Icons.qr_code_rounded, size: 50),
            label: Text("QR Code"),
          ),
        ],
      ),
    );
  }
}
