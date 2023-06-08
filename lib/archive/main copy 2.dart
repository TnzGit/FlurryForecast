import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
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
          DataCell(Text(data['hourly']['rain'][i].toString())),
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
              'Rain',
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Fetch Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'API Fetch Example Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=-36.87&longitude=147.28&hourly=temperature_2m,rain,showers,snowfall,snow_depth,windspeed_10m,windgusts_10m&models=best_match&daily=rain_sum,showers_sum,snowfall_sum&forecast_days=16&timezone=Australia%2FSydney'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      var data = jsonDecode(response.body);
      var table = MyDataTable(data: data);
      return table
      // return jsonDecode(response.body)['hourly']['snowfall'].toString();
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
        child: FutureBuilder<String>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Data: ${snapshot.data}');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
