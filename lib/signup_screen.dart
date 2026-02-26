// This imports Flutter's visual components (buttons, text fields, etc.)
import 'package:flutter/material.dart';

// This imports the Supabase package so we can use login/signup/database features
import 'package:supabase_flutter/supabase_flutter.dart';

// This creates a shortcut variable called "supabase" so we don't have to type
// "Supabase.instance.client" every time we want to talk to the database
final supabase = Supabase.instance.client;

// "StatefulWidget" means this screen can change/update its appearance
// (e.g., showing a loading spinner when the button is pressed)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key}); // "super.key" is just Flutter's way of identifying this widget

  @override
  // This links the screen to its "State" class below where all the logic lives
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// This is where all the logic and data for the Sign Up screen lives
class _SignUpScreenState extends State<SignUpScreen> {

  // This controls and reads whatever the user types in the Email text field
  final _emailController = TextEditingController();

  // This controls and reads whatever the user types in the Password text field
  final _passwordController = TextEditingController();

  // This is a true/false variable — true means we're waiting for Supabase to respond
  // We use it to show a loading spinner while the sign up is happening
  bool _isLoading = false;

  // "Future<void>" means this function does something that takes time (like talking to Supabase)
  // "async" means it will wait for each step to finish before moving to the next
  Future<void> _signUp() async {

    // Set _isLoading to true — this will show the loading spinner on the button
    // "setState" tells Flutter "something changed, please redraw the screen"
    setState(() => _isLoading = true);

    // "try" means: attempt this code, but if something goes wrong, don't crash —
    // instead jump to the "catch" block below
    try {

      // This calls Supabase's built-in sign up function and waits for a response
      // ".trim()" removes any accidental spaces the user may have typed
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),      // Gets the text the user typed in the email field
        password: _passwordController.text.trim(), // Gets the text the user typed in the password field
      );

      // Check if Supabase successfully created a user
      // "response.user" will be null if something went wrong
      if (response.user != null) {

        // Save the new user's info into our "profiles" table in the database
        // response.user!.id is the unique ID Supabase automatically gave this user
        // The "!" after user means "I'm sure this isn't null, go ahead"
        await supabase.from('profiles').insert({
          'id': response.user!.id,                    // Supabase auto-generated user ID
          'email': _emailController.text.trim(),       // The email they signed up with
        });

        // "mounted" checks that the screen is still open before trying to update it
        // (the user could have navigated away while waiting)
        if (mounted) {

          // Show a small popup message at the bottom of the screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please log in.')),
          );

          // Go back to the previous screen (the Login screen)
          Navigator.pop(context);
        }
      }

    // "catch (e)" runs if anything in the "try" block above failed
    // "e" contains the error message
    } catch (e) {
      if (mounted) {
        // Show the error message to the user in a popup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // "$e" inserts the error text into the string
        );
      }
    }

    // Sign up is done (success or fail) — hide the loading spinner
    setState(() => _isLoading = false);
  }

  // "build" is called every time Flutter needs to draw this screen
  // "context" contains information about where this widget is in the app
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold is a basic screen layout with appBar + body
      appBar: AppBar(title: const Text('Sign Up')), // The top bar with "Sign Up" title

      body: Padding( // Padding adds space around the content so it doesn't touch the edges
        padding: const EdgeInsets.all(24.0), // 24 pixels of space on all sides
        child: Column( // Column stacks widgets vertically (top to bottom)
          mainAxisAlignment: MainAxisAlignment.center, // Centers everything vertically
          children: [

            // Big title text
            const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

            const SizedBox(height: 32), // Empty space (32 pixels tall) between widgets

            // Email input field
            TextField(
              controller: _emailController, // Links this field to our email controller
              decoration: const InputDecoration(
                labelText: 'Email',           // Placeholder/label text inside the field
                border: OutlineInputBorder(), // Gives the field a box border
              ),
              keyboardType: TextInputType.emailAddress, // Shows email-friendly keyboard on mobile
            ),

            const SizedBox(height: 16), // Space between the two text fields

            // Password input field
            TextField(
              controller: _passwordController, // Links this field to our password controller
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Hides the text with dots (like a password field should)
            ),

            const SizedBox(height: 24), // Space before the button

            // SizedBox with full width makes the button stretch across the whole screen
            SizedBox(
              width: double.infinity, // "double.infinity" means "as wide as possible"
              child: ElevatedButton( // A raised/elevated button
                // If _isLoading is true, pass null (disables the button)
                // If _isLoading is false, call _signUp when pressed
                onPressed: _isLoading ? null : _signUp,

                // If loading, show a spinning circle; otherwise show "Sign Up" text
                child: _isLoading
                    ? const CircularProgressIndicator() // Spinning loading circle
                    : const Text('Sign Up'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}