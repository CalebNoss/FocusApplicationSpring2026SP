// Imports Flutter's visual components (buttons, text fields, etc.)
import 'package:flutter/material.dart';

import 'home_screen.dart';

// Imports Supabase so we can use the login feature
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports our Sign Up screen so we can navigate to it
import 'signup_screen.dart';

// Shortcut to talk to Supabase without typing the full name every time
final supabase = Supabase.instance.client;

// StatefulWidget because this screen can change (loading spinner, errors, etc.)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Controls and reads what the user types in the Email field
  final _emailController = TextEditingController();

  // Controls and reads what the user types in the Password field
  final _passwordController = TextEditingController();

  // True when we're waiting for Supabase to respond (shows loading spinner)
  bool _isLoading = false;

  // This function runs when the user presses "Login"
  Future<void> _login() async {

    // Show the loading spinner
    setState(() => _isLoading = true);

    try {
      // Ask Supabase to sign in with the email and password the user typed
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login was successful, response.user will not be null
      if (response.user != null && mounted) {

        // Show a welcome message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome back!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

    } catch (e) {
      // If login failed, show the error to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    // Hide the loading spinner when done
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          // Limits the form width so it doesn't stretch across the whole screen
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24.0), // 24px space on all sides
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center everything vertically
              children: [

                // App title
                const Text(
                  'Focus Camp',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // takes a special Flutter constant, not a number
                  ),
                ),

                const SizedBox(height: 8), // Small space

                // Subtitle
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 48), // Larger space before the fields

                // Email input field
                // "style" makes the typed text white
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white), // typed text is white
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey), // label text color
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38), // border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // border when focused/clicked
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Password input field (text is hidden)
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white), // typed text is white
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey), // label text color
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38), // border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // border when focused/clicked
                    ),
                  ),
                  obscureText: true, // Hides password with dots
                ),

                const SizedBox(height: 24),

                // Login button — full width
                // styleFrom lets you customize the button's colors
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,  // button background
                      foregroundColor: Colors.black,  // button text color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _login, // Disabled while loading
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 16),

                // "Don't have an account?" link to go to Sign Up screen
                TextButton(
                  onPressed: () {
                    // Navigate to the SignUpScreen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.grey), // grey link text
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}