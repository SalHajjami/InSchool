import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import '../seance/add_seance.dart';
import '../authenticate/login_page.dart';
import 'package:inschool/pages/professor/Prof_GrpCourseList.dart';
import 'package:inschool/pages/professor/Prof_ind_course_list.dart';
import 'package:flutter/foundation.dart';
import 'package:inschool/pages/profile/user_profile_page.dart';
import 'package:inschool/pages/Chat/Chat_Prof.dart'; // Import the ChatPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Fetch user document from Firestore using UID
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('username') ?? 'username'; // Fetch the username
          });
        } else {
          if (kDebugMode) {
            print("No user document found in Firestore");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user data: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("No user signed in");
      }
    }
  }

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void addSeance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSeancePage()),
    );
  }

  void openDiscussion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  void checkSolde() {
    // Functionality to check solde
  }

  void goToCoursIndividuelles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfIndCourseList()),
    );
  }

  void goToCoursEngroupe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfGrpCourseList()),
    );
  }

  Future<void> _navigateToProfilePage() async {
    // Navigate to UserProfilePage and wait for result
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    );
    // Refresh user name after returning
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
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
                  const SizedBox(height: 10),
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
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.blue[900],
        selectedLabelStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.black,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Seance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Discussion',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Solde',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: _userName ?? 'username', // Dynamically display the username
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            addSeance(context);
          } else if (index == 1) {
            openDiscussion(context);
          } else if (index == 2) {
            checkSolde();
          } else if (index == 3) {
            _navigateToProfilePage();
          }
        },
      ),
    );
  }
}
