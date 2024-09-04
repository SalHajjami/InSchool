import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../professor/prof_calendar.dart'; // Import the ProfCalendar page
import 'package:inschool/components/my_button.dart'; // Import the custom button widget
import 'package:flutter/foundation.dart';

class AddSeancePage extends StatefulWidget {
  const AddSeancePage({super.key});

  @override
  _AddSeancePageState createState() => _AddSeancePageState();
}

class _AddSeancePageState extends State<AddSeancePage> {
  DateTime? _selectedDate;
  String? _selectedMode;
  String? _selectedType;
  String? _matiere; // Added for retrieved matiere
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _niveauController = TextEditingController();
  final TextEditingController _nombreEtudiantsController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _modes = ['en ligne', 'présentielle'];
  final List<String> _types = ['en groupe', 'individuel'];

  @override
  void initState() {
    super.initState();
    _fetchMatiere();
  }

  Future<void> _fetchMatiere() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _matiere =
                userDoc['matiere'] as String; // Ensure matiere is a String
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching matiere: $e");
        }
      }
    }
  }

  void _selectDate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfCalendar(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result['day'];
        _startHourController.text = result['startHour'];
        _endHourController.text = result['endHour'];
      });
    }
  }

  void _saveSeance() {
    if (_selectedDate != null &&
        _startHourController.text.isNotEmpty &&
        _endHourController.text.isNotEmpty &&
        _villeController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        _niveauController.text.isNotEmpty &&
        _nombreEtudiantsController.text.isNotEmpty &&
        _selectedMode != null &&
        _selectedType != null &&
        _matiere != null) {
      _addSession(
        type: _selectedType!,
        matiere: _matiere!,
        ville: _villeController.text,
        prix: _prixController.text,
        niveau: _niveauController.text,
        startHour: _startHourController.text,
        endHour: _endHourController.text,
        nombreEtudiants: int.parse(_nombreEtudiantsController.text),
        date: _selectedDate!,
        mode: _selectedMode!,
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  Future<void> _addSession({
    required String type,
    required String matiere,
    required String ville,
    required String prix,
    required String niveau,
    required String startHour,
    required String endHour,
    required int nombreEtudiants,
    required DateTime date,
    required String mode,
  }) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        final sessionData = {
          'matiere': matiere,
          'ville': ville,
          'prix': prix,
          'niveau': niveau,
          'startHour': startHour,
          'endHour': endHour,
          'nombre_etudiants': nombreEtudiants,
          'professor_id': user.uid,
          'type': type,
          'date': date,
          'mode': mode,
        };

        // Add session to `seances` collection
        await _firestore.collection('seances').add(sessionData);

        // Add session to specific collection based on type
        if (type == 'en groupe') {
          await _firestore.collection('cours_engroupe').add(sessionData);
        } else if (type == 'individuel') {
          await _firestore.collection('cours_individuele').add(sessionData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session added successfully')),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error adding session: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF064789),
        title: const Text("Add Seance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSeance,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display matiere as text rather than a text field
            Text(
              _matiere ?? 'Matiere not available',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _villeController,
              decoration: const InputDecoration(labelText: "Ville"),
            ),
            TextField(
              controller: _prixController,
              decoration: const InputDecoration(labelText: "Prix"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _niveauController,
              decoration: const InputDecoration(labelText: "Niveau"),
            ),
            TextField(
              controller: _nombreEtudiantsController,
              decoration:
                  const InputDecoration(labelText: "Nombre d'Étudiants"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              hint: const Text('Select Mode'),
              items: _modes.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMode = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Mode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text('Select Type'),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            MyButton(
              text: 'Select Time',
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Date: ${_selectedDate != null ? _selectedDate.toString() : 'None'}',
            ),
            Text(
              'Start Hour: ${_startHourController.text}',
            ),
            Text(
              'End Hour: ${_endHourController.text}',
            ),
          ],
        ),
      ),
    );
  }
}
