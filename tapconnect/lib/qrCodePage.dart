import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tapconnect/ScannersList.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({super.key});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  String name = '';
  String mobile = '';
  String email = '';
  String userId = '';
  String qrData = '';
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    // Note: Do not establish the websocket connection here.
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  String _decryptData(String encryptedText) {
    final parts = encryptedText.split(':');
    final iv = encryption.IV.fromBase64(parts[0].trim());
    final encrypted = encryption.Encrypted.fromBase64(parts[1].trim());

    final key = encryption.Key.fromUtf8(dotenv.env['ENCRYPTKEY']!);
    final encrypter =
        encryption.Encrypter(encryption.AES(key, mode: encryption.AESMode.cbc));

    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<void> _connectWebSocket(String wsUrl, String userId) async {
    // Establish the websocket connection on demand.
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    final Set<Map<String, dynamic>> scannerList = {};
    channel!.stream.listen(
      (message) {
        // print("Received from WebSocket: $message");
        final parsedData = json.decode(message);
        if (parsedData['type'] == 'scannersUpdate') {
          print(parsedData['scanners']);
          final scannersDetails = parsedData['scanners'] as List<dynamic>;
          for (var scanner in scannersDetails) {
            scannerList.add({'name': scanner['name'], 'details': scanner});
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScannerDetailsList(scannersDetails: scannerList),
            ),
          );
        }
        // Process message here...
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
      onDone: () {
        print("WebSocket connection closed");
      },
    );

    // Register with the server by sending your userId.
    channel!.sink.add(json.encode({
      "type": "register",
      "userId": userId,
    }));
  }

  Future<void> _triggerQrDetails() async {
    // Get userId and call /QrDetails HTTP endpoint.
    final userId = await _getUserId();
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('http://40.81.249.61:5555/QrDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      final respData = json.decode(response.body);
      final wsUrl = respData['wsUrl'];
      // Now connect to the WebSocket server on demand.
      _connectWebSocket(wsUrl, userId);
    } else {
      print("Failed to trigger QR details");
    }
  }

  Future<void> _getUserDetails() async {
    try {
      final userId1 = await _getUserId();
      if (userId1 != null && userId1.isNotEmpty) {
        final response = await http.post(
          Uri.parse('http://40.81.249.61:5555/getDetails'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'userId': userId1}),
        );

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          setState(() {
            name = responseBody['data']['name'];
            mobile = _decryptData(responseBody['data']['mobile']);
            email = _decryptData(responseBody['data']['email']);
            userId = userId1;
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Widget _buildQrCode() {
    qrData = 'Name: $name\nPhone: $mobile\nEmail: $email\nuserId: $userId';
    return Container(
      color: const Color.fromARGB(255, 239, 236, 236),
      padding: const EdgeInsets.all(16),
      child: QrImageView(
        data: qrData,
        size: 250,
        version: QrVersions.auto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        foregroundColor: const Color.fromARGB(255, 239, 236, 236),
      ),
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQrCode(),
            const SizedBox(height: 16),
            const Text(
              "Scan this QR Code",
              style: TextStyle(
                color: Color.fromARGB(255, 239, 236, 239),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _triggerQrDetails();
              },
              child: const Text("Get user Details"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }
}
