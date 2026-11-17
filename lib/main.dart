import 'package:flutter/material.dart';

import 'pages/medicines_page.dart';
import 'pages/today_page.dart';
import 'services/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.load();
  runApp(RemediosApp(controller: controller));
}

class RemediosApp extends StatelessWidget {
  const RemediosApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remédios do Dia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 80,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: HomeShell(controller: controller),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          TodayPage(controller: widget.controller),
          MedicinesPage(controller: widget.controller),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined, size: 30),
            selectedIcon: Icon(Icons.today_rounded, size: 30),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined, size: 30),
            selectedIcon: Icon(Icons.medication_rounded, size: 30),
            label: 'Remédios',
          ),
        ],
      ),
    );
  }
}
