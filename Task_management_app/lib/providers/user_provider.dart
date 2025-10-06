import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _user;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usersData = await ApiService.fetchUsers();
      _users = usersData.map((userJson) => User.fromJson(userJson)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await ApiService.fetchUserData(userId);
      _user = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void clearUsers() {
    _users = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}