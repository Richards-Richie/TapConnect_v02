import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ScannerDetailsList extends StatefulWidget {
  final Set<Map<String, dynamic>> scannersDetails;

  const ScannerDetailsList({super.key, required this.scannersDetails});

  @override
  State<ScannerDetailsList> createState() => _ScannerDetailsListState();

  String _decryptData(String encryptedText) {
    try {
      final parts = encryptedText.split(':');
      final iv = encryption.IV.fromBase64(parts[0].trim());
      final encrypted = encryption.Encrypted.fromBase64(parts[1].trim());

      final key = encryption.Key.fromUtf8(dotenv.env['ENCRYPTKEY']!);
      final encrypter = encryption.Encrypter(
          encryption.AES(key, mode: encryption.AESMode.cbc));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return 'Decryption failed';
    }
  }

  Future<void> _savecontact(
      name, phoneNumber, email, BuildContext context) async {
    final newContact = Contact()
      ..name.first = name
      ..phones = [Phone(phoneNumber)]
      ..emails = [Email(email)];

    try {
      final permissionGranted = await FlutterContacts.requestPermission();

      if (permissionGranted) {
        await newContact.insert();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission to access contacts denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contact: $e')),
      );
    }
  }
}

class _ScannerDetailsListState extends State<ScannerDetailsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scanners Details'),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widget.scannersDetails.map((scanner) {
            String Name = scanner['name'];
            String encryptedEmail = scanner['details']['email'];
            String encryptedMobile = scanner['details']['mobile'];

            String decryptedEmail = widget._decryptData(encryptedEmail);
            String decryptedMobile = widget._decryptData(encryptedMobile);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.purple[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: $decryptedEmail',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mobile: $decryptedMobile',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor:
                              const Color.fromARGB(255, 239, 236, 236),
                        ),
                        onPressed: () async {
                          await widget._savecontact(
                              Name, decryptedMobile, decryptedEmail, context);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
