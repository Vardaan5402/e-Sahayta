import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final List<TextEditingController> _nameControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _phoneControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final Map<String, dynamic>? data =
        await UserProfileService.getCurrentUserProfile();
    final List<dynamic> contacts =
        (data?['emergencyContacts'] as List<dynamic>?) ?? <dynamic>[];

    for (int i = 0; i < contacts.length && i < 5; i++) {
      final Map<String, dynamic> contact =
          contacts[i] as Map<String, dynamic>;
      _nameControllers[i].text = (contact['name'] as String?) ?? '';
      _phoneControllers[i].text = (contact['phone'] as String?) ?? '';
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveContacts() async {
    await UserProfileService.saveEmergencyContacts(
      List.generate(
        5,
        (index) => {
          'name': _nameControllers[index].text,
          'phone': _phoneControllers[index].text,
        },
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency contacts saved')),
    );
  }

  Widget _contactCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact ${index + 1}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff0F2A44),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameControllers[index],
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneControllers[index],
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add up to 5 trusted contacts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff0F2A44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Store both name and number for emergency use.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff667085),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => _contactCard(index),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveContacts,
                      child: const Text('Save Contacts'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
