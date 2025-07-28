import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Service/api_service.dart';
import '../models/user.dart';
import '../view_models/user_view_model.dart';

// Token JWT
final tokenProvider = StateProvider<String?>((ref) => null);

// User courant (objet User fort typé)
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>(
      (ref) => CurrentUserNotifier(),
);

final userViewModelProvider = ChangeNotifierProvider<UserViewModel>((ref) {
  final token = ref.watch(tokenProvider);
  return UserViewModel(token: token);
});

Future<void> onLoginSuccess(Map<String, dynamic> loginResponse, WidgetRef ref) async {
  final token = loginResponse['token'];
  if (token == null) return;

  ref.read(tokenProvider.notifier).state = token;

  final api = ApiService(token: token);
  final response = await api.get('/me');

  if (response.statusCode == 200) {
    final userJson = jsonDecode(response.body);
    final user = User.fromJson(userJson);
    ref.read(currentUserProvider.notifier).setUser(user);
  } else {
    ref.read(currentUserProvider.notifier).setUser(null);
  }
}

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier() : super(null);

  void setUser(User? user) {
    state = user;
  }

  void addSentFriendRequest(String friendId) {
    if (state == null) return;
    if (state!.sentFriendRequestsId.contains(friendId)) return;

    state = state!.copyWith(
      sentFriendRequestsId: [...state!.sentFriendRequestsId, friendId],
    );
  }

  void addFriend(String friendId) {
    if (state != null) {
      state = state!.copyWith(
        friendIds: [...state!.friendIds, friendId],
        friendRequestId: state!.friendRequestId.where((id) => id != friendId).toList(),
      );
    }
  }

  void removeFriendRequest(String requesterId) {
    if (state != null) {
      state = state!.copyWith(
        friendRequestId: state!.friendRequestId.where((id) => id != requesterId).toList(),
      );
    }
  }
}
