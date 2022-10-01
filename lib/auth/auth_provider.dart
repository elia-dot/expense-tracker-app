import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker_app/user/craete_user.dart';
import 'package:expense_tracker_app/utils/headers.dart';
import 'package:expense_tracker_app/user/user.dart';

class Auth with ChangeNotifier {
  User _authUser = User(
    id: '',
    email: '',
    name: '',
    isPasswordConfirm: false,
    monthlyBudget: 0,
    allowNotifications: false,
  );

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
        'allowNotifications': user.allowNotifications,
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
        _authUser.allowNotifications = userData['allowNotifications'];
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
    _authUser.allowNotifications =
        extractedUserData['allowNotifications'] as bool;
    notifyListeners();
  }

  Future<String> login(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['API']}/auth/login'),
      body: data,
    );
    if (res.body.isNotEmpty) {
      var resData = json.decode(res.body);
      if (res.statusCode >= 400 && res.statusCode < 500) {
        return 'אימייל או סיסמא לא נכונים';
      } else if (res.statusCode >= 500) {
        return 'אירעה שגיאה';
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('authToken', resData['access_token']);
      getCurrentUser();
      await setPushToken();
      return 'login';
    } else {
      return 'אירעה שגיאה';
    }
  }

  Future<String> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['API']}/auth/signup'),
      body: data,
    );
    var resData = json.decode(res.body);
    if (res.statusCode >= 400 && res.statusCode < 500) {
      if (resData['message'] == 'User already exists') {
        return 'משתמש עם כתובת מייל זו כבר קיים';
      }
      return 'אירעה שגיאה';
    } else if (res.statusCode >= 500) {
      return 'אירעה שגיאה';
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', resData['access_token']);
    getCurrentUser();
    await setPushToken();
    return 'register';
  }

  Future<void> setPushToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    await http.post(
      Uri.parse('${dotenv.env['API']}/users/update-push-token'),
      body: json.encode({'pushToken': token}),
      headers: await headers(),
    );
  }

  Future<void> updatePassword(String password) async {
    var body = json.encode({'newPassword': password});
    final res = await http.post(
      Uri.parse('${dotenv.env['API']}/auth/update-password'),
      body: body,
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      _authUser.isPasswordConfirm = true;
      notifyListeners();
      await setUserData(_authUser);
    }
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

  Future<String> forgotPassword(String email) async {
    var res = await http.post(
      Uri.parse('${dotenv.env['API']}/auth/forgot-password/$email'),
    );
    if (res.statusCode == 200) {
      return 'done';
    }
    if (json.decode(res.body)['message'] == 'User not found') {
      return 'משתמש לא נמצא';
    }
    return 'אירעה שגיאה';
  }

  Future<String> updateProfile(Map<String, dynamic> data) async {
    if (data['password'] == null) {
      data.remove('password');
    }
    if (data['currentPassword'] == null) {
      data.remove('currentPassword');
    }

    var res = await http.patch(
      Uri.parse('${dotenv.env['API']}/users/update'),
      headers: await headers(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      User user = createUser(jsonDecode(res.body));
      _authUser = user;
      setUserData(authUser);
      notifyListeners();
      return 'done';
    } else {
      final result = json.decode(res.body);
      if (result['message'] == 'Password is incorrect') {
        return 'סיסמא לא נכונה';
      }
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
