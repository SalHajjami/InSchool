import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import '../seance/add_seance.dart';
import '../authenticate/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:inschool/pages/profile/user_profile_page.dart'; // Ensure this path matches your project structure
import '../seance/edit_seance.dart'; // Import the Edit Course Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  String? _userName;
  String _filter = 'All'; // Default filter
  String? _professorId;

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
            _professorId = user.uid; // Store the professor ID
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

  Future<void> _navigateToProfilePage() async {
    // Navigate to UserProfilePage and wait for result
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    );
    // Refresh user name after returning
    _fetchUserName();
  }

  void _filterSeances(String filter) {
    setState(() {
      _filter = filter;
    });
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
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                addSeance(context); // Navigate to Add Seance page
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Seances',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      addSeance(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: $_filter',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select Filter'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('All'),
                                  onTap: () {
                                    _filterSeances('All');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Individuel'),
                                  onTap: () {
                                    _filterSeances('individuel');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('En Groupe'),
                                  onTap: () {
                                    _filterSeances('en groupe');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('seances')
                  .where('professor_id', isEqualTo: _professorId) // Filter by professor ID
                  .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No seances available'));
                  }

                  // Apply filter to the retrieved documents
                  final filteredSeances = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] ?? '';
                    if (kDebugMode) {
                      print('Document type: $type, Filter: $_filter'); // Debugging line
                    }
                    return _filter == 'All' || type == _filter;
                  }).toList();

                  if (filteredSeances.isEmpty) {
                    return const Center(child: Text('No seances available'));
                  }

                  return ListView(
                    children: filteredSeances.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['matiere'] ?? 'Unknown'),
                        subtitle: Text(
                          '${data['ville']}, ${data['prix']}, ${data['startHour']} - ${data['endHour']}',
                        ),
                        trailing: Text(data['type'] ?? 'Unknown'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCoursePage(
                                courseId: doc.id, // Pass the seance ID to the EditCoursePage
                                initialData: data, // Pass the initial data to the EditCoursePage
                                collectionName: 'seances', // Pass the collection name
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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
            openDiscussion();
          } else if (index == 1) {
            checkSolde();
          } else if (index == 2) {
            _navigateToProfilePage();
          }
        },
      ),
    );
  }
}
