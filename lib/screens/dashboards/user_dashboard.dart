import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/sos_service.dart';
import '../../services/sms_service.dart';
import '../user/emergency_panel.dart';
import '../user/profile_page.dart';
import '../user/sos_map_screen.dart';
import '../user/verify_worker_page.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  static const List<_HelplineContact> _helplineContacts = [
    _HelplineContact(
      label: 'Emergency',
      number: '112',
      icon: Icons.call,
      color: Color(0xffD64545),
    ),
    _HelplineContact(
      label: 'Ambulance',
      number: '108',
      icon: Icons.local_hospital,
      color: Color(0xff2D9CDB),
    ),
    _HelplineContact(
      label: 'Women',
      number: '1090',
      icon: Icons.shield_outlined,
      color: Color(0xffC68A2E),
    ),
    _HelplineContact(
      label: 'Fire',
      number: '101',
      icon: Icons.local_fire_department,
      color: Color(0xffEB5757),
    ),
    _HelplineContact(
      label: 'Road',
      number: '1073',
      icon: Icons.traffic,
      color: Color(0xff27AE60),
    ),
    _HelplineContact(
      label: 'Cyber',
      number: '1930',
      icon: Icons.security,
      color: Color(0xff6C5CE7),
    ),
  ];

  Future<void> _callHelpline(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    final bool launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer for $number')),
      );
    }
  }

  Future<void> triggerSOS() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services first')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required for SOS')),
      );
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final String caseId = await SosService.createOrUpdateSOSCase(
      position: position,
    );

    final String message =
        'Emergency alert from eSahayta.\n'
        'User needs help.\n'
        'Location:\n'
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    try {
      await SMSService.sendSOS(message);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open SMS app, but emergency map is opening'),
        ),
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SOSMapScreen(
          caseId: caseId,
          lat: position.latitude,
          lng: position.longitude,
        ),
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xffE4E7EC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F2A44),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff0F2A44),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff667085),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Color(0xff98A2B3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelplineCard(_HelplineContact contact) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _callHelpline(contact.number),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xffE4E7EC)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: contact.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(contact.icon, color: contact.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                contact.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0F2A44),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xff667085),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmergencyPanel(),
      appBar: AppBar(
        title: const Text('USER'),
        centerTitle: true,
        backgroundColor: const Color(0xff0F2A44),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff0F2A44),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick actions for SOS, worker verification and direct helpline calling.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPrimaryAction(
              title: 'SOS',
              subtitle: 'Open map and send emergency alert',
              icon: Icons.sos_rounded,
              color: const Color(0xffD64545),
              onTap: triggerSOS,
            ),
            const SizedBox(height: 14),
            _buildPrimaryAction(
              title: 'Verify Worker',
              subtitle: 'Scan QR code or enter worker ID',
              icon: Icons.verified_user_outlined,
              color: const Color(0xff2D9CDB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerifyWorkerPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Helpline Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F2A44),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap any card to place a direct phone call.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff667085),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _helplineContacts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  return _buildHelplineCard(_helplineContacts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelplineContact {
  final String label;
  final String number;
  final IconData icon;
  final Color color;

  const _HelplineContact({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
  });
}
