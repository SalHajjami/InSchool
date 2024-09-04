import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
class SeanceDetailsPage extends StatefulWidget {
  final String seanceId;

  const SeanceDetailsPage({super.key, required this.seanceId});

  @override
  _SeanceDetailsPageState createState() => _SeanceDetailsPageState();
}

class _SeanceDetailsPageState extends State<SeanceDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> _seanceData;

  @override
  void initState() {
    super.initState();
    _fetchSeanceData();
  }

  Future<void> _fetchSeanceData() async {
    try {
      DocumentSnapshot seanceDoc = await _firestore.collection('seances').doc(widget.seanceId).get();
      if (seanceDoc.exists) {
        setState(() {
          _seanceData = seanceDoc.data() as Map<String, dynamic>;
        });
      } else {
        if (kDebugMode) {
          print("No seance document found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching seance data: $e");
      }
    }
  }

  Future<void> _updateSeance() async {
    try {
      await _firestore.collection('seances').doc(widget.seanceId).update(_seanceData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seance updated successfully')));
    } catch (e) {
      if (kDebugMode) {
        print("Error updating seance: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update seance')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seance Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateSeance,
          ),
        ],
      ),
      body: _seanceData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matiere: ${_seanceData['matiere'] ?? 'Unknown'}'),
                  Text('Ville: ${_seanceData['ville'] ?? 'Unknown'}'),
                  Text('Prix: ${_seanceData['prix'] ?? 'Unknown'}'),
                  Text('Start Hour: ${_seanceData['startHour'] ?? 'Unknown'}'),
                  Text('End Hour: ${_seanceData['endHour'] ?? 'Unknown'}'),
                  Text('Type: ${_seanceData['type'] ?? 'Unknown'}'),
                  Text('Mode: ${_seanceData['mode'] ?? 'Unknown'}'),
                  Text('Niveau: ${_seanceData['niveau'] ?? 'Unknown'}'),
                  Text('Nombre Etudiants: ${_seanceData['nombre_etudiants'] ?? 'Unknown'}'),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Matiere'),
                    controller: TextEditingController(text: _seanceData['matiere']),
                    onChanged: (value) => _seanceData['matiere'] = value,
                  ),
                  // Add other fields here similarly
                ],
              ),
            ),
    );
  }
}
