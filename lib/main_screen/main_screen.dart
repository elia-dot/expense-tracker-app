import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/services/local_notifications_service.dart';
import 'package:expense_tracker_app/main_screen/budget_box.dart';
import 'package:expense_tracker_app/main_screen/update_password.dart';
import 'package:expense_tracker_app/auth/auth_provider.dart';
import 'package:expense_tracker_app/main_screen/expense_filter_options.dart';
import 'package:expense_tracker_app/expenses/add_expense.dart';
import 'package:expense_tracker_app/expenses/expenses_list.dart';
import 'package:expense_tracker_app/main_screen/main_screen_chart.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:expense_tracker_app/main_screen/app_drawer.dart';
import 'package:expense_tracker_app/utils/formater.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message");
}

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLoading = false;
  late PageController _pageController;
  int initialPage = 0;
  Future<void> expensesFuture = Future.value();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String get filterText {
    switch (Provider.of<ExpenseProvider>(context, listen: false).filter) {
      case FilterOptions.all:
        return 'הכל';
      case FilterOptions.day:
        return 'היום';
      case FilterOptions.threeMonths:
        return ' 3 חודשים';
      case FilterOptions.month:
        return 'החודש האחרון';
      case FilterOptions.custom:
        return dateFormater.format(
            Provider.of<ExpenseProvider>(context, listen: false)
                .customExpensesDate);
    }
  }

  Future<void> getExpenses() async {
    setState(() {
      isLoading = true;
    });
    final expensesProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    await expensesProvider.fetchAndSetExpenses();
    await expensesProvider.getMonthlyExpenses();
    expensesProvider.setFilter(FilterOptions.month);
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
    messaging.requestPermission();
    LocalNotificationsService.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    getExpenses();
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> buildChart() {
    List<Widget> pages = [];
    final expensesProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final months = expensesProvider.months;
    for (var i = 0; i < months.length; i++) {
      pages.add(
        MainScreenChart(
          month: months[i],
          pageController: _pageController,
        ),
      );
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpenseProvider>(context);
    final authProvider = Provider.of<Auth>(context);
    List<Expense> expenses = expensesProvider.groupExpenses.reversed.toList();

    return authProvider.authUser.isPasswordConfirm
        ? Scaffold(
            appBar: AppBar(
              title: const Text('מעקב הוצאות'),
              actions: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      isScrollControlled: true,
                      builder: ((context) {
                        return const AddExpense();
                      }),
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                )
              ],
            ),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BudgetBox(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'הוצאות אחרונות',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(200, 40),
                                    maximumSize: const Size(200, 40),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: ((context) {
                                        return ExpenseFilterOptions(
                                            expensesProvider: expensesProvider);
                                      }),
                                    );
                                  },
                                  child: Text(
                                    '$filterText : ${expenseAmount(expensesProvider.totalAmount)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ExpensesList(expenses: expenses),
                          ),
                        ],
                      ),
                    ),
            ),
            drawer: const AppDrawer(),
          )
        : const UpdatePassword();
  }
}
