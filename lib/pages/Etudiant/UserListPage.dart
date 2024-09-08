import 'package:flutter/material.dart';
import 'package:inschool/pages/Chat/Chat_Prof.dart'; // Import the new user list page


class UserListPage extends StatelessWidget {
  final List<Map<String, String>> users = [
    {'name': 'Salim', 'message': 'Sent 2 h ago', 'image': 'lib/images/salim.png'},
    {'name': 'Achraf', 'message': 'Sent 5 h ago', 'image': 'lib/images/achraf.png'},
    {'name': 'Zakaria', 'message': 'Seen yesterday', 'image': 'lib/images/zakaria.png'},
    {'name': 'Ismail', 'message': 'Seen 1 d ago', 'image': 'lib/images/ismail.png'},
  ];

  UserListPage({super.key});

  void openChat(BuildContext context, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(), // Replace with your ChatPage widget
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16325B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16325B),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Handle action for new message
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(users[index]['image']!),
            ),
            title: Text(
              users[index]['name']!,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: Text(
              users[index]['message']!,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: () {
                // Handle camera action
              },
            ),
            onTap: () {
              openChat(context, users[index]['name']!);
            },
          );
        },
      ),
    );
  }
}
