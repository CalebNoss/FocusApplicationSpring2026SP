import 'package:flutter/material.dart';
import 'native.dart';
import 'dart:async';
import 'audio_player_widget.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/timer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'screens/progress_screen.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mkdmmdmwhsigrkemxpbz.supabase.co',
    anonKey: 'sb_publishable_efuTHwIo_cSKek4N1cVDjQ_tLLAdo5w',
  );

  runApp(const MyApp());
}

final native = NativeBindings();
final controller = TextEditingController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _backgroundTimer;
  bool isRunning = false;



  @override
  void initState() {
    super.initState();
    _backgroundTimer = Timer.periodic(Duration(seconds: 1), (_) => runCheck());
  }

  void runCheck() {
    if (isRunning) {
      native.callRunMiddle(controller.text);
    }
  }

  @override
  void dispose() {
    _backgroundTimer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Home'),
                  Tab(text: 'Audio'),
                  Tab(text: 'Timer'),
                  Tab(text: 'Journey'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                HomeScreen(
                  onStartFocus: () {
                    tabController.animateTo(2);
                  },
                ),
                const Center(child: AudioPlayerWidget()),
                const TimerScreen(),
                ProgressScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}