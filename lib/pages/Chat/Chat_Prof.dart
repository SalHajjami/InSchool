import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final types.User _dummyUser = const types.User(
    id: 'dummyUser',
    firstName: 'Professor',
  );

  Future<void> _handleSendPressed(types.PartialText message) async {
    final messageData = {
      'text': message.text,
      'createdAt': Timestamp.now(),
      'userId': _dummyUser.id,
    };

    await _firestore.collection('messages').add(messageData);
  }

  Stream<List<types.Message>> _getMessages() {
  return _firestore
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    print('Fetched ${snapshot.docs.length} messages');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      print('Message data: $data');

      return types.TextMessage(
        id: doc.id,
        author: types.User(id: data['userId']),
        text: data['text'],
        createdAt: (data['createdAt'] as Timestamp).millisecondsSinceEpoch,
      );
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF064789), // Dark Blue
        title: const Text('Chat'),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: _getMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Chat(
            messages: snapshot.data!,
            onSendPressed: _handleSendPressed,
            user: _dummyUser,
            theme: DefaultChatTheme(
              primaryColor: const Color(0xFF064789), // Dark Blue
              inputBackgroundColor: const Color(0xFFEBF2FA), // Light Blue
              inputTextColor: Colors.black,
              inputBorderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
