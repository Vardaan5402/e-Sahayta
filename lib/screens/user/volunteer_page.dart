import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _application;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final Map<String, dynamic>? profile =
        await UserProfileService.getCurrentUserProfile();
    _application =
        profile?['volunteerApplication'] as Map<String, dynamic>?;

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _apply() async {
    await UserProfileService.applyForVolunteer();
    await _loadStatus();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Volunteer request submitted')),
    );
  }

  String _value(String key, {String fallback = 'Pending'}) {
    return (_application?[key]?.toString() ?? fallback)
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  Widget _statusTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE4E7EC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xff0F2A44),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xff667085),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Volunteer'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff0F2A44),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Volunteer Program',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Become part of the support community by applying as a volunteer.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Volunteer Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff0F2A44),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Current flow: request submission, number OTP, email verification, and admin approval.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff667085),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _statusTile('Application', _value('status', fallback: 'NOT APPLIED')),
                  _statusTile(
                    'Number OTP',
                    (_application?['otpVerified'] == true) ? 'YES' : 'PENDING',
                  ),
                  _statusTile(
                    'Email Verification',
                    (_application?['emailVerified'] == true) ? 'YES' : 'NO',
                  ),
                  _statusTile(
                    'Admin Approval',
                    _value('adminApproval', fallback: 'NOT REQUESTED'),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Apply Now'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
