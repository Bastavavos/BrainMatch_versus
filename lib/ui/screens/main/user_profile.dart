import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../service/api_service.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/user_profile_card.dart';
import '../../widgets/profil_friend.dart';

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
    final user = ref.read(currentUserProvider);
    await ref.read(currentUserProvider.notifier).refreshUser(ref);


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

  // Cette fonction met à jour l'URL de l'image dans le provider
  void _updateUserImage(String newUrl) {
    // Appelle un notifier ou une fonction dans ton userProvider pour modifier l'utilisateur
    ref.read(currentUserProvider.notifier).updatePicture(newUrl);
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
              onImageUpdated: (newUrl) {
                _updateUserImage(newUrl);
              },
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

                // Widget pour les demandes d'ami
                const FriendRequestsWidget(),

                const SizedBox(height: 24),

                // Liste des amis
                if (_friendsData.isEmpty)
                  const Text("Aucun ami trouvé.")
                else
                  ..._friendsData.map((friend) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: (friend['picture'] != null && friend['picture'] != '')
                            ? NetworkImage(friend['picture'])
                            : null,
                        child: (friend['picture'] == null || friend['picture'] == '')
                            ? const Icon(Icons.person, color: Colors.deepPurple)
                            : null,
                      ),
                      title: Text(friend['username'] ?? ''),
                    );
                  }).toList(),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
