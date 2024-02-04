import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Fetch all users when the widget is initialized
    fetchAllUsers();
  }

  // Callback function to update the profile image
  void updateProfileImage(String? imagePath) {
    setState(() {
      profileImagePath = imagePath;
    });
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
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled deletion
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

  Future<void> fetchAllUsers() async {
    List<User> users =
        await Provider.of<AdminService>(context, listen: false).getAllUsers();
    setState(() {
      allUsers = users;
      filterUsers(); // Initial filter based on empty query
    });
  }

  void filterUsers() {
    // Filter users based on searchQuery
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
          // Display the profile image in the app bar
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
                    title: Text('Settings'),
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
            Divider(),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  filterUsers(); // Update the filtered list on each change
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
                      return ListTile(
                        title: Text(filteredUsers[index].username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${filteredUsers[index].emailAddress}'),
                            Text('Role: ${filteredUsers[index].role}'),
                            Text(
                                'Created Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(filteredUsers[index].createdDate)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: const Color.fromARGB(255, 117, 34, 28),
                          ),
                          onPressed: () {
                            _deleteUser(filteredUsers[index].id);
                          },
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
