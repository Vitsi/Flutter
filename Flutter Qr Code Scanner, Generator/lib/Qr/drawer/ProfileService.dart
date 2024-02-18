import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
class ProfileService {
  final String baseUrl;
  String? userAccessToken;
   String? userId;

  ProfileService(this.baseUrl);


  Future<void> updateUserProfile(
  String newUsername,
  String newEmail,
  String newPassword,
  String? profileImagePath,
  String? base64Image,
)  async {
    if (userAccessToken == null || userId == null) {
      throw Exception('Admin access token not available');
    }

    http.MultipartRequest request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/Useraccount/User/${userId}'),
    );

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
    request.headers['Authorization'] = 'Bearer $userAccessToken';

    request.fields['Username'] = newUsername;
    request.fields['EmailAddress'] = newEmail;
    request.fields['Password'] = newPassword;

    try {
      final response = await request.send();

      print(
          'Update User Profile Response Status Code: ${response.statusCode}');

      // for debugging in the console
      final responseBody = await response.stream.bytesToString();
      print('Update User Profile Response Body: $responseBody');

      if (response.statusCode != 204) {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      print('Error updating admin profile: $error');
      throw Exception('Failed to update user profile');
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
      photo: json['photo'] != null ? base64Decode(json['photo']) : null,
    );
  }
}


// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;

// class ProfileService {
//   final String baseUrl;
//   String? userAccessToken;
//   String? userId;
//   String? photoString;
//   ProfileService(this.baseUrl);

//   Future<void> updateUserProfile(
//     String newUsername,
//     String newEmail,
//     String newPassword,
//     String? profileImagePath,
//     String? base64Image,
//   ) async {
//     if (userAccessToken == null || userId == null) {
//       throw Exception('Admin access token not available');
//     }

//     http.MultipartRequest request = http.MultipartRequest(
//       'PUT',
//       Uri.parse('$baseUrl/Useraccount/User/${userId}'),
//     );

//     // Add the image file if profileImagePath is not null
//     if (profileImagePath != null) {
//       var profileImage =
//           await http.MultipartFile.fromPath('profileImage', profileImagePath);
//       request.files.add(profileImage);
//     }
//     //edd base64 encoded image
//     if (base64Image != null) {
//       var photoFile = http.MultipartFile.fromString('Photo', base64Image);
//       request.files.add(photoFile);
//     }

//     request.headers['Content-Type'] = 'application/json';
//     request.headers['Authorization'] = 'Bearer $userAccessToken';

//     request.fields['Username'] = newUsername;
//     request.fields['EmailAddress'] = newEmail;
//     request.fields['Password'] = newPassword;

//     try {
//       final response = await request.send();

//       print('Update User Profile Response Status Code: ${response.statusCode}');

//       // Print response body for debugging
//       final responseBody = await response.stream.bytesToString();
//       print('Update User Profile Response Body: $responseBody');

//       if (response.statusCode != 204) {
//         throw Exception('Failed to update user profile');
//       }
//     } catch (error) {
//       print('Error updating admin profile: $error');
//       throw Exception('Failed to update user profile');
//     }
//   }
// }

// class User {
//   final String id;
//   final String username;
//   final String emailAddress;
//   final String role;
//   final DateTime createdDate;
//   final Uint8List? photo;

//   User({
//     required this.id,
//     required this.username,
//     required this.emailAddress,
//     required this.role,
//     required this.createdDate,
//     this.photo,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       emailAddress: json['emailAddress'],
//       role: json['role'],
//       createdDate: DateTime.parse(json['createdDate']),
//       photo: json['photo'] != null ? base64Decode(json['photo']) : null,
//     );
//   }
// }
