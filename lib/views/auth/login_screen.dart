import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/watch_background.dart';
import 'package:lottie/lottie.dart';

enum AuthScreenState {
  signIn,
  signUp,
  forgotPassword,
  checkEmail,
  resetPassword,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  
  AuthScreenState _currentState = AuthScreenState.signIn;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController(text: "Alexander Thorne");
  final TextEditingController _emailController = TextEditingController(text: "a.thorne@chronodata.io");
  final TextEditingController _passwordController = TextEditingController(text: "password123");
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Test Bypass state parameters
  String _selectedRole = "user"; // 'user' or 'admin'
  String _selectedPlan = "paid"; // 'free' or 'paid'

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleBypassLogin() async {
    final success = await _authController.login(
      _nameController.text.trim().isEmpty ? "Horology Fan" : _nameController.text,
      _selectedRole,
      _selectedPlan,
    );
    if (success) {
      if (_selectedRole == 'admin') {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/home');
      }
    }
  }

  // Opens a settings bottom sheet allowing testing users to select login role/plan bypass parameters
  void _showTestBypassSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Testing Bypass Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryNav),
            ),
            const SizedBox(height: 8),
            Text(
              "Modify the role and billing plan for your bypass session below. Pressing 'Enter' on any screen logs in with these parameters.",
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor, height: 1.4),
            ),
            const SizedBox(height: 20),
            
            const Text("Seeded Username", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                hintText: "E.g. John Doe",
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Role picker
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Role Profile", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        items: const [
                          DropdownMenuItem(value: "user", child: Text("Regular User")),
                          DropdownMenuItem(value: "admin", child: Text("Platform Admin")),
                        ],
                        onChanged: (val) => setState(() => _selectedRole = val ?? 'user'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Plan picker
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Billing Tier", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedPlan,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        items: const [
                          DropdownMenuItem(value: "free", child: Text("Free Limit (5/mo)")),
                          DropdownMenuItem(value: "paid", child: Text("Premium Unlimited")),
                        ],
                        onChanged: (val) => setState(() => _selectedPlan = val ?? 'free'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _handleBypassLogin();
                },
                child: const Text("Enter with these Settings"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackArrow = _currentState == AuthScreenState.forgotPassword ||
        _currentState == AuthScreenState.checkEmail ||
        _currentState == AuthScreenState.resetPassword;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: WatchBackground(
        showDialTicks: true,
        showGears: true,
        isDark: context.isDarkTheme,
        child: Stack(
          children: [
            // Main Scroll View Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Brand Header Section
                      Text(
                        "WatchWise",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: context.primaryNav,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "START DISCOVERING",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.textSecondaryColor,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Crossfading State Switcher for outstanding micro-animations
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _buildStateWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top-left Back Arrow Button
            if (showBackArrow)
              Positioned(
                top: 48,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: context.textSecondaryColor, size: 28),
                  onPressed: () {
                    setState(() {
                      if (_currentState == AuthScreenState.resetPassword) {
                        _currentState = AuthScreenState.signIn;
                      } else if (_currentState == AuthScreenState.checkEmail) {
                        _currentState = AuthScreenState.forgotPassword;
                      } else {
                        _currentState = AuthScreenState.signIn;
                      }
                    });
                  },
                ),
              ),

            // Settings bypass launcher gear icon (moved to top right to avoid overlap)
            Positioned(
              top: 48,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: context.chipBg.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: context.primaryNav),
                  onPressed: _showTestBypassSheet,
                  tooltip: "Bypass options",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Switches between widgets based on state
  Widget _buildStateWidget() {
    switch (_currentState) {
      case AuthScreenState.signIn:
        return _buildSignInState();
      case AuthScreenState.signUp:
        return _buildSignUpState();
      case AuthScreenState.forgotPassword:
        return _buildForgotPasswordState();
      case AuthScreenState.checkEmail:
        return _buildCheckEmailState();
      case AuthScreenState.resetPassword:
        return _buildResetPasswordState();
    }
  }

  // 1. SIGN IN STATE (Dark Blue Container matching screenshot)
  Widget _buildSignInState() {
    return Obx(() {
      final isLoading = _authController.isLoading.value;
      return Column(
        key: const ValueKey("signIn"),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 360),
            decoration: BoxDecoration(
              color: context.isDarkTheme ? AppColors.surfaceDark : const Color(0xFF002952), // Deep Navy or Slate background
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: context.isDarkTheme ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isLoading
                  ? Center(
                      key: const ValueKey("signInLoader"),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/timer.json',
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Syncing Watch Vault...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Calibrating indices & credentials",
                            style: TextStyle(
                              color: context.textSecondaryColor.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      key: const ValueKey("signInForm"),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Underline Input
                        const Text(
                          "Email Address",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: "mail@example.com",
                            hintStyle: TextStyle(color: Colors.white38),
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password Underline Input
                        const Text(
                          "Password",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.5)),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleBypassLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: context.isDarkTheme ? AppColors.backgroundDark : const Color(0xFF002952),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _currentState = AuthScreenState.forgotPassword),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider lines
          Row(
            children: [
              Expanded(child: Divider(color: context.borderColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "OR CONTINUE WITH",
                  style: TextStyle(fontSize: 10, color: context.textSecondaryColor, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              Expanded(child: Divider(color: context.borderColor, thickness: 1)),
            ],
          ),
          const SizedBox(height: 24),

          // Apple & Google Buttons
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  label: "Apple",
                  iconWidget: Icon(Icons.apple, size: 22, color: context.textPrimaryColor),
                  onTap: _handleBypassLogin,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSocialButton(
                  label: "Google",
                  iconWidget: const GoogleLogo(size: 20),
                  onTap: _handleBypassLogin,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Create Account navigation link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: TextStyle(color: context.textSecondaryColor, fontSize: 14)),
              GestureDetector(
                onTap: () => setState(() => _currentState = AuthScreenState.signUp),
                child: Text(
                  "Create Account",
                  style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          )
        ],
      );
    });
  }

  // 2. CREATE ACCOUNT STATE (White Background with underline fields)
  Widget _buildSignUpState() {
    return Obx(() {
      final isLoading = _authController.isLoading.value;
      return Column(
        key: const ValueKey("signUp"),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            Container(
              height: 480, // Matches form height to prevent layout jumps
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/timer.json',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Calibrating Vault Credentials...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryNav,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Generating secure local SQLite keys",
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              "Create your\naccount",
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.bold, 
                color: context.primaryNav,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Sign in to continue tracking luxury watch listings.",
              style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
            ),
            const SizedBox(height: 32),

            // Name Underline Input
            Text("Full Name", style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
            TextField(
              controller: _nameController,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: "Your Name",
                hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.4)),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryNav, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // Email Underline Input
            Text("Email", style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
            TextField(
              controller: _emailController,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: "mail@example.com",
                hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.4)),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryNav, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),

            // Password Underline Input
            Text("Password", style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: InputDecoration(
                hintText: "••••••••",
                hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.4)),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryNav, width: 1.5)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: context.textSecondaryColor,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Register action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleBypassLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryNav,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),

            // Already have link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ", style: TextStyle(color: context.textSecondaryColor, fontSize: 14)),
                GestureDetector(
                  onTap: () => setState(() => _currentState = AuthScreenState.signIn),
                  child: Text(
                    "Sign In",
                    style: TextStyle(color: context.primaryNav, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  // 3. FORGOT PASSWORD / RECOVER ACCESS STATE (Dark Blue Card matching screenshot)
  Widget _buildForgotPasswordState() {
    return Container(
      key: const ValueKey("forgotPassword"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkTheme ? AppColors.surfaceDark : const Color(0xFF002952),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.isDarkTheme ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recover Access",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your email to receive a reset link.",
            style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
          ),
          const SizedBox(height: 32),

          const Text(
            "Email Address",
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: "mail@example.com",
              hintStyle: TextStyle(color: Colors.white38),
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.5)),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Instantly advance to success page
                setState(() => _currentState = AuthScreenState.checkEmail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: context.isDarkTheme ? AppColors.backgroundDark : const Color(0xFF002952),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Send Link", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 28),

          const Center(
            child: Text(
              "Need help contacting support?",
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 4. CHECK EMAIL SUCCESS STATE (Dark Blue Card with mail icon matching screenshot)
  Widget _buildCheckEmailState() {
    return Container(
      key: const ValueKey("checkEmail"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkTheme ? AppColors.surfaceDark : const Color(0xFF002952),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.isDarkTheme ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          
          // White Circular Avatar with Navy Envelope
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.email_outlined,
                color: context.isDarkTheme ? AppColors.surfaceDark : const Color(0xFF002952),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            "Check Your Email",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            "We've sent a password reset link to your email address.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text(
            "Didn't receive it? Check spam or resend.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white38, height: 1.4),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Open Reset Password state directly to complete testing demo loop
                setState(() => _currentState = AuthScreenState.resetPassword);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: context.isDarkTheme ? AppColors.backgroundDark : const Color(0xFF002952),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Back to Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 5. RESET PASSWORD INPUT STATE (White Background directly with underline fields)
  Widget _buildResetPasswordState() {
    return Column(
      key: const ValueKey("resetPassword"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reset Password",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.primaryNav),
        ),
        const SizedBox(height: 8),
        Text(
          "Please enter your new watch-vault credentials below.",
          style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
        ),
        const SizedBox(height: 32),

        // New Password field
        Text("New Password", style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: context.textPrimaryColor),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.4)),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryNav, width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: context.textSecondaryColor,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Confirm Password field
        Text("Confirm Password", style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: context.textPrimaryColor),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(color: context.textSecondaryColor.withValues(alpha: 0.4)),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.borderColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryNav, width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: context.textSecondaryColor,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Action Reset Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar("Success", "Password updated successfully!");
              setState(() => _currentState = AuthScreenState.signIn);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryNav,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),

        // Back to Sign In footer
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _currentState = AuthScreenState.signIn),
            child: Text(
              "Back to sign in",
              style: TextStyle(color: context.textSecondaryColor, fontSize: 14, decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  // Social Button Widget (Apple / Google)
  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border.all(color: context.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google Logo vector drawn with CustomPaint to avoid network dependency issues
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = w / 2;
    final center = Offset(w / 2, h / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.28;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2);

    // Red Arc (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -pi * 0.75, pi / 2, false, paint);

    // Yellow Arc (Left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -pi * 1.25, pi / 2, false, paint);

    // Green Arc (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, pi * 0.25, pi / 2, false, paint);

    // Blue Arc (Right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -pi * 0.25, pi / 2, false, paint);

    // Horizontal blue bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    final double barHeight = w * 0.28;
    final Rect barRect = Rect.fromLTWH(
      center.dx,
      center.dy - barHeight / 2,
      radius,
      barHeight,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
