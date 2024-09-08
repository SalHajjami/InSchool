import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../seance/edit_seance.dart';
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
              final courseId = courses[index].id; // Get the document ID

              return ListTile(
                title: Text('Matiere: ${course['matiere']}'),
                subtitle: Text(
                  'Ville: ${course['ville']}\n'
                  'Prix: ${course['prix']}\n'
                  'Niveau: ${course['niveau']}\n'
                  
                  'Start Hour: ${course['startHour']}\n'
                  'End Hour: ${course['endHour']}\n'
                  'Mode: ${course['mode']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCoursePage(
                              courseId: courseId,
                              initialData: course,
                              collectionName: 'cours_individuele',
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, courseId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: const Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCourse(courseId, 'cours_individuele');
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(String courseId, String collectionName) {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(courseId)
        .delete()
        .then((_) {
          // Show a success message if needed
          print("Course deleted successfully");
        })
        .catchError((error) {
          // Handle errors if needed
          print("Error deleting course: $error");
        });
  }
}