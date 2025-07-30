import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          indicatorColor: Colors.grey,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Classement',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.play_arrow),
              icon: Icon(Icons.play_arrow),
              label: 'Jouer',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
