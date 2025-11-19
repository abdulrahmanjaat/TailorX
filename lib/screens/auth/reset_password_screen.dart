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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF101010), Color(0xFF181818), Color(0xFF0D0D0D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
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
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 32.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 40,
                                offset: const Offset(0, 30),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 8.h),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.gold.withValues(alpha: 0.4),
                                        colorScheme.secondary.withValues(alpha: 0.2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.35),
                                        blurRadius: 36,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(20.w),
                                  child: Image.asset(
                                    'lib/assets/images/logo.png',
                                    width: 110.w,
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
                                  SizedBox(height: 8.h),
                                  Text(
                                    'We’ll email you a secure link to create a new password.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                      height: 1.5,
                                    ),
                                  ).animate().fadeIn(delay: 400.ms),
                                ],
                              ),
                              SizedBox(height: 26.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.35),
                                  ),
                                  color: AppColors.gold.withValues(alpha: 0.08),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white10,
                                      ),
                                      child: Icon(
                                        Icons.lock_reset_rounded,
                                        color: AppColors.gold,
                                        size: 22.w,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        'Use the email linked to your account. We’ll send a reset link instantly.',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 13.5.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 520.ms),
                              SizedBox(height: 24.h),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.white54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.white24),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: AppColors.gold),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.04),
                                  hintText: 'Enter your email',
                                  hintStyle: const TextStyle(
                                    color: Colors.white38,
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
                                  .fadeIn(delay: 650.ms)
                                  .slideY(begin: 0.1, end: 0),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleReset,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                ),
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
                                        'Send reset link'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                              )
                                  .animate()
                                  .fadeIn(delay: 820.ms)
                                  .scaleXY(begin: 0.95, end: 1),
                              SizedBox(height: 18.h),
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 18.w,
                                  color: AppColors.gold,
                                ),
                                label: Text(
                                  'Back to login',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.gold,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 980.ms),
                            ],
                          ),
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