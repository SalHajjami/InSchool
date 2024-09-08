import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:inschool/pages/authenticate/login_page.dart'; // Import the login page

class CreateStuAccPage extends StatefulWidget {
  const CreateStuAccPage({super.key});

  @override
  _CreateStuAccPageState createState() => _CreateStuAccPageState();
}

class _CreateStuAccPageState extends State<CreateStuAccPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  File? _profileImage;
  String? _gender;
  String? _educationLevel;
  String? _grade;

  final List<String> genders = ['Masculin', 'Féminin'];
  final List<String> educationLevels = ['Primaire', 'Collège', 'Lycée'];

  final Map<String, List<String>> gradeOptions = {
    'Primaire': ['1ère année', '2ème année', '3ème année', '4ème année', '5ème année', '6ème année'],
    'Collège': ['1ère année collège', '2ème année collège', '3ème année collège'],
    'Lycée': ['Tronc commun', '1ère année Bac', '2ème année Bac'],
  };

  Future<void> _createStudentAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the newly created user ID
      String uid = userCredential.user!.uid;

      // Upload profile image if it exists
      String? profileImageUrl;
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      // Store the student information directly in the "etudiants" collection
      await FirebaseFirestore.instance.collection('etudiants').doc(uid).set({
        'prenom': _firstNameController.text.trim(),
        'nom': _lastNameController.text.trim(),
        'nom_utilisateur': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'etudiant_id': uid,  // Store the user ID as a reference
        'sexe': _gender,
        'cycle_scolaire': _educationLevel,
        'niveau': _grade, // Store grade for any education level
        'profile_image': profileImageUrl, // Nullable in Firestore
      });

      // Redirect the user to the login page after account creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: Text(e.message ?? 'Une erreur s\'est produite.'),
          );
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Method to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is disposed to free up resources
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16325B), // Background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF16325B), // Match AppBar color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White return icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Profile Picture with upload functionality
                  GestureDetector(
                    onTap: _pickImage, // Allow the user to pick a profile picture
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person_outline, size: 50, color: Color(0xFF227B94))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Veuillez choisir une photo de profil',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      hintText: 'Prénom',
                      filled: true,
                      fillColor: const Color(0xFF78B7D0), // Field background color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      hintText: 'Nom',
                      filled: true,
                      fillColor: const Color(0xFF78B7D0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Nom d\'utilisateur',
                      filled: true,
                      fillColor: const Color(0xFF78B7D0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom d\'utilisateur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: const Color(0xFF78B7D0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      filled: true,
                      fillColor: const Color(0xFF78B7D0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit comporter au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Gender Dropdown
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200), // Smooth animation
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF78B7D0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      hint: const Text('Sélectionnez votre sexe'),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      items: genders.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Veuillez sélectionner votre sexe' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Education Level Dropdown
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200), // Smooth animation
                    child: DropdownButtonFormField<String>(
                      value: _educationLevel,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF78B7D0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      hint: const Text('Sélectionnez votre cycle scolaire'),
                      onChanged: (value) {
                        setState(() {
                          _educationLevel = value;
                          _grade = null; // Reset the grade when changing education level
                        });
                      },
                      items: educationLevels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Veuillez sélectionner votre cycle scolaire' : null,
                    ),
                  ),

                  if (_educationLevel != null) ...[
                    const SizedBox(height: 20),
                    // Grade Dropdown for selected education level
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200), // Smooth animation
                      child: DropdownButtonFormField<String>(
                        value: _grade,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF78B7D0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        hint: const Text('Sélectionnez votre niveau'),
                        onChanged: (value) {
                          setState(() {
                            _grade = value;
                          });
                        },
                        items: gradeOptions[_educationLevel]!.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) => value == null ? 'Veuillez sélectionner votre niveau' : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  // Register Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _createStudentAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFDC7F), // Button background color
                                foregroundColor: Colors.black, // Button text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                              ),
                              child: const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Vous avez déjà un compte ?',
                                  style: TextStyle(color: Colors.grey[200]),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      color: Color(0xFF78B7D0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
