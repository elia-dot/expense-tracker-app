import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_tracker_app/user/user.dart';
import 'package:expense_tracker_app/utils/headers.dart';
import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  final List<User> _groupMembers = [];

  List<User> get groupMembers {
    return [..._groupMembers];
  }

  Future<void> getGroupMembers() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/users/group-users'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final groupMembers = json.decode(res.body) as List<dynamic>;
      _groupMembers.clear();
      for (var member in groupMembers) {
        _groupMembers.add(User(
          id: member['_id'],
          email: member['email'],
          name: member['name'],
          isPasswordConfirm: member['isPasswordConfirm'],
          monthlyBudget: member['monthlyBudget'].toDouble(),
          allowNotifications: member['allowNotifications'],
        ));
      }
      notifyListeners();
    } else {
      return;
    }
  }

  Future<String> addGroupMember(String email) async {
    final res = await http.post(
      Uri.parse('${dotenv.env['API']}/users/create-user'),
      headers: await headers(),
      body: json.encode({
        'email': email,
      }),
    );
    if (res.statusCode == 201) {
      final userData = json.decode(res.body);
      _groupMembers.add(
        User(
          id: userData['user']['_id'],
          email: userData['user']['email'],
          name: userData['user']['name'],
          isPasswordConfirm: userData['user']['isPasswordConfirm'],
          monthlyBudget: userData['user']['monthlyBudget'].toDouble(),
          allowNotifications: userData['user']['allowNotifications'],
        ),
      );
      notifyListeners();
      return 'done';
    } else {
      if (json.decode(res.body)['message'] == 'User already exists') {
        return 'משתמש קיים';
      } else {
        return 'משהו השתבש';
      }
    }
  }
}
