import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSeancePage extends StatefulWidget {
  final String seanceId;
  final Map<String, dynamic> seanceData;

  const EditSeancePage({super.key, required this.seanceId, required this.seanceData});

  @override
  _EditSeancePageState createState() => _EditSeancePageState();
}

class _EditSeancePageState extends State<EditSeancePage> {
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _niveauController = TextEditingController();
  final TextEditingController _nombreEtudiantsController = TextEditingController();
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  String? _selectedMode;
  String? _selectedType;

  final List<String> _modes = ['en ligne', 'présentielle'];
  final List<String> _types = ['en groupe', 'individuel'];

  @override
  void initState() {
    super.initState();

    // Initialize the text fields with the existing seance data
    _villeController.text = widget.seanceData['ville'];
    _prixController.text = widget.seanceData['prix'];
    _niveauController.text = widget.seanceData['niveau'];
    _nombreEtudiantsController.text = widget.seanceData['nombre_etudiants'].toString();
    _startHourController.text = widget.seanceData['startHour'];
    _endHourController.text = widget.seanceData['endHour'];
    _selectedMode = widget.seanceData['mode'];
    _selectedType = widget.seanceData['type'];
  }

  void _saveChanges() async {
    // Validate input before saving
    if (_villeController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        _niveauController.text.isNotEmpty &&
        _nombreEtudiantsController.text.isNotEmpty &&
        _startHourController.text.isNotEmpty &&
        _endHourController.text.isNotEmpty &&
        _selectedMode != null &&
        _selectedType != null) {
      try {
        await FirebaseFirestore.instance.collection('seances').doc(widget.seanceId).update({
          'ville': _villeController.text,
          'prix': _prixController.text,
          'niveau': _niveauController.text,
          'nombre_etudiants': int.parse(_nombreEtudiantsController.text),
          'startHour': _startHourController.text,
          'endHour': _endHourController.text,
          'mode': _selectedMode,
          'type': _selectedType,
        });

        // Update the specific collection based on type
        if (_selectedType == 'en groupe') {
          await FirebaseFirestore.instance.collection('cours_engroupe').doc(widget.seanceId).update({
            'ville': _villeController.text,
            'prix': _prixController.text,
            'niveau': _niveauController.text,
            'nombre_etudiants': int.parse(_nombreEtudiantsController.text),
            'startHour': _startHourController.text,
            'endHour': _endHourController.text,
            'mode': _selectedMode,
          });
        } else if (_selectedType == 'individuel') {
          await FirebaseFirestore.instance.collection('cours_individuele').doc(widget.seanceId).update({
            'ville': _villeController.text,
            'prix': _prixController.text,
            'niveau': _niveauController.text,
            'nombre_etudiants': int.parse(_nombreEtudiantsController.text),
            'startHour': _startHourController.text,
            'endHour': _endHourController.text,
            'mode': _selectedMode,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seance updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating seance: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Seance'),
        backgroundColor: const Color(0xFF064789),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              decoration: const InputDecoration(labelText: "Nombre d'Étudiants"),
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
            const SizedBox(height: 16),
            TextField(
              controller: _startHourController,
              decoration: const InputDecoration(labelText: "Start Hour"),
            ),
            TextField(
              controller: _endHourController,
              decoration: const InputDecoration(labelText: "End Hour"),
            ),
          ],
        ),
      ),
    );
  }
}
