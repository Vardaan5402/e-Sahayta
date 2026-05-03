import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'worker_details_page.dart';

class VerifyWorkerPage extends StatefulWidget {
  const VerifyWorkerPage({super.key});

  @override
  State<VerifyWorkerPage> createState() => _VerifyWorkerPageState();
}

class _VerifyWorkerPageState extends State<VerifyWorkerPage> {
  final TextEditingController _workerIdController = TextEditingController();
  bool _hasShownResult = false;

  @override
  void dispose() {
    _workerIdController.dispose();
    super.dispose();
  }

  void _showWorkerDialog(String workerId) {
    final String trimmedId = workerId.trim();
    if (_hasShownResult || trimmedId.isEmpty) return;

    _hasShownResult = true;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Worker Verified'),
        content: Text('Worker ID: $trimmedId'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _hasShownResult = false;
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hasShownResult = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkerDetailsPage(workerId: trimmedId),
                ),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Worker'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Worker QR',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F2A44),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan the worker QR code or verify by entering the worker ID.',
              style: TextStyle(
                color: Color(0xff667085),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    if (_hasShownResult) return;

                    for (final Barcode barcode in capture.barcodes) {
                      final String? code = barcode.rawValue;
                      if (code != null) {
                        _showWorkerDialog(code);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _workerIdController,
              decoration: InputDecoration(
                labelText: 'Worker ID',
                hintText: 'Enter worker ID manually',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showWorkerDialog(_workerIdController.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showWorkerDialog(_workerIdController.text),
                icon: const Icon(Icons.verified),
                label: const Text('Verify ID'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
