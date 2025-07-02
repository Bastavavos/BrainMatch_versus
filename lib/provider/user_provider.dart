import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user.dart';
//
// final userProvider = StateProvider<User?>((ref) => null);
// final connectedUsersProvider = StateProvider<List<User>>((ref) => []);