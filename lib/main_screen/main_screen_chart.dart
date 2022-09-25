import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:expense_tracker_app/utils/formater.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:expense_tracker_app/chartdata/chart_data.dart';

class MainScreenChart extends StatefulWidget {
  final String month;
  final PageController pageController;
  const MainScreenChart({
    Key? key,
    required this.month,
    required this.pageController,
  }) : super(key: key);

  @override
  State<MainScreenChart> createState() => MainScreenChartState();
}

class MainScreenChartState extends State<MainScreenChart> {
  @override
  Widget build(BuildContext context) {
    final monthlyExpenses =
        Provider.of<ExpenseProvider>(context).monthlyExpenses;
    String fullMonth =
        '${getMonthName(int.parse(widget.month.split('-')[0]))}-${widget.month.split('-')[1]}';
    bool isFirst = widget.month == monthlyExpenses.keys.first;
    bool isLast = widget.month == monthlyExpenses.keys.last;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: width * 0.8 + 30,
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: monthlyExpenses[widget.month] != null
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isLast)
                        IconButton(
                          onPressed: () {
                            widget.pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                          ),
                        ),
                      Text(
                        fullMonth,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isFirst)
                        IconButton(
                          onPressed: () {
                            widget.pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: monthlyExpenses[widget.month]!,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelMapper: (datum, index) {
                          return expenseAmount(datum.y);
                        },
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                        color: Theme.of(context).primaryColor,
                        width: 0.2,
                      )
                    ],
                  ),
                ],
              )
            : const Center(child: Text('No data')),
      ),
    );
  }
}
