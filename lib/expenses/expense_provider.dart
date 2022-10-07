import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker_app/user/craete_user.dart';
import 'package:expense_tracker_app/utils/headers.dart';
import 'package:expense_tracker_app/chartdata/category_chart_data.dart';
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
  Shop shop;
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
  Map<String, List<ChartData>> monthlyExpenses = {};
  List<CategoryChartData> categoriesChartData = [];
  Map<String, Color> categoriesColors = {};

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
      String month = '${_expenses[i].date.month}-${_expenses[i].date.year}';
      if (!months.contains(month)) {
        months.add(month);
      }
    }
    return months.reversed.toList();
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

  double get totalAmount {
    if (filter == FilterOptions.all) {
      return _expenses.fold(0, (sum, expense) => sum + expense.amount);
    } else {
      return filterExpenses.fold(0, (sum, expense) => sum + expense.amount);
    }
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
      if (filter != FilterOptions.custom) {
        filterExpenses.add(expense);
      }
      notifyListeners();
      String month = '${DateTime.now().month}-${DateTime.now().year}';
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

  Color getCategoryColor(String category) {
    if (categoriesColors[category] == null) {
      categoriesColors[category] =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    return categoriesColors[category]!;
  }

  Map<String, List<Expense>> getExpensesByMonth(String month) {
    Map<String, List<Expense>> monthlyExpensesByCategory = {};
    List<Expense> expenses = _expenses
        .where(
            (expense) => expense.date.month == int.parse(month.split('-')[0]))
        .toList();
    for (int i = 0; i < expenses.length; i++) {
      if (monthlyExpensesByCategory[expenses[i].shop.category] == null) {
        monthlyExpensesByCategory[expenses[i].shop.category] = [expenses[i]];
      } else {
        monthlyExpensesByCategory[expenses[i].shop.category]!.add(expenses[i]);
      }
    }
    categoriesChartData = [];
    monthlyExpensesByCategory.forEach((key, value) {
      for (Expense expense in value) {
        var indexOfCategory = categoriesChartData
            .indexWhere((element) => element.category == expense.shop.category);
        if (indexOfCategory == -1) {
          categoriesChartData.add(
            CategoryChartData(key, expense.amount, getCategoryColor(key)),
          );
        } else {
          categoriesChartData[indexOfCategory] = CategoryChartData(
              expense.shop.category,
              categoriesChartData[indexOfCategory].amount + expense.amount,
              getCategoryColor(expense.shop.category));
        }
      }
    });
    return monthlyExpensesByCategory;
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
      imageUrl: shop['imageUrl'],
    );
  }
}
