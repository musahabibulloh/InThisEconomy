import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Show splash screen for at least 2 seconds for branding
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/icons/market_mind_logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            const Text(
              'Market Mind',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                letterSpacing: 1.2,
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 200.ms).fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 8),
            const Text(
              'Validasi Ide Bisnis & Analisis Pasar',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
