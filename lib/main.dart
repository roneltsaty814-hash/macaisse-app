import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/factures_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/abonnement_screen.dart';

void main() {
  runApp(const ComptaApp());
}

class ComptaApp extends StatelessWidget {
  const ComptaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Caisse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F6E56),
      ),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    FacturesScreen(),
    ClientsScreen(),
    AbonnementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Factures'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Abonnement'),
        ],
      ),
    );
  }
}
