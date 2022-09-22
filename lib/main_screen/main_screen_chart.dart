import 'package:expense_tracker_app/utils/formater.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:expense_tracker_app/chartdata/chart_data.dart';

class MainScreenChart extends StatefulWidget {
  final int month;
  final Map<String, List<ChartData>> monthlyExpenses;
  const MainScreenChart(
      {Key? key, required this.monthlyExpenses, required this.month})
      : super(key: key);

  @override
  State<MainScreenChart> createState() => MainScreenChartState();
}

class MainScreenChartState extends State<MainScreenChart> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: width * 0.8 + 30,
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.monthlyExpenses['${widget.month}'] != null
            ? Column(
                children: [
                  Text(
                    getMonthName(widget.month),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: widget.monthlyExpenses['${widget.month}']!,
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
