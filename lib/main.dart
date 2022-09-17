import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_tracker_app/main_screen/main_screen.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:expense_tracker_app/theme/app_colors.dart';
import 'package:expense_tracker_app/auth/auth_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final ThemeData theme = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Auth())],
      child: Consumer<Auth>(
        builder: (
          ctx,
          auth,
          _,
        ) =>
            MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: AppColors.primaryColor,
            colorScheme: theme.colorScheme.copyWith(
              secondary: AppColors.secondaryColor,
            ),
            appBarTheme: const AppBarTheme(
              color: AppColors.primaryColor,
            ),
          ),
          home: auth.isAuth
              ? const MainScreen()
              : FutureBuilder(
                  builder: (ctx, authResultSnapshot) {
                    if (authResultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return const AuthScreen();
                    }
                  },
                  future: auth.getCurrentUser(),
                ),
          routes: {
            MainScreen.routeName: (ctx) => const MainScreen(),
          },
        ),
      ),
    );
  }
}
