import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/sos_service.dart';

class SOSMapScreen extends StatefulWidget {
  final String caseId;
  final double lat;
  final double lng;

  const SOSMapScreen({
    super.key,
    required this.caseId,
    required this.lat,
    required this.lng,
  });

  @override
  State<SOSMapScreen> createState() => _SOSMapScreenState();
}

class _SOSMapScreenState extends State<SOSMapScreen> {
  late GoogleMapController mapController;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _userLocation = LatLng(widget.lat, widget.lng);
    _startLiveLocationSync();
  }

  void _startLiveLocationSync() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      _userLocation = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {});
      }

      await SosService.updateSOSCaseLocation(
        caseId: widget.caseId,
        position: position,
      );
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng userLocation = _userLocation ?? LatLng(widget.lat, widget.lng);
    final LatLng workerLocation = LatLng(
      widget.lat + 0.0015,
      widget.lng + 0.0012,
    );
    final LatLng policeLocation = LatLng(
      widget.lat - 0.0012,
      widget.lng + 0.0008,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Map'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('user'),
                  position: userLocation,
                  infoWindow: const InfoWindow(title: 'You'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('worker'),
                  position: workerLocation,
                  infoWindow: const InfoWindow(title: 'Nearby Worker'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('police'),
                  position: policeLocation,
                  infoWindow: const InfoWindow(title: 'Police Support'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS Alert Active',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff0F2A44),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Yellow marker: self\nBlue marker: worker\nRed marker: police\nYour live location is being updated for the assigned worker.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
