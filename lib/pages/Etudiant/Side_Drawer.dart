import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inschool/pages/authenticate/login_page.dart'; // Import the login page
import 'package:inschool/pages/Etudiant/EtdProfil.dart'; // Import the profile page

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String? _profileImageUrl;
  String? _username;
  
  // State variables to control hover effect
  bool _isMonProfilPressed = false;
  bool _isParametresPressed = false;
  bool _isSeDeconnecterPressed = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile on drawer load
  }

  Future<void> _fetchUserProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('etudiants').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profile_image']; // Assuming 'profile_image' is the key in Firestore
          _username = userDoc['nom_utilisateur']; // Assuming 'nom_utilisateur' is the key for username
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFF2D3A45), // Same consistent dark gray color
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Align in the center of the drawer
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null, // Load image if available
                child: _profileImageUrl == null
                    ? const Icon(Icons.person_outline, size: 60, color: Color(0xFF9394a5))
                    : null, // Show default icon if no image is available
              ),
              const SizedBox(height: 20),
              if (_username != null) // Display the username if available
                Text(
                  _username!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Make the username bigger
                    fontWeight: FontWeight.bold, // Make it bold
                  ),
                ),
              const SizedBox(height: 20), // Space before the separating line
              // Separating line
              Divider(
                color: Colors.white54, // Light color for the dividing line
                thickness: 1.0,
                indent: 40, // Indent the line to align it nicely within the drawer
                endIndent: 40,
              ),
              const SizedBox(height: 30), // Space after the line

              // "Mon Profil" button with hover effect and rounded edges
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isMonProfilPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isMonProfilPressed = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EtdProfilPage()),
                  );
                },
                onTapCancel: () {
                  setState(() {
                    _isMonProfilPressed = false; // Revert color if press is canceled
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * 0.7, // Control width to match the line and Se Déconnecter button
                  decoration: BoxDecoration(
                    color: _isMonProfilPressed ? Colors.teal.shade600 : Colors.transparent, // Reverts to transparent
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                    border: Border.all(color: Colors.white54, width: 1.0), // Border for the button
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0), // Adjusted padding for a consistent size
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Mon Profil',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between the buttons

              // "Paramètres" button with hover effect and rounded edges
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isParametresPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isParametresPressed = false;
                  });
                  // Add logic for settings when available
                },
                onTapCancel: () {
                  setState(() {
                    _isParametresPressed = false; // Revert color if press is canceled
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * 0.7, // Control width to match the line and Se Déconnecter button
                  decoration: BoxDecoration(
                    color: _isParametresPressed ? Colors.teal.shade600 : Colors.transparent, // Reverts to transparent
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                    border: Border.all(color: Colors.white54, width: 1.0), // Border for the button
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0), // Adjusted padding for a consistent size
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Paramètres',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(), // Pushes everything up, leaving "Se Déconnecter" at the bottom

              // "Se Déconnecter" button with hover effect and rounded edges
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isSeDeconnecterPressed = true;
                  });
                },
                onTapUp: (_) async {
                  setState(() {
                    _isSeDeconnecterPressed = false;
                  });
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                onTapCancel: () {
                  setState(() {
                    _isSeDeconnecterPressed = false; // Revert color if press is canceled
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isSeDeconnecterPressed ? Colors.red.shade700 : Colors.red, // Reverts to original color
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26, // Light shadow to give a floating effect
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Adjusted padding for a balanced button size
                  margin: const EdgeInsets.symmetric(horizontal: 50), // Adjust margin to make it fit better
                  child: const Center(
                    child: Text(
                      'Se Déconnecter',
                      style: TextStyle(
                        fontSize: 14, // Slightly smaller text
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Space for the "Terms of Service"
              const Text(
                'Terms of Service | Privacy Policy',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
