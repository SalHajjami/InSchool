import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EtudiantRegisterPage extends StatefulWidget {
  const EtudiantRegisterPage({super.key});

  @override
  _EtudiantRegisterPageState createState() => _EtudiantRegisterPageState();
}

class _EtudiantRegisterPageState extends State<EtudiantRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedCountry;
  String? _selectedLevel;
  String? _selectedCourse;
  bool _isLoading = false;
  bool showCountryError = false;

  // Define lists for education levels and courses for students
  final List<String> levels = ['Primary School', 'Middle School', 'High School', 'University'];
  final Map<String, List<String>> coursesByLevel = {
    'Primary School': ['Mathematics', 'Science', 'English'],
    'Middle School': ['Mathematics', 'Science', 'English', 'History'],
    'High School': ['Physics', 'Chemistry', 'Biology', 'Mathematics', 'History'],
    'University': ['Engineering', 'Medicine', 'Law', 'Arts'],
  };

  Future<void> _registerEtudiant() async {
    if (!_formKey.currentState!.validate() || _selectedCountry == null) {
      setState(() {
        showCountryError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('etudiants').doc(uid).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _selectedCountry,
        'level': _selectedLevel,
        'course': _selectedCourse,
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.message ?? 'An error occurred.'),
          );
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'lib/images/Inschool_logo.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _firstNameController,
                    hintText: 'First Name',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _lastNameController,
                    hintText: 'Last Name',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                  ),
                  const SizedBox(height: 20),
                  CSCPicker(
                    onCountryChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        showCountryError = false;
                      });
                    },
                    onStateChanged: (value) {},
                    onCityChanged: (value) {},
                    countryDropdownLabel: 'Country',
                    stateDropdownLabel: 'State',
                    cityDropdownLabel: 'City',
                    showStates: false,
                    showCities: false,
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    dropdownItemStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  if (showCountryError && _selectedCountry == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a country',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    value: _selectedLevel,
                    hint: 'Education Level',
                    items: levels,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLevel = newValue;
                        _selectedCourse = null; // Reset course when level changes
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    value: _selectedCourse,
                    hint: 'Course',
                    items: _selectedLevel != null ? coursesByLevel[_selectedLevel!]! : [],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCourse = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerEtudiant,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      ),
      hint: Text(hint),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}