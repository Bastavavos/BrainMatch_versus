import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Service/api_service.dart';
import '../view_models/user_view_model.dart';

final tokenProvider = StateProvider<String?>((ref) => null);

/// Contient les infos de l'utilisateur actuel récupéré via /me
final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final userViewModelProvider = ChangeNotifierProvider<UserViewModel>((ref) {
  final token = ref.watch(tokenProvider);
  return UserViewModel(token: token);
});

Future<void> onLoginSuccess(Map<String, dynamic> loginResponse, WidgetRef ref) async {

  final token = loginResponse['token'];
  if (token == null) return;

  ref.read(tokenProvider.notifier).state = token;

  // Appel à /me
  final api = ApiService(token: token);
  final response = await api.get('/me');
    print(response);
  if (response.statusCode == 200) {
    final user = jsonDecode(response.body);
    ref.read(userProvider.notifier).state = user;
    print("/me");
  } else {
    // optionnel : handle erreur /me
    ref.read(userProvider.notifier).state = null;
  }
}