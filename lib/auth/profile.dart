import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/utils/formater.dart';
import 'package:expense_tracker_app/user/user_avatar.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart';

enum Mode { view, edit }

class Profile extends StatefulWidget {
  static const routeName = '/profile';
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Mode mode = Mode.view;
  bool isLoading = false;

  String username = '';
  double budget = 0.0;
  String currentPpassword = '';
  String newPassword = '';
  bool allowNotifications = false;

  String passwordError = '';

  void reset() {
    setState(() {
      username = '';
      budget = 0.0;
      currentPpassword = '';
      newPassword = '';
      allowNotifications = false;
      passwordError = '';
    });
  }

  Future<void> submit() async {
    if (newPassword != '' && currentPpassword == '') {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final auth = Provider.of<Auth>(context, listen: false);
    final res = await auth.updateProfile({
      "name": username != '' ? username : auth.authUser.name,
      "monthlyBudget": budget != 0.0 ? budget : auth.authUser.monthlyBudget,
      "password": newPassword != '' ? newPassword : null,
      "currentPassword": currentPpassword != '' ? currentPpassword : null,
      "allowNotifications":
          allowNotifications != auth.authUser.allowNotifications
              ? allowNotifications
              : auth.authUser.allowNotifications,
    });
    setState(() {
      isLoading = false;
    });
    if (res == 'done') {
      setState(() {
        mode = Mode.view;
      });
    } else {
      if (res == 'סיסמא לא נכונה') {
        setState(() {
          passwordError = res;
        });
      }
    }
    reset();
  }

  @override
  void initState() {
    final authProvider = Provider.of<Auth>(context, listen: false);
    setState(() {
      allowNotifications = authProvider.authUser.allowNotifications;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.authUser.name),
        actions: [
          if (mode == Mode.view)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  mode = Mode.edit;
                  allowNotifications = authProvider.authUser.allowNotifications;
                });
              },
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: UserAvatar(
                  user: authProvider.authUser,
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 80),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'שם משתמש:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (mode == Mode.view)
                      Text(
                        authProvider.authUser.name,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    if (mode == Mode.edit)
                      SizedBox(
                        width: 200,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              username = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: authProvider.authUser.name,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (mode == Mode.view)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'אימייל:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        authProvider.authUser.email,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'התראות:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (mode == Mode.view)
                      Text(
                        authProvider.authUser.allowNotifications
                            ? 'פעיל'
                            : 'כבוי',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    if (mode == Mode.edit)
                      Switch.adaptive(
                        value: allowNotifications,
                        onChanged: (value) {
                          setState(() {
                            allowNotifications = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'תקציב חודשי:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (mode == Mode.view)
                      Text(
                        expenseAmount(
                          authProvider.authUser.monthlyBudget,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    if (mode == Mode.edit)
                      SizedBox(
                        width: 200,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              budget = double.tryParse(value) ?? 0.0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: expenseAmount(
                              authProvider.authUser.monthlyBudget,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (mode == Mode.edit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'עדכן סיסמא',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  currentPpassword = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'סיסמא נוכחית',
                                border: const OutlineInputBorder(),
                                errorText:
                                    passwordError != '' ? 'סיסמא שגויה' : null,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  newPassword = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'סיסמא חדשה',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              if (mode == Mode.edit)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            reset();
                            setState(() {
                              mode = Mode.view;
                            });
                          },
                          child: const Text('בטל'),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('עדכן פרטים'),
                              if (isLoading)
                                const SizedBox(
                                  width: 10,
                                ),
                              if (isLoading)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
