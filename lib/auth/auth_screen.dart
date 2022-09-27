import 'package:expense_tracker_app/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/theme/app_colors.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart' as auth;

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<String?> onLogin(LoginData data) async {
      final authProvider = Provider.of<auth.Auth>(context, listen: false);
      String res = await authProvider.login({
        'email': data.name,
        'password': data.password,
      });
      if (res == 'login') {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
        });
        return null;
      } else {
        return res;
      }
    }

    Future<String?> onSignup(SignupData data) async {
      final authProvider = Provider.of<auth.Auth>(context, listen: false);
      String res = await authProvider.register({
        'email': data.name,
        'password': data.password,
      });
      if (res == 'register') {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
        });
        return null;
      } else {
        return res;
      }
    }

    Future<String?> onRecoverPassword(String data) async {
      final authProvider = Provider.of<auth.Auth>(context, listen: false);
      String res = await authProvider.forgotPassword(data);
      if (res != 'done') {
        return res;
      } else {
        return null;
      }
    }

    return Scaffold(
      body: FlutterLogin(
        theme: LoginTheme(
          primaryColor: AppColors.primaryColor,
          buttonTheme: const LoginButtonTheme(
            backgroundColor: AppColors.primaryColor,
          ),
        ),
        onLogin: onLogin,
        onSignup: onSignup,
        messages: LoginMessages(
          userHint: 'אימייל',
          passwordHint: 'סיסמא',
          confirmPasswordHint: 'אשר סיסמא',
          loginButton: 'התחבר',
          signupButton: 'צור חשבון',
          forgotPasswordButton: 'שכחתי סיסמא',
          recoverPasswordButton: 'שלח קוד',
          goBackButton: 'חזור',
          confirmPasswordError: 'סיסמאות לא תואמות',
          recoverPasswordDescription: 'אנו נשלח סיסמא זמנית לאימייל שלך',
          recoverPasswordSuccess: 'סיסמא שונתה בהצלחה',
          recoverPasswordIntro: "אנא הכנס אימייל",
        ),
        onRecoverPassword: onRecoverPassword,
        title: 'Expense Tracker',
      ),
    );
  }
}
