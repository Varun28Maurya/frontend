class AppRoutes {
  static const splash = "/";
  static const auth = "/auth";

  static const ownerHome = ownerDashboard;
  // ✅ Owner sub routes (for tabs)
  static const ownerDashboard = "/owner/dashboard";
  static const ownerProjects = "/owner/projects";
  static const ownerApprovals = "/owner/approvals";
  static const ownerChat = "/owner/chat";
  static const ownerDocs = "/owner/docs";

  
  static const engineerHome = "/engineer";
  static const managerHome = "/manager";
  static const clientHome = "/client";

  static const profile = "/profile";
  static const settings = "/settings";
  // settings sub-pages
  static const settingsGeneral = "/settings/general";
  static const settingsChats = "/settings/chats";
  static const settingsNotifications = "/settings/notifications";
  static const settingsAccessibility = "/settings/accessibility";
  static const settingsCalls = "/settings/calls";
  static const settingsAbout = "/settings/about";
  static const settingsHelp = "/settings/help";
  static const terms = "/settings/terms";
  static const supportFaq = "/settings/support/faq";
  static const supportChat = "/settings/support/chat";
  static const supportRaiseTicket = "/settings/support/raise-ticket";
  static const supportTrackTicket = "/settings/support/track-ticket";
  static const supportTutorials = "/settings/support/tutorials";
  static const supportReportProblem = "/settings/support/report-problem";
  static const supportFeedback = "/settings/support/feedback";
}
