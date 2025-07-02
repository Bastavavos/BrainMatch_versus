import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/user.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final String baseUrl = dotenv.env['API_KEY']!;
    final response = await http.get(Uri.parse('$baseUrl/user'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<User> loadedUsers = data.map((e) => User.fromJson(e)).toList();

      // Trier par score décroissant
      loadedUsers.sort((a, b) => b.score.compareTo(a.score));

      setState(() {
        users = loadedUsers;
        isLoading = false;
      });
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Or
      case 1:
        return const Color(0xFFC0C0C0); // Argent
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white;
    }
  }

  void _sendFriendRequest(String userId, String username) {
    // add api call add friends
    // await http.post(Uri.parse('$baseUrl/api/friends/add'), body: {'friendId': userId});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request send to : $username")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final podiumUsers = users.take(3).toList();
    final otherUsers = users.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FD),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              '🏆 Big brainers',
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 16),
            _buildPodium(podiumUsers),
            const Divider(thickness: 2),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final user = otherUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundImage: user.picture != null
                          ? CachedNetworkImageProvider(user.picture!)
                          : null,
                      child: user.picture == null
                          ? const Icon(Icons.person, size: 26)
                          : null,
                    ),
                    title: Text(
                      user.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Score : ${user.score}',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "#${index + 4}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () => _sendFriendRequest(
                              user.id, user.username),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<User> topUsers) {
    List<Widget> podiumWidgets = [];

    for (int i = 0; i < 3; i++) {
      final user = topUsers.length > i ? topUsers[i] : null;
      podiumWidgets.add(
        Expanded(
          child: Column(
            children: [
              Text(
                _rankLabel(i),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getRankColor(i),
                ),
              ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: i == 0 ? 40 : 30,
                backgroundColor: _getRankColor(i),
                backgroundImage: user?.picture != null
                    ? CachedNetworkImageProvider(user!.picture!)
                    : null,
                child: user?.picture == null
                    ? Icon(Icons.person,
                    size: i == 0 ? 40 : 30, color: Colors.deepPurple)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                user?.username ?? "-",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                user != null ? '${user.score} pts' : '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          podiumWidgets[1],
          podiumWidgets[0], // Le 1er est au centre
          podiumWidgets[2],
        ],
      ),
    );
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0:
        return '🥇 1er';
      case 1:
        return '🥈 2e';
      case 2:
        return '🥉 3e';
      default:
        return '';
    }
  }
}
