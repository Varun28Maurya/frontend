import 'package:flutter/material.dart';
import 'app_header.dart';
import '../components/logout.dart';
import '../routes.dart';

enum AppRole { owner, engineer, manager, client }

class AppLayout extends StatefulWidget {
  final Widget child;

  /// ✅ optional (so old pages won’t break)
  final AppRole? role;

  const AppLayout({
    super.key,
    required this.child,
    this.role,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool isOffline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        isOffline: isOffline,
        onToggleOffline: () => setState(() => isOffline = !isOffline),
        onReadAloud: () {},
        onNotifications: () {},
        onProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
        onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
        onLogout: () async => await logout(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
