// this imports flutter's visual building blocks — things like buttons, text, colors, etc.
import 'package:flutter/material.dart';

// this imports supabase so we can create accounts and save data to the database
import 'package:supabase_flutter/supabase_flutter.dart';

// this creates a shortcut so we can just type "supabase" instead of the full long name every time
final supabase = Supabase.instance.client;

// "StatefulWidget" means this screen is allowed to change visually while it's open
// for example, it can show a loading spinner while waiting for supabase to respond
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key}); // "super.key" is just flutter's internal id system for widgets

  @override
  // this connects the widget to its "state" class below, which is where all the logic lives
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// this is the "state" class — think of it as the brain behind the signup screen
// all our variables and functions live here
class _SignUpScreenState extends State<SignUpScreen> {

  // this reads whatever the user types into the email field
  // "TextEditingController" is like a little listener attached to a text box
  final _emailController = TextEditingController();

  // same thing but for the password field
  final _passwordController = TextEditingController();

  // this is a true/false switch — when it's true, we show the loading spinner
  // when it's false, we show the normal "sign up" button text
  bool _isLoading = false;

  // "Future<void>" means this function takes time to finish (it talks to the internet)
  // "async" lets us use "await" inside, which pauses the function until each step is done
  Future<void> _signUp() async {

    // turn on the loading spinner by setting _isLoading to true
    // "setState" tells flutter "hey, something changed — please redraw the screen"
    setState(() => _isLoading = true);

    // "try" means: attempt the following code, but if anything breaks,
    // don't crash the app — instead run the "catch" block further down
    try {

      // this calls supabase's built-in signup function and waits for it to finish
      // ".trim()" removes any extra spaces the user might have accidentally typed
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),       // grab the email the user typed
        password: _passwordController.text.trim(), // grab the password the user typed
      );

      // "response.user" will be null (empty) if the signup failed
      // if it's not null, that means supabase created the account successfully
      if (response.user != null) {

        // now we save the user's info into our own "profiles" table in the database
        // "response.user!.id" is the unique id supabase automatically assigns every user
        // the "!" after "user" tells dart "i know this isn't null, trust me"
        await supabase.from('profiles').insert({
          'id': response.user!.id,               // the unique id supabase gave this user
          'email': _emailController.text.trim(),  // the email they signed up with
        });

        // "mounted" checks if this screen is still open
        // if the user navigated away while waiting, we skip the ui updates to avoid errors
        if (mounted) {

          // show a little popup message at the bottom of the screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please log in.')),
          );

          // go back to the login screen
          // "Navigator.pop" removes this screen and returns to the one before it
          Navigator.pop(context);
        }
      }

    // "catch (e)" runs if anything in the try block above threw an error
    // "e" is a variable that holds the error message
    } catch (e) {
      // only show the error if the screen is still open
      if (mounted) {
        // show a popup with the error message so the user knows what went wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')), // "$e" inserts the actual error text here
        );
      }
    }

    // whether signup worked or failed, turn off the loading spinner now
    setState(() => _isLoading = false);
  }

  // "build" is the function flutter calls every time it needs to draw this screen
  // it returns a tree of widgets that describe what the screen looks like
  @override
  Widget build(BuildContext context) {

    // "Scaffold" is a basic screen template — it gives us a background and a body area
    return Scaffold(
      backgroundColor: Colors.black, // set the whole screen background to black

      // "body" is the main content area of the screen
      body: Center( // "Center" puts its child in the middle of the screen
        child: SizedBox(
          width: 400, // limit the width so it doesn't stretch too wide on large screens
          child: Padding(
            padding: const EdgeInsets.all(24.0), // add 24 pixels of space on all 4 sides
            child: Column( // "Column" stacks widgets on top of each other vertically
              mainAxisAlignment: MainAxisAlignment.center, // vertically center everything
              children: [

                // the big title text at the top
                const Text(
                  'Focus Camp',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // "bold" is a flutter constant, not a number like css
                  ),
                ),

                const SizedBox(height: 8), // a small invisible box used as a spacer (8px tall)

                // subtitle text below the title
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 48), // larger gap before the input fields

                // the email text field
                // "controller" links this field to _emailController so we can read what was typed
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white), // make the typed text white
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey), // the "Email" label is grey
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38), // faint border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // bright border when the user taps it
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress, // shows "@" on the mobile keyboard
                ),

                const SizedBox(height: 16), // gap between the two input fields

                // the password text field
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white), // make the typed text white
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true, // hides the password text with dots — like a real password field
                ),

                const SizedBox(height: 24), // gap before the button

                // "SizedBox" with double.infinity makes the button stretch the full width
                SizedBox(
                  width: double.infinity, // "double.infinity" means "as wide as the parent allows"
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,  // white button background
                      foregroundColor: Colors.black,  // black text on the button
                      padding: const EdgeInsets.symmetric(vertical: 16), // taller button
                    ),
                    // if _isLoading is true, pass null to disable the button
                    // if _isLoading is false, call _signUp when the button is pressed
                    onPressed: _isLoading ? null : _signUp,
                    // if loading, show a spinning circle; otherwise show the "Sign Up" text
                    child: _isLoading
                        ? const CircularProgressIndicator() // this is the spinning loading circle
                        : const Text('Sign Up'),
                  ),
                ),

                const SizedBox(height: 16), // gap before the back link

                // a text button at the bottom that goes back to the login screen
                TextButton(
                  onPressed: () {
                    // "Navigator.pop" removes this screen and goes back to login
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(color: Colors.grey), // grey link text to match the login screen
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