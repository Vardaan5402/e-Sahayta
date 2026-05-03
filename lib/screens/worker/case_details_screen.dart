import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseDetailsScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final double lat;
  final double lng;
  final String caseId;

  const CaseDetailsScreen({
    super.key,
    required this.userName,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.caseId,
  });

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  Future<void> openNavigation() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('sos_cases')
        .doc(widget.caseId)
        .get();

    final Map<String, dynamic>? data = snapshot.data();
    final double lat = (data?['lat'] as num?)?.toDouble() ?? widget.lat;
    final double lng = (data?['lng'] as num?)?.toDouble() ?? widget.lng;
    final String url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  Future<void> callUser(String phone) async {
    final String url = "tel:$phone";
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Case"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('sos_cases')
            .doc(widget.caseId)
            .snapshots(),
        builder: (context, snapshot) {
          final Map<String, dynamic>? data = snapshot.data?.data();
          final String userName =
              (data?['userName'] ?? widget.userName).toString();
          final String phone = (data?['phone'] ?? widget.phone).toString();
          final String status = (data?['status'] ?? 'ACTIVE').toString();
          final double lat = (data?['lat'] as num?)?.toDouble() ?? widget.lat;
          final double lng = (data?['lng'] as num?)?.toDouble() ?? widget.lng;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  "User : $userName",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Phone : $phone",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Live Location : ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  "Status : ${status.replaceAll('_', ' ')}",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => callUser(phone),
                  icon: const Icon(Icons.call),
                  label: const Text("Call User"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: openNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text("Navigate to User"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("sos_cases")
                        .doc(widget.caseId)
                        .update({
                      "status": "RESPONDER_REACHED"
                    });

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Responder reached the location"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text("REACHED"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("sos_cases")
                        .doc(widget.caseId)
                        .update({
                      "status": "COMPLETED"
                    });

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Case completed successfully"),
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("COMPLETE CASE"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
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
