import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inschool/pages/authenticate/Acc_Type.dart';
import 'package:inschool/pages/authenticate/forgot_password.dart';
import 'package:inschool/pages/Etudiant/StudentDrawerWrapper.dart'; 
import 'package:inschool/pages/home/Home_Page.dart'; // Import professor homepage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Sign in the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the user's unique ID (UID)
      String uid = userCredential.user!.uid;

      // First check if the user is in the 'etudiants' collection (student)
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (studentDoc.exists) {
        // User is a student, redirect to the student home page
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentDrawerWrapper()),
        );
        return; // Exit the method, we don't want to check the 'users' collection now
      }

      // Now check if the user is in the 'users' collection (professor or other)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        // User is a professor or another role, redirect to the professor home page
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Close the progress dialog
        Navigator.pop(context);
        // If user not found in any collection, show an error
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Error'),
              content: Text('User not found in the system.'),
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // Close the progress dialog
      Navigator.pop(context);

      // Show appropriate error message
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Incorrect Email'),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Incorrect Password'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16325B), // Background color
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
                    color: Color(0xFFFFDC7F), // Text color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFF78B7D0), // Field background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF78B7D0), // Field background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFFFFDC7F)), // Text color
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: signUserIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDC7F), // Button background color
                    foregroundColor: Colors.black, // Button text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[200]),
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
                          color: Color(0xFF78B7D0), // Link color
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
