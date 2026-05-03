import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _open(String value) async {
    await launchUrl(Uri.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Our Email / Contact Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F2A44),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xffE4E7EC)),
              ),
              leading: const Icon(Icons.email_outlined),
              title: const Text('support@esahayta.app'),
              subtitle: const Text('Email support'),
              onTap: () => _open('mailto:support@esahayta.app'),
            ),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xffE4E7EC)),
              ),
              leading: const Icon(Icons.call_outlined),
              title: const Text('+91 98765 43210'),
              subtitle: const Text('Support contact'),
              onTap: () => _open('tel:+919876543210'),
            ),
          ],
        ),
      ),
    );
  }
}
