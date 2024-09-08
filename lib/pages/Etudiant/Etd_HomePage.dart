import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:inschool/pages/Etudiant/StuNavbar.dart';
import 'package:inschool/pages/Etudiant/UserListPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:intl/intl.dart';

class EtdHomePage extends StatefulWidget {
  final AdvancedDrawerController controller;

  const EtdHomePage({super.key, required this.controller});

  @override
  _EtdHomePageState createState() => _EtdHomePageState();
}

class _EtdHomePageState extends State<EtdHomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  double _currentPage = 0.0;

  // Data to hold user profiles fetched from Firestore
  List<Map<String, dynamic>> userData = [];

  // Data to hold seances fetched from Firestore
  List<Map<String, dynamic>> seancesData = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.55, // Adjusts the size of each page to be smaller
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _pageController.initialPage.toDouble();
      });
    });

    // Fetch user profiles and seances from Firestore on init
    _fetchUsersData();
    _fetchSeancesData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fetch user profiles from Firestore
  void _fetchUsersData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      setState(() {
        userData = docs.map((doc) {
          return {
            'username': doc['username'],
            'matiere': doc['matiere'],
            'profile_image': doc['profile_image'] ?? 'https://via.placeholder.com/150', // Provide a default image if null
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching user profiles: $e");
    }
  }

  // Fetch seances data from Firestore
  void _fetchSeancesData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('seances').get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      setState(() {
        seancesData = docs.map((doc) {
          Timestamp timestamp = doc['date'] as Timestamp;
          DateTime dateTime = timestamp.toDate();
          String formattedDate = DateFormat.yMMMd().format(dateTime);

          return {
            'matiere': doc['matiere'],
            'date': formattedDate,
            'startHour': doc['startHour'],
            'endHour': doc['endHour'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching seances: $e");
    }
  }

  void _onTabSelected(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Handle Seances page navigation
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserListPage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  // Build each card with user info
  Widget _buildUserCard(Map<String, dynamic> data, int index) {
  double scale = 1.0;
  double difference = (_currentPage - index).abs();

  if (difference < 1.0) {
    scale = 1 - (difference * 0.2);
  } else {
    scale = 0.8;
  }

  return Transform.scale(
    scale: scale,
    child: Container(
      width: 200, // Added a fixed width to prevent horizontal stretching
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Updated color for the cards
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 10, // Shadow blur
            offset: const Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              data['profile_image'],
              height: 135, // Adjusted size to make it smaller
              width: 135,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 140); // Default icon
              },
            ),
          ),
          const SizedBox(height: 10),
          // Username
          Text(
            data['username'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Matiere
          Text(
            data['matiere'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Add logic for booking or details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C6DD0), // Updated button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Consulter le profil',  // Updated button text
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}


  // Build each seance in the list view
  Widget _buildSeanceItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12), // Reduced padding to reduce item height
      decoration: BoxDecoration(
        color: Colors.white, // Updated color for the seance list items
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 10, // Shadow blur
            offset: const Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the text
        children: [
          Text(
            data['matiere'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${data['date']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            'Time: ${data['startHour']} - ${data['endHour']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 245, 242), // Updated app bar background color
        leading: IconButton(
          onPressed: () {
            widget.controller.showDrawer(); // Use the controller to open the drawer
          },
          icon: ValueListenableBuilder<AdvancedDrawerValue>(
            valueListenable: widget.controller,
            builder: (_, value, __) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250), // Smooth transition duration
                child: Icon(
                  value.visible ? Icons.clear : Icons.menu, // Switch between menu and X
                  key: ValueKey<bool>(value.visible), // Use different keys for the icons to animate
                  color: Colors.black, // Updated icon color
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search logic here
            },
            color: Colors.black, // Updated search icon color
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 246, 245, 242), // Updated page background color
      body: Column(
        children: [
          // Header with title and button for "Profs les plus visites"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profs les plus visites",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Add logic to see all profiles
                  },
                  child: const Text(
                    "Voir tout",
                    style: TextStyle(color: Color(0xFF1C6DD0)),
                  ),
                ),
              ],
            ),
          ),
          // User cards carousel
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3, // Reduced height
            child: userData.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(userData[index], index);
                    },
                  )
                : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching
          ),
          const SizedBox(height: 16),
          // Optional: Add a page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: userData.length,
            effect: const WormEffect(
              dotHeight: 8, // Adjusted size of dots
              dotWidth: 8,
              activeDotColor: Color(0xFF1C6DD0), // Updated indicator active dot color
            ),
          ),
          const SizedBox(height: 20),
          // Header with title and button for "Seances recommandées"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Seances recommandées",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Add logic to see all seances
                  },
                  child: const Text(
                    "Voir tout",
                    style: TextStyle(color: Color(0xFF1C6DD0)),
                  ),
                ),
              ],
            ),
          ),
          // Seances list view with centered transform animations
          Expanded(
            child: seancesData.isNotEmpty
                ? TransformableListView.builder(
                    itemCount: seancesData.length,
                    getTransformMatrix: (TransformableListItem item) {
                      final animationProgress = item.visibleExtent / item.size.height;
                      final scale = 0.8 + (0.2 * animationProgress);
                      final transform = Matrix4.identity();

                      // Center the item shrink from both sides
                      transform
                        ..translate(item.size.width / 2)
                        ..scale(scale)
                        ..translate(-item.size.width / 2);
                      
                      return transform;
                    },
                    itemBuilder: (context, index) {
                      return _buildSeanceItem(seancesData[index]);
                    },
                  )
                : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching
          ),
        ],
      ),
      bottomNavigationBar: StuNavbar(
        selectedIndex: _selectedIndex, // Pass the selected index to highlight the correct tab
        onTabSelected: _onTabSelected, // Handle tab selection and navigation
      ),
    );
  }
}
