import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SensorScreen extends StatefulWidget {
  @override
  SensorScreenState createState() => SensorScreenState();
}

class SensorScreenState extends State<SensorScreen> {
  Map<String, dynamic> sensorData = {
    'waterT': 0,
    'airT': 0,
    'airH': 0,
    'soilM1': 0,
    'soilM2': 0,
    'light': 0,
    'level': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    final url = Uri.parse('http://alexandergh2023.tplinkdns.com/api/d/get');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          sensorData = {
            'waterT': data['wT'],
            'airT': data['aT'],
            'airH': data['aH'],
            'soilM1': data['sM1'],
            'soilM2': data['sM2'],
            'light': data['l'],
            'level': data['lev'],
          };
        });
      } else {
        print('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.green[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Показания датчиков',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.green[800]),
                onPressed: fetchSensorData,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: EdgeInsets.all(16.0),
            children: [
              buildSensorCard('Температура воздуха', sensorData['airT'], '°C'),
              buildSensorCard('Влажность воздуха', sensorData['airH'], '%'),
              buildSensorCard('Влажность почвы грядки 1', sensorData['soilM1'], '%'),
              buildSensorCard('Влажность почвы грядки 2', sensorData['soilM2'], '%'),
              buildSensorCard('Температура воды', sensorData['waterT'], '°C'),
              buildSensorCard('Уровень воды', sensorData['level'], '%'),
              buildSensorCard('Освещенность', sensorData['light'], 'Лк'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSensorCard(String title, dynamic value, String unit) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[300]!, Colors.green[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
