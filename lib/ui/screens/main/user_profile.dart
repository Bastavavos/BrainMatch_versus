import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../provider/user_provider.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _friendsData = [];

  Future<void> _fetchFriendsData(
    List<dynamic> friendIds,
    String baseUrl,
    String? token,
  ) async {
    List<Map<String, dynamic>> friends = [];

    for (var friendId in friendIds) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/user/$friendId'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          friends.add(data);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la récupération de $friendId : $e');
        }
      }
    }
    setState(() {
      _friendsData = friends;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = ref.read(userProvider);
    if (user == null || user['userId'] == null) {
      setState(() {
        _isLoading = false;
        _error = "Utilisateur non connecté.";
      });
      return;
    }

    final String baseUrl = dotenv.env['API_KEY']!;
    final String userId = user['userId'];
    final String? token = user['token'];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data;
          _isLoading = false;
        });
        final friendIds = data['friends'] ?? [];
        await _fetchFriendsData(friendIds, baseUrl, token);
      } else {
        setState(() {
          _error = 'Erreur serveur : ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau : $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text("Aucune donnée utilisateur trouvée.")),
      );
    }

    final String username = _userData!['username'];
    final String email = _userData!['email'];
    final int score = _userData!['score'] ?? 0;
    final String pictureUrl =
        _userData!['picture'] ?? 'https://exemple.com/default.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: _userData!['picture'] != null && _userData!['picture'] != ''
                    ? NetworkImage(_userData!['picture'])
                    : null,
                child: (_userData!['picture'] == null || _userData!['picture'] == '')
                    ? const Icon(Icons.person, size: 48, color: Colors.deepPurple)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Score",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$score",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Column(
              children: [
                const Divider(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Friends",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _friendsData.map((friend) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: friend['picture'] != null && friend['picture'] != ''
                            ? NetworkImage(friend['picture'])
                            : null,
                        child: (friend['picture'] == null || friend['picture'] == '')
                            ? const Icon(Icons.person, color: Colors.deepPurple)
                            : null,
                      ),
                      title: Text(friend['username']),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Changer de compte"),
              onPressed: () async {
                final baseUrl = dotenv.env['API_KEY'];
                final user = ref.read(userProvider);
                final token = user?['token'];

                if (token != null) {
                  try {
                    final response = await http.post(
                      Uri.parse("$baseUrl/user/logout"),
                      headers: {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer $token",
                      },
                    );

                    if (kDebugMode) {
                      print("Logout status: ${response.statusCode}");
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print("Erreur lors de la déconnexion : $e");
                    }
                  }
                }
                ref.read(userProvider.notifier).state = null;
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
