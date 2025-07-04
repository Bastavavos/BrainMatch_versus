import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class UserRepository {
  final String baseUrl = dotenv.env['API_KEY']!;

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/user'));

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
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de la récupération de l\'utilisateur');
    }
  }
}