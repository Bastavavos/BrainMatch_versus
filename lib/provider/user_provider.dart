import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

void onLoginSuccess(Map<String, dynamic> loginResponse, WidgetRef ref) {
  ref.read(userProvider.notifier).state = loginResponse;
}