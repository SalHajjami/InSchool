import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class CoursEnGroupe extends StatefulWidget {
  const CoursEnGroupe({super.key});

  @override
  _CoursEnGroupeState createState() => _CoursEnGroupeState();
}

class _CoursEnGroupeState extends State<CoursEnGroupe> {
  final FlutterListViewController _controller = FlutterListViewController();

  final List<Map<String, String>> _courses = [
    {'name': 'Maths', 'startHour': '09:00', 'endHour': '10:00'},
    {'name': 'Francais', 'startHour': '10:30', 'endHour': '11:30'},
    {'name': 'Science', 'startHour': '12:00', 'endHour': '13:00'},
    {'name': 'PC', 'startHour': '14:00', 'endHour': '15:00'},
    {'name': 'Geography', 'startHour': '15:30', 'endHour': '16:30'},
    {'name': 'History', 'startHour': '16:45', 'endHour': '17:45'},
    {'name': 'Art', 'startHour': '18:00', 'endHour': '19:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF064789), // Dark Blue
        title: const Text("Cours en groupe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FlutterListView(
          controller: _controller,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) {
              var course = _courses[index];
              return _buildCourseItem(course['name']!, course['startHour']!, course['endHour']!);
            },
            childCount: _courses.length,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(String name, String startHour, String endHour) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEBF2FA), // Light Blue background
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF064789), // Dark Blue
              ),
            ),
            subtitle: Text(
              'From $startHour to $endHour',
              style: const TextStyle(color: Color(0xFF427AA1)), // Medium Blue
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: const Color(0xFF064789), // Dark Blue
            ),
          ),
        ),
      ),
    );
  }
}
