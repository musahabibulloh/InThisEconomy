import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1B2838),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Supabase
  if (SupabaseConfig.url.isNotEmpty) {
    await SupabaseConfig.initialize();
  }

  runApp(const ValidasiIdeApp());
}
