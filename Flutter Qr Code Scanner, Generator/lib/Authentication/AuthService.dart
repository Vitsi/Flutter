import 'dart:convert';

//?import 'package:first/Authentication/Admin/Admin_page.dart';
import 'package:QR_Code_Studio/Qr/drawer/ProfileService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Admin/AdminService.dart';

class AuthService {
  final String baseUrl;
  //String? _authToken;

  AuthService(this.baseUrl);

  Future<String?> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('Login Response Status Code: ${response.statusCode}');
    print('Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final userToken = data['token'];
      final userId = data['id'];
      
      // Set user token and ID in ProfileService

      // Handle the case where userId is null
      if (userId == null) {
        print('User ID is null after login.');
        return null;
      }

      Provider.of<ProfileService>(context, listen: false).userAccessToken =
          userToken;
      Provider.of<ProfileService>(context, listen: false).userId = userId;

      //return data['token'];
      return userToken;
    } else {
      return null;
    }
  }

  Future<String?> adminLogin(
      BuildContext context, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Login/AdminLogin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('Admin Login Response Status Code: ${response.statusCode}');
    print('Admin Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final adminToken = data['token'];
      final adminId = data['id'];
    
      // Set admin token and ID in AdminService
      Provider.of<AdminService>(context, listen: false).adminAccessToken =
          adminToken;
      Provider.of<AdminService>(context, listen: false).adminId = adminId;

      return adminToken;
    } else {
      return null;
    }
  }

  Future<bool> register(
      String username, String emailAddress, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'emailAddress': emailAddress,
        'password': password,
      }),
    );

    print('Registration Response Status Code: ${response.statusCode}');
    print('Registration Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  
}
