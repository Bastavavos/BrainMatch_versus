import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../Service/api_service.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/profil_friend.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>  {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _friendsData = [];

  Future<void> _fetchFriendsData(
      List<String> friendIds,
      String? token,
      ) async {
    List<Map<String, dynamic>> friends = [];

    for (var friendId in friendIds) {
      try {
        final api = ApiService(token: token);
        final response = await api.get('/user/$friendId');

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
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = "Utilisateur non connecté.";
      });
      return;
    }

    final token = ref.read(tokenProvider);
    await _fetchFriendsData(user.friendIds, token);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Aucune donnée utilisateur trouvée.")),
      );
    }

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
                backgroundImage: user.picture != null && user.picture!.isNotEmpty
                    ? NetworkImage(user.picture!)
                    : null,
                child: (user.picture == null || user.picture!.isEmpty)
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
                    user.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
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
                        "${user.score}",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                const Text(
                  "Friends",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // Affichage des demandes d'ami
                const FriendRequestsWidget(),

                const SizedBox(height: 24),

                // Affichage de la liste des amis déjà acceptés
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
                final token = ref.read(tokenProvider);

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

                ref.read(currentUserProvider.notifier).setUser(null);
                ref.read(tokenProvider.notifier).state = null;

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

