import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GoldenThreadsPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 640 ? 480.0 : null;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth ?? 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 12.h),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.secondary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 6,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child:
                                    Image.asset(
                                          'lib/assets/images/logo.png',
                                          width: 140.w,
                                          color: Colors.white,
                                        )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .scale(),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Column(
                              children: [
                                Text(
                                      'Welcome Back',
                                      style: GoogleFonts.playfairDisplay(
                                        color: colorScheme.secondary,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideY(begin: 0.2, end: 0),
                                SizedBox(height: 10.h),
                                Text(
                                  'Sign in to continue',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                              ],
                            ),
                            SizedBox(height: 36.h),
                            TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: _buildInputDecoration(
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .slideY(begin: 0.1, end: 0),
                            SizedBox(height: 20.h),
                            TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: _buildInputDecoration(
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be 6+ characters';
                                    }
                                    return null;
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideY(begin: 0.1, end: 0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.montserrat(
                                    color: colorScheme.secondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 1000.ms),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child:
                                      _isLoading
                                          ? SizedBox(
                                            width: 22.w,
                                            height: 22.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        Colors.black,
                                                      ),
                                                ),
                                          )
                                          : const Text('LOGIN'),
                                )
                                .animate()
                                .fadeIn(delay: 1200.ms)
                                .scaleXY(begin: 0.95, end: 1),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white54,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1400.ms),
                            SizedBox(height: 20.h),
                            OutlinedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: Image.asset(
                                'lib/assets/images/google_icon.png',
                                width: 22.w,
                                height: 22.w,
                              ),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ).animate().fadeIn(delay: 1600.ms),
                            SizedBox(height: 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/signup',
                                      ),
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.montserrat(
                                      color: colorScheme.secondary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1800.ms),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (credential != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.user?.email ?? '');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      _showError('Google Sign-In failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Reset Password',
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFFD4AF37),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) return;
                  try {
                    await _authService.sendPasswordReset(email);
                    if (!mounted || !dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent')),
                    );
                  } catch (e) {
                    _showError('Unable to send reset link: $e');
                  }
                },
                child: const Text('Send Link'),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GoldenThreadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFD4AF37).withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    for (double i = -500; i < size.width + 500; i += 40) {
      canvas.drawLine(
        Offset(i, -100),
        Offset(i + 500, size.height + 100),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
