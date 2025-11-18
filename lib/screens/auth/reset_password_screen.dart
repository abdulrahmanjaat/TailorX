import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class PremiumResetPasswordScreen extends StatefulWidget {
  const PremiumResetPasswordScreen({super.key});

  @override
  State<PremiumResetPasswordScreen> createState() => _PremiumResetPasswordScreenState();
}

class _PremiumResetPasswordScreenState extends State<PremiumResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Background Elements
          Positioned.fill(
            child: CustomPaint(
              painter: _GoldenThreadsPainter(),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 600 ? 460.0 : null;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth ?? 520),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 16.h),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 6,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'lib/assets/images/logo.png',
                                  width: 120.w,
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
                                  'Reset Password',
                                  style: GoogleFonts.playfairDisplay(
                                    color: AppColors.gold,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideY(begin: 0.2, end: 0),
                                SizedBox(height: 14.h),
                                Text(
                                  'Enter your email to receive a reset link',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                              ],
                            ),
                            SizedBox(height: 32.h),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: AppColors.gold),
                                ),
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
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleReset,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'SEND RESET LINK',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .scaleXY(begin: 0.95, end: 1),
                            SizedBox(height: 18.h),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Back to Login',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.gold,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ).animate().fadeIn(delay: 1000.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send reset link: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Reusable Background Painter
class _GoldenThreadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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