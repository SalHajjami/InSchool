import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfCalendar extends StatefulWidget {
  const ProfCalendar({super.key});

  @override
  _ProfCalendarState createState() => _ProfCalendarState();
}

class _ProfCalendarState extends State<ProfCalendar> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF2FA), // Light blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF064789), // Dark blue color for the app bar
        title: const Text('Date de la seance'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildCourseForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF064789), // Dark blue for selected day
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF427AA1), // Medium blue for today
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                color: const Color(0xFFEBF2FA), // Light blue for default day
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                color: const Color(0xFFDCE2E9), // Slightly darker for weekends
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF064789)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseForm() {
    if (_selectedDay == null) return Container();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTextField(
            controller: _startHourController,
            label: "Start Hour",
            hint: "e.g. 09:00",
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _endHourController,
            label: "End Hour",
            hint: "e.g. 11:00",
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _saveCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF427AA1), // Medium blue for the button
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Save Course", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({required TextEditingController controller, required String label, required String hint}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.datetime,
      ),
    );
  }

  void _saveCourse() {
    if (_startHourController.text.isNotEmpty &&
        _endHourController.text.isNotEmpty &&
        _selectedDay != null) {
      // Save the course data here
      final courseData = {
        'day': _selectedDay,
        'startHour': _startHourController.text,
        'endHour': _endHourController.text,
      };

      // You can print the data or save it to a database
      print("Course saved: $courseData");

      // Clear fields after saving
      _startHourController.clear();
      _endHourController.clear();
      setState(() {
        _selectedDay = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course saved on ${courseData['day']} from ${courseData['startHour']} to ${courseData['endHour']}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
}
