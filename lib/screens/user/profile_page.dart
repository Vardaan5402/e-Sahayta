import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final Map<String, dynamic>? data =
        await UserProfileService.getCurrentUserProfile();

    if (data != null) {
      name.text = (data['name'] as String?) ?? '';
      phone.text = (data['phone'] as String?) ?? '';
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    await UserProfileService.saveCurrentUserProfile(
      name: name.text,
      phone: phone.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Saved'),
      ),
    );
  }

  Widget field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xffE4E7EC)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xff0F2A44),
                          child: Text(
                            (name.text.isNotEmpty ? name.text[0] : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff667085),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Photo and personal details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff0F2A44),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  field('Full Name', name),
                  const SizedBox(height: 14),
                  field('Phone Number', phone),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
