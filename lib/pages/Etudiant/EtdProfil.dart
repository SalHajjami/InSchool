import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EtdProfilPage extends StatefulWidget {
  const EtdProfilPage({super.key});

  @override
  _EtdProfilPageState createState() => _EtdProfilPageState();
}

class _EtdProfilPageState extends State<EtdProfilPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _educationLevel;
  String? _grade;
  File? _newProfileImage;
  String? _profileImageUrl;

  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  bool _isEditingUsername = false;
  bool _isEditingEmail = false;
  bool _isSaving = false;
  bool _dropdownChanged = false;

  String? _initialEducationLevel; // Added to store initial value
  String? _initialGrade; // Added to store initial value

  bool _educationLevelError = false; // Error flag for cycle scolaire
  bool _gradeError = false; // Error flag for niveau

  final List<String> educationLevels = ['Primaire', 'Collège', 'Lycée'];
  final Map<String, List<String>> gradeOptions = {
    'Primaire': ['1ère année', '2ème année', '3ème année', '4ème année', '5ème année', '6ème année'],
    'Collège': ['1ère année collège', '2ème année collège', '3ème année collège'],
    'Lycée': ['Tronc commun', '1ère année Bac', '2ème année Bac'],
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('etudiants').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        _firstNameController.text = userDoc['prenom'];
        _lastNameController.text = userDoc['nom'];
        _usernameController.text = userDoc['nom_utilisateur'];
        _emailController.text = userDoc['email'];
        _profileImageUrl = userDoc['profile_image'];
        _educationLevel = userDoc['cycle_scolaire'];
        _grade = userDoc['niveau'];

        // Store initial values
        _initialEducationLevel = userDoc['cycle_scolaire'];
        _initialGrade = userDoc['niveau'];
      });
    }
  }

  Future<void> updateUserData() async {
    if (_educationLevel == null || _grade == null) {
      setState(() {
        _educationLevelError = _educationLevel == null;
        _gradeError = _grade == null;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (_newProfileImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await storageRef.putFile(_newProfileImage!);
      _profileImageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('etudiants').doc(uid).update({
      'prenom': _firstNameController.text.trim(),
      'nom': _lastNameController.text.trim(),
      'nom_utilisateur': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'profile_image': _profileImageUrl,
      'cycle_scolaire': _educationLevel,
      'niveau': _grade,
    });

    setState(() {
      _isSaving = false;
      _isEditingFirstName = false;
      _isEditingLastName = false;
      _isEditingUsername = false;
      _isEditingEmail = false;
      _newProfileImage = null;
      _dropdownChanged = false;
      _educationLevelError = false;
      _gradeError = false;

      // Update initial values to reflect saved state
      _initialEducationLevel = _educationLevel;
      _initialGrade = _grade;
    });
  }

  void _showImageActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.teal)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Prendre une photo', style: TextStyle(color: Colors.teal)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer l\'image', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _deleteProfileImage();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteProfileImage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

    await storageRef.delete();

    setState(() {
      _profileImageUrl = null;
      _newProfileImage = null;
    });

    await FirebaseFirestore.instance.collection('etudiants').doc(uid).update({
      'profile_image': null,
    });
  }

  Widget buildInfoTile(String title, String value, bool isEditing, VoidCallback onEdit, TextEditingController controller, VoidCallback onCancel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isEditing
                ? IconButton(
                    key: const ValueKey('cancelIcon'),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onCancel,
                  )
                : IconButton(
                    key: const ValueKey('editIcon'),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: onEdit,
                  ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isEditing ? 1.0 : 0.0,
          child: Visibility(
            visible: isEditing,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF78B7D0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.white,
          height: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16325B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16325B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImageActionSheet,
                child: CircleAvatar(
                  radius: 70, // Enlarged profile image
                  backgroundColor: Colors.white,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null) as ImageProvider?,
                  child: _profileImageUrl == null && _newProfileImage == null
                      ? const Icon(Icons.person_outline, size: 70, color: Color(0xFF227B94))
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              buildInfoTile(
                'Prénom',
                _firstNameController.text,
                _isEditingFirstName,
                () {
                  setState(() {
                    _isEditingFirstName = true;
                  });
                },
                _firstNameController,
                () {
                  setState(() {
                    _isEditingFirstName = false;
                  });
                },
              ),
              buildInfoTile(
                'Nom',
                _lastNameController.text,
                _isEditingLastName,
                () {
                  setState(() {
                    _isEditingLastName = true;
                  });
                },
                _lastNameController,
                () {
                  setState(() {
                    _isEditingLastName = false;
                  });
                },
              ),
              buildInfoTile(
                'Nom d\'utilisateur',
                _usernameController.text,
                _isEditingUsername,
                () {
                  setState(() {
                    _isEditingUsername = true;
                  });
                },
                _usernameController,
                () {
                  setState(() {
                    _isEditingUsername = false;
                  });
                },
              ),
              buildInfoTile(
                'Email',
                _emailController.text,
                _isEditingEmail,
                () {
                  setState(() {
                    _isEditingEmail = true;
                  });
                },
                _emailController,
                () {
                  setState(() {
                    _isEditingEmail = false;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Cycle Scolaire Dropdown
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: DropdownButtonFormField<String>(
                  value: _educationLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF78B7D0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: _educationLevelError ? 'Veuillez sélectionner un cycle scolaire' : null,
                  ),
                  hint: const Text('Sélectionnez votre cycle scolaire'),
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _grade = null;
                      _dropdownChanged = _educationLevel != _initialEducationLevel; // Set dropdown change flag only if different
                    });
                  },
                  items: educationLevels.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

              if (_educationLevel != null) ...[
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: DropdownButtonFormField<String>(
                    value: _grade,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF78B7D0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: _gradeError ? 'Veuillez sélectionner un niveau' : null,
                    ),
                    hint: const Text('Sélectionnez votre niveau'),
                    onChanged: (value) {
                      setState(() {
                        _grade = value;
                        _dropdownChanged = _educationLevel != _initialEducationLevel || _grade != _initialGrade;
                      });
                    },
                    items: gradeOptions[_educationLevel]!.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isEditingFirstName ||
                        _isEditingLastName ||
                        _isEditingUsername ||
                        _isEditingEmail ||
                        _newProfileImage != null ||
                        _dropdownChanged
                    ? 1.0
                    : 0.0,
                child: Visibility(
                  visible: _isEditingFirstName ||
                      _isEditingLastName ||
                      _isEditingUsername ||
                      _isEditingEmail ||
                      _newProfileImage != null ||
                      _dropdownChanged,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: updateUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFDC7F),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 50),
                          ),
                          child: const Text(
                            'Sauvegarder les modifications',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
