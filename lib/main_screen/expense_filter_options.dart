import 'package:flutter/material.dart';

import 'package:expense_tracker_app/expenses/expense_provider.dart';

class ExpenseFilterOptions extends StatelessWidget {
  const ExpenseFilterOptions({
    Key? key,
    required this.expensesProvider,
  }) : super(key: key);

  final ExpenseProvider expensesProvider;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            ListTile(
              trailing: expensesProvider.filter == FilterOptions.all
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              title: const Text('הכל'),
              onTap: () {
                expensesProvider.setFilter(FilterOptions.all);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              trailing: expensesProvider.filter == FilterOptions.day
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              title: const Text('היום'),
              onTap: () {
                expensesProvider.setFilter(FilterOptions.day);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              trailing: expensesProvider.filter == FilterOptions.month
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              title: const Text('החודש האחרון'),
              onTap: () {
                expensesProvider.setFilter(FilterOptions.month);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              trailing: expensesProvider.filter == FilterOptions.threeMonths
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              title: const Text(' 3 חודשים אחרונים'),
              onTap: () {
                expensesProvider.setFilter(FilterOptions.threeMonths);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              trailing: expensesProvider.filter == FilterOptions.custom
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              title: const Text('בחר תאריך'),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime.now(),
                ).then((value) {
                  if (value != null) {
                    expensesProvider.setCustomExpensesDate(value);
                    expensesProvider.setFilter(FilterOptions.custom);
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
