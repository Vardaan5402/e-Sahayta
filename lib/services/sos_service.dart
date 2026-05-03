import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'user_profile_service.dart';

class SosService {
  SosService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> _activeStatuses = [
    'ACTIVE',
    'RESPONDER_ON_THE_WAY',
    'RESPONDER_REACHED',
  ];

  static String get _currentUid => _auth.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> get _currentCaseDoc =>
      _firestore.collection('sos_cases').doc(_currentUid);

  static Future<String> createOrUpdateSOSCase({
    required Position position,
  }) async {
    final Map<String, dynamic>? profile =
        await UserProfileService.getCurrentUserProfile();

    final QuerySnapshot<Map<String, dynamic>> workersSnapshot = await _firestore
        .collection('gig_workers')
        .where('available', isEqualTo: true)
        .limit(10)
        .get();

    final List<String> assignedWorkers = workersSnapshot.docs
        .map((doc) => doc.id)
        .where((workerId) => workerId != _currentUid)
        .toList();

    await _currentCaseDoc.set({
      'caseId': _currentUid,
      'userId': _currentUid,
      'userName': (profile?['name'] ?? 'User').toString(),
      'phone': (profile?['phone'] ?? '').toString(),
      'email': (profile?['email'] ?? '').toString(),
      'lat': position.latitude,
      'lng': position.longitude,
      'status': 'ACTIVE',
      'assignedWorkers': assignedWorkers,
      'emergencyContacts':
          List<Map<String, dynamic>>.from(profile?['emergencyContacts'] ?? []),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _currentUid;
  }

  static Future<void> updateSOSCaseLocation({
    required String caseId,
    required Position position,
  }) async {
    await _firestore.collection('sos_cases').doc(caseId).set({
      'lat': position.latitude,
      'lng': position.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> closeCurrentUserSOSCase() async {
    await _currentCaseDoc.set({
      'status': 'COMPLETED',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static bool isCaseActive(Map<String, dynamic>? caseData) {
    final String status = (caseData?['status'] ?? '').toString();
    return _activeStatuses.contains(status);
  }
}
