import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class WindAndGustLineChart extends StatelessWidget {
  final Map<String, dynamic> data;
  var variable_name_wind = 'windspeed_10m';
  var variable_name_gust = 'windgusts_10m';
  final List<String> timeLabels;
  List<String> timeLabelsHours = [];

  WindAndGustLineChart({required this.data})
      : timeLabels = (data['hourly']['time'] as List).map((dateTime) {
          return DateFormat('MM/dd').format(dateTime);
        }).toList() {
    timeLabelsHours = (data['hourly']['time'] as List).map((dateTime) {
      return DateFormat('MM/dd-HH').format(dateTime);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var windData = data['hourly'][variable_name_wind]
        .sublist(0, data['hourly'][variable_name_wind].length ~/ 2);
    var gustData = data['hourly'][variable_name_gust]
        .sublist(0, data['hourly'][variable_name_gust].length ~/ 2);

    List<FlSpot> spotsWind = [];
    List<FlSpot> spotsGust = [];
    for (int i = 0; i < windData.length; i++) {
      spotsWind.add(FlSpot(i.toDouble(), windData[i]));
    }

    for (int i = 0; i < gustData.length; i++) {
      spotsGust.add(FlSpot(i.toDouble(), gustData[i]));
    }

    final maxY = math.max(
        data['hourly'][variable_name_wind]
                .reduce((value, element) => value > element ? value : element)
            as num,
        data['hourly'][variable_name_gust]
                .reduce((value, element) => value > element ? value : element)
            as num);

    return Column(
      children: [
        const Text(
          'Wind and Gust (km/h)',
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
                horizontalInterval: 20,
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
                    int interval = 8;
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
                    return value.toStringAsFixed(0);
                  },
                  interval: 20, // for example, if you want 5 labels
                ),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1)),
              minX: 0,
              maxX: windData.length.toDouble() - 1,
              minY: 0,
              maxY: maxY as double,
              lineBarsData: [
                LineChartBarData(
                  spots: spotsWind,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.blue],
                  belowBarData: BarAreaData(
                      show: true, colors: [Colors.lightBlue.withOpacity(0.3)]),
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: spotsGust,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.red],
                  belowBarData: BarAreaData(
                      show: true, colors: [Colors.orange.withOpacity(0.3)]),
                  dotData: FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        'Time: ${timeLabelsHours[touchedSpot.x.toInt()]}\nSpeed: ${touchedSpot.y.toStringAsFixed(2)}',
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
