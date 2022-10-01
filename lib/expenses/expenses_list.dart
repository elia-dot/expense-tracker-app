import 'package:flutter/material.dart';

import 'package:expense_tracker_app/utils/formater.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    Key? key,
    required List<Expense> expenses,
  })  : _expenses = expenses,
        super(key: key);

  final List<Expense> _expenses;

  @override
  Widget build(BuildContext context) {
    return _expenses.isEmpty
        ? const Center(
            child: Text(
              'אין הוצאות',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, index) => Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(
                bottom: index == _expenses.length - 1 ? 10 : 0,
                right: 5,
                left: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      expenseAmount(_expenses[index].amount),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _expenses[index].shop.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormater.format(_expenses[index].date),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  Text(
                    _expenses[index].shop.category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            itemCount: _expenses.length,
          );
  }
}
