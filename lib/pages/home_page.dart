import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void addSeance() {
    // Functionality to add a seance
  }

  void openDiscussion() {
    // Functionality to open discussions
  }

  void checkSolde() {
    // Functionality to check solde
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))
      ]),
      body: Center(child: Text("Logged In")),
    );
  }
}
