import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker_app/user/user.dart';

class Auth with ChangeNotifier {
  final User _authUser = User(
      id: '', email: '', name: '', isPasswordConfirm: false, monthlyBudget: 0);

  User get authUser {
    return _authUser;
  }

  bool get isAuth {
    return _authUser.id != '';
  }

  Future<void> setUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'userData',
      json.encode({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'isPasswordConfirm': user.isPasswordConfirm,
        'monthlyBudget': user.monthlyBudget,
      }),
    );
  }

  Future<void> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      final res = await http.get(
        Uri.parse('${dotenv.env['API']}/users/me'),
        headers: await headers(),
      );
      if (res.statusCode == 200) {
        final userData = json.decode(res.body);
        _authUser.id = userData['_id'];
        _authUser.email = userData['email'];
        _authUser.name = userData['name'];
        _authUser.isPasswordConfirm = userData['isPasswordConfirm'];
        _authUser.monthlyBudget = userData['monthlyBudget'].toDouble();
        notifyListeners();
        await setUserData(_authUser);
      } else {
        return;
      }
    }
    final userData = prefs.getString('userData');
    final extractedUserData = json.decode(userData!);
    _authUser.id = extractedUserData['id'] as String;
    _authUser.email = extractedUserData['email'] as String;
    _authUser.name = extractedUserData['name'] as String;
    _authUser.isPasswordConfirm =
        extractedUserData['isPasswordConfirm'] as bool;
    _authUser.monthlyBudget = extractedUserData['monthlyBudget'] as double;
    notifyListeners();
  }

  Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> login(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['API']}/auth/login'),
      body: data,
    );
    var resData = json.decode(res.body);
    if (res.statusCode >= 400 && res.statusCode < 500) {
      return 'אימייל או סיסמא לא נכונים';
    } else if (res.statusCode >= 500) {
      return 'אירעה שגיאה';
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', resData['access_token']);
    getCurrentUser();
    return 'login';
  }

  Future<String> setBudget(double budget) async {
    var res = await http.patch(
      Uri.parse('${dotenv.env['API']}/users/update'),
      headers: await headers(),
      body: json.encode({'monthlyBudget': budget}),
    );
    if (res.statusCode == 200) {
      _authUser.monthlyBudget = budget;
      setUserData(authUser);
      notifyListeners();
      return 'done';
    }
    return 'error';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _authUser.id = '';
    _authUser.email = '';
    _authUser.name = '';
    _authUser.isPasswordConfirm = false;
    _authUser.monthlyBudget = 0;
    notifyListeners();
  }
}
