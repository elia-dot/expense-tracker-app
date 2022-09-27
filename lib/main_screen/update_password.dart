import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  var isLoading = false;
  var password = '';
  var confirmPassword = '';
  var error = '';

  Future<void> submit() async {
    if (password == '') {
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        error = 'הסיסמאות אינן תואמות';
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    final authProvider = Provider.of<Auth>(context, listen: false);
    await authProvider.updatePassword(password);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('עדכן סיסמא'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 300,
                child: Text(
                  ' אנא בחר סיסמא חדשה כדי להמשיך',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'סיסמא חדשה',
                  ),
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'אימות סיסמא חדשה',
                    errorText: error == '' ? null : error,
                  ),
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: submit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'עדכן',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 10,
                        ),
                      if (isLoading)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
