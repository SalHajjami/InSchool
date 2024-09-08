import 'package:flutter/material.dart';
import 'package:inschool/components/my_button.dart';
import 'package:inschool/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inschool/pages/authenticate/forgot_password.dart';
import 'package:inschool/pages/home/Home_Page.dart'; // Professor HomePage
import 'package:inschool/pages/Etudiant/Etd_HomePage.dart'; // Student HomePage
import '../authenticate/Acc_type.dart'; // Registration Page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Sign in the user
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get the user's ID
      String uid = userCredential.user!.uid;

      // Check if the user is a professor or a student
      DocumentSnapshot professorDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection('etudiants').doc(uid).get();

      // Close the progress dialog
      if (mounted) Navigator.pop(context);

      // Navigate based on the collection the user is found in
      if (professorDoc.exists) {
        // Navigate to Professor's HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (studentDoc.exists) {
        // Navigate to Student's Etd_HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EtdHomePage()),
        );
      } else {
        _showErrorDialog('User not found in any collection.');
      }
    } on FirebaseAuthException catch (e) {
      // Close the progress dialog
      if (mounted) Navigator.pop(context);

      // Show appropriate error message
      switch (e.code) {
        case 'user-not-found':
          _showErrorDialog('No user found for that email.');
          break;
        case 'wrong-password':
          _showErrorDialog('Wrong password provided.');
          break;
        case 'invalid-email':
          _showErrorDialog('The email address is badly formatted.');
          break;
        case 'user-disabled':
          _showErrorDialog('This user has been disabled.');
          break;
        case 'too-many-requests':
          _showErrorDialog('Too many attempts. Try again later.');
          break;
        default:
          _showErrorDialog('An unexpected error occurred. Please try again.');
          break;
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorDialog('An error occurred. Please check your internet connection and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'lib/images/Inschool_logo.png',
                  height: 200,
                ),
                const SizedBox(height: 50),
                const Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: signUserIn,
                  text: 'Login',
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccTypePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
