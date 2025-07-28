import '../../../models/user.dart';
import '../../../repositories/user_repository.dart';
import 'package:flutter/material.dart';

import '../Service/api_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  List<User> _users = [];
  User? _currentUser;

  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserViewModel({required String? token})
      : _userRepository = UserRepository(api: ApiService(token: token));

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userRepository.fetchUsers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userRepository.fetchUserById(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}