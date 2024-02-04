import 'dart:io';

import 'package:flutter/material.dart';
import 'drawer/Usersettings_page.dart';
//import 'generate_qr_page.dart';\

import 'drawer/saved_code_page.dart';
import 'generate_qr_page.dart';
import 'scan_qr_page.dart';

class MainQRPage extends StatefulWidget {
  @override
  State<MainQRPage> createState() => _MainQRPageState();
}

class _MainQRPageState extends State<MainQRPage> {
  String? profileImagePath;

  void updateProfileImage(String? imagePath) {
    setState(() {
      profileImagePath = imagePath;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qr Code Studio'),
        actions: [
          // Display the profile image in the app bar
          GestureDetector(
            onTap: () async {
              var updatedImagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    updateProfileImageCallback: updateProfileImage,
                  ),
                ),
              );

              if (updatedImagePath != null) {
                updateProfileImage(updatedImagePath);
              }
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: profileImagePath != null
                  ? FileImage(File(profileImagePath!)) as ImageProvider<Object>?
                  : AssetImage('images/profileImage.png'),
            ),
          ),

          SizedBox(width: 15),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateQRCode(),
                  ),
                );
              },
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRViewWidget(),
                  ),
                );
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                     title: Text('Saved Codes'),
                     onTap: () {
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => SavedCodesPage(),
                         ),
                       );
                     },
                   ),
                  ListTile(
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            updateProfileImageCallback: updateProfileImage,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Divider(),
            Container(
              padding: EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/Login');
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: Color.fromARGB(222, 207, 187, 253), width: 1.6),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
