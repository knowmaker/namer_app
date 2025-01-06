import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlScreen extends StatefulWidget {
  @override
  ControlScreenState createState() => ControlScreenState();
}

class ControlScreenState extends State<ControlScreen> {
  Map<String, bool> controlState = {
    'ventilation': false,
    'watering1': false,
    'watering2': false,
    'lighting': false,
  };

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

  @override
  Widget build(BuildContext context) {
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
