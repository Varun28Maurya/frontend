import 'package:flutter/material.dart';
import '../../layout/app_layout.dart';

class EngineerHomePage extends StatelessWidget {
  const EngineerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      role: AppRole.engineer,
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
              "Engineer Dashboard 🦺",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome Engineer! Track tasks, updates, and project progress here.",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
