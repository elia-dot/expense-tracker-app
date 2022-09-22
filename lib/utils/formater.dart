import 'package:intl/intl.dart';

final dateFormater = DateFormat('dd/MM/yyyy');

final numberFormater = NumberFormat.decimalPattern();

final currencyFormater = NumberFormat.simpleCurrency(
  locale: 'he',
  name: 'ILS',
);

List<Map<String, dynamic>> hebrewMonths = [
  {'month': 'ינואר', 'monthNumber': 1},
  {'month': 'פברואר', 'monthNumber': 2},
  {'month': 'מרץ', 'monthNumber': 3},
  {'month': 'אפריל', 'monthNumber': 4},
  {'month': 'מאי', 'monthNumber': 5},
  {'month': 'יוני', 'monthNumber': 6},
  {'month': 'יולי', 'monthNumber': 7},
  {'month': 'אוגוסט', 'monthNumber': 8},
  {'month': 'ספטמבר', 'monthNumber': 9},
  {'month': 'אוקטובר', 'monthNumber': 10},
  {'month': 'נובמבר', 'monthNumber': 11},
  {'month': 'דצמבר', 'monthNumber': 12},
];

String getMonthName(int month) {
  return hebrewMonths
      .firstWhere((element) => element['monthNumber'] == month)['month'];
}

bool isInt(double num) => num == num.roundToDouble();

String expenseAmount(double amount) =>
    '${currencyFormater.currencySymbol}${numberFormater.format(double.parse(amount.toStringAsFixed(isInt(amount) ? 0 : 1)))}';
