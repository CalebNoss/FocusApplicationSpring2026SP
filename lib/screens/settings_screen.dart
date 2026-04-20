import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'credits_screen.dart';
import '../login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<void> _openAudioSettings(BuildContext context) async {
    Uri? target;

    if (kIsWeb) {
      // chrome:// URLs are blocked in most web contexts, so use a stable
      // browser audio settings/help page.
      target = Uri.parse('https://support.google.com/chrome/answer/2693767');
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      target = Uri.parse('ms-settings:sound');
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      target = Uri.parse('x-apple.systempreferences:com.apple.preference.sound');
    }

    if (target == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio settings shortcut is not supported on this platform.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(target);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open audio settings. Please open system sound settings manually.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.speaker_outlined, color: Colors.white),
                    title: const Text('Audio Output', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      kIsWeb
                          ? 'Open browser audio settings'
                          : 'Open system sound settings',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.open_in_new, color: Colors.white70),
                    onTap: () => _openAudioSettings(context),
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined, color: Colors.white),
                    title: const Text('Credits', style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      'Project team and third-party attributions',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreditsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                    subtitle: const Text(
                      'Log out of your account',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
