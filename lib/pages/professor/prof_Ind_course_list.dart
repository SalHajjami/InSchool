import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfIndCourseList extends StatelessWidget {
  const ProfIndCourseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Courses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cours_individuele')
            .where('professor_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No individual courses found'));
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text('Matiere: ${course['matiere']}'),
                subtitle: Text(
                  'Ville: ${course['ville']}\n'
                  'Prix: ${course['prix']}\n'
                  'Niveau: ${course['niveau']}\n'
                  'Nombre d\'Étudiants: ${course['nombre_etudiants']}\n'
                  'Start Hour: ${course['startHour']}\n'
                  'End Hour: ${course['endHour']}\n'
                  'Mode: ${course['mode']}',
                ),
                trailing: Text('Type: ${course['type']}'),
              );
            },
          );
        },
      ),
    );
  }
}
