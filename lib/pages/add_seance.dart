import 'package:flutter/material.dart';

class AddSeancePage extends StatelessWidget {
  const AddSeancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Seance'),
        backgroundColor: Colors.blue[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Save seance data to Firebase or other backend
                // FirebaseFirestore.instance.collection('seances').add({
                //   'title': title,
                //   'description': description,
                //   'timestamp': Timestamp.now(),
                // });

                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('Save Seance'),
            ),
          ],
        ),
      ),
    );
  }
}

void addSeance(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddSeancePage()),
  );
}
