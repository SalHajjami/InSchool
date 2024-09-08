import 'package:flutter/material.dart';
import 'package:inschool/pages/Etudiant/UserListPage.dart'; // Import the new user list page
import '../authenticate/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EtdHomePage extends StatelessWidget {
  const EtdHomePage({super.key});
  void signUserOut(BuildContext context) async {
    // Show confirmation dialog before signing out
    bool confirmSignOut = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    );

    if (confirmSignOut) {
      // If the user confirms, sign out
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: const Color(0xFF16325B),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7, // Set the drawer width to 70% of the screen
        child: Container(
          color: const Color(0xFF227B94),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF227B94),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Navigate to Profil page
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Se Deconnecter', style: TextStyle(color: Colors.white)),
                onTap: () => signUserOut(context),
                
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: pageController,
              children: [
                // Main Home Page
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppBar(
                      backgroundColor: const Color(0xFF16325B),
                      elevation: 0,
                      leading: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              Scaffold.of(context).openDrawer(); // Open the drawer when the menu icon is clicked
                            },
                          );
                        },
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () {
                            pageController.jumpToPage(1); // Navigate to user list page
                          },
                        ),
                      ],
                      centerTitle: true,
                      title: const Text(
                        'InSchool',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Seances Presentielles
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: const Color(0xFF78B7D0),
                      ),
                      child: const Text(
                        'Seances Presentielles',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Seances en Ligne
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: const Color(0xFF78B7D0),
                      ),
                      child: const Text(
                        'Seances en Ligne',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Reserver Seance
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        backgroundColor: const Color(0xFFFFDC7F),
                      ),
                      child: const Text(
                        'Reserver Seance',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),

                // User List Page (Swipe Right)
                UserListPage(), // Replace this with your user list page widget
              ],
            ),
          ],
        ),
      ),
    );
  }
}
