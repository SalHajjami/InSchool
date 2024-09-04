import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inschool/components/my_button.dart';
import 'package:inschool/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _matiereController = TextEditingController(); // New controller for matiere

  String? _country;
  bool _isLoading = false;
  bool showCountryError = false;

  List<String> countries = ['France', 'USA', 'Canada', 'UK'];

Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate() || _country == null) {
      setState(() {
        showCountryError = true;
      });
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

      // Store additional user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'country': _country,
        'matiere': _matiereController.text.trim(),  // Save the "matière"
      });

      // Navigate back or to the next page
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

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(countries[index]),
                      onTap: () {
                        setState(() {
                          _country = countries[index];
                          showCountryError = false;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'lib/images/Inschool_logo.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showCountryError = false;
                      });
                      _showCountryPicker(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.flag),
                          const SizedBox(width: 16),
                          Text(
                            _country ?? 'Select Country',
                            style: TextStyle(
                              color:
                                  _country == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showCountryError && _country == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a country',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _matiereController, // Matière field
                    hintText: 'Matière',
                    obscureText: false,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                          onTap: _createAccount,
                          text: 'Register',
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
}
