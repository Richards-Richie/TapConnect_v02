import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SaveContactPage extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;

  SaveContactPage({
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  @override
  _SaveContactPageState createState() => _SaveContactPageState();
}

class _SaveContactPageState extends State<SaveContactPage> {
  String name = '';
  String phoneNumber = '';
  String email = '';

  @override
  void initState() {
    super.initState();

    // Trim the prefixes such as "Name:", "Phone:", and "Email:" if present
    name = _removePrefix(widget.name, 'Name: ');
    phoneNumber = _removePrefix(widget.phoneNumber, 'Phone: ');
    email = _removePrefix(widget.email, 'Email: ');
  }

  // Helper function to remove the prefix from a string
  String _removePrefix(String text, String prefix) {
    if (text.startsWith(prefix)) {
      return text.substring(prefix.length).trim();
    }
    return text.trim();
  }

  // Function to save the contact using flutter_contacts
  Future<void> _saveContact() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        title: Text('Save Contact'),
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        foregroundColor: Color.fromARGB(255, 239, 236, 236),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: name),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 232, 230, 230)),
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: phoneNumber),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 232, 230, 230)),
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: email),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 232, 230, 230)),
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              onPressed: _saveContact, // Call _saveContact to save contact
              child: Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
