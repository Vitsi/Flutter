import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminService.dart';
import 'Admin_Drawer/Adminsetting_page.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String searchQuery = '';
  List<User> allUsers = []; // Maintain a local list of all users
  List<User> filteredUsers = []; // List to display based on search
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
     loadProfileImage();
    fetchAllUsers();
  }

  void updateProfileImage(String? imagePath) {
    setState(() {
      profileImagePath = imagePath;
      saveProfileImage(imagePath);
    });
  }

   Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImagePath');
    setState(() {
      profileImagePath = imagePath;
    });
  }
  Future<void> saveProfileImage(String? imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImagePath', imagePath ?? '');
  }

  Future<void> _refreshUsers() async {
    await fetchAllUsers();
  }

  void _deleteUser(String userId) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this user from the database?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await Provider.of<AdminService>(context, listen: false)
            .deleteUser(userId);
        // Refresh the user list after deletion
        await fetchAllUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Color.fromARGB(255, 16, 86, 6),
          ),
        );
      } catch (error) {
        print('Error deleting user: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user. $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _upgradeUserToAdmin(String userId, String username) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm User Upgrade'),
          content: Text(
            'Are you sure you want to upgrade $username to an admin?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await Provider.of<AdminService>(context, listen: false)
            .upgradeUserToAdmin(userId);
        await fetchAllUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User upgraded to admin successfully'),
            backgroundColor: Color.fromARGB(255, 0, 128, 0),
          ),
        );
      } catch (error) {
        print('Error upgrading user to admin: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upgrade user to admin. $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> fetchAllUsers() async {
    List<User> users =
        await Provider.of<AdminService>(context, listen: false).getAllUsers();
    setState(() {
      allUsers = users;
      filterUsers(); // initial filter searc based on empty searching
    });
  }

  void filterUsers() {
    filteredUsers = searchQuery.isEmpty
        ? List.from(allUsers)
        : allUsers
            .where((user) =>
                user.username
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                user.emailAddress
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                user.role.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          // update profile image in the app bar when the one in settings gets updated
          GestureDetector(
            onTap: () async {
              var updatedImagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminSettingPage(
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
      drawer: Drawer(
        child: Container(
          // color:  Color.fromARGB(222, 37, 10, 105),
          color: Color.fromARGB(183, 19, 2, 58),
          child: Column(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white, 
                  image: DecorationImage(
                    image: AssetImage(
                        'images/appicon.png'),
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
                      leading: Icon(Icons.settings, color: Colors.white),
                      title: Text(
                        'Settings',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminSettingPage(
                              updateProfileImageCallback: updateProfileImage,
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
                padding: EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/Login');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.blueGrey, width: 1.6),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  filterUsers(); 
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              child: Builder(
                builder: (BuildContext context) {
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      // Check if the users nname starts with "admin_" or the role is "Admin"
                      final bool isAdminUser =
                          user.username.startsWith("admin_") ||
                              user.role.toLowerCase() == "admin";

                      return ListTile(
                        title: Text(user.username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user.emailAddress}'),
                            Text('Role: ${user.role}'),
                            Text(
                              'Created Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(user.createdDate)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: isAdminUser
                                    ? Colors.grey
                                    : const Color.fromARGB(255, 117, 34, 28),
                              ),
                              onPressed: isAdminUser
                                  ? null
                                  : () {
                                      _deleteUser(user.id);
                                    },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.move_up_sharp,
                                color: isAdminUser ? Colors.grey : Colors.green,
                              ),
                              onPressed: isAdminUser
                                  ? null
                                  : () {
                                      _upgradeUserToAdmin(
                                          user.id, user.username);
                                    },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
