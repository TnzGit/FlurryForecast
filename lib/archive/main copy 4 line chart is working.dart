import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falls Creek Snow Accumulation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Falls Creek Snow Accumulation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=-36.87&longitude=147.28&hourly=temperature_2m,rain,showers,snowfall,snow_depth,windspeed_10m,windgusts_10m&models=best_match&daily=rain_sum,showers_sum,snowfall_sum&forecast_days=16&timezone=Australia%2FSydney'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Convert 'time' strings to DateTime objects
      data['hourly']['time'] =
          (data['hourly']['time'] as List).map((timeString) {
        // Adjust this as needed based on the format of your time strings
        return DateTime.parse(timeString);
      }).toList();

      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 200, // specify the height of the container
                        child: MyLineChart(data: snapshot.data!),
                      ),
                    ),
                    // MyDataTable(data: snapshot.data!),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class MyDataTable extends StatelessWidget {
  final Map<String, dynamic> data;

  MyDataTable({required this.data});

  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];
    for (int i = 0; i < data['hourly']['time'].length; i++) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(data['hourly']['time'][i])),
          DataCell(Text(data['hourly']['temperature_2m'][i].toString())),
          DataCell(Text(data['hourly']['snowfall'][i].toString())),
          // Add more DataCell widgets here for the other fields
        ],
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Time',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Temperature',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Snow(cm)',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          // Add more DataColumn widgets here for the other fields
        ],
        rows: rows,
      ),
    );
  }
}

class MyLineChart extends StatelessWidget {
  final Map<String, dynamic> data;
  var variable_name = 'snowfall';
  final List<String> timeLabels;

  MyLineChart({required this.data})
      : timeLabels = (data['hourly']['time'] as List).map((dateTime) {
          return DateFormat('MM/dd').format(dateTime);
        }).toList();

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data['hourly'][variable_name].length; i++) {
      spots.add(FlSpot(i.toDouble(), data['hourly'][variable_name][i]));
    }

    final maxY = data['hourly'][variable_name]
        .reduce((value, element) => value > element ? value : element);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          // drawHorizontalLine: true,
          drawVerticalLine: true,
          verticalInterval: null,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
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
              if (value.toInt() % 18 == 0) {
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
            interval: maxY / 5, // for example, if you want 5 labels
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
            isCurved: true,
            barWidth: 2,
            colors: [Colors.blue],
            belowBarData: BarAreaData(
                show: true, colors: [Colors.lightBlue.withOpacity(0.3)]),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
