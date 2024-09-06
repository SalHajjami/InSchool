import 'dart:io';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _userProfileFuture;
  String? _selectedCountry;
  String? _selectedMatiere;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (!data.containsKey('documentNames')) {
          data['documentNames'] = [];
        }
        return data;
      }
    }
    return {};
  }

  void _editUserProfile(BuildContext context, String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: field == 'Country'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CSCPicker(
                      onCountryChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      onStateChanged: (value) {},
                      onCityChanged: (value) {},
                      countryDropdownLabel: 'Country',
                      stateDropdownLabel: 'State',
                      cityDropdownLabel: 'City',
                      showStates: false,
                      showCities: false,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Selected Country: ${_selectedCountry ?? 'None'}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                )
              : field == 'Matière'
                  ? DropdownButton<String>(
                      value: _selectedMatiere ?? currentValue,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMatiere = newValue;
                        });
                      },
                      items: <String>['Math', 'Physique', 'Chemistry', 'Biology', 'Computer Science']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  : TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Enter new $field',
                      ),
                    ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    field.toLowerCase(): field == 'Country'
                        ? _selectedCountry
                        : field == 'Matière'
                            ? _selectedMatiere
                            : controller.text,
                  });
                  setState(() {
                    _userProfileFuture = _fetchUserProfile();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewDocument(String fileName) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      String downloadUrl = await storage.ref().child('user_documents').child(fileName).getDownloadURL();

      if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('View Image'),
              ),
              body: PhotoViewGallery.builder(
                itemCount: 1,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(downloadUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (fileName.endsWith('.pdf')) {
        final http.Response response = await http.get(Uri.parse(downloadUrl));
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('View PDF'),
              ),
              body: PDFView(
                filePath: filePath,
              ),
            ),
          ),
        );
      } else {
        print('Unsupported file type');
      }
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'zip'],
    );

    if (result != null && result.files.isNotEmpty) {
      final PlatformFile file = result.files.first;
      final User? user = _auth.currentUser;
      if (user != null) {
        final String fileName = await uploadFileToFirebase(file);
        await _firestore.collection('users').doc(user.uid).update({
          'documentNames': FieldValue.arrayUnion([fileName]),
        });
        setState(() {
          _userProfileFuture = _fetchUserProfile();
        });
      }
    }
  }

  Future<void> _deleteDocument(String fileName) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      await storage.ref().child('user_documents').child(fileName).delete();
      await _firestore.collection('users').doc(user.uid).update({
        'documentNames': FieldValue.arrayRemove([fileName]),
      });
      setState(() {
        _userProfileFuture = _fetchUserProfile();
      });
    }
  }

  Future<String> uploadFileToFirebase(PlatformFile file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    Reference ref = storage.ref().child('user_documents').child(fileName);

    try {
      await ref.putFile(File(file.path!));
      return fileName;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF064789),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No user data available'));
          } else {
            Map<String, dynamic> userData = snapshot.data!;
            List<String> documentNames = List<String>.from(userData['documentNames'] ?? []);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue[700]),
                                const SizedBox(width: 8.0),
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF064789),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildProfileField(context, 'Username', userData['username']),
                            _buildProfileField(context, 'First_Name', userData['first_name']),
                            _buildProfileField(context, 'Last_Name', userData['last_name']),
                            _buildProfileField(context, 'Email', userData['email']),
                            _buildProfileField(context, 'Country', userData['country']),
                            _buildProfileField(context, 'Matière', userData['matiere']),
                            const SizedBox(height: 16.0),
                            const Text(
                              'Uploaded Documents',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064789),
                              ),
                            ),
                            if (documentNames.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: documentNames.map((docName) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Document Name: $docName',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.green),
                                        onPressed: () => _viewDocument(docName),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteDocument(docName),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              )
                            else
                              const Text('No documents uploaded.'),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _uploadDocument,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF064789),
                              ),
                              child: const Text('Upload Document'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, String field, String value) {
    return GestureDetector(
      onTap: () => _editUserProfile(context, field, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$field:',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.edit, color: Colors.blue),
                
              ],
            ),
          ],
        ),
      ),
      
    );
 
  }
}