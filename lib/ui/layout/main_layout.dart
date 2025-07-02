import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../screens/main/leaderboard.dart';
import '../screens/main/selection_mode.dart';
import '../screens/main/user_profile.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    LeaderboardScreen(),
    SelectionModePage(),
    UserProfilePage()
  ];

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
