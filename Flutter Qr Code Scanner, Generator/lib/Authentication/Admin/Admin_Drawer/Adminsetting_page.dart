import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../AdminService.dart';

class AdminSettingPage extends StatefulWidget {
  final Function(String?) updateProfileImageCallback;

  AdminSettingPage({Key? key, required this.updateProfileImageCallback})
      : super(key: key);

  @override
  _AdminSettingPageState createState() => _AdminSettingPageState();
}

class _AdminSettingPageState extends State<AdminSettingPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String passwordError = '';
  String usernameError = '';
  String emailError = '';
  String? profileImagePath;

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Change Profile',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickProfilePicture,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                          as ImageProvider<Object>?
                      : AssetImage('images/profileImage.png'),
                ),
              ),
              SizedBox(height: 20),
              Text('Tap to change profile picture'),
              TextField(
                controller: usernameController, // Add this line
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  errorText: usernameError.isNotEmpty ? usernameError : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorText: emailError.isNotEmpty ? emailError : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  errorText: passwordError.isNotEmpty ? passwordError : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Username validation
                  if (!usernameController.text.startsWith('admin_')) {
                    setState(() {
                      usernameError = 'Username must start with "admin_"';
                    });
                    return;
                  } else {
                    setState(() {
                      usernameError = '';
                    });
                  }
                  // Email validation
                  final emailRegex =
                      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                  if (!emailRegex.hasMatch(emailController.text)) {
                    setState(() {
                      emailError = 'Enter a valid email address';
                    });
                    return;
                  } else {
                    setState(() {
                      emailError = '';
                    });
                  }
                  // Password validation
                  if (newPasswordController.text.length < 6) {
                    setState(() {
                      passwordError =
                          'Password must be at least 6 characters long';
                    });
                    return;
                  } else {
                    setState(() {
                      passwordError = '';
                    });
                  }
                  // Password match validation
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    setState(() {
                      passwordError =
                          'New Password and Confirm Password must match';
                    });
                    return;
                  } else {
                    setState(() {
                      passwordError = '';
                    });
                  }
                  //to see on console whats being sent
                  print('Username: ${usernameController.text}');
                  print('Email: ${emailController.text}');
                  print('New Password: ${newPasswordController.text}');
                  print('Confirm Password: ${confirmPasswordController.text}');
                  print('Profile Image Path: $profileImagePath');

                  // Use the AdminService to update the admin's profile

                  // Uint8List photoBytes = await File(profileImagePath!).readAsBytes();
                  // String base64Image = base64Encode(photoBytes);
                  try {
                    if (profileImagePath != null &&
                        File(profileImagePath!).existsSync()) {
                      Uint8List photoBytes =
                          await File(profileImagePath!).readAsBytes();
                      String base64Image = base64Encode(photoBytes);

                      await Provider.of<AdminService>(context, listen: false)
                          .updateAdminProfile(
                              usernameController.text,
                              emailController.text,
                              newPasswordController.text,
                              profileImagePath,
                              base64Image);
                      // Show a success message or navigate back
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: Color.fromARGB(255, 57, 106, 59),
                        ),
                      );
                      // Pass the updated profileImagePath back to AdminPage
                      widget.updateProfileImageCallback(profileImagePath);
                      Navigator.pop(context); // Close the settings page
                    } else {
                      // Handle the case where profileImagePath is null or file doesn't exist
                      print('Invalid profile image path');
                    }
                  } catch (error) {
                    // Handle errors, show an error message, etc.
                    print('Error updating profile: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update profile. $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
