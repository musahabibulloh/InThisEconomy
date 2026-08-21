import 'package:flutter/material.dart';
import 'core/config/app_theme.dart';
import 'core/router/app_router.dart';

class ValidasiIdeApp extends StatelessWidget {
  const ValidasiIdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ValidasiIde - Validasi Ide Bisnis UMKM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
