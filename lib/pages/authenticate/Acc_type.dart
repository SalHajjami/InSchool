import 'package:flutter/material.dart';
import 'package:inschool/pages/authenticate/EtudiantRegisterPage.dart';
import 'package:inschool/pages/authenticate/create_account_page.dart';


class AccTypePage extends StatefulWidget {
  const AccTypePage({super.key});

  @override
  _AccTypePageState createState() => _AccTypePageState();
}

class _AccTypePageState extends State<AccTypePage> {
  String? selectedAccountType; // Variable to track selected account type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16325B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16325B), // Changed the AppBar color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White return icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // Ensure taps on empty space are detected
        onTap: () {
          // Deselect the highlighted box only if the tap is outside
          setState(() {
            selectedAccountType = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Vous êtes",
                style: TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAccountOption(
                      context,
                      title: 'Etudiant',
                      description:
                          'Je suis un etudiant à la recherche des professeurs expérimentés pour développer mon niveau scolaire.',
                      icon: Icons.school,
                      isSelected: selectedAccountType == 'Etudiant',
                      onPressed: () {
                        setState(() {
                          selectedAccountType = 'Etudiant';
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildAccountOption(
                      context,
                      title: 'Professeur',
                      description:
                          'Je suis un professeur prêt à offrir mes services à des étudiants pour les aider à réussir.',
                      icon: Icons.person_outline,
                      isSelected: selectedAccountType == 'Professeur',
                      onPressed: () {
                        setState(() {
                          selectedAccountType = 'Professeur';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (selectedAccountType == null) {
                    // Show the snack bar when no profession is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez choisir votre profession"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (selectedAccountType == 'Etudiant') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EtudiantRegisterPage(),
                      ),
                    );
                  } else if (selectedAccountType == 'Professeur') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountPage(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDC7F), // "Done" button is always yellow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: const Text(
                  "Suivant",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected, // Added parameter for selection state
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onPressed(); // Set the selectedAccountType
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          height: isSelected ? 300 : 150, // Animate height based on selection
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFDC7F) : const Color(0xFF227B94),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: isSelected ? Colors.black : Colors.white),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
              ], // Show description only if selected
            ],
          ),
        ),
      ),
    );
  }
}
