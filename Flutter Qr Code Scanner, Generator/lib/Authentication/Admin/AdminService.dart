import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class AdminService {
  final String baseUrl;
  String? adminAccessToken;
  String? adminId;

  AdminService(this.baseUrl);

  Future<List<User>> searchUsers(String username) async {
    if (adminAccessToken == null) {
      throw Exception('Admin access token not available');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/Useraccount/ByUsername/$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $adminAccessToken',
      },
    );

    print('Search Users Response Status Code: ${response.statusCode}');
    print('Search Users Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      // Check if the data is a list or a single user (map)
      if (data is List) {
        final searchedUsers = data.map((json) => User.fromJson(json)).toList();
        return searchedUsers;
      } else if (data is Map<String, dynamic>) {
        // If it's a single user, convert it to a list with one element
        final searchedUser = User.fromJson(data);
        return [searchedUser];
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<void> deleteUser(String userId) async {
    if (adminAccessToken == null) {
      throw Exception('Admin access token not available');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/Useraccount/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $adminAccessToken',
      },
    );
    print('Delete User Response Status Code: ${response.statusCode}');
    print('Delete User Response Body: ${response.body}');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<List<User>> getAllUsers() async {
    if (adminAccessToken == null) {
      throw Exception('Admin access token not available');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/Useraccount'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $adminAccessToken',
      },
    );

    print('Get All Users Response Status Code: ${response.statusCode}');
    print('Get All Users Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      //*filtering admins out so later on admin doesnt delete admin in the dashboard
      final filteredUsers =
          data.where((json) => json['role'] != 'Admin').toList();
      return filteredUsers.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get users');
    }
  }

  Future<void> updateAdminProfile(
      String newUsername,
      String newEmail,
      String newPassword,
      String? profileImagePath,
       String? base64Image) async {
    if (adminAccessToken == null || adminId == null) {
      throw Exception('Admin access token not available');
    }

    http.MultipartRequest request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/Useraccount/${adminId}'),
    );

    // Add the image file if profileImagePath is not null
    if (profileImagePath != null) {
      var profileImage =
          await http.MultipartFile.fromPath('profileImage', profileImagePath);
      request.files.add(profileImage);
    }
    //edd base64 encoded image
  if (base64Image != null) {
    var photoFile = http.MultipartFile.fromString('Photo', base64Image);
    request.files.add(photoFile);
  }


    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $adminAccessToken';

    request.fields['Username'] = newUsername;
    request.fields['EmailAddress'] = newEmail;
    request.fields['Password'] = newPassword;

    try {
      final response = await request.send();

      print(
          'Update Admin Profile Response Status Code: ${response.statusCode}');

      // Print response body for debugging
      final responseBody = await response.stream.bytesToString();
      print('Update Admin Profile Response Body: $responseBody');

      if (response.statusCode != 204) {
        throw Exception('Failed to update admin profile');
      }
    } catch (error) {
      print('Error updating admin profile: $error');
      throw Exception('Failed to update admin profile');
    }
  }
}

class User {
  final String id;
  final String username;
  final String emailAddress;
  final String role;
  final DateTime createdDate;
  final Uint8List? photo;

  User({
    required this.id,
    required this.username,
    required this.emailAddress,
    required this.role,
    required this.createdDate,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      emailAddress: json['emailAddress'],
      role: json['role'],
      createdDate: DateTime.parse(json['createdDate']),
      photo: json['photo'] != null
          ? base64Decode(json['photo'])
          : null, // Decode the base64 photo string
    );
  }
}
