import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set system UI style — light theme: dark icons on transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,       // Dark icons on light bg
    statusBarBrightness: Brightness.light,           // iOS: light status bar
    systemNavigationBarColor: Color(0xFFF7F4EF),    // Match bgLight
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase
  if (SupabaseConfig.url.isNotEmpty) {
    await SupabaseConfig.initialize();
  }

  runApp(const ValidasiIdeApp());
}
