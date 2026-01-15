import 'package:flutter/material.dart';
import 'routes.dart';
import 'auth/splash_decider.dart';
import 'auth/auth_page.dart';
import 'pages/engineer/engineer_home.dart';
import 'pages/manager/manager_home.dart';
import 'pages/client/client_home.dart';
import 'pages/common/profile_page.dart';
import 'pages/common/settings/settings_page.dart';
import 'pages/common/settings/general_settings.dart';
import 'pages/common/settings/chats_settings.dart';
import 'pages/common/settings/notifications_settings.dart';
import 'pages/common/settings/accessibility_settings.dart';
import 'pages/common/settings/calls_settings.dart';
import 'pages/common/settings/about_page.dart';
import 'pages/common/settings/help_support.dart';
import 'pages/common/settings/app_settings_store.dart';
import 'pages/common/settings/terms_page.dart';
import 'pages/common/settings/support/faq_page.dart';
import 'pages/common/settings/support/support_chat_page.dart';
import 'pages/common/settings/support/raise_ticket_page.dart';
import 'pages/common/settings/support/track_ticket_page.dart';
import 'pages/common/settings/support/tutorials_page.dart';
import 'pages/common/settings/support/report_problem_page.dart';
import 'pages/common/settings/support/feedback_page.dart';
import 'nav/owner_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsStore.load();

  runApp(const SiteSaarthiApp());
}

class SiteSaarthiApp extends StatelessWidget {
  const SiteSaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettingsStore.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<double>(
          valueListenable: AppSettingsStore.fontScale,
          builder: (context, scale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              // ✅ Global theme controller
              themeMode: mode,

              // ✅ Light Theme
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  iconTheme: IconThemeData(color: Color(0xFF0F172A)),
                  titleTextStyle: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),

              // ✅ Dark Theme
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0B1220),
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Color(0xFF0F172A),
                  surfaceTintColor: Color(0xFF0F172A),
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),

              // ✅ Global font scaling
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                );
              },

              initialRoute: AppRoutes.splash,
              routes: {
                AppRoutes.splash: (_) => const SplashDecider(),
                AppRoutes.auth: (_) => const AuthPage(),

                // ✅ Role home routes
                AppRoutes.ownerHome: (_) => const OwnerNav(initialIndex: 0),
                AppRoutes.engineerHome: (_) => const EngineerHomePage(),
                AppRoutes.managerHome: (_) => const ManagerHomePage(),
                AppRoutes.clientHome: (_) => const ClientHomePage(),

                // ✅ Common
                AppRoutes.profile: (_) => const ProfilePage(),
                AppRoutes.settings: (_) => const SettingsPage(),
                AppRoutes.settingsGeneral: (_) => const GeneralSettingsPage(),
                AppRoutes.settingsChats: (_) => const ChatsSettingsPage(),
                AppRoutes.settingsNotifications: (_) =>
                    const NotificationsSettingsPage(),
                AppRoutes.settingsAccessibility: (_) =>
                    const AccessibilitySettingsPage(),
                AppRoutes.settingsCalls: (_) => const CallsSettingsPage(),
                AppRoutes.settingsAbout: (_) => const AboutPage(),
                AppRoutes.settingsHelp: (_) => const HelpSupportPage(),
                AppRoutes.terms: (_) => const TermsPage(),
                AppRoutes.supportFaq: (_) => const FaqPage(),
                AppRoutes.supportChat: (_) => const SupportChatPage(),
                AppRoutes.supportRaiseTicket: (_) => const RaiseTicketPage(),
                AppRoutes.supportTrackTicket: (_) => const TrackTicketPage(),
                AppRoutes.supportTutorials: (_) => const TutorialsPage(),
                AppRoutes.supportReportProblem: (_) =>
                    const ReportProblemPage(),
                AppRoutes.supportFeedback: (_) => const FeedbackPage(),

                // ✅ Owner deep routes
                AppRoutes.ownerDashboard: (_) =>
                    const OwnerNav(initialIndex: 0),
                AppRoutes.ownerProjects: (_) => const OwnerNav(initialIndex: 1),
                AppRoutes.ownerApprovals: (_) =>
                    const OwnerNav(initialIndex: 2),
                AppRoutes.ownerChat: (_) => const OwnerNav(initialIndex: 3),
                AppRoutes.ownerDocs: (_) => const OwnerNav(initialIndex: 4),
              },
            );
          },
        );
      },
    );
  }
}
