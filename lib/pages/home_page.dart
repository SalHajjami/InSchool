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
      backgroundColor: Colors.blue[500],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // The header or title at the top with a sign-out button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'InSchool',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: signUserOut,
                  ),
                ],
              ),
            ),
            // Spacer to push the buttons to the center of the page
            const Spacer(),
            // Center the first button
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {}, // Add your action here
                    child: const Text('Seance Individuelle'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {}, // Action for Seance en Groupe
                    child: const Text('Seance en Groupe'),
                  ),
                ],
              ),
            ),
            // Another spacer to balance the layout
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            label: 'Add Seance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: 'Discussion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            label: 'Solde',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            addSeance();
          } else if (index == 1) {
            openDiscussion();
          } else if (index == 2) {
            checkSolde();
          }
        },
      ),
    );
  }
}
