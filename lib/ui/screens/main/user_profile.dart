import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../service/api_service.dart';
import '../../../provider/user_provider.dart';
import '../../theme.dart';
import '../../widgets/user_profile/user_profile_card.dart';
import '../../widgets/user_profile/profile_friend.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _friendsData = [];

  Future<void> _fetchFriendsData(List<String> friendIds, String? token) async {
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

  Future<void> _fetchUserData() async {
    await ref.read(currentUserProvider.notifier).refreshUser(ref);

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
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final token = ref.watch(tokenProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (token == null) {
      return const Scaffold(
        body: Center(child: Text("Token manquant, veuillez vous reconnecter.")),
      );
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
            const SizedBox(height: 24),
            UserProfileCard(
              user: user,
              token: token,
              onLogout: () {
                // Ajoute ici la logique de déconnexion si nécessaire
              },
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FriendRequestsWidget(),
                const SizedBox(height: 24),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mes amis :",
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_friendsData.isEmpty)
                          const Text("Aucun ami trouvé.")
                        else
                          ..._friendsData.map((friend) {
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepPurple.shade100,
                                    backgroundImage: (friend['picture'] != null && friend['picture'] != '')
                                        ? NetworkImage(friend['picture'])
                                        : null,
                                    child: (friend['picture'] == null || friend['picture'] == '')
                                        ? const Icon(Icons.person, color: Colors.deepPurple)
                                        : null,
                                  ),
                                  title: Text(
                                    friend['username'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Mulish',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            )





          ],
        ),
      ),
    );
  }
}
