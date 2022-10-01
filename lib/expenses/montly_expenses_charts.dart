import 'package:expense_tracker_app/chartdata/category_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/chartdata/chart_data.dart';
import 'package:expense_tracker_app/utils/formater.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyCharts extends StatefulWidget {
  static const routeName = '/monthlyCharts';
  const MonthlyCharts({super.key});

  @override
  State<MonthlyCharts> createState() => _MonthlyChartsState();
}

class _MonthlyChartsState extends State<MonthlyCharts> {
  String month = '';
  List<ChartData> chartExpenses = [];
  Map<String, List<Expense>> expenses = {};

  @override
  void initState() {
    month = '${DateTime.now().month}-${DateTime.now().year}';
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    chartExpenses = expenseProvider.monthlyExpenses[month] ?? [];
    expenses = expenseProvider.getExpensesByMonth(month);
    super.initState();
  }

  String totalExpenses(List<Expense> expenses) {
    double total = 0;
    for (var element in expenses) {
      total += element.amount;
    }
    return expenseAmount(total);
  }

  String monthTotalExpenses() {
    double total = 0;
    for (var element in chartExpenses) {
      total += element.y;
    }
    return expenseAmount(total);
  }

  void setMonth(String month) {
    setState(() {
      this.month = month;
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      chartExpenses = expenseProvider.monthlyExpenses[month] ?? [];
      expenses = expenseProvider.getExpensesByMonth(month);
    });
  }

  Color getCategoryColor(String category) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    return expenseProvider.categoriesColors[category] ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    String fullMonth =
        '${getMonthName(int.parse(month.split('-')[0]))}-${month.split('-')[1]}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('הוצאות חודשיות'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final months =
                            Provider.of<ExpenseProvider>(context, listen: false)
                                .months;
                        showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: SizedBox(
                                  height: 300,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'בחר חודש',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 200,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (var month in months)
                                                ListTile(
                                                  title: Text(
                                                    '${getMonthName(int.parse(month.split('-')[0]))}-${month.split('-')[1]}',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setMonth(month);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      fullMonth,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      monthTotalExpenses(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.8,
                child: SfCircularChart(
                  series: [
                    DoughnutSeries<CategoryChartData, String>(
                      dataSource: Provider.of<ExpenseProvider>(context)
                          .categoriesChartData,
                      xValueMapper: (CategoryChartData data, _) =>
                          data.category,
                      yValueMapper: (CategoryChartData data, _) => data.amount,
                      pointColorMapper: (CategoryChartData data, _) =>
                          getCategoryColor(data.category),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.width -
                    100,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var category in expenses.keys)
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: getCategoryColor(category),
                                ),
                              ),
                              subtitle:
                                  Text('${expenses[category]!.length} הוצאות'),
                              trailing: Text(
                                totalExpenses(expenses[category]!),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
