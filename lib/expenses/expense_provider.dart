import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker_app/chartdata/chart_data.dart';
import 'package:expense_tracker_app/user/user.dart';
import 'package:expense_tracker_app/shops/shop.dart';

enum FilterOptions {
  all,
  day,
  month,
  threeMonths,
  custom,
}

class Expense {
  final String id;
  final Shop shop;
  final double amount;
  final DateTime date;
  final User createdBy;
  final String? description;
  final int? installments;

  Expense({
    required this.id,
    required this.shop,
    required this.amount,
    required this.date,
    required this.createdBy,
    this.installments,
    this.description,
  });
}

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  FilterOptions filter = FilterOptions.month;
  List<Expense> filterExpenses = [];

  DateTime customExpensesDate = DateTime.now();

  List<Expense> get groupExpenses {
    return filterExpenses.isEmpty && filter == FilterOptions.all
        ? [..._expenses]
        : [...filterExpenses];
  }

  List<Expense> get expenses {
    return [..._expenses];
  }

  List<String> get months {
    List<String> months = [];
    for (int i = 0; i < _expenses.length; i++) {
      if (!months.contains(_expenses[i].date.month.toString())) {
        months.add(_expenses[i].date.month.toString());
      }
    }
    months.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    return months;
  }

  void setFilter(FilterOptions selectedFilter) {
    filter = selectedFilter;
    switch (filter) {
      case FilterOptions.all:
        filterExpenses = [..._expenses];
        notifyListeners();
        break;
      case FilterOptions.day:
        filterExpenses = _expenses
            .where(
              (expense) =>
                  expense.date.day == DateTime.now().day &&
                  expense.date.month == DateTime.now().month &&
                  expense.date.year == DateTime.now().year,
            )
            .toList();
        notifyListeners();
        break;
      case FilterOptions.threeMonths:
        filterExpenses = _expenses
            .where((expense) => expense.date.month >= DateTime.now().month - 3)
            .toList();
        notifyListeners();
        break;
      case FilterOptions.month:
        filterExpenses = _expenses
            .where((expense) => expense.date.month == DateTime.now().month)
            .toList();
        notifyListeners();
        break;
      case FilterOptions.custom:
        filterExpenses = _expenses
            .where((expense) =>
                expense.date.day == customExpensesDate.day &&
                expense.date.month == customExpensesDate.month &&
                expense.date.year == customExpensesDate.year)
            .toList();
        notifyListeners();
        break;
    }
  }

  void setCustomExpensesDate(DateTime date) {
    customExpensesDate = date;

    notifyListeners();
  }

  Map<String, List<ChartData>> monthlyExpenses = {};

  double get totalAmount {
    if (filter == FilterOptions.all) {
      return _expenses.fold(0, (sum, expense) => sum + expense.amount);
    } else {
      return filterExpenses.fold(0, (sum, expense) => sum + expense.amount);
    }
  }

  Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchAndSetExpenses() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/expenses'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> expenses = data['expenses'];

      _expenses = expenses
          .map(
            (expense) => Expense(
              id: expense['_id'],
              shop: createShop(expense['shop']),
              amount: expense['amount'].toDouble(),
              date: DateTime.parse(expense['date']),
              createdBy: createUser(expense['createdBy']),
              description: expense['description'],
              installments: expense['installments'],
            ),
          )
          .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<String> addExpense(Map<String, dynamic> expense) async {
    var res = await http.post(
      Uri.parse('${dotenv.env['API']}/expenses'),
      headers: await headers(),
      body: json.encode(expense),
    );
    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      final expense = Expense(
        id: data['expense']['_id'],
        shop: createShop(data['expense']['shop']),
        amount: data['expense']['amount'].toDouble(),
        date: DateTime.parse(data['expense']['date']),
        createdBy: createUser(data['expense']['createdBy']),
      );
      _expenses.add(expense);
      String month = '${DateTime.now().month}';
      String day = '${DateTime.now().day}';
      if (monthlyExpenses[month] == null) {
        monthlyExpenses[month] = [ChartData(day, expense.amount)];
      } else {
        int indexOfCurrentDay =
            monthlyExpenses[month]!.indexWhere((element) => element.x == day);
        if (indexOfCurrentDay == -1) {
          monthlyExpenses[month]!.add(
            ChartData(day, expense.amount),
          );
        } else {
          monthlyExpenses[month]![indexOfCurrentDay] = ChartData(day,
              monthlyExpenses[month]![indexOfCurrentDay].y + expense.amount);
        }
      }
      notifyListeners();
      return 'done';
    }
    return 'error';
  }

  Future<void> getMonthlyExpenses() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/expenses/monthly'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final Map<String, List<ChartData>> expenses = {};
      data.forEach((key, value) {
        if (expenses[key] == null) {
          expenses[key] = [];
        }
        value.forEach((innerKey, innerValue) {
          if (innerKey != 'total') {
            expenses[key]?.add(ChartData(innerKey, innerValue.toDouble()));
          }
        });
      });
      monthlyExpenses = expenses;
      for (int i = 1; i < 31; i++) {
        if (monthlyExpenses['$i'] == null) {
          monthlyExpenses['$i'] = [];
        }
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Shop createShop(Map shop) {
    return Shop(
      id: shop['_id'],
      name: shop['name'],
      category: shop['category'],
      isOnline: shop['isOnline'],
      createdForGroupId: shop['createdForGroupId'],
    );
  }

  User createUser(Map user) {
    return User(
      id: user['_id'],
      email: user['email'],
      name: user['name'],
      isPasswordConfirm: user['isPasswordConfirm'],
    );
  }
}
