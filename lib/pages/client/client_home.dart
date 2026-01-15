import 'package:flutter/material.dart';
import '../../layout/app_layout.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      role: AppRole.client,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Client Dashboard 🏡",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome Client! See progress, photos, timeline updates, and raise queries.",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
