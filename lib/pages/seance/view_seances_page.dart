import 'package:flutter/material.dart';
import 'package:inschool/pages/professor/Prof_GrpCourseList.dart';
import 'package:inschool/pages/professor/Prof_ind_course_list.dart';

class ViewSeancesPage extends StatefulWidget {
  const ViewSeancesPage({super.key});

  @override
  _ViewSeancesPageState createState() => _ViewSeancesPageState();
}

class _ViewSeancesPageState extends State<ViewSeancesPage> {
  String _selectedFilter = 'Tous'; // Default filter

  void _navigateToSeanceList() {
    if (_selectedFilter == 'En Groupe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfGrpCourseList()),
      );
    } else if (_selectedFilter == 'Individuel') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfIndCourseList()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Seances'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedFilter,
              items: <String>['Tous', 'En Groupe', 'Individuel'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToSeanceList,
              child: const Text('View Seances'),
            ),
          ],
        ),
      ),
    );
  }
}
