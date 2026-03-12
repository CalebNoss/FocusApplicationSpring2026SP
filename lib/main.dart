import 'package:flutter/material.dart';
import 'screens/progress_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Text('Home')),
              Tab(icon: Text('Audio')),
              Tab(icon: Text('Timer')),
              Tab(icon: Text('Journey')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text('Home Tab Data')),
            const Center(child: Text('Audio Tab Data')),
            const Center(child: Text('Timer Tab Data')),
            ProgressScreen(),
          ],
        ),
      ),
    );
  }
}