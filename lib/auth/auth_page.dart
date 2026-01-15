import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------------------------------------------------
/// COLORS (match your React UI)
/// ------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFFF4F4F5);
  static const card = Color(0xFFFFFFFF);

  static const primary = Color(0xFF0B3C5D);
  static const primaryHover = Color(0xFF1E40AF);

  static const orange = Color(0xFFF97316);

  static const text = Color(0xFF111827);
  static const subtext = Color(0xFF374151);

  static const error = Color(0xFFDC2626);

  static const border = Color(0xFFE5E7EB); // gray-200 approx
}

/// ------------------------------------------------------------
/// USER MODEL
/// ------------------------------------------------------------
class AuthUser {
  final String id;
  final String name;
  final String phone;
  final String role;

  AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "role": role,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        role: json["role"],
      );
}

/// ------------------------------------------------------------
/// MOCK DETAILS.JSON (owners + engineers)
/// You can replace with asset loading later.
/// ------------------------------------------------------------
class MockDetailsDB {
  static final owners = <AuthUser>[
    AuthUser(id: "owner-1", name: "Amit Patel", phone: "9876543210", role: "OWNER"),
  ];

  static final engineers = <AuthUser>[
    AuthUser(id: "eng-1", name: "Rahul Sharma", phone: "9123456780", role: "ENGINEER"),
  ];

  static AuthUser? findUserByPhone(String phone) {
    for (final o in owners) {
      if (o.phone == phone) return o;
    }
    for (final e in engineers) {
      if (e.phone == phone) return e;
    }
    return null;
  }
}

/// ------------------------------------------------------------
/// AUTH STEP
/// ------------------------------------------------------------
enum AuthStep { form, otp }

/// ------------------------------------------------------------
/// AUTH PAGE
/// ------------------------------------------------------------
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  // state
  bool isLogin = true;
  AuthStep step = AuthStep.form;

  String role = "";
  String mobile = "";
  String fullName = "";
  String companyName = "";

  String otpInput = "";
  String error = "";

  // OTP handling
  String? currentOtp;
  Timer? otpExpiryTimer;

  // success modal
  bool showSuccess = false;

  // animation
  late final AnimationController otpAnimController;
  late final Animation<Offset> otpSlide;
  late final Animation<double> otpFade;

  @override
  void initState() {
    super.initState();

    otpAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    otpSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: otpAnimController, curve: Curves.easeOutCubic),
    );

    otpFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: otpAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    otpExpiryTimer?.cancel();
    otpAnimController.dispose();
    super.dispose();
  }

  TextStyle get tTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      );

  TextStyle get tSub => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.subtext,
      );

  /// only letters + space
  void handleNameChange(String val) {
    final regex = RegExp(r'^[a-zA-Z\s]*$');
    if (regex.hasMatch(val)) {
      setState(() => fullName = val);
    }
  }

  void switchMode(bool loginMode) {
    setState(() {
      isLogin = loginMode;
      step = AuthStep.form;
      error = "";
      otpInput = "";
    });
  }

  Future<List<AuthUser>> _getLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("users");
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => AuthUser.fromJson(e)).toList();
  }

  Future<void> _saveLocalUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalUsers();
    list.add(user);
    await prefs.setString("users", jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveAuthUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("authUser", jsonEncode(user.toJson()));
  }

  Future<AuthUser?> _findExistingUser(String phone) async {
    // check in mock details first (like details.json)
    final mock = MockDetailsDB.findUserByPhone(phone);
    if (mock != null) return mock;

    // check in shared pref DB
    final list = await _getLocalUsers();
    for (final u in list) {
      if (u.phone == phone) return u;
    }
    return null;
  }

  void _generateOtpAndMove() async {
    setState(() => error = "");

    if (mobile.length != 10) {
      setState(() => error = "Please enter a valid 10-digit mobile number.");
      return;
    }

    final existingUser = await _findExistingUser(mobile);

    if (isLogin && existingUser == null) {
      setState(() => error = "Number not registered. Please sign up.");
      return;
    }

    if (!isLogin && existingUser != null) {
      setState(() => error = "User already exists. Please log in.");
      return;
    }

    // extra signup validation
    if (!isLogin) {
      if (fullName.trim().isEmpty) {
        setState(() => error = "Please enter your full name.");
        return;
      }
      if (companyName.trim().isEmpty) {
        setState(() => error = "Please enter site / company name.");
        return;
      }
    }

    // OTP
    final generated = (1000 + Random().nextInt(9000)).toString();
    currentOtp = generated;

    // custom toast popup
    OtpToast.show(context, otp: generated);

    otpExpiryTimer?.cancel();
    otpExpiryTimer = Timer(const Duration(seconds: 20), () {
      currentOtp = null;
    });

    setState(() {
      step = AuthStep.otp;
      otpInput = "";
      error = "";
    });

    otpAnimController.forward(from: 0);
  }

  void _verifyOtp() async {
    setState(() => error = "");

    if (currentOtp == null) {
      setState(() => error = "OTP expired. Please try again.");
      return;
    }

    if (otpInput != currentOtp) {
      setState(() => error = "Invalid OTP.");
      return;
    }

    otpExpiryTimer?.cancel();
    currentOtp = null;

    final existingUser = await _findExistingUser(mobile);

    AuthUser user;

    if (isLogin) {
      user = existingUser!;
    } else {
      if (role.isEmpty) {
        setState(() => error = "Please select a role.");
        return;
      }

      user = AuthUser(
        id: "${role.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}",
        name: fullName.trim(),
        phone: mobile,
        role: role,
      );

      await _saveLocalUser(user);
    }

    await _saveAuthUser(user);

    setState(() => showSuccess = true);
  }

  void _continue() async {
  setState(() => showSuccess = false);

  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString("authUser");
  if (raw == null) return;

  final user = jsonDecode(raw);
  final role = user["role"];

  if (!mounted) return;

  if (role == "OWNER") {
    Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
  } else if (role == "ENGINEER") {
    Navigator.pushReplacementNamed(context, AppRoutes.engineerHome);
  } else if (role == "MANAGER") {
    Navigator.pushReplacementNamed(context, AppRoutes.managerHome);
  } else if (role == "CLIENT") {
    Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }
}


  @override
  Widget build(BuildContext context) {
    final cardMaxWidth = 420.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardMaxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 25,
                          offset: Offset(0, 14),
                          color: Color(0x11000000),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Header(),

                        const SizedBox(height: 18),

                        if (step == AuthStep.form) ...[
                          _AuthToggle(
                            isLogin: isLogin,
                            onLogin: () => switchMode(true),
                            onSignup: () => switchMode(false),
                          ),
                          const SizedBox(height: 16),
                          _FormStep(
                            isLogin: isLogin,
                            fullName: fullName,
                            onFullNameChanged: handleNameChange,
                            companyName: companyName,
                            onCompanyChanged: (v) => setState(() => companyName = v),
                            role: role,
                            onRoleChanged: (r) => setState(() => role = r),
                            mobile: mobile,
                            onMobileChanged: (v) => setState(() => mobile = v),
                            error: error,
                            onSubmit: _generateOtpAndMove,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "By continuing, you agree to our Terms & Conditions.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ] else ...[
                          FadeTransition(
                            opacity: otpFade,
                            child: SlideTransition(
                              position: otpSlide,
                              child: _OtpStep(
                                mobile: mobile,
                                otp: otpInput,
                                onOtpChanged: (v) => setState(() => otpInput = v),
                                error: error,
                                onEdit: () => setState(() {
                                  step = AuthStep.form;
                                  error = "";
                                  otpInput = "";
                                }),
                                onVerify: _verifyOtp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SUCCESS MODAL
          if (showSuccess)
            SuccessModal(
              isLogin: isLogin,
              onContinue: _continue,
            ),
        ],
      ),
    );
  }
}
/// ------------------------------------------------------------
/// HEADER
/// ------------------------------------------------------------
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // logo
        Center(
          child: Image.asset(
            "assets/SiteSaarthiLogo.png",
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "SiteSaarthi",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Construction Field Management",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.subtext,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// TOGGLE
/// ------------------------------------------------------------
class _AuthToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _AuthToggle({
    required this.isLogin,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    Widget pillButton({
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 4),
                        color: Color(0x14000000),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: active ? AppColors.primary : AppColors.subtext,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          pillButton(label: "Log In", active: isLogin, onTap: onLogin),
          pillButton(label: "Sign Up", active: !isLogin, onTap: onSignup),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// FORM STEP
/// ------------------------------------------------------------
class _FormStep extends StatelessWidget {
  final bool isLogin;
  final String fullName;
  final ValueChanged<String> onFullNameChanged;

  final String companyName;
  final ValueChanged<String> onCompanyChanged;

  final String role;
  final ValueChanged<String> onRoleChanged;

  final String mobile;
  final ValueChanged<String> onMobileChanged;

  final String error;
  final VoidCallback onSubmit;

  const _FormStep({
    required this.isLogin,
    required this.fullName,
    required this.onFullNameChanged,
    required this.companyName,
    required this.onCompanyChanged,
    required this.role,
    required this.onRoleChanged,
    required this.mobile,
    required this.onMobileChanged,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin) ...[
          _InputLabel("Full Name *"),
          const SizedBox(height: 6),
          _IconTextField(
            icon: LucideIcons.user,
            hint: "Rahul Sharma",
            value: fullName,
            onChanged: onFullNameChanged,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 14),

          _InputLabel("Site / Company Name *"),
          const SizedBox(height: 6),
          _IconTextField(
            icon: LucideIcons.building2,
            hint: "ABC Constructions",
            value: companyName,
            onChanged: onCompanyChanged,
          ),
          const SizedBox(height: 14),

          _InputLabel("Your Role *"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RoleButton(
                  title: "Owner / Manager",
                  active: role == "OWNER",
                  onTap: () => onRoleChanged("OWNER"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleButton(
                  title: "Site Engineer",
                  active: role == "ENGINEER",
                  onTap: () => onRoleChanged("ENGINEER"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        _InputLabel("Mobile Number *"),
        const SizedBox(height: 6),

        _MobileField(
          value: mobile,
          onChanged: onMobileChanged,
        ),

        if (error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),

        _PrimaryButton(
          text: isLogin ? "Get OTP" : "Create Account",
          icon: LucideIcons.arrowRight,
          onTap: onSubmit,
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.subtext,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _IconTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  const _IconTextField({
    required this.icon,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
      ),
    );
  }
}

class _MobileField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _MobileField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border.all(color: AppColors.border),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          child: Center(
            child: Text(
              "+91",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.subtext,
              ),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              fontSize: 18,
              letterSpacing: 1.7,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
            onChanged: (v) {
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length <= 10) onChanged(digits);
            },
            decoration: InputDecoration(
              hintText: "98765 43210",
              prefixIcon: Icon(LucideIcons.phone, size: 18, color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                borderSide: const BorderSide(color: AppColors.orange, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : AppColors.subtext,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// OTP STEP
/// ------------------------------------------------------------
class _OtpStep extends StatelessWidget {
  final String mobile;
  final String otp;
  final ValueChanged<String> onOtpChanged;

  final String error;
  final VoidCallback onEdit;
  final VoidCallback onVerify;

  const _OtpStep({
    required this.mobile,
    required this.otp,
    required this.onOtpChanged,
    required this.error,
    required this.onEdit,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Verify Mobile",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sent to +91 $mobile",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.subtext,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Row(
                children: [
                  Icon(LucideIcons.pencil, size: 14, color: AppColors.orange),
                  const SizedBox(width: 4),
                  Text(
                    "Edit",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        const SizedBox(height: 18),

        Text(
          "ENTER 4-DIGIT OTP",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.subtext,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: 220,
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
              color: AppColors.text,
            ),
            onChanged: (v) {
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length <= 4) onOtpChanged(digits);
            },
            decoration: InputDecoration(
              counterText: "",
              hintText: "• • • •",
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(LucideIcons.lockKeyhole, size: 18, color: Colors.grey.shade400),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.orange, width: 2),
              ),
            ),
          ),
        ),

        if (error.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        ],

        const SizedBox(height: 18),

        _PrimaryButton(
          text: "Verify & Proceed",
          icon: LucideIcons.arrowRight,
          onTap: onVerify,
        ),

        const SizedBox(height: 14),

        Text(
          "Resend OTP in 30s",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// PRIMARY BUTTON
/// ------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x4D0B3C5D), // 30% + shadow feeling
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// OTP TOAST POPUP (custom overlay notification)
/// ------------------------------------------------------------
class OtpToast {
  static void show(BuildContext context, {required String otp}) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) {
        return _OtpToastWidget(
          otp: otp,
          onClose: () => entry.remove(),
        );
      },
    );

    overlay.insert(entry);

    // auto dismiss
    Future.delayed(const Duration(seconds: 3), () {
      try {
        entry.remove();
      } catch (_) {}
    });
  }
}

class _OtpToastWidget extends StatefulWidget {
  final String otp;
  final VoidCallback onClose;

  const _OtpToastWidget({
    required this.otp,
    required this.onClose,
  });

  @override
  State<_OtpToastWidget> createState() => _OtpToastWidgetState();
}

class _OtpToastWidgetState extends State<_OtpToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Offset> slide;
  late final Animation<double> fade;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      left: 16,
      right: 16,
      child: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0, 10),
                      color: Color(0x14000000),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.lockKeyhole, color: AppColors.orange, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your OTP is ${widget.otp}",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SUCCESS MODAL (zoom-in)
/// ------------------------------------------------------------
class SuccessModal extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onContinue;

  const SuccessModal({
    super.key,
    required this.isLogin,
    required this.onContinue,
  });

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> fade;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    scale = Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: Container(
                width: 360,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 26,
                      offset: Offset(0, 14),
                      color: Color(0x22000000),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7), // green-100
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.isLogin ? "Login Successful" : "Account Created",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isLogin
                          ? "You have successfully logged in."
                          : "Your account has been created successfully.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: widget.onContinue,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
