import 'package:expense_tracker_app/user/user.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double fontSize;
  const UserAvatar({
    Key? key,
    required this.user,
    this.fontSize = 20,
  }) : super(key: key);

  String createInitials() {
    final name = user.name.split(' ');
    String initials = '';
    for (var i = 0; i < name.length; i++) {
      initials += name[i][0].toUpperCase();
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: user.isPasswordConfirm ? 1 : 0.5,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Center(
          child: Text(
            createInitials(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
