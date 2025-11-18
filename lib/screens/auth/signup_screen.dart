import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class PremiumSignupScreen extends StatefulWidget {
  const PremiumSignupScreen({super.key});

  @override
  State<PremiumSignupScreen> createState() => _PremiumSignupScreenState();
}

class _PremiumSignupScreenState extends State<PremiumSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
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
                final maxWidth = constraints.maxWidth > 640 ? 500.0 : null;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
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
                                      color: colorScheme.secondary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 32,
                                      spreadRadius: 6,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'lib/assets/images/logo.png',
                                  width: 140.w,
                                  color: Colors.white,
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .scale(),
                              ),
                            ),
                            SizedBox(height: 28.h),
                            Column(
                              children: [
                                Text(
                                  'Create Account',
                                  style: GoogleFonts.playfairDisplay(
                                    color: colorScheme.secondary,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideY(begin: 0.2, end: 0),
                                SizedBox(height: 8.h),
                                Text(
                                  'Join our tailoring community',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                              ],
                            ),
                            SizedBox(height: 32.h),
                            _buildAuthField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 600.ms),
                            SizedBox(height: 18.h),
                            _buildAuthField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 800.ms),
                            SizedBox(height: 18.h),
                            _buildAuthField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be 6+ characters';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 1000.ms),
                            SizedBox(height: 18.h),
                            _buildAuthField(
                              label: 'Confirm Password',
                              icon: Icons.lock_reset,
                              obscureText: _obscureConfirmPassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 1200.ms),
                            SizedBox(height: 28.h),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('SIGN UP'),
                            )
                                .animate()
                                .fadeIn(delay: 1400.ms)
                                .scaleXY(begin: 0.95, end: 1),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
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
                            ).animate().fadeIn(delay: 1600.ms),
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
                            ).animate().fadeIn(delay: 1800.ms),
                            SizedBox(height: 22.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.montserrat(
                                      color: colorScheme.secondary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 2000.ms),
                            SizedBox(height: 24.h),
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

  Widget _buildAuthField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
      validator: validator,
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _fullNameController.text.trim(),
        );
        await FirebaseAuth.instance.currentUser?.reload();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      _showError('Sign up failed: $e');
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
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError('Google Sign-In failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// =================================================================
// GOLDEN THREADS BACKGROUND PAINTER (REQUIRED FOR THE DESIGN)
// =================================================================
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
