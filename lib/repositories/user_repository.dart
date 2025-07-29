import 'dart:convert';
import 'package:brain_match/service/api_service.dart';

import '../models/user.dart';

class UserRepository {
  final ApiService api;

  UserRepository({required this.api});

  Future<List<User>> fetchUsers() async {
    final response = await api.get('/user');

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<User> users = body.map((dynamic item) => User.fromJson(item)).toList();
      users.sort((a, b) => b.score.compareTo(a.score));
      return users;
    } else {
      throw Exception('Échec de la récupération des utilisateurs');
    }
  }

  Future<User> fetchUserById(String userId) async {
    final response = await api.get('/user/$userId');


    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de la récupération de l\'utilisateur');
    }
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final response = await api.patch('/user/friend/send/$senderId/$receiverId');


    if (response.statusCode == 200) {
      print('Demande d\'ami envoyée avec succès');
    } else {
      throw Exception(
          'Échec de l\'envoi de la demande d\'ami : ${response.body}');
    }
  }

  Future<List<User>> getFriendRequests(String userId) async {
    try {
      final response = await api.get('/user/friend-requests/$userId');
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<User> friendRequests = jsonList.map((json) => User.fromJson(json)).toList();
        print("Nombre de demandes d'ami: ${friendRequests.length}");
        return friendRequests;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans getFriendRequests: $e');
      rethrow;
    }
  }


// Accepter une demande d'ami
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    final response = await api.patch('/user/friend/accept/$userId/$requesterId');

    if (response.statusCode == 200) {
      print('Demande d\'ami acceptée');
    } else {
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception(
        'Échec de l\'acceptation de la demande',
      );
    }
  }

// Supprimer/refuser une demande d'ami
  Future<void> deleteFriendRequest(String userId, String requesterId) async {
    final response = await api.delete('/user/friend/delete/$userId/$requesterId');

    if (response.statusCode == 200) {
      print('Demande d\'ami supprimée');
    } else {
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception(
        'Échec de la suppression de la demande ',
      );
    }
  }

}

