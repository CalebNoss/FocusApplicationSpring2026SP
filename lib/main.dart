// Imports Flutter's visual components
import 'package:flutter/material.dart';

// Imports Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports our Login screen so we can show it first when the app opens
import 'login_screen.dart';

// Shortcut to talk to Supabase
final supabase = Supabase.instance.client;

// "async" because we need to wait for Supabase to initialize before starting the app
Future<void> main() async {

  // Makes sure Flutter is ready before we do anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Connects our app to Supabase — must happen before runApp()
  await Supabase.initialize(
    url: 'https://mkdmmdmwhsigrkemxpbz.supabase.co',  // ← your Project URL
    anonKey: 'sb_publishable_efuTHwIo_cSKek4N1cVDjQ_tLLAdo5w',                     // ← your Publishable API Key
  );

  // Starts the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // LoginScreen is now the first screen the user sees
      home: const LoginScreen(),
    );
  }
}