import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Fetch Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'API Fetch Example Home Page'),
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
      // If the server returns a 200 OK response, then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
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
              return MyDataTable(data: snapshot.data!);
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
