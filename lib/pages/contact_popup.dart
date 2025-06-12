import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactPopup extends StatelessWidget {
  const ContactPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F35),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact info
            const ListTile(
              leading: Icon(Icons.email, color: Color(0xFF173F35)),
              title: Text(
                "support@hasad.com",
                style: TextStyle(color: Color(0xFF173F35)),
              ),
            ),
            const ListTile(
              leading:
                  FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF173F35)),
              title: Text(
                "facebook.com/hasad",
                style: TextStyle(color: Color(0xFF173F35)),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF173F35)),
              title: Text(
                "+213 5 42 83 37 70",
                style: TextStyle(color: Color(0xFF173F35)),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF173F35)),
              title: Text(
                "+213 5 52 80 58 24",
                style: TextStyle(color: Color(0xFF173F35)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
