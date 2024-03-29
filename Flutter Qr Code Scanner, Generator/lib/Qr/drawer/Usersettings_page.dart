import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'ProfileService.dart';

class SettingsPage extends StatefulWidget {
  final Function(String?) updateProfileImageCallback;

  SettingsPage(
      {Key? key,
      required this.updateProfileImageCallback,
      required Future<void> Function(String newUsername)
          updateUsernameCallback})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      widget.updateProfileImageCallback(profileImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Settings'), actions: [
        IconButton(
            icon: SvgPicture.asset(
              'svg/white.svg',
              height: 24.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/MainQR');
              (
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            })
      ]),
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
                  if (usernameController.text == null) {
                    setState(() {
                      usernameError = 'Please provide username';
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
                  try {
                    if (profileImagePath != null &&
                        File(profileImagePath!).existsSync()) {
                      Uint8List photoBytes =
                          await File(profileImagePath!).readAsBytes();
                      String base64Image = base64Encode(photoBytes);

                      await Provider.of<ProfileService>(context, listen: false)
                          .updateUserProfile(
                              usernameController.text,
                              emailController.text,
                              newPasswordController.text,
                              profileImagePath,
                              base64Image);
                      //sucess snack
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: Color.fromARGB(255, 57, 106, 59),
                        ),
                      );
                      // Pass the updated image path back to User[age
                      widget.updateProfileImageCallback(profileImagePath);
                      Navigator.pop(context); // Close the settings page
                    } else {
                      print('Invalid profile image path');
                    }
                  } catch (error) {
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
