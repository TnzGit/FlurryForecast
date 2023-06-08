import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SnowAccumulation.dart';
import 'NewSnow.dart';
import 'WindAndGust.dart';
import 'NewRain.dart';

enum Locations { fallsCreek, mtHotham, mtBuller, perisher }

Map<Locations, Map<String, double>> locationData = {
  Locations.fallsCreek: {'latitude': -36.86, 'longitude': 147.28},
  Locations.mtHotham: {'latitude': -36.98, 'longitude': 147.13},
  Locations.mtBuller: {'latitude': -37.15, 'longitude': 146.45},
  Locations.perisher: {'latitude': -36.40, 'longitude': 148.41},
};

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
      home: MyHomePage(title: 'Aust Snow Forecast'),
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
  Locations location = Locations.fallsCreek; // Default location

  void updateLocation(Locations newLocation) {
    setState(() {
      location = newLocation;
    });
    fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final locationCoords = locationData[location];
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${locationCoords!['latitude']}&longitude=${locationCoords!['longitude']}&hourly=temperature_2m,rain,showers,snowfall,snow_depth,windspeed_10m,windgusts_10m&models=best_match&daily=rain_sum,showers_sum,snowfall_sum&forecast_days=16&timezone=Australia%2FSydney'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Convert 'time' strings to DateTime objects
      data['hourly']['time'] =
          (data['hourly']['time'] as List).map((timeString) {
        // Adjust this as needed based on the format of your time strings
        return DateTime.parse(timeString);
      }).toList();

      data['daily']['time'] = (data['daily']['time'] as List).map((timeString) {
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
      appBar: AppBar(title: Text(widget.title), actions: <Widget>[
        IconButton(onPressed: fetchData, icon: const Icon(Icons.refresh))
      ]),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    LocationChoice(
                      currentLocation: location,
                      onLocationChanged: updateLocation,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 250, // specify the height of the container
                        child: NewSnowBarChart(data: snapshot.data!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 250, // specify the height of the container
                        child: SnowAccumulationLineChart(data: snapshot.data!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 250, // specify the height of the container
                        child: WindAndGustLineChart(data: snapshot.data!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 250, // specify the height of the container
                        child: NewRainBarChart(data: snapshot.data!),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Made by T🍉NY\nData Source: Open-Meteo\nNon-commercial Use Only",
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      "Comments Welcomed @ TnzGit/FlurryForecast on Github",
                      style: TextStyle(fontSize: 12),
                    )
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

class LocationChoice extends StatefulWidget {
  final Locations currentLocation;
  final ValueChanged<Locations> onLocationChanged;

  LocationChoice({
    Key? key,
    required this.currentLocation,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<LocationChoice> createState() => _LocationChoiceState();
}

class _LocationChoiceState extends State<LocationChoice> {
  Set<Locations> selection = <Locations>{};

  @override
  void initState() {
    super.initState();
    selection.add(widget.currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Locations>(
      segments: const <ButtonSegment<Locations>>[
        ButtonSegment<Locations>(
            value: Locations.fallsCreek, label: Text('Falls Creek')),
        ButtonSegment<Locations>(
            value: Locations.mtHotham, label: Text('Mt Hotham')),
        ButtonSegment<Locations>(
            value: Locations.mtBuller, label: Text('Mt Buller')),
        ButtonSegment<Locations>(
          value: Locations.perisher,
          label: Text('Perisher'),
        ),
      ],
      selected: selection,
      onSelectionChanged: (Set<Locations> newSelection) {
        setState(() {
          selection = newSelection;
        });
        if (newSelection.isNotEmpty) {
          widget.onLocationChanged(newSelection.first);
        }
      },
      multiSelectionEnabled: false,
    );
  }
}
