import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _currentUid => _auth.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_currentUid);

  static String generateESahaytaId() {
    final random = Random();
    final number = 10000000 + random.nextInt(90000000);
    return 'eS-$number';
  }

  static Future<void> createUserRecord({
    required String role,
    required String name,
    required String phone,
    required String email,
    required String aadhaarNumber,
    required String profilePhotoPath,
    required String aadhaarCardPhotoPath,
    String? companyName,
    String? companyIdPhotoPath,
    String? companyEmployeeId,
  }) async {
    await _userDoc.set({
      'uid': _currentUid,
      'eSahaytaId': generateESahaytaId(),
      'email': email,
      'phone': phone,
      'role': role,
      'name': name,
      'photoUrl': profilePhotoPath,
      'aadhaarNumber': aadhaarNumber,
      'aadhaarCardPhotoUrl': aadhaarCardPhotoPath,
      'companyName': (companyName ?? '').trim(),
      'companyIdPhotoUrl': (companyIdPhotoPath ?? '').trim(),
      'companyEmployeeId': (companyEmployeeId ?? '').trim(),
      'emergencyContacts': <Map<String, dynamic>>[],
      'volunteerApplication': {
        'isVolunteer': false,
        'status': 'not_applied',
        'emailVerified': _auth.currentUser?.emailVerified ?? false,
        'adminApproval': 'not_requested',
      },
      'profileCompleted': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _userDoc.get();
    return snapshot.data();
  }

  static Future<void> saveCurrentUserProfile({
    required String name,
    required String phone,
  }) async {
    await _userDoc.set({
      'name': name.trim(),
      'phone': phone.trim(),
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> saveEmergencyContacts(
    List<Map<String, String>> contacts,
  ) async {
    final List<Map<String, dynamic>> cleanedContacts = contacts
        .where(
          (contact) =>
              (contact['name'] ?? '').trim().isNotEmpty ||
              (contact['phone'] ?? '').trim().isNotEmpty,
        )
        .map(
          (contact) => {
            'name': (contact['name'] ?? '').trim(),
            'phone': (contact['phone'] ?? '').trim(),
          },
        )
        .toList();

    await _userDoc.set({
      'emergencyContacts': cleanedContacts,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> applyForVolunteer() async {
    await _auth.currentUser?.reload();

    await _userDoc.set({
      'volunteerApplication': {
        'isVolunteer': false,
        'status': 'pending',
        'description':
            'User has requested to become a volunteer and is awaiting review.',
        'emailVerified': _auth.currentUser?.emailVerified ?? false,
        'otpVerified': false,
        'adminApproval': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
