import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../provider/user_provider.dart';
import '../widgets/nav_bar.dart';
import '../screens/main/leaderboard.dart';
import '../screens/main/selection_mode.dart';
import '../screens/main/user_profile.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    LeaderboardScreen(),
    SelectionModePage(),
    UserProfilePage()
  ];

  Future<void> _logout() async {
    final token = ref.read(tokenProvider);
    final baseUrl = dotenv.env['API_KEY'];

    if (token != null && baseUrl != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/user/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        debugPrint("Erreur logout: $e");
      }
    }

    ref.read(currentUserProvider.notifier).setUser(null);
    ref.read(tokenProvider.notifier).state = null;

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            'assets/images/logo.png',
            height: 60,
          ),
        ),
        title: Image.asset(
          'assets/images/title.png',
          height: 70,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
              tooltip: 'Déconnexion',
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
