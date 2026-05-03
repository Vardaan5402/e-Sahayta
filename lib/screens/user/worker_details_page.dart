import 'package:flutter/material.dart';

class WorkerDetailsPage extends StatelessWidget {

  final String workerId;

  const WorkerDetailsPage({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Details"),
        backgroundColor: const Color(0xff0F2A44),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Worker Verified",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Text("Worker ID : $workerId"),
            const Text("Company : Zomato"),
            const Text("Vehicle : UP32 AB 1234"),
            const Text("Status : Verified"),
          ],
        ),
      ),
    );
  }
}