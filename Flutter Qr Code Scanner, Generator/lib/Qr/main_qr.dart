import 'dart:io';
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer/Usersettings_page.dart';
import 'drawer/saved_code_page.dart';
import 'generate_qr_page.dart';
import 'scan_qr_page.dart';

class MainQRPage extends StatefulWidget {
  @override
  State<MainQRPage> createState() => _MainQRPageState();
}

class _MainQRPageState extends State<MainQRPage> {
  String? profileImagePath;
  late SharedPreferences sharedPref;
  String? username;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    sharedPref = await SharedPreferences.getInstance();
    setState(() {
      profileImagePath = sharedPref.getString("UserProfileImagePath");
      username = sharedPref.getString("Username");
    });
  }

  Future<void> updateProfileImage(String? imagePath) async {
    await sharedPref.setString("UserProfileImagePath", imagePath ?? '');

    setState(() {
      profileImagePath = imagePath;
    });
  }

  Future<void> updateUsername(String newUsername) async {
    await sharedPref.setString("Username", newUsername);

    setState(() {
      username = newUsername;
    });
  }

  Future<void> logout() async {
    await sharedPref.clear();

    setState(() {
      profileImagePath = null;
    });

    Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qr Code Studio'),
        actions: [
          GestureDetector(
            onTap: () async {
              var updatedImagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    updateProfileImageCallback: updateProfileImage,
                    updateUsernameCallback: updateUsername,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color.fromARGB(222, 255, 255, 255),
            ),
          ),
//moving particles for front page
          Center(
            child: ParticlesFly(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              connectDots: true,
              numberOfParticles: 100,
            ),
          ),
          Center(
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
                  // child: Text('Generate QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(222, 37, 10, 105), // Background color
                  ),
                  child: Text(
                    'Generate QR Code',
                    style: TextStyle(
                      color: Color.fromARGB(222, 229, 226, 236), // Text color
                    ),
                  ),
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
                  // child: Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(222, 37, 10, 105), // Background color
                  ),
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Color.fromARGB(222, 229, 226, 236), // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          //color: Color.fromARGB(222, 37, 10, 105),
          color: Color.fromARGB(183, 19, 2, 58),
          child: Column(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white, // Drawer header color
                  image: DecorationImage(
                    image:
                        AssetImage('images/appicon.png'), // Add your own image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.white),
                      title: Text(
                        'Home',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.qr_code, color: Colors.white),
                      title: Text(
                        'Saved Codes',
                        style: TextStyle(color: Colors.white),
                      ),
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
                      leading: Icon(Icons.settings, color: Colors.white),
                      title: Text(
                        'Settings',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              updateProfileImageCallback: updateProfileImage,
                              updateUsernameCallback: updateUsername,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white, // Divider color
                thickness: 1.0,
                indent: 16.0,
                endIndent: 16.0,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      profileImagePath = null;
                    });

                    Navigator.pushReplacementNamed(context, '/Login');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Color.fromARGB(255, 108, 63, 181), width: 1.6),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Color.fromARGB(222, 37, 10, 105),
                        fontWeight: FontWeight.bold,
                      ),
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
