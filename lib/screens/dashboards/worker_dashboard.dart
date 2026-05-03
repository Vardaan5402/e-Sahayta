import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/sms_service.dart';
import '../../services/sos_service.dart';
import '../user/emergency_panel.dart';
import '../user/profile_page.dart';
import '../user/sos_map_screen.dart';
import '../worker/case_details_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
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

  GoogleMapController? mapController;
  LatLng? currentLatLng;
  final geo = GeoFlutterFire();

  String? activeCaseId;
  Map<String, dynamic>? activeCaseData;
  StreamSubscription<Position>? positionSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sosSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? activeCaseSubscription;
  bool _alertDialogOpen = false;

  @override
  void initState() {
    super.initState();
    initializeWorker();
  }

  Future<void> initializeWorker() async {
    await getLocation();
    if (!mounted) return;
    listenForSOS();
  }

  Future<void> getLocation() async {
    await Geolocator.requestPermission();

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {});

    await saveLocationToFirestore(position.latitude, position.longitude);
  }

  Future<void> saveLocationToFirestore(double lat, double lng) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final GeoFirePoint myLocation = geo.point(latitude: lat, longitude: lng);

    await FirebaseFirestore.instance.collection('gig_workers').doc(uid).set({
      'position': myLocation.data,
      'available': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void listenForSOS() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    sosSubscription = FirebaseFirestore.instance
        .collection('sos_cases')
        .where('assignedWorkers', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> activeDocs =
              snapshot.docs
                  .where((doc) => SosService.isCaseActive(doc.data()))
                  .toList();

          if (activeDocs.isEmpty) {
            activeCaseId = null;
            activeCaseData = null;
            activeCaseSubscription?.cancel();
            if (mounted) {
              setState(() {});
            }
            return;
          }

          final QueryDocumentSnapshot<Map<String, dynamic>> caseDoc =
              activeDocs.first;
          activeCaseId = caseDoc.id;
          _listenToActiveCase(caseDoc.id);

          if ((caseDoc.data()['status'] ?? '') == 'ACTIVE' && !_alertDialogOpen) {
            showEmergencyDialog();
          }
        });
  }

  void _listenToActiveCase(String caseId) {
    activeCaseSubscription?.cancel();
    activeCaseSubscription = FirebaseFirestore.instance
        .collection('sos_cases')
        .doc(caseId)
        .snapshots()
        .listen((doc) {
          activeCaseData = doc.data();
          _focusOnActiveCase();
          if (!mounted) return;
          setState(() {});
        });
  }

  Future<void> _focusOnActiveCase() async {
    if (mapController == null ||
        currentLatLng == null ||
        activeCaseData?['lat'] == null ||
        activeCaseData?['lng'] == null) {
      return;
    }

    final LatLng helpSeeker = LatLng(
      (activeCaseData?['lat'] as num).toDouble(),
      (activeCaseData?['lng'] as num).toDouble(),
    );

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        currentLatLng!.latitude < helpSeeker.latitude
            ? currentLatLng!.latitude
            : helpSeeker.latitude,
        currentLatLng!.longitude < helpSeeker.longitude
            ? currentLatLng!.longitude
            : helpSeeker.longitude,
      ),
      northeast: LatLng(
        currentLatLng!.latitude > helpSeeker.latitude
            ? currentLatLng!.latitude
            : helpSeeker.latitude,
        currentLatLng!.longitude > helpSeeker.longitude
            ? currentLatLng!.longitude
            : helpSeeker.longitude,
      ),
    );

    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  void showEmergencyDialog() {
    if (activeCaseData == null) return;
    _alertDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🚨 EMERGENCY ALERT'),
        content: const Text(
          'You have been assigned to an emergency.\nPlease respond immediately.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('sos_cases')
                  .doc(activeCaseId)
                  .update({
                'status': 'RESPONDER_ON_THE_WAY'
              });

              startLiveTracking();

              if (!mounted) return;
              _alertDialogOpen = false;
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CaseDetailsScreen(
                    userName: activeCaseData?['userName'] ?? 'User',
                    phone: activeCaseData?['phone'] ?? 'N/A',
                    lat: (activeCaseData?['lat'] ?? 0).toDouble(),
                    lng: (activeCaseData?['lng'] ?? 0).toDouble(),
                    caseId: activeCaseId ?? '',
                  ),
                ),
              );
            },
            child: const Text('ON THE WAY'),
          )
        ],
      ),
    ).then((_) {
      _alertDialogOpen = false;
    });
  }

  void startLiveTracking() {
    positionSubscription?.cancel();

    positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 20,
      ),
    ).listen((Position position) async {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final GeoFirePoint myLocation = geo.point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      currentLatLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {});
      }

      _focusOnActiveCase();

      await FirebaseFirestore.instance.collection('gig_workers').doc(uid).update({
        'position': myLocation.data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _callHelpline(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    final bool launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer for $number')),
      );
    }
  }

  Future<void> _callHelpSeeker() async {
    final String phone = (activeCaseData?['phone'] ?? '').toString();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No help-seeker contact is available')),
      );
      return;
    }

    final Uri uri = Uri.parse('tel:$phone');
    final bool launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer for help-seeker')),
      );
    }
  }

  Future<void> _triggerSOS() async {
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

    final String message =
        'Emergency alert from eSahayta worker.\n'
        'Worker needs help.\n'
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
          caseId: 'worker-${FirebaseAuth.instance.currentUser!.uid}',
          lat: position.latitude,
          lng: position.longitude,
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    if (currentLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('worker'),
          position: currentLatLng!,
          infoWindow: const InfoWindow(title: 'Worker Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    if (activeCaseData != null &&
        activeCaseData?['lat'] != null &&
        activeCaseData?['lng'] != null) {
      final LatLng userLatLng = LatLng(
        (activeCaseData?['lat'] as num).toDouble(),
        (activeCaseData?['lng'] as num).toDouble(),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('help_seeker'),
          position: userLatLng,
          infoWindow: InfoWindow(
            title: activeCaseData?['userName']?.toString() ?? 'Help Seeker',
            snippet: activeCaseData?['phone']?.toString() ?? '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildMapSection() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: const Color(0xffE4E7EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2A44),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: activeCaseData != null &&
                          activeCaseData?['lat'] != null &&
                          activeCaseData?['lng'] != null
                      ? LatLng(
                          (activeCaseData?['lat'] as num).toDouble(),
                          (activeCaseData?['lng'] as num).toDouble(),
                        )
                      : currentLatLng!,
                  zoom: 15,
                ),
                markers: _buildMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  mapController = controller;
                  _focusOnActiveCase();
                },
              ),
      ),
    );
  }

  Widget _buildSOSAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffD64545),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _triggerSOS,
        child: const Text(
          'SOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCasePanel() {
    if (activeCaseData == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Active Help Request',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F2A44),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'When a SOS case is assigned to this worker, the help-seeker name, phone number, and live map location will appear here.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff667085),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    final String userName = activeCaseData?['userName']?.toString() ?? 'User';
    final String phone = activeCaseData?['phone']?.toString() ?? 'N/A';
    final String status =
        (activeCaseData?['status']?.toString() ?? 'ACTIVE').replaceAll('_', ' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help Request Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff0F2A44),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Name: $userName',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff344054),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contact: $phone',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff344054),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${status.toUpperCase()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xffD64545),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callHelpSeeker,
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CaseDetailsScreen(
                          userName: userName,
                          phone: phone,
                          lat: (activeCaseData?['lat'] as num?)?.toDouble() ?? 0,
                          lng: (activeCaseData?['lng'] as num?)?.toDouble() ?? 0,
                          caseId: activeCaseId ?? '',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Open Case'),
                ),
              ),
            ],
          ),
        ],
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
  void dispose() {
    positionSubscription?.cancel();
    sosSubscription?.cancel();
    activeCaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmergencyPanel(),
      appBar: AppBar(
        title: const Text('WORKER'),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Worker Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your location, send SOS and see the assigned help-seeker details live.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMapSection(),
            const SizedBox(height: 18),
            _buildSOSAction(),
            const SizedBox(height: 18),
            _buildActiveCasePanel(),
            const SizedBox(height: 24),
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
              'Same emergency contact shortcuts as the user dashboard.',
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
                  childAspectRatio: 0.78,
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
