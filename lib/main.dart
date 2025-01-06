import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Умная Теплица',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SensorScreen(),
    );
  }
}

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
  Map<String, bool> controlState = {
  'ventilation': false,
  'watering1': false,
  'watering2': false,
  'lighting': false,
};

  int _selectedIndex = 0;

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

  Future<void> fetchControlState() async {
    final url = Uri.parse('http://alexandergh2023.tplinkdns.com/api/st/get');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          controlState = {
            'ventilation': data['ventilation'] == 1,
            'watering1': data['watering1'] == 1,
            'watering2': data['watering2'] == 1,
            'lighting': data['lighting'] == 1,
          };
        });
      } else {
        print('Failed to load control state: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching control state: $e');
    }
  }

  Future<void> updateControlState(String controlName, bool state) async {
    final url = Uri.parse('http://alexandergh2023.tplinkdns.com/api/c/$controlName/${state ? '1' : '0'}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('$controlName updated to ${state ? 'ON' : 'OFF'}');
      } else {
        print('Failed to update $controlName: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating control state for $controlName: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      fetchControlState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Умная Теплица',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 28),
              onPressed: () {
                // Добавьте действие для иконки пользователя, если нужно
                print("User icon tapped");
              },
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildSensorStateScreen(),
          buildControlScreen(),
          Center(child: Text("Настройки", style: TextStyle(fontSize: 24))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Состояние',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Управление',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildSensorStateScreen() {
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
Widget buildControlScreen() {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.purple[100],
        child: Text(
          'Управление',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
      ),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          padding: EdgeInsets.all(16.0),
          children: [
            buildControlCard('Проветривание', 'ventilation', Icons.air),
            buildControlCard('Полив 1', 'watering1', Icons.opacity),
            buildControlCard('Полив 2', 'watering2', Icons.opacity_outlined),
            buildControlCard('Освещение', 'lighting', Icons.lightbulb),
          ],
        ),
      ),
    ],
  );
}

Widget buildControlCard(String title, String controlName, IconData icon) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          SizedBox(height: 8),
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
          Switch(
            value: controlState[controlName] ?? false,
            onChanged: (bool value) {
              setState(() {
                controlState[controlName] = value;
              });
              updateControlState(controlName, value);
            },
          ),
        ],
      ),
    ),
  );
}


}
