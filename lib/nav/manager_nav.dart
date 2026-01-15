import 'package:flutter/material.dart';

class ManagerNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChange;

  const ManagerNav({
    super.key,
    required this.currentIndex,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onChange,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Overview"),
        BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "Projects"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
