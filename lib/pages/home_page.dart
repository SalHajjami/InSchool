import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_seance.dart';
import 'login_page.dart';
import 'Prof_IndCourseList.dart'; // Import the CoursIndividuelles page
import 'Prof_GrpCourseList.dart'; // Import the CoursEnGroupe page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to LoginPage after sign-out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginPage()),
    );
  }

  void addSeance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSeancePage()),
    );
  }

  void openDiscussion() {
    // Functionality to open discussions
  }

  void checkSolde() {
    // Functionality to check solde
  }

  void goToCoursIndividuelles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoursIndividuelles()),
    );
  }

  void goToCoursEngroupe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoursEnGroupe()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[500],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'InSchool',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => signUserOut(context),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      goToCoursIndividuelles(context);
                    },
                    child: const Text('Seance Individuelle'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      goToCoursEngroupe(context);
                    },
                    child: const Text('Seance en Groupe'),
                  ),
                ],
              ),
            ),
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
            addSeance(context);
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
