import 'package:expense_tracker_app/user/user.dart';

User createUser(Map user) {
  return User(
    id: user['_id'],
    email: user['email'],
    name: user['name'],
    isPasswordConfirm: user['isPasswordConfirm'],
    monthlyBudget: user['monthlyBudget'].toDouble(),
    allowNotifications: user['allowNotifications'],
  );
}