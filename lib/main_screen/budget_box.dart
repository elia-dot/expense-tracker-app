import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:expense_tracker_app/utils/formater.dart';

class BudgetBox extends StatefulWidget {
  const BudgetBox({super.key});

  @override
  State<BudgetBox> createState() => _BudgetBoxState();
}

class _BudgetBoxState extends State<BudgetBox> {
  double budget = 0;
  bool isLoading = false;

  YYDialog budgetDialog(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    return YYDialog().build(context)
      ..width = 300
      ..borderRadius = 8.0
      ..text(
        padding: const EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: "הגדר תקציב חודשי",
        color: Theme.of(context).primaryColor,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      )
      ..widget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'הכנס סכום',
              ),
              onChanged: (value) {
                setState(() {
                  budget = double.parse(value);
                });
              },
            ),
          ),
        ),
      )
      ..divider()
      ..doubleButton(
        isClickAutoDismiss: false,
        padding: const EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "ביטול",
        color1: Colors.redAccent,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {
          Navigator.pop(context);
        },
        text2: isLoading ? "מעדכן.." : "אישור",
        color2: Theme.of(context).primaryColor,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () async {
          setState(() {
            isLoading = true;
          });
          var res = await authProvider.setBudget(budget);
          setState(() {
            isLoading = false;
          });
          if (res == 'done') {
            Future.delayed(Duration.zero, () {
              Navigator.pop(context);
            });
          }
        },
      )
      ..show();
  }

  Color getColor(double amount) {
    if (amount < 0) {
      return Colors.redAccent;
    } else if (amount > 0) {
      return Colors.green;
    } else {
      return Colors.black;
    }
  }

  double getPercent(double amount, double budget) {
    if (amount / budget > 1) {
      return 1;
    } else {
      return amount / budget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: authProvider.authUser.monthlyBudget == 0
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'עדיין לא הגדרת תקציב חודשי',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 8.0,
                    ),
                  ),
                  onPressed: () {
                    budgetDialog(context);
                  },
                  child: Text(
                    'לחץ כאן כדי להגדיר',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      top: 16,
                    ),
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: 'תקציב פנוי:  ',
                        children: [
                          TextSpan(
                            text: expenseAmount(
                                authProvider.authUser.monthlyBudget -
                                    expenseProvider.totalAmount),
                            style: TextStyle(
                              color: getColor(
                                  authProvider.authUser.monthlyBudget -
                                      expenseProvider.totalAmount),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 32,
                    animation: true,
                    lineHeight: 15.0,
                    animationDuration: 2500,
                    percent: getPercent(expenseProvider.totalAmount,
                        authProvider.authUser.monthlyBudget),
                    center: Text(
                        "${(getPercent(expenseProvider.totalAmount, authProvider.authUser.monthlyBudget) * 100).toStringAsFixed(0)}%"),
                    barRadius: const Radius.circular(8),
                    progressColor: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'תקציב חודשי:  ${expenseAmount(authProvider.authUser.monthlyBudget)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            budgetDialog(context);
                          },
                          child: Text(
                            'ערוך',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
