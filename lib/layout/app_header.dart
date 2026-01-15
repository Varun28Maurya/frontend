import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isOffline;
  final VoidCallback onLogout;
  final VoidCallback onSettings;
  final VoidCallback onToggleOffline;
  final VoidCallback onReadAloud;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  const AppHeader({
    super.key,
    required this.isOffline,
    required this.onToggleOffline,
    required this.onReadAloud,
    required this.onNotifications,
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            "assets/SiteSaarthiLogo.png",
            height: 32,
          ),
          const SizedBox(width: 10),
          const Text(
            "SiteSaarthi",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        // ✅ ONLINE / OFFLINE pill (safe sizing)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onToggleOffline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isOffline
                      ? const Color(0xFFFFE4E6)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOffline ? Icons.wifi_off : Icons.wifi,
                      size: 15,
                      color: isOffline
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOffline ? "OFFLINE" : "ONLINE",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isOffline
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // ✅ Read aloud
        IconButton(
          tooltip: "Read aloud",
          onPressed: onReadAloud,
          icon: const Icon(Icons.volume_up_outlined, color: Colors.black54),
        ),

        const SizedBox(width: 2),

        // ✅ Notifications (with dot)
        Stack(
          children: [
            IconButton(
              onPressed: onNotifications,
              icon: const Icon(Icons.notifications_none, color: Colors.black54),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),

        // ✅ Profile menu button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Builder(
            builder: (ctx) {
              return InkWell(
                onTap: () async {
                  final RenderBox button = ctx.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(ctx).context.findRenderObject() as RenderBox;

                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(
                        button.size.bottomRight(Offset.zero),
                        ancestor: overlay,
                      ),
                    ),
                    Offset.zero & overlay.size,
                  );

                  final selected = await showMenu<String>(
                    context: context,
                    position: position,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    items: [
                      PopupMenuItem<String>(
                        value: "profile",
                        child: Row(
                          children: const [
                            Icon(Icons.person_outline, size: 18),
                            SizedBox(width: 10),
                            Text(
                              "Profile",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: "settings",
                        child: Row(
                          children: const [
                            Icon(Icons.settings_outlined, size: 18),
                            SizedBox(width: 10),
                            Text(
                              "Settings",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: "logout",
                        child: Row(
                          children: const [
                            Icon(Icons.logout, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (selected == null) return;

                  // ✅ Call parent callbacks
                  if (selected == "profile") {
                    onProfile(); // navigate to profile screen
                  } else if (selected == "settings") {
                    onSettings();
                  } else if (selected == "logout") {
                    onLogout();
                  }
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child:
                      const Icon(Icons.person_outline, color: Colors.black54),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
