import 'dart:convert';

import 'package:brain_match/Service/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
}