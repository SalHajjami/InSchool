import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:inschool/pages/Etudiant/Side_Drawer.dart';
import 'package:inschool/pages/Etudiant/Etd_HomePage.dart'; // Import the student homepage

class StudentDrawerWrapper extends StatefulWidget {
  const StudentDrawerWrapper({super.key});

  @override
  _StudentDrawerWrapperState createState() => _StudentDrawerWrapperState();
}

class _StudentDrawerWrapperState extends State<StudentDrawerWrapper> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: const Color(0xFF2D3A45), // Set the consistent dark gray color
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: const SideDrawer(), // The drawer content
      // Pass the controller to the EtdHomePage
      child: EtdHomePage(controller: _advancedDrawerController), // Pass the controller here
    );
  }
}
