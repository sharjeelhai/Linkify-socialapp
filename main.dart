import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found, using default configuration');
  }
  // Initialize Supabase ✅
  await Supabase.initialize(
    url: 'https://mqqzeoenshhemjekptfi.supabase.co', // Replace with your URL
    anonKey: """
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xcXplb2Vuc2hoZW1qZWtwdGZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MTYyNTgsImV4cCI6MjA3OTM5MjI1OH0.GP8HdjwJdHa5aqnGm0R7YEVRsMiYUeeImfvVt6HDU-4""", // Replace with your key
  );
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notifications
  await NotificationService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: LinkifyApp()));
}
