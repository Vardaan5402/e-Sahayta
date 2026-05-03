import 'package:flutter/material.dart';

import 'about_page.dart';
import 'emergency_contacts_page.dart';
import 'faq_page.dart';
import 'help_page.dart';
import 'profile_page.dart';
import 'volunteer_page.dart';

class EmergencyPanel extends StatelessWidget {
  const EmergencyPanel({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff0F2A44),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.menu, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                const Text(
                  'e-Sahayta Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Profile, contacts, support and volunteer options',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () => _openPage(context, const ProfilePage()),
          ),
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
            title: const Text('Emergency Contacts'),
            onTap: () => _openPage(context, const EmergencyContactsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About e-Sahayta'),
            onTap: () => _openPage(context, const AboutPage()),
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: const Text('FAQ'),
            onTap: () => _openPage(context, const FAQPage()),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Help'),
            onTap: () => _openPage(context, const HelpPage()),
          ),
          const Divider(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF4F7FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Become a Volunteer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff0F2A44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Apply to help the community with verification and admin approval.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xff667085),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openPage(context, const VolunteerPage()),
                      child: const Text('Open Volunteer Page'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
