import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_tracker_app/shops/shop_details.dart';
import 'package:expense_tracker_app/shops/shop.dart';
import 'package:expense_tracker_app/shops/shops_page.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
        )
      ],
      child: Consumer<Auth>(
        builder: (
          ctx,
          auth,
          _,
        ) =>
            GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: AppColors.primaryColor,
              colorScheme: theme.colorScheme.copyWith(
                secondary: AppColors.secondaryColor,
              ),
              appBarTheme: const AppBarTheme(
                color: AppColors.primaryColor,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
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
              ShopsPage.routeName: (ctx) => const ShopsPage(),
              ShopDetails.routeName: (ctx) => const ShopDetails(),
            },
          ),
        ),
      ),
    );
  }
}
