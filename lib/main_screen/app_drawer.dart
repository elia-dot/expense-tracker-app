import 'package:expense_tracker_app/user/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/group/group_page.dart';
import 'package:expense_tracker_app/auth/auth_screen.dart';
import 'package:expense_tracker_app/expenses/montly_expenses_charts.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:expense_tracker_app/shops/shops_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: DrawerHeader(
                  child: Row(
                    children: [
                      UserAvatar(user: authProvider.authUser),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        authProvider.authUser.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.group,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: const Text(
                        'קבוצה',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          GroupPage.routeName,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.attach_money_sharp,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: const Text(
                        'הוצאות חודשיות',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context)
                            .pushNamed(MonthlyCharts.routeName);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.store,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: const Text(
                        'חנויות',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(ShopsPage.routeName);
                      },
                    ),
                    Expanded(child: Container()),
                    ElevatedButton(
                      onPressed: (() => {
                            authProvider.logout(),
                            Navigator.of(context)
                                .pushReplacementNamed(AuthScreen.routeName),
                          }),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 26,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'יציאה מהחשבון',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
