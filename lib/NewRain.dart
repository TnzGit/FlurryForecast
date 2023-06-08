import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class NewRainBarChart extends StatelessWidget {
  final Map<String, dynamic> data;
  var interval_name = 'daily';
  var variable_name = 'rain_sum';
  final List<String> timeLabels;

  NewRainBarChart({required this.data})
      : timeLabels = (data['daily']['time'] as List).map((dateTime) {
          return DateFormat('MM/dd').format(dateTime);
        }).toList();

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < data[interval_name][variable_name].length; i++) {
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              y: data[interval_name][variable_name][i], colors: [Colors.blue])
        ],
      ));
    }

    final maxY = data[interval_name][variable_name]
        .reduce((value, element) => value > element ? value : element);

    return Column(children: [
      const Text(
        'Rain (mm)',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 10,
      ),
      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: maxY == 0 ? 0.01 : maxY / 5,
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (context, value) => const TextStyle(
                    color: Color(0xff68737d),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                getTitles: (value) {
                  int interval = data[interval_name][variable_name].length ~/ 5;
                  if (value.toInt() % interval == 0) {
                    return timeLabels[value.toInt()];
                  }
                  return '';
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (context, value) => const TextStyle(
                    color: Color(0xff67727d),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                getTitles: (value) {
                  return value.toStringAsFixed(2);
                },
                interval: maxY == 0
                    ? 0.01
                    : maxY / 5, // for example, if you want 5 labels
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (BarChartGroupData group, int groupIndex,
                    BarChartRodData rod, int rodIndex) {
                  return BarTooltipItem(
                    'Time: ${timeLabels[group.x.toInt()]}\nRain: ${rod.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.black),
                  );
                },
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
