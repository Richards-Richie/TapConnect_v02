// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class details extends StatefulWidget {
  const details({super.key});
  @override
  State<details> createState() => _detailsState();
}

class _detailsState extends State<details> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String encryptData(String text) {
    final plainText = text;
    final key1 = encryption.Key.fromUtf8(dotenv.env['ENCRYPTKEY']!);
    final iv = encryption.IV.fromLength(16);
    final encrypter = encryption.Encrypter(
        encryption.AES(key1, mode: encryption.AESMode.cbc));
    final encryptedData = encrypter.encrypt(plainText, iv: iv);
    return "${iv.base64} :${encryptedData.base64} ";
  }

  String decryptData(String encryptedText) {
    // Split the combined IV + encrypted data
    final parts = encryptedText.split(':');
    final iv = encryption.IV.fromBase64(parts[0].trim());
    final encrypted = encryption.Encrypted.fromBase64(parts[1].trim());

    final key = encryption.Key.fromUtf8(dotenv.env['ENCRYPTKEY']!);
    final encrypter = encryption.Encrypter(
      encryption.AES(key, mode: encryption.AESMode.cbc),
    );

    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<void> saveUserId(userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
    } catch (error) {
      print(error);
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> saveDetails() async {
    try {
      final String name = _name.text;
      final String mobile = encryptData(_mobile.text);
      final String email = encryptData(_email.text);

      final response = await http
          .post(
            Uri.parse('http://localhost:5555/putDetails'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'mobile': mobile,
              'email': email,
            }),
          )
          .timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userId = responseData['userId'];
        await saveUserId(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details saved successfully' + userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: data')),
        );
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection')),
      );
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request time out")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text("Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              style: const TextStyle(color: Color.fromARGB(255, 232, 230, 230)),
              decoration: const InputDecoration(
                labelText: 'Enter name',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 234, 232, 232)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mobile,
              style: const TextStyle(color: Color.fromARGB(255, 232, 230, 230)),
              decoration: const InputDecoration(
                labelText: 'Enter mobile',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 234, 232, 232)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              style: const TextStyle(color: Color.fromARGB(255, 232, 230, 230)),
              decoration: const InputDecoration(
                labelText: 'Enter email',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 234, 232, 232)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: const Color.fromARGB(255, 239, 236, 236),
                  ),
                  onPressed: saveDetails,
                  child: const Text("save")),
            ),
          ],
        ),
      ),
    );
  }
}
