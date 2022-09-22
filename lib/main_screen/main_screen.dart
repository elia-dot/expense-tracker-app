import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/main_screen/expense_filter_options.dart';
import 'package:expense_tracker_app/expenses/add_expense.dart';
import 'package:expense_tracker_app/expenses/expenses_list.dart';
import 'package:expense_tracker_app/main_screen/main_screen_chart.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:expense_tracker_app/main_screen/app_drawer.dart';
import 'package:expense_tracker_app/utils/formater.dart';

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

  String get filterText {
    switch (Provider.of<ExpenseProvider>(context, listen: false).filter) {
      case FilterOptions.all:
        return 'הכל';
      case FilterOptions.day:
        return 'היום';
      case FilterOptions.week:
        return 'השבוע האחרון';
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
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
    int currentMonth = DateTime.now().month;
    for (var i = 0; i < months.length; i++) {
      if (getMonthName(currentMonth) == getMonthName(int.parse(months[i]))) {}
      pages.add(
        MainScreenChart(
          monthlyExpenses: expensesProvider.monthlyExpenses,
          month: int.parse(months[i]),
        ),
      );
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpenseProvider>(context);
    List<Expense> expenses = expensesProvider.groupExpenses.reversed.toList();
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('הוצאות'),
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
            : expensesProvider.expenses.isEmpty
                ? const Center(
                    child: Text('No expenses'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: width * 0.8,
                          width: width,
                          child: PageView(
                            controller: _pageController,
                            children: buildChart(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }
}
