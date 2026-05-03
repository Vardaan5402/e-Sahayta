import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About e-Sahayta'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F2A44),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'e-Sahayta is a safety support platform built to connect users with emergency help, worker verification, and trusted contacts in one place.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff344054),
                height: 1.6,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The goal is to make emergency response easier, faster, and more accessible for daily users.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff344054),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
