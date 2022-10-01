import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:expense_tracker_app/user/user_avatar.dart';
import 'package:expense_tracker_app/group/group_provider.dart';

class GroupPage extends StatefulWidget {
  static const routeName = '/group';
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String email = '';
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    groupProvider.getGroupMembers();
    super.initState();
  }

  Widget addUser(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: ((context, setState) {
          return AlertDialog(
            title: const Text('הוספת משתמש'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'אימייל',
                  ),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                if (error != '')
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ביטול'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final res = await groupProvider.addGroupMember(email);
                  if (res == 'done') {
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pop();
                    });
                  } else {
                    setState(() {
                      error = res;
                    });
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('הוסף'),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<Auth>(context);
    final groupMembers = groupProvider.groupMembers;
    groupMembers
        .removeWhere((element) => element.id == authProvider.authUser.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('קבוצה'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (groupMembers.isNotEmpty)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'משתמשים בקבוצה',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              const Divider(),
              for (var member in groupMembers)
                ListTile(
                  leading: UserAvatar(user: member),
                  title: Text(
                    member.name,
                    style: TextStyle(
                      color:
                          member.isPasswordConfirm ? Colors.black : Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  'הוסף חבר',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: ((context) {
                        return addUser(context);
                      }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
