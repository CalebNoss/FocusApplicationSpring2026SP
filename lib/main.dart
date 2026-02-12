import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/timer_screen.dart';

void main() {
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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Focus App'),
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
                    tabController.animateTo(2); // Timer tab (0=Home,1=Audio,2=Timer)
                  },
                ),
                const Center(child: Text('Audio Tab Data')),
                const TimerScreen(),
                const Center(child: Text('Journey Tab Data')),
              ],
            ),
          );
        },
      ),
    );
  }
}
