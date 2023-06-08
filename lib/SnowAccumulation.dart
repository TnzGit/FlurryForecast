import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class SnowAccumulationLineChart extends StatelessWidget {
  final Map<String, dynamic> data;
  var variable_name = 'snow_depth';
  final List<String> timeLabels;

  SnowAccumulationLineChart({required this.data})
      : timeLabels = (data['hourly']['time'] as List).map((dateTime) {
          return DateFormat('MM/dd').format(dateTime);
        }).toList();

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data['hourly'][variable_name].length; i++) {
      spots.add(
          FlSpot(i.toDouble(), math.max(data['hourly'][variable_name][i], 0)));
    }

    final maxY = data['hourly'][variable_name]
        .reduce((value, element) => value > element ? value : element);

    return Column(
      children: [
        const Text(
          'Snow Depth (m)',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: maxY == 0 ? 0.01 : maxY / 5,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTextStyles: (context, value) => const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  getTitles: (value) {
                    int interval = data['hourly'][variable_name].length ~/ 26;
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
                      ? 0.1
                      : maxY / 5, // for example, if you want 5 labels
                ),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              minX: 0,
              maxX: data['hourly'][variable_name].length.toDouble() - 1,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  barWidth: 2,
                  colors: [Colors.blue],
                  belowBarData: BarAreaData(
                      show: true, colors: [Colors.lightBlue.withOpacity(0.3)]),
                  dotData: FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        'Time: ${timeLabels[touchedSpot.x.toInt()]}\nDepth: ${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.black),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
