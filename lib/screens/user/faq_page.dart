import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        'What does the SOS button do?',
        'It opens the emergency map and starts the quick alert flow.',
      ),
      (
        'How can I verify a worker?',
        'Open Verify Worker and scan the QR code or enter the worker ID manually.',
      ),
      (
        'How many emergency contacts can I add?',
        'You can save up to 5 emergency contacts with name and number.',
      ),
      (
        'What is the volunteer option?',
        'It allows you to apply as a volunteer for future safety support participation.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ExpansionTile(
              title: Text(
                faq.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0F2A44),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq.$2,
                    style: const TextStyle(
                      color: Color(0xff475467),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
