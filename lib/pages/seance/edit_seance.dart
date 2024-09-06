import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCoursePage extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> initialData;
  final String collectionName;

  const EditCoursePage({
    super.key,
    required this.courseId,
    required this.initialData,
    required this.collectionName,
  });

  @override
  _EditCoursePageState createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  late TextEditingController _villeController;
  late TextEditingController _prixController;
  late TextEditingController _niveauController;
  late TextEditingController _nombreEtudiantsController;
  late TextEditingController _startHourController;
  late TextEditingController _endHourController;
  String? _mode;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the initial data
    _villeController = TextEditingController(text: widget.initialData['ville']);
    _prixController = TextEditingController(text: widget.initialData['prix']);
    _niveauController =
        TextEditingController(text: widget.initialData['niveau']);
    _nombreEtudiantsController = TextEditingController(
        text: widget.initialData['nombre_etudiants'].toString());
    _startHourController =
        TextEditingController(text: widget.initialData['startHour']);
    _endHourController =
        TextEditingController(text: widget.initialData['endHour']);
    _mode = widget.initialData['mode'];
  }

  @override
  void dispose() {
    // Dispose controllers
    _villeController.dispose();
    _prixController.dispose();
    _niveauController.dispose();
    _nombreEtudiantsController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    super.dispose();
  }

  void _updateCourse() async {
    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.courseId)
          .update({
        'ville': _villeController.text,
        'prix': _prixController.text,
        'niveau': _niveauController.text,
        'nombre_etudiants': int.parse(_nombreEtudiantsController.text),
        'startHour': _startHourController.text,
        'endHour': _endHourController.text,
        'mode': _mode,
      });

      Navigator.pop(context); // Go back to the previous page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateCourse,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _villeController,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              TextField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _niveauController,
                decoration: const InputDecoration(labelText: 'Niveau'),
              ),
              TextField(
                controller: _nombreEtudiantsController,
                decoration:
                    const InputDecoration(labelText: 'Nombre d\'Étudiants'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _startHourController,
                decoration: const InputDecoration(labelText: 'Start Hour'),
              ),
              TextField(
                controller: _endHourController,
                decoration: const InputDecoration(labelText: 'End Hour'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _mode,
                hint: const Text('Select Mode'),
                items: ['en ligne', 'présentielle'].map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _mode = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Mode',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
