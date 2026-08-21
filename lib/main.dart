import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F0F23),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Supabase
  if (SupabaseConfig.url.isNotEmpty) {
    await SupabaseConfig.initialize();
  }

  runApp(const ValidasiIdeApp());
}
